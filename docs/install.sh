#!/bin/bash
set -e

# =============================================================================
# Brewfile Installer
# https://github.com/Sbastien/Brewfile
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration (customize these for your fork)
# -----------------------------------------------------------------------------

readonly GITHUB_USER="Sbastien"

readonly REPO_URL="https://raw.githubusercontent.com/${GITHUB_USER}/Brewfile/main/Brewfile"
readonly BREWFILE_PATH="$HOME/.Brewfile"

readonly GUM_VERSION="0.17.0"

# Log file for background commands, so failures can be diagnosed
readonly LOG_FILE="${TMPDIR:-/tmp}/brewfile-install.log"

# Resolved by detect_platform()
BREW_PREFIX=""
GUM_URL=""

readonly COLOR_BREW="#FBB040"
readonly COLOR_SUCCESS="#81C784"
readonly COLOR_INFO="#81D4FA"
readonly COLOR_HEART="#FF6B9D"

readonly ANSI_BREW="\033[38;2;251;176;64m"
readonly ANSI_ERROR="\033[38;2;244;67;54m"
readonly ANSI_RESET="\033[0m"

GUM_TMP_DIR=""

# Gum styling
export GUM_CONFIRM_PROMPT_FOREGROUND="$COLOR_BREW"
export GUM_CONFIRM_SELECTED_BACKGROUND="$COLOR_BREW"
export GUM_CONFIRM_SELECTED_FOREGROUND="#000"
export GUM_SPIN_SPINNER_FOREGROUND="$COLOR_BREW"

# -----------------------------------------------------------------------------
# Core Utilities
# -----------------------------------------------------------------------------

# Spinner with optional minimum duration.
# Returns the watched job's exit code so callers can react to failures.
# Usage: spin <pid> <message> [min_seconds]
spin() {
    local pid=$1 msg=$2 min_duration=${3:-0}
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local end_time=$((SECONDS + min_duration))
    local rc=0

    while [[ $SECONDS -lt $end_time ]] || kill -0 "$pid" 2>/dev/null; do
        for f in "${frames[@]}"; do
            printf "\r  ${ANSI_BREW}%s${ANSI_RESET} %s" "$f" "$msg"
            sleep 0.05
        done
    done

    wait "$pid" || rc=$?

    if ((rc != 0)); then
        printf "\r  ${ANSI_ERROR}✗${ANSI_RESET} %s\n" "$msg"
    else
        printf "\r  🍺 %s\n" "$msg"
    fi

    return "$rc"
}

# Print error and exit, showing the tail of the log when there is one
die() {
    printf "\r  ${ANSI_ERROR}✗${ANSI_RESET} %s\n" "$1" >&2

    if [[ -s "$LOG_FILE" ]]; then
        printf "\n  Last lines of %s:\n\n" "$LOG_FILE" >&2
        tail -n 10 "$LOG_FILE" | sed 's/^/    /' >&2
        printf "\n" >&2
    fi

    exit 1
}

# Cleanup temporary files
cleanup() {
    [[ -n "$GUM_TMP_DIR" && -d "$GUM_TMP_DIR" ]] && rm -rf "$GUM_TMP_DIR"
}

# Resolve architecture-dependent paths and URLs
detect_platform() {
    [[ "$(uname -s)" == "Darwin" ]] || die "This installer only supports macOS."

    local arch
    arch=$(uname -m)

    case "$arch" in
        arm64) BREW_PREFIX="/opt/homebrew" ;;
        x86_64) BREW_PREFIX="/usr/local" ;;
        *) die "Unsupported architecture: $arch" ;;
    esac

    GUM_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_Darwin_${arch}.tar.gz"
}

# -----------------------------------------------------------------------------
# Bootstrap Functions
# -----------------------------------------------------------------------------

setup_homebrew() {
    command -v brew &>/dev/null && return 0

    if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
        eval "$("$BREW_PREFIX/bin/brew" shellenv)"
        return 0
    fi

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >>"$LOG_FILE" 2>&1 &
    spin $! "Installing Homebrew..." || die "Homebrew installation failed."

    [[ -x "$BREW_PREFIX/bin/brew" ]] || die "Homebrew was installed but not found at $BREW_PREFIX/bin/brew."
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
}

setup_gum() {
    command -v gum &>/dev/null && return 0

    # Use brew if already available
    if command -v brew &>/dev/null || [[ -x "$BREW_PREFIX/bin/brew" ]]; then
        [[ -x "$BREW_PREFIX/bin/brew" ]] && eval "$("$BREW_PREFIX/bin/brew" shellenv)"
        brew install gum -q >>"$LOG_FILE" 2>&1 &
        spin $! "Installing gum via Homebrew..." || die "Failed to install gum via Homebrew."
        return 0
    fi

    # Otherwise download temporarily
    GUM_TMP_DIR=$(mktemp -d)
    local archive="$GUM_TMP_DIR/gum.tar.gz"

    curl -fsSL "$GUM_URL" -o "$archive" >>"$LOG_FILE" 2>&1 &
    spin $! "Downloading gum..." 1 || die "Failed to download gum from $GUM_URL"

    tar -xzf "$archive" -C "$GUM_TMP_DIR" --strip-components=1 ||
        die "Failed to extract gum archive."

    export PATH="$GUM_TMP_DIR:$PATH"
    command -v gum &>/dev/null || die "gum is still not available after bootstrap."
}

