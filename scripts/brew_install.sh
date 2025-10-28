#!/bin/sh

# Homebrew installer for Apple Silicon

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/log_utils.sh"
. "$SCRIPT_DIR/lib/error_handler.sh"
. "$SCRIPT_DIR/lib/utils.sh"

BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Check if Homebrew is installed
check_homebrew_installed() {
    command_exists brew
}

# Check if Homebrew is in PATH
check_brew_in_path() {
    if command_exists brew; then
        return 0
    fi

    if [ -x "$BREW_BIN" ]; then
        log_debug "Homebrew found at $BREW_PREFIX but not in PATH"
        return 1
    fi

    return 1
}

# Add Homebrew to PATH
configure_brew_path() {
    log_step "Configuring Homebrew in PATH..."

    if setup_brew_env; then
        log_success "Homebrew configured in PATH"
    else
        log_error "Failed to configure Homebrew in PATH"
        return 1
    fi
}

# Verify Homebrew installation
verify_homebrew() {
    log_step "Verifying Homebrew installation..."

    if ! command_exists brew; then
        log_error "Homebrew command not found after installation"
        return 1
    fi

    local version
    version=$(brew --version 2>&1 | head -n1)
    log_success "Homebrew verified: $version"

    local prefix
    prefix=$(brew --prefix 2>&1)
    log_info "Homebrew prefix: $prefix"

    return 0
}

# Install Homebrew
install_homebrew() {
    log_step "Installing Homebrew..."

    # Check internet connectivity
    if ! check_internet; then
        return 1
    fi

    # Download and run Homebrew installer
    log_info "Downloading Homebrew installer..."
    log_info "You may be prompted for your password..."

    # Run installer with /dev/tty for interactive prompts
    if ! /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")" </dev/tty; then
        log_error "Homebrew installation failed"
        log_info "Please check the error messages above"
        return 1
    fi

    log_success "Homebrew installation completed"

    # Configure PATH after installation
    if ! configure_brew_path; then
        log_warn "Homebrew installed but PATH configuration failed"
        log_info "You may need to run: eval \"\$(/opt/homebrew/bin/brew shellenv)\""
        return 1
    fi

    return 0
}

# Update Homebrew
update_homebrew() {
    log_step "Updating Homebrew..."

    if ! brew update; then
        log_warn "Homebrew update failed (this is usually not critical)"
        return 1
    fi

    log_success "Homebrew updated successfully"
    return 0
}

# Run Homebrew diagnostics
run_diagnostics() {
    log_step "Running Homebrew diagnostics..."

    # Run brew doctor but don't fail on warnings
    if brew doctor >/dev/null 2>&1; then
        log_success "Homebrew diagnostics passed"
    else
        log_warn "Homebrew diagnostics found some issues (usually not critical)"
        log_info "Run 'brew doctor' for details"
    fi

    return 0
}

main() {
    setup_error_handling

    log_section "Homebrew Installation"

    # Pre-flight checks
    check_macos || exit 1
    check_not_sudo || exit 1

    # Require Xcode Command Line Tools
    if ! command_exists git; then
        log_error "Xcode Command Line Tools required but not found"
        log_info "Please run: xcode-select --install"
        exit 1
    fi

    # Check if already installed
    if check_homebrew_installed; then
        log_success "Homebrew is already installed"

        # Verify it's working
        verify_homebrew || exit 1

        # Update Homebrew
        update_homebrew

        # Run diagnostics
        run_diagnostics

        exit 0
    fi

    # Check if installed but not in PATH
    if check_brew_in_path; then
        log_warn "Homebrew is installed but not in PATH"

        if configure_brew_path; then
            log_success "Homebrew configured successfully"
            verify_homebrew || exit 1
            update_homebrew
            exit 0
        else
            log_error "Failed to configure Homebrew PATH"
            exit 1
        fi
    fi

    # Install Homebrew
    if ! install_homebrew; then
        log_error "Homebrew installation failed"
        exit 1
    fi

    # Verify installation
    if ! verify_homebrew; then
        log_error "Homebrew installation could not be verified"
        exit 1
    fi

    # Run diagnostics
    run_diagnostics

    log_success "Homebrew setup completed successfully"
}

main "$@"
