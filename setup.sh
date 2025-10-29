#!/bin/sh

# Main setup script for macOS development environment
# Orchestrates all installation steps

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/scripts/lib/log_utils.sh"
. "$SCRIPT_DIR/scripts/lib/error_handler.sh"
. "$SCRIPT_DIR/scripts/lib/utils.sh"

# Default Brewfile
BREWFILE="$SCRIPT_DIR/profiles/default.brewfile"
PROFILE=""

# Total setup start time
SETUP_START_TIME=$(date +%s)

# Parse command line arguments
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --profile=*)
                PROFILE="${1#*=}"
                ;;
            --profile)
                shift
                PROFILE="$1"
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  --profile=PATH    Use a custom Brewfile (path or URL)
  -h, --help        Show this help message

Built-in Profiles:
  default           Full installation - 47+ tools (default if no --profile specified)
  minimal           Git only - build your own from scratch

Examples:
  # Full installation (default)
  $0

  # Minimal (git only)
  $0 --profile=minimal

  # Your own local Brewfile
  $0 --profile=~/my-tools.brewfile
  $0 --profile=/path/to/custom.brewfile

  # From your dotfiles repo (recommended!)
  $0 --profile=https://raw.githubusercontent.com/YOU/dotfiles/main/Brewfile

  # From a GitHub Gist
  $0 --profile=https://gist.githubusercontent.com/user/abc123/raw/my.brewfile

Combining Multiple Brewfiles:
  # Start minimal, add your tools gradually
  $0 --profile=minimal
  ./scripts/brew_bundle.sh ~/my-personal-tools.brewfile
  ./scripts/brew_bundle.sh https://raw.githubusercontent.com/team/tools/main/Brewfile

Learn More:
  See profiles/README.md for full customization guide

EOF
}

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

# Download remote Brewfile from URL
download_remote_brewfile() {
    local url="$1"
    local temp_file="$HOME/.cache/macgyver/remote-brewfile-$(date +%s).brewfile"

    ensure_dir "$(dirname "$temp_file")" || return 1

    log_info "Downloading remote Brewfile from: $url" >&2

    if curl -fsSL "$url" -o "$temp_file"; then
        # Verify it's a valid Brewfile (basic check)
        if grep -qE "^(brew|cask|tap|mas)" "$temp_file"; then
            log_success "Remote Brewfile downloaded successfully" >&2
            echo "$temp_file"
            return 0
        else
            log_error "Downloaded file doesn't appear to be a valid Brewfile" >&2
            rm -f "$temp_file"
            return 1
        fi
    else
        log_error "Failed to download remote Brewfile" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Resolve profile to Brewfile path
resolve_profile() {
    if [ -z "$PROFILE" ]; then
        # No profile specified, use default
        log_debug "Using default Brewfile: $BREWFILE"
        return 0
    fi

    # Check if PROFILE is a URL (http:// or https://)
    case "$PROFILE" in
        http://*|https://*)
            local downloaded_file
            downloaded_file=$(download_remote_brewfile "$PROFILE")
            if [ $? -eq 0 ] && [ -f "$downloaded_file" ]; then
                BREWFILE="$downloaded_file"
                log_info "Using remote Brewfile: $PROFILE"
                return 0
            else
                log_error "Failed to download remote Brewfile from: $PROFILE"
                exit 1
            fi
            ;;
    esac

    # Check if PROFILE is a file path
    if [ -f "$PROFILE" ]; then
        BREWFILE="$PROFILE"
        log_info "Using custom Brewfile: $BREWFILE"
        return 0
    fi

    # Check if PROFILE is a relative path from SCRIPT_DIR
    if [ -f "$SCRIPT_DIR/$PROFILE" ]; then
        BREWFILE="$SCRIPT_DIR/$PROFILE"
        log_info "Using Brewfile: $BREWFILE"
        return 0
    fi

    # Check if it's a named profile
    case "$PROFILE" in
        minimal|default)
            BREWFILE="$SCRIPT_DIR/profiles/$PROFILE.brewfile"
            ;;
        *)
            # Try as filename in profiles/
            if [ -f "$SCRIPT_DIR/profiles/$PROFILE" ]; then
                BREWFILE="$SCRIPT_DIR/profiles/$PROFILE"
            elif [ -f "$SCRIPT_DIR/profiles/$PROFILE.brewfile" ]; then
                BREWFILE="$SCRIPT_DIR/profiles/$PROFILE.brewfile"
            else
                log_error "Profile not found: $PROFILE"
                log_info "Available built-in profiles: minimal, default"
                log_info "Or provide a path/URL to a custom Brewfile"
                exit 1
            fi
            ;;
    esac

    log_info "Using profile '$PROFILE': $BREWFILE"
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

    # Resolve profile to Brewfile
    resolve_profile

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
    # Parse command line arguments
    parse_args "$@"

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
