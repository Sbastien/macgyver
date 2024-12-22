#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/log_utils.sh"

install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log "🔧" "Installing Homebrew..." "done"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            log "❌" "Failed to install Homebrew. Please check your internet connection." "done"
            exit 1
        }
        log "✅" "Homebrew installed successfully." "done"
    else
        log "✅" "Homebrew is already installed." "done"
    fi
}

main() {
    install_homebrew
}

main
