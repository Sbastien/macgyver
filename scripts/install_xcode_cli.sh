#!/bin/sh

# Xcode Command Line Tools installer
# This script checks for and installs Xcode CLT if needed

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/log_utils.sh"
. "$SCRIPT_DIR/lib/error_handler.sh"
. "$SCRIPT_DIR/lib/utils.sh"

# Constants
readonly XCODE_PATH="/Library/Developer/CommandLineTools"
readonly XCODE_INSTALL_TIMEOUT=900  # 15 minutes in seconds
readonly PROGRESS_UPDATE_INTERVAL=30  # Show progress every 30 seconds

# Check if Xcode CLT is properly installed
check_xcode_cli_installed() {
    if ! xcode-select --print-path >/dev/null 2>&1; then
        return 1
    fi

    local xcode_path
    xcode_path=$(xcode-select --print-path 2>/dev/null)

    # Check if the path exists and is valid
    if [ ! -d "$xcode_path" ]; then
        return 1
    fi

    # Verify essential tools are present
    if ! command_exists gcc || ! command_exists git; then
        return 1
    fi

    return 0
}

# Clean up invalid Xcode path
cleanup_xcode_path() {
    local current_path
    current_path=$(xcode-select --print-path 2>/dev/null || echo "")

    if [ -n "$current_path" ] && [ ! -d "$current_path" ]; then
        log_step "Cleaning up invalid Xcode path: $current_path"
        sudo rm -rf "$current_path" 2>/dev/null || true
        sudo xcode-select --reset 2>/dev/null || true
        log_success "Invalid Xcode path cleaned up"
    fi
}

# Wait for Xcode CLT installation to complete
wait_for_installation() {
    local start_time
    local elapsed
    local last_message_time=0

    start_time=$(date +%s)

    log_progress "Waiting for Xcode Command Line Tools installation to complete..."

    while true; do
        # Check if installation is complete
        if [ -d "$XCODE_PATH" ] && [ -f "$XCODE_PATH/usr/bin/git" ]; then
            log_success "Xcode Command Line Tools installation detected"
            return 0
        fi

        elapsed=$(( $(date +%s) - start_time ))

        # Show progress every PROGRESS_UPDATE_INTERVAL seconds
        if [ $((elapsed - last_message_time)) -ge "$PROGRESS_UPDATE_INTERVAL" ]; then
            log_progress "Still waiting... ($(format_duration "$elapsed") elapsed)"
            last_message_time=$elapsed
        fi

        # Check timeout
        if [ "$elapsed" -gt "$XCODE_INSTALL_TIMEOUT" ]; then
            log_error "Installation timeout reached after $(format_duration "$XCODE_INSTALL_TIMEOUT")"
            log_info "Please complete the installation manually and run this script again"
            return 1
        fi

        sleep 3
    done
}

# Configure Xcode developer directory
configure_xcode() {
    log_step "Configuring Xcode developer directory..."

    if ! sudo xcode-select --switch "$XCODE_PATH" 2>/dev/null; then
        log_error "Failed to configure Xcode developer directory"
        return 1
    fi

    # Accept license if needed
    if ! sudo xcodebuild -license accept 2>/dev/null; then
        log_debug "Could not auto-accept Xcode license (may not be required)"
    fi

    log_success "Xcode developer directory configured"
    return 0
}

# Trigger Xcode CLT installation
install_xcode_cli() {
    log_step "Initiating Xcode Command Line Tools installation..."

    # Try to trigger installation
    if xcode-select --install >/dev/null 2>&1; then
        log_info "Installation dialog opened. Please complete the installation."
        log_info "The script will wait for the installation to complete..."

        # Wait for installation
        if ! wait_for_installation; then
            return 1
        fi

        # Configure after installation
        if ! configure_xcode; then
            return 1
        fi

        log_success "Xcode Command Line Tools installed and configured successfully"
        return 0
    else
        # Check if already installed
        if [ -d "$XCODE_PATH" ]; then
            log_debug "Installation already in progress or completed"
            configure_xcode
            return 0
        else
            log_error "Failed to start installation"
            log_info "Please try running: xcode-select --install"
            return 1
        fi
    fi
}

# Verify installation
verify_installation() {
    log_step "Verifying Xcode Command Line Tools installation..."

    local version
    version=$(xcode-select --version 2>&1 | head -n1)
    log_success "Xcode Command Line Tools verified: $version"
}

main() {
    setup_error_handling
    log_section "Xcode Command Line Tools Installation"

    # Pre-flight checks
    check_macos || exit 1

    # Clean up any invalid paths
    cleanup_xcode_path

    # Check if already installed
    if check_xcode_cli_installed; then
        log_success "Xcode Command Line Tools are already installed"
        verify_installation
        exit 0
    fi

    # Install Xcode CLT
    if ! install_xcode_cli; then
        log_error "Xcode Command Line Tools installation failed"
        exit 1
    fi

    # Verify installation
    if ! verify_installation; then
        log_error "Xcode Command Line Tools installation could not be verified"
        exit 1
    fi

    log_success "Xcode Command Line Tools setup completed successfully"
}

main "$@"
