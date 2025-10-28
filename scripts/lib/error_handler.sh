#!/bin/sh

# Global variables for error handling
ERROR_OCCURRED=0
CLEANUP_FUNCTIONS=""

# Register a cleanup function to be called on exit
register_cleanup() {
    local func="$1"
    if [ -z "$CLEANUP_FUNCTIONS" ]; then
        CLEANUP_FUNCTIONS="$func"
    else
        CLEANUP_FUNCTIONS="$CLEANUP_FUNCTIONS $func"
    fi
}

# Execute all registered cleanup functions
run_cleanup() {
    if [ -n "$CLEANUP_FUNCTIONS" ]; then
        log_debug "Running cleanup functions..."
        for func in $CLEANUP_FUNCTIONS; do
            if command -v "$func" >/dev/null 2>&1; then
                $func || log_warn "Cleanup function '$func' failed"
            fi
        done
    fi
}

# Error handler called on script failure
error_handler() {
    local exit_code=$?
    local line_number="$1"

    ERROR_OCCURRED=1

    if [ "$exit_code" -ne 0 ]; then
        log_error "Script failed at line $line_number with exit code $exit_code"
    fi

    run_cleanup
    exit "$exit_code"
}

# Exit handler called on script exit
exit_handler() {
    local exit_code=$?

    # Only run cleanup if error handler hasn't run yet
    if [ "$ERROR_OCCURRED" -eq 0 ]; then
        run_cleanup
    fi

    exit "$exit_code"
}

# Setup error handling traps
setup_error_handling() {
    set -e  # Exit on error
    set -u  # Exit on undefined variable

    # Enable pipefail if supported (bash/zsh feature, not POSIX sh)
    # Fails gracefully in shells that don't support it
    ( set -o pipefail 2>/dev/null ) && set -o pipefail || true

    # Set up traps
    # Note: $LINENO must be unquoted to expand at trap execution time
    # shellcheck disable=SC3047
    trap 'error_handler $LINENO' ERR
    trap 'exit_handler' EXIT
    trap 'exit_handler' INT TERM
}

# Safe command execution with error message
safe_exec() {
    local error_msg="$1"
    shift

    if ! "$@"; then
        log_error "$error_msg"
        return 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a directory exists and is writable
check_writable_dir() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        log_error "Directory does not exist: $dir"
        return 1
    fi

    if [ ! -w "$dir" ]; then
        log_error "Directory is not writable: $dir"
        return 1
    fi

    return 0
}

# Require a command to exist
require_command() {
    local cmd="$1"
    local install_msg="${2:-Please install $cmd and try again.}"

    if ! command_exists "$cmd"; then
        log_error "Required command not found: $cmd"
        log_info "$install_msg"
        return 1
    fi
}

# Check if running on macOS
check_macos() {
    if [ "$(uname)" != "Darwin" ]; then
        log_error "This script must be run on macOS"
        return 1
    fi
}

# Check macOS version
check_macos_version() {
    local min_version="${1:-26.0}"
    local current_version

    current_version=$(sw_vers -productVersion)

    log_debug "Current macOS version: $current_version (minimum required: $min_version)"

    # Use sort -V for version comparison (works with any version format)
    if ! printf '%s\n%s\n' "$min_version" "$current_version" | sort -V -C 2>/dev/null; then
        log_error "macOS $min_version or later is required (current: $current_version)"
        return 1
    fi
}

# Check if running with sudo (warn if yes)
check_not_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        log_warn "This script should not be run with sudo"
        log_warn "It will prompt for sudo when needed"
        return 1
    fi
    return 0
}