# -----------------------------------------------------------------------------
# UI Components
# -----------------------------------------------------------------------------

# Initialize UI variables (requires gum)
init_ui() {
    BULLET=$(gum style --foreground "$COLOR_BREW" '•')
    CHECK="🍺"
}

# Display success message
ui_success() {
    gum style "  $CHECK $1"
}

# Display info message
ui_info() {
    gum style "  $(gum style --foreground "$COLOR_INFO" '▶') $(gum style --bold "$1")"
}

# Display footer with credits
ui_footer() {
    gum style "
  Made with $(gum style --foreground "$COLOR_HEART" '♥') and 🍺 by $(gum style --foreground "$COLOR_BREW" --bold "$GITHUB_USER")

  $(gum style --faint "github.com/${GITHUB_USER}/Brewfile")
"
}

# Display banner
ui_banner() {
    gum style "
$(gum style --foreground "$COLOR_BREW" '  ██████╗ ██████╗ ███████╗██╗    ██╗███████╗██╗██╗     ███████╗
  ██╔══██╗██╔══██╗██╔════╝██║    ██║██╔════╝██║██║     ██╔════╝
  ██████╔╝██████╔╝█████╗  ██║ █╗ ██║█████╗  ██║██║     █████╗
  ██╔══██╗██╔══██╗██╔══╝  ██║███╗██║██╔══╝  ██║██║     ██╔══╝
  ██████╔╝██║  ██║███████╗╚███╔███╔╝██║     ██║███████╗███████╗
  ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝     ╚═╝╚══════╝╚══════╝')

$(gum style --faint '  macOS dev environment in one command')

  $(gum style --bold 'This will:')

  $BULLET Check for Homebrew
  $BULLET Download Brewfile to ~/.Brewfile
  $BULLET Install all packages
  $BULLET Configure dotfiles with chezmoi (optional)
"
}

# -----------------------------------------------------------------------------
# Installation Steps
# -----------------------------------------------------------------------------

install_brewfile() {
    # Never clobber an existing global Brewfile
    if [[ -f "$BREWFILE_PATH" ]]; then
        local backup
        backup="${BREWFILE_PATH}.backup-$(date +%Y%m%d%H%M%S)"
        cp "$BREWFILE_PATH" "$backup" || die "Failed to back up $BREWFILE_PATH"
        ui_info "Existing Brewfile saved as $(basename "$backup")"
    fi

    # Download to a temporary file so a failure leaves the target untouched
    local tmp="${BREWFILE_PATH}.download"

    curl -fsSL "$REPO_URL" -o "$tmp" >>"$LOG_FILE" 2>&1 &
    spin $! "Downloading Brewfile..." 1 || die "Failed to download Brewfile from $REPO_URL"

    [[ -s "$tmp" ]] || die "Downloaded Brewfile is empty."
    mv "$tmp" "$BREWFILE_PATH"
}

install_packages() {
    local brews casks
    # `grep -c` already prints 0 when nothing matches; `|| true` only guards
    # its non-zero exit status. Using `|| echo 0` here would print 0 twice.
    brews=$(grep -c '^brew "' "$BREWFILE_PATH" || true)
    casks=$(grep -c '^cask "' "$BREWFILE_PATH" || true)

    gum style ""
    ui_info "Installing $brews formulas, $casks casks..."
    gum style ""

    brew bundle --global || die "Some packages failed to install."
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    # Clear screen and scrollback
    printf '\033[2J\033[3J\033[H'

    # Register cleanup before anything creates temporary files
    trap cleanup EXIT

    : >"$LOG_FILE"

    detect_platform

    # Bootstrap gum for UI
    setup_gum
    init_ui

    # Show banner and prompt
    ui_banner

    if ! gum confirm "  Continue with installation?"; then
        gum style "
  $(gum style --faint 'Maybe next time!') 👋
"
        ui_footer
        exit 0
    fi

    # Setup Homebrew (asks for sudo if needed)
    if ! command -v brew &>/dev/null && [[ ! -x "$BREW_PREFIX/bin/brew" ]]; then
        gum style ""
        ui_info "Administrator privileges required"
        sudo -v || die "Administrator privileges are required to install Homebrew."
    fi

    setup_homebrew
    ui_success "Homebrew ready"

    install_brewfile
    install_packages

    # Success message
    gum style "
  $CHECK All packages installed!

  🍺 $(gum style --foreground "$COLOR_SUCCESS" --bold 'Cheers! Your dev environment is ready.')
"

    if gum confirm "  Run 'brew cleanup' to remove old downloads?"; then
        gum style ""
        brew cleanup --prune=all -q >>"$LOG_FILE" 2>&1 &
        # Non-fatal: cleanup is housekeeping, not part of the install
        spin $! "Cleaning up..." || ui_info "Cleanup reported errors, see $LOG_FILE"
    fi

    if gum confirm "  Configure your shell with dotfiles?"; then
        gum style ""
        chezmoi init --apply "$GITHUB_USER" >>"$LOG_FILE" 2>&1 &
        spin $! "Applying dotfiles..." 1 || die "chezmoi failed to apply dotfiles."
    fi

    ui_footer
}

main "$@"
