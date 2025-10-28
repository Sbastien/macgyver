#!/bin/sh

# Bootstrap script - Downloads and runs the full setup
# Usage: curl -fsSL https://raw.githubusercontent.com/Sbastien/macos-dev-setup/main/bootstrap.sh | sh

set -e

ZIP_URL="https://github.com/Sbastien/macos-dev-setup/archive/main.zip"
TEMP_DIR="/tmp/macos-dev-setup"
EXTRACTED_DIR="/tmp/macos-dev-setup-main"

# Minimal inline logging (to avoid circular dependencies in bootstrap)
log_info() { printf "\033[0;34mℹ️  %s\033[0m\n" "$1"; }
log_success() { printf "\033[0;32m✅ %s\033[0m\n" "$1"; }
log_error() { printf "\033[0;31m❌ %s\033[0m\n" "$1" >&2; }
log_step() { printf "\033[0;34m🔧 %s\033[0m\n" "$1"; }
log_section() {
    printf "\n\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
    printf "\033[0;34m📦 %s\033[0m\n" "$1"
    printf "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
}

# Cleanup function
cleanup() {
    # Only log and clean if there are actually files to remove
    if [ -e "$TEMP_DIR.zip" ] || [ -e "$EXTRACTED_DIR" ]; then
        log_step "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR.zip" "$EXTRACTED_DIR" 2>/dev/null || true
        log_success "Cleanup completed"
    fi
}

# Setup error handling
# shellcheck disable=SC3047
trap 'cleanup; log_error "Bootstrap failed"; exit 1' ERR
trap 'cleanup' EXIT

# Check if running on macOS with Apple Silicon
# Note: Duplicated from lib/error_handler.sh to avoid circular dependencies
# (bootstrap downloads the repo, can't source libs before download)
check_macos() {
    if [ "$(uname)" != "Darwin" ]; then
        log_error "This script must be run on macOS"
        exit 1
    fi

    if [ "$(uname -m)" != "arm64" ]; then
        log_error "This setup requires Apple Silicon"
        log_error "Detected architecture: $(uname -m)"
        exit 1
    fi

    log_success "Running on macOS with Apple Silicon"
}

# Check if running as root
# Note: Duplicated from lib/error_handler.sh (check_not_sudo) to avoid dependencies
check_not_root() {
    if [ "$(id -u)" -eq 0 ]; then
        log_error "Do not run this script as root or with sudo"
        log_info "It will prompt for sudo when needed"
        exit 1
    fi
}

# Check for required commands
check_requirements() {
    log_step "Checking requirements..."

    local missing=""

    for cmd in curl unzip; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing="$missing $cmd"
        fi
    done

    if [ -n "$missing" ]; then
        log_error "Missing required commands:$missing"
        log_info "Please install these tools and try again"
        exit 1
    fi

    log_success "All requirements met"
}

# Check internet connectivity
# Note: Simplified version of lib/utils.sh check_internet() to avoid dependencies
check_internet() {
    log_step "Checking internet connectivity..."

    if curl -fsSL --connect-timeout 10 --max-time 30 --head "https://github.com" >/dev/null 2>&1 || \
       curl -fsSL --connect-timeout 10 --max-time 30 --head "https://www.google.com" >/dev/null 2>&1; then
        log_success "Internet connection verified"
    else
        log_error "No internet connection detected"
        log_info "Please check your network and try again"
        exit 1
    fi
}

# Download setup files
download_files() {
    log_step "Downloading setup files from GitHub..."

    if ! curl -fsSL --connect-timeout 10 --max-time 300 "$ZIP_URL" -o "$TEMP_DIR.zip"; then
        log_error "Failed to download setup files"
        log_info "Please check your internet connection and try again"
        exit 1
    fi

    log_success "Setup files downloaded"
}

# Extract setup files
extract_files() {
    log_step "Extracting setup files..."

    if ! unzip -qo "$TEMP_DIR.zip" -d /tmp/; then
        log_error "Failed to extract setup files"
        exit 1
    fi

    log_success "Setup files extracted"
}

# Verify extracted directory
verify_extraction() {
    if [ ! -d "$EXTRACTED_DIR" ]; then
        log_error "Extracted directory not found: $EXTRACTED_DIR"
        exit 1
    fi

    if [ ! -f "$EXTRACTED_DIR/setup.sh" ]; then
        log_error "setup.sh not found in extracted directory"
        exit 1
    fi

    log_success "Extraction verified"
}

# Run setup script
run_setup() {
    log_section "Running Setup Script"

    cd "$EXTRACTED_DIR" || {
        log_error "Failed to navigate to extracted directory"
        exit 1
    }

    log_info "Executing setup.sh..."
    log_info "Output from setup.sh follows:"
    echo ""

    # Run setup script and capture exit code
    if sh setup.sh </dev/tty; then
        log_success "Setup completed successfully"
    else
        log_error "Setup script failed"
        log_info "Check the output above for errors"
        exit 1
    fi
}

# Main function
main() {
    log_section "macOS Development Environment Bootstrap"

    # Pre-flight checks
    check_macos
    check_not_root
    check_requirements
    check_internet

    # Download and extract
    download_files
    extract_files
    verify_extraction

    # Run setup
    run_setup

    log_section "Bootstrap Completed Successfully"
    log_success "Your macOS development environment is ready!"
    log_info "You may need to restart your terminal for all changes to take effect"
}

main "$@"
