#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/log_utils.sh"

BREWFILE="$1"
BREWFILE_HASH="$HOME/.local/Brewfile.hash"

setup_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        if [ -d "/opt/homebrew/bin" ]; then
            log "🔧" "Configuring Homebrew in PATH..."
            eval "$(/opt/homebrew/bin/brew shellenv)"
            log "✅" "Homebrew successfully configured in PATH." "done"
        else
            log "❌" "Homebrew not installed. Please install Homebrew first." "done"
            return 1
        fi
    fi
    return 0
}

run_brew_bundle() {
    log "🔧" "Running 'brew bundle' for $BREWFILE..."
    if brew bundle --file="$BREWFILE"; then
        shasum -a 256 "$BREWFILE" | awk '{print $1}' > "$BREWFILE_HASH"
        log "✅" "Brewfile processed successfully and hash updated." "done"
    else
        log "❌" "'brew bundle' failed. Please check your Brewfile." "done"
        exit 1
    fi
}

if [ -z "$BREWFILE" ]; then
    log "❌" "No Brewfile specified. Usage: $0 /path/to/Brewfile" "done"
    exit 1
fi

if [ ! -f "$BREWFILE" ]; then
    log "❌" "Brewfile not found at $BREWFILE." "done"
    exit 1
fi

setup_brew || exit 1

CURRENT_HASH=$(shasum -a 256 "$BREWFILE" | awk '{print $1}')
SAVED_HASH=$(cat "$BREWFILE_HASH" 2>/dev/null || echo "")

if [ "$CURRENT_HASH" != "$SAVED_HASH" ]; then
    run_brew_bundle
else
    log "✅" "No changes detected in Brewfile. Skipping 'brew bundle'." "done"
fi
