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
readonly GUM_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_Darwin_arm64.tar.gz"

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

# Spinner with optional minimum duration
# Usage: spin <pid> <message> [min_seconds]
spin() {
    local pid=$1 msg=$2 min_duration=${3:-0}
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local end_time=$((SECONDS + min_duration))

    while [[ $SECONDS -lt $end_time ]] || kill -0 "$pid" 2>/dev/null; do
        for f in "${frames[@]}"; do
            printf "\r  ${ANSI_BREW}%s${ANSI_RESET} %s" "$f" "$msg"
            sleep 0.05
        done
    done

    wait "$pid" 2>/dev/null
    printf "\r  🍺 %s\n" "$msg"
}

# Print error and exit
die() {
    printf "\r  ${ANSI_ERROR}✗${ANSI_RESET} %s\n" "$1" >&2
    exit 1
}

# Cleanup temporary files
cleanup() {
    [[ -n "$GUM_TMP_DIR" && -d "$GUM_TMP_DIR" ]] && rm -rf "$GUM_TMP_DIR"
}

# -----------------------------------------------------------------------------
# Bootstrap Functions
# -----------------------------------------------------------------------------

setup_homebrew() {
    command -v brew &>/dev/null && return 0

    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        return 0
    fi

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null &
    spin $! "Installing Homebrew..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

setup_gum() {
    command -v gum &>/dev/null && return 0

    # Use brew if already available
    if command -v brew &>/dev/null || [[ -f /opt/homebrew/bin/brew ]]; then
        [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
        brew install gum -q &
        spin $! "Installing gum via Homebrew..."
        return 0
    fi

    # Otherwise download temporarily
    GUM_TMP_DIR=$(mktemp -d)
    local archive="$GUM_TMP_DIR/gum.tar.gz"

    curl -fsSL "$GUM_URL" -o "$archive" &
    spin $! "Downloading gum..." 1

    tar -xzf "$archive" -C "$GUM_TMP_DIR" --strip-components=1
    export PATH="$GUM_TMP_DIR:$PATH"
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
    curl -fsSL "$REPO_URL" -o "$BREWFILE_PATH" &
    spin $! "Downloading Brewfile..." 1
}

install_packages() {
    local brews casks
    brews=$(grep -c '^brew "' "$BREWFILE_PATH" 2>/dev/null || echo "0")
    casks=$(grep -c '^cask "' "$BREWFILE_PATH" 2>/dev/null || echo "0")

    gum style ""
    ui_info "Installing $brews formulas, $casks casks..."
    gum style ""

    brew bundle --global
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    # Clear screen and scrollback
    printf '\033[2J\033[3J\033[H'

    # Bootstrap gum for UI
    setup_gum
    init_ui
    trap cleanup EXIT

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
    if ! command -v brew &>/dev/null && [[ ! -f /opt/homebrew/bin/brew ]]; then
        gum style ""
        ui_info "Administrator privileges required"
        sudo -v
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
        brew cleanup --prune=all -q &
        spin $! "Cleaning up..."
    fi

    if gum confirm "  Configure your shell with dotfiles?"; then
        gum style ""
        chezmoi init --apply "$GITHUB_USER" &>/dev/null &
        spin $! "Applying dotfiles..." 1
    fi

    ui_footer
}

main "$@"
