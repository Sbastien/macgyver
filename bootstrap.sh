#!/bin/bash

set -e

ZIP_URL="https://github.com/Sbastien/macos-dev-setup/archive/main.zip"
TEMP_DIR="/tmp/macos-dev-setup"
EXTRACTED_DIR="$TEMP_DIR-main"

log() {
    local emoji="$1"
    local message="$2"
    local end="$3"
    if [ "$end" = "done" ]; then
        printf "\r\033[K%s %s\n" "$emoji" "$message"
    else
        printf "\r\033[K%s %s" "$emoji" "$message"
    fi
}

download_and_extract_files() {
    log "🔧" "Downloading setup files..."
    curl -fsSL "$ZIP_URL" -o "$TEMP_DIR.zip" || {
        log "❌" "Failed to download setup files." "done"
        exit 1
    }
    log "✅" "Setup files downloaded." "done"

    log "🔧" "Extracting setup files..."
    unzip -qo "$TEMP_DIR.zip" -d /tmp/ || {
        log "❌" "Failed to extract setup files." "done"
        exit 1
    }
    log "✅" "Setup files extracted." "done"
}

run_setup_script() {
    log "📂" "Navigating to the extracted directory..."
    if [ -d "$EXTRACTED_DIR" ]; then
        cd "$EXTRACTED_DIR"
        log "✅" "Navigated to $EXTRACTED_DIR." "done"
    else
        log "❌" "Extracted directory not found." "done"
        exit 1
    fi

    log "🔧" "Running the setup script..."
    if [ -f "setup.sh" ]; then
        echo -e "\n🔧 Running setup.sh logs below (output redirected):\n"
        bash setup.sh 2>&1 | sed 's/^/[macos-dev-setup] /' || {
            log "❌" "Setup script execution failed." "done"
            exit 1
        }
        log "✅" "Setup script executed successfully." "done"
    else
        log "❌" "setup.sh not found in the extracted directory." "done"
        exit 1
    fi
}

cleanup() {
    log "🧹" "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR.zip" "$EXTRACTED_DIR"
    log "✅" "Temporary files cleaned up." "done"
}

main() {
    log "🚀" "Starting the bootstrap process..."
    download_and_extract_files
    run_setup_script
    cleanup
    log "🎉" "Bootstrap process completed successfully!" "done"
}

main
