#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/log_utils.sh"

check_xcode_cli_installed() {
    xcode-select --print-path &>/dev/null
}

install_xcode_cli() {
    echo "🔧 Installing Xcode Command Line Tools..."

    if ! xcode-select --install > /dev/null 2>&1; then
        if [ -d "/Library/Developer/CommandLineTools" ]; then
            echo "✅ Xcode Command Line Tools are already installed."
            return 0
        else
            echo "❌ Failed to start the installation. Please check manually."
            exit 1
        fi
    else
        echo "📂 Follow the prompts to complete the installation."
    fi

    echo "⏳ Waiting for Xcode Command Line Tools installation to complete..."
    MAX_WAIT=900
    START_TIME=$(date +%s)

    while true; do
        if [ -d "/Library/Developer/CommandLineTools" ]; then
            break
        fi

        if [ $(( $(date +%s) - START_TIME )) -gt $MAX_WAIT ]; then
            echo "❌ Installation timeout reached. Please check manually."
            exit 1
        fi

        sleep 5
    done

    if ! sudo xcode-select --switch /Library/Developer/CommandLineTools > /dev/null 2>&1; then
        echo "❌ Failed to configure the developer directory. Please check manually."
        exit 1
    fi

    echo "✅ Xcode Command Line Tools installed and configured."
}

cleanup_xcode_path() {
    if [ ! -d "$(xcode-select --print-path 2>/dev/null)" ]; then
        log "🧹" "Cleaning invalid Xcode path..."
        sudo rm -rf "$(xcode-select --print-path 2>/dev/null)" || true
        sudo xcode-select --reset
        log "✅" "Invalid Xcode path cleaned up." "done"
    fi
}

main() {
    cleanup_xcode_path

    if check_xcode_cli_installed; then
        log "✅" "Xcode Command Line Tools are already installed." "done"
    else
        install_xcode_cli
    fi
}

main
