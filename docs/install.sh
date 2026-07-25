#!/bin/bash
set -euo pipefail

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

# Where install_packages reads from; set by install_brewfile
BREWFILE_SOURCE=""

# --dry-run performs every read-only step for real — platform detection, the
# Brewfile download, counting — and skips only the parts that change the
# machine. It also answers every prompt with "no", so CI can run the script
# end to end without installing 86 packages or blocking on input.
DRY_RUN=0

# Set by init_ui()
BULLET=""
CHECK=""

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

    # A carriage return does not collapse a line in a CI log, so the animation
    # would emit one frame per redraw. Print once and wait instead.
    if [[ ! -t 1 ]]; then
        printf '  %s\n' "$msg"
        wait "$pid" || rc=$?
        ((rc != 0)) && printf '  FAILED: %s\n' "$msg"
        return "$rc"
    fi

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

# Report a step a dry run is skipping or simulating
dry() {
    printf '  \033[2m[dry-run]\033[0m %s\n' "$1"
}

# gum confirm, except a dry run never blocks and answers with the given
# default. The main gate defaults to yes so a dry run exercises the whole
# script; the optional post-install steps default to no.
# Usage: confirm <prompt> [yes|no]
confirm() {
    local prompt=$1 dry_answer=${2:-no}

    if ((DRY_RUN)); then
        dry "prompt \"${prompt# }\" -> $dry_answer"
        [[ "$dry_answer" == "yes" ]]
        return
    fi

    gum confirm "$prompt"
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

# Cleanup temporary files.
#
# The explicit `return 0` matters: this runs as an EXIT trap, and when the
# trap's last command fails bash replaces the script's exit status with it.
# Without it, the `[[ -n "" ]]` test failing on the common path turned every
# `exit 0` into an exit 1 — so declining the installation reported failure.
cleanup() {
    [[ -n "$GUM_TMP_DIR" && -d "$GUM_TMP_DIR" ]] && rm -rf "$GUM_TMP_DIR"
    return 0
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

    if ((DRY_RUN)); then
        dry "would install Homebrew into $BREW_PREFIX"
        return 0
    fi

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >>"$LOG_FILE" 2>&1 &
    spin $! "Installing Homebrew..." || die "Homebrew installation failed."

    [[ -x "$BREW_PREFIX/bin/brew" ]] || die "Homebrew was installed but not found at $BREW_PREFIX/bin/brew."
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
}

setup_gum() {
    command -v gum &>/dev/null && return 0

    # Installing gum through brew changes the machine, so a dry run falls
    # through to the temporary tarball instead, which is removed on exit.
    if ((DRY_RUN == 0)) && { command -v brew &>/dev/null || [[ -x "$BREW_PREFIX/bin/brew" ]]; }; then
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
    # The download itself runs in a dry run: fetching is read-only, and it is
    # the step most likely to be broken. Only the move into place is skipped.
    local tmp="${BREWFILE_PATH}.download"
    ((DRY_RUN)) && tmp="${TMPDIR:-/tmp}/brewfile-dry-run.Brewfile"

    curl -fsSL "$REPO_URL" -o "$tmp" >>"$LOG_FILE" 2>&1 &
    spin $! "Downloading Brewfile..." 1 || die "Failed to download Brewfile from $REPO_URL"

    [[ -s "$tmp" ]] || die "Downloaded Brewfile is empty."

    if ((DRY_RUN)); then
        BREWFILE_SOURCE="$tmp"
        dry "would write $tmp to $BREWFILE_PATH"
        return 0
    fi

    # Never clobber an existing global Brewfile
    if [[ -f "$BREWFILE_PATH" ]]; then
        local backup
        backup="${BREWFILE_PATH}.backup-$(date +%Y%m%d%H%M%S)"
        cp "$BREWFILE_PATH" "$backup" || die "Failed to back up $BREWFILE_PATH"
        ui_info "Existing Brewfile saved as $(basename "$backup")"
    fi

    mv "$tmp" "$BREWFILE_PATH"
    BREWFILE_SOURCE="$BREWFILE_PATH"
}

install_packages() {
    local brews casks
    # `grep -c` already prints 0 when nothing matches; `|| true` only guards
    # its non-zero exit status. Using `|| echo 0` here would print 0 twice.
    brews=$(grep -c '^brew "' "$BREWFILE_SOURCE" || true)
    casks=$(grep -c '^cask "' "$BREWFILE_SOURCE" || true)

    gum style ""
    ui_info "Installing $brews formulas, $casks casks..."
    gum style ""

    if ((DRY_RUN)); then
        # Parsing the downloaded file is read-only and catches the case that
        # matters most here: a Brewfile published on main that does not load.
        if command -v brew &>/dev/null; then
            brew bundle list --all --file="$BREWFILE_SOURCE" >/dev/null ||
                die "The published Brewfile does not parse."
            dry "published Brewfile parses"
        else
            dry "brew not available, skipped parsing the published Brewfile"
        fi
        dry "would run: brew bundle --global"
        return 0
    fi

    brew bundle --global || die "Some packages failed to install."
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

usage() {
    cat <<'EOF'
Brewfile installer

Usage: install.sh [--dry-run] [--help]

  --dry-run   Run every read-only step for real — platform detection, the
              Brewfile download, parsing — and report the rest instead of
              changing the machine. Never prompts. Used by CI.
  --help      Show this message.
EOF
}

parse_args() {
    while (($# > 0)); do
        case "$1" in
            --dry-run) DRY_RUN=1 ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                usage >&2
                die "Unknown option: $1"
                ;;
        esac
        shift
    done
}

main() {
    # Truncate the log first: die() prints its tail, and a stale tail from a
    # previous run is worse than no context at all.
    : >"$LOG_FILE"

    # Register cleanup before anything creates temporary files
    trap cleanup EXIT

    parse_args "$@"

    # Clear screen and scrollback, unless a dry run is filling a CI log
    ((DRY_RUN)) || printf '\033[2J\033[3J\033[H'

    detect_platform

    # Bootstrap gum for UI
    setup_gum
    init_ui

    # Show banner and prompt
    ui_banner

    if ! confirm "  Continue with installation?" yes; then
        gum style "
  $(gum style --faint 'Maybe next time!') 👋
"
        ui_footer
        exit 0
    fi

    # Setup Homebrew (asks for sudo if needed)
    if ! command -v brew &>/dev/null && [[ ! -x "$BREW_PREFIX/bin/brew" ]]; then
        gum style ""
        if ((DRY_RUN)); then
            dry "would request administrator privileges"
        else
            ui_info "Administrator privileges required"
            sudo -v || die "Administrator privileges are required to install Homebrew."
        fi
    fi

    setup_homebrew
    ui_success "Homebrew ready"

    install_brewfile
    install_packages

    # Success message
    ((DRY_RUN)) && {
        gum style ""
        dry "no changes were made"
        ui_footer
        exit 0
    }

    gum style "
  $CHECK All packages installed!

  🍺 $(gum style --foreground "$COLOR_SUCCESS" --bold 'Cheers! Your dev environment is ready.')
"

    if confirm "  Run 'brew cleanup' to remove old downloads?"; then
        gum style ""
        brew cleanup --prune=all -q >>"$LOG_FILE" 2>&1 &
        # Non-fatal: cleanup is housekeeping, not part of the install
        spin $! "Cleaning up..." || ui_info "Cleanup reported errors, see $LOG_FILE"
    fi

    if confirm "  Configure your shell with dotfiles?"; then
        gum style ""
        chezmoi init --apply "$GITHUB_USER" >>"$LOG_FILE" 2>&1 &
        spin $! "Applying dotfiles..." 1 || die "chezmoi failed to apply dotfiles."
    fi

    ui_footer
}

# Sourcing this file with BREWFILE_INSTALLER_LIB set loads the functions
# without running the installer, which is how the test suite exercises them.
# A BASH_SOURCE guard would not work here: under `bash <(curl ...)` the script
# is /dev/fd/63 while $0 is bash, so the installer would silently do nothing.
[[ -n "${BREWFILE_INSTALLER_LIB:-}" ]] || main "$@"
