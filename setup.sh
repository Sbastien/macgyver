#!/bin/sh

# Main setup script for macOS development environment
# Orchestrates all installation steps

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/scripts/lib/log_utils.sh"
. "$SCRIPT_DIR/scripts/lib/error_handler.sh"
. "$SCRIPT_DIR/scripts/lib/utils.sh"

BREWFILE="$SCRIPT_DIR/Brewfile"

# Total setup start time
SETUP_START_TIME=$(date +%s)

# Display welcome message
show_welcome() {
    log_section "macOS Development Environment Setup"
    log_info "This script will set up your macOS development environment"
    log_info "The following will be installed:"
    log_info "  1. Xcode Command Line Tools"
    log_info "  2. Homebrew"
    log_info "  3. Packages from Brewfile"
    log_info "  4. macOS system configurations (optional)"
    echo ""
}

# Run pre-flight checks
preflight_checks() {
    log_section "Pre-flight Checks"

    # Check macOS
    check_macos || exit 1

    # Check Apple Silicon
    is_apple_silicon || exit 1

    # Check not running as root
    check_not_sudo || exit 1

    # Check macOS version (minimum 26.0)
    check_macos_version "26.0" || {
        log_warn "This script is designed for macOS 26.0 or later"
        log_info "It may work on older versions but is not tested"
    }

    # Check internet connectivity
    check_internet || exit 1

    # Check if Brewfile exists
    if [ ! -f "$BREWFILE" ]; then
        log_error "Brewfile not found: $BREWFILE"
        exit 1
    fi

    log_success "All pre-flight checks passed"
}

# Install Xcode Command Line Tools
install_xcode() {
    log_section "Step 1: Xcode Command Line Tools"

    if ! "$SCRIPT_DIR/scripts/install_xcode_cli.sh"; then
        log_error "Xcode Command Line Tools installation failed"
        return 1
    fi

    log_success "Xcode Command Line Tools ready"
    return 0
}

# Install Homebrew
install_homebrew() {
    log_section "Step 2: Homebrew"

    if ! "$SCRIPT_DIR/scripts/brew_install.sh"; then
        log_error "Homebrew installation failed"
        return 1
    fi

    # Ensure brew is in PATH for subsequent commands
    setup_brew_env || {
        log_error "Failed to configure Homebrew environment"
        return 1
    }

    log_success "Homebrew ready"
    return 0
}

# Install packages from Brewfile
install_packages() {
    log_section "Step 3: Package Installation"

    if ! "$SCRIPT_DIR/scripts/brew_bundle.sh" "$BREWFILE"; then
        log_error "Package installation failed"
        return 1
    fi

    log_success "All packages installed"
    return 0
}


# Configure macOS defaults (optional)
configure_macos() {
    local macos_script="$SCRIPT_DIR/scripts/macos_defaults.sh"

    if [ ! -f "$macos_script" ]; then
        log_debug "macOS defaults script not found, skipping"
        return 0
    fi

    log_section "Step 4: macOS Configuration (Optional)"

    log_info "macOS system configuration is available"
    log_warn "This will modify system settings and requires a restart"

    if confirm "Do you want to apply macOS system configurations?" "n"; then
        log_info "Applying macOS configurations..."

        if ! "$macos_script"; then
            log_error "macOS configuration failed"
            return 1
        fi

        log_success "macOS configurations applied"
        log_warn "A restart is recommended for all changes to take effect"
    else
        log_info "Skipping macOS configuration"
        log_info "Run $macos_script manually to apply later"
    fi

    return 0
}

# Display summary
show_summary() {
    local duration=$(($(date +%s) - SETUP_START_TIME))

    log_section "Setup Summary"

    log_success "Setup completed successfully!"
    log_info "Total time: $(format_duration "$duration")"

    echo ""
    log_info "Next steps:"
    log_info "  1. Restart your terminal or run: source ~/.zshrc"
    log_info "  2. Verify installations: brew doctor"
    log_info "  3. Check installed packages: brew list"

    echo ""
    log_info "Installed tools:"

    # Show some key installed tools
    for tool in git zsh tmux neovim; do
        if command_exists "$tool"; then
            local version
            case "$tool" in
                git) version=$(git --version 2>&1 | head -n1) ;;
                zsh) version=$(zsh --version 2>&1 | head -n1) ;;
                tmux) version=$(tmux -V 2>&1) ;;
                neovim) version=$(nvim --version 2>&1 | head -n1) ;;
            esac
            log_info "  ✓ $tool: $version"
        fi
    done

    echo ""
}

# Main function
main() {
    # Setup error handling
    setup_error_handling

    # Welcome
    show_welcome

    # Pre-flight checks
    preflight_checks

    # Step 1: Xcode Command Line Tools
    if ! install_xcode; then
        log_error "Setup failed at step 1: Xcode Command Line Tools"
        exit 1
    fi

    # Step 2: Homebrew
    if ! install_homebrew; then
        log_error "Setup failed at step 2: Homebrew"
        exit 1
    fi

    # Step 3: Install packages
    if ! install_packages; then
        log_error "Setup failed at step 3: Package installation"
        exit 1
    fi

    # Step 4: macOS configuration (optional, interactive)
    configure_macos || log_warn "macOS configuration had issues (non-critical)"

    # Summary
    show_summary

    log_section "Setup Complete!"
    log_success "Your macOS development environment is ready to use!"
}

main "$@"
