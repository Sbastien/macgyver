#!/bin/sh

# Check if running on Apple Silicon (required)
is_apple_silicon() {
    if [ "$(uname -m)" != "arm64" ]; then
        log_error "This setup requires Apple Silicon"
        log_error "Detected architecture: $(uname -m)"
        return 1
    fi
    return 0
}

# Retry a command with exponential backoff
retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-2}"
    local attempt=1
    shift 2

    while [ "$attempt" -le "$max_attempts" ]; do
        log_debug "Attempt $attempt of $max_attempts: $*"

        if "$@"; then
            return 0
        fi

        if [ "$attempt" -lt "$max_attempts" ]; then
            log_warn "Command failed, retrying in ${delay}s..."
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
        fi

        attempt=$((attempt + 1))
    done

    log_error "Command failed after $max_attempts attempts: $*"
    return 1
}

# Check if a URL is reachable (used by check_internet)
check_url() {
    local url="$1"
    curl -fsSL --connect-timeout 10 --max-time 30 --head "$url" >/dev/null 2>&1
}

# Create directory if it doesn't exist
# Returns: 0 on success, 1 on failure
ensure_dir() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        log_debug "Creating directory: $dir"
        mkdir -p "$dir" || {
            log_error "Failed to create directory: $dir"
            return 1
        }
    fi
    return 0
}

# Safely remove a file or directory
safe_remove() {
    local path="$1"

    if [ -e "$path" ]; then
        log_debug "Removing: $path"
        rm -rf "$path" || {
            log_warn "Failed to remove: $path"
            return 1
        }
    fi
}

# Get a hash of a file
file_hash() {
    local file="$1"
    shasum -a 256 "$file" 2>/dev/null | awk '{print $1}'
}

# Compare two file hashes
compare_hash() {
    local file="$1"
    local hash_file="$2"

    local current_hash
    local saved_hash

    current_hash=$(file_hash "$file")
    saved_hash=$(cat "$hash_file" 2>/dev/null || echo "")

    [ "$current_hash" = "$saved_hash" ]
}

# Save hash of a file
save_hash() {
    local file="$1"
    local hash_file="$2"

    file_hash "$file" > "$hash_file"
}


# Ask user for confirmation (default: yes)
confirm() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-y}"
    local response

    if [ "$default" = "y" ]; then
        printf "%s [Y/n] " "$prompt"
    else
        printf "%s [y/N] " "$prompt"
    fi

    read -r response
    response=${response:-$default}

    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Homebrew constants
BREW_PREFIX="/opt/homebrew"
BREW_BIN="$BREW_PREFIX/bin/brew"

# Configure Homebrew environment
setup_brew_env() {
    if [ ! -x "$BREW_BIN" ]; then
        log_debug "Homebrew not found at $BREW_PREFIX"
        return 1
    fi

    log_debug "Configuring Homebrew environment"
    eval "$($BREW_BIN shellenv)"
}

# Check internet connectivity
check_internet() {
    log_debug "Checking internet connectivity..."

    if check_url "https://www.google.com" || \
       check_url "https://www.cloudflare.com"; then
        log_debug "Internet connection available"
        return 0
    else
        log_error "No internet connection detected"
        log_info "Please check your network connection and try again"
        return 1
    fi
}

# Get elapsed time in human readable format
# Args: $1 - duration in seconds (must be a non-negative integer)
# Returns: formatted string like "1h 23m 45s" or "45s"
format_duration() {
    local seconds="${1:-0}"

    # Validate input is a non-negative integer
    case "$seconds" in
        ''|*[!0-9]*) seconds=0 ;;
    esac

    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))
    local secs=$((seconds % 60))

    if [ "$hours" -gt 0 ]; then
        printf "%dh %dm %ds" "$hours" "$minutes" "$secs"
    elif [ "$minutes" -gt 0 ]; then
        printf "%dm %ds" "$minutes" "$secs"
    else
        printf "%ds" "$secs"
    fi
}

