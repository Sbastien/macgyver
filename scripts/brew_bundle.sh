#!/bin/sh

# Homebrew bundle installer
# Installs packages from Brewfile with hash-based change detection

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/log_utils.sh"
. "$SCRIPT_DIR/lib/error_handler.sh"
. "$SCRIPT_DIR/lib/utils.sh"

BREWFILE="${1:-}"
CACHE_DIR="$HOME/.cache/macgyver"
BREWFILE_HASH_FILE="$CACHE_DIR/Brewfile.hash"
BREWFILE_BACKUP="$CACHE_DIR/Brewfile.backup"

# Validate Brewfile
validate_brewfile() {
    if [ -z "$BREWFILE" ]; then
        log_error "No Brewfile specified"
        log_info "Usage: $0 /path/to/Brewfile"
        return 1
    fi

    if [ ! -f "$BREWFILE" ]; then
        log_error "Brewfile not found: $BREWFILE"
        return 1
    fi

    if [ ! -r "$BREWFILE" ]; then
        log_error "Brewfile is not readable: $BREWFILE"
        return 1
    fi

    log_debug "Using Brewfile: $BREWFILE"
    return 0
}

# Check if Brewfile has changed
brewfile_changed() {
    if [ ! -f "$BREWFILE_HASH_FILE" ]; then
        log_debug "No previous Brewfile hash found"
        return 0  # Changed (first run)
    fi

    if compare_hash "$BREWFILE" "$BREWFILE_HASH_FILE"; then
        log_debug "Brewfile unchanged since last run"
        return 1  # Not changed
    else
        log_debug "Brewfile has been modified"
    fi
}

# Backup current Brewfile
backup_brewfile() {
    log_debug "Backing up Brewfile..."

    ensure_dir "$CACHE_DIR" || return 1

    if ! cp "$BREWFILE" "$BREWFILE_BACKUP"; then
        log_warn "Failed to backup Brewfile"
        return 1
    fi

    log_debug "Brewfile backed up to: $BREWFILE_BACKUP"
}

# Display Brewfile summary
show_brewfile_summary() {
    log_info "Brewfile summary:"
    awk '/^tap / {t++} /^brew / {b++} /^cask / {c++} /^mas / {m++}
         END {
             print "  - Taps: " t+0
             print "  - Formulae: " b+0
             print "  - Casks: " c+0
             print "  - Mac App Store: " m+0
         }' "$BREWFILE" | while IFS= read -r line; do
        log_info "$line"
    done
}

# Setup Homebrew environment
setup_homebrew() {
    log_step "Setting up Homebrew environment..."

    if ! command_exists brew; then
        if ! setup_brew_env; then
            log_error "Homebrew not found"
            log_info "Please run brew_install.sh first"
            return 1
        fi
    fi

    log_success "Homebrew environment ready"
    return 0
}

# Run brew bundle
run_brew_bundle() {
    log_step "Running 'brew bundle' from $BREWFILE..."

    # Show summary before installation
    show_brewfile_summary

    # Backup Brewfile
    backup_brewfile

    log_info "Installing packages (this may take a while)..."

    # Run brew bundle - let it handle its own output
    local start_time
    start_time=$(date +%s)

    if brew bundle --file="$BREWFILE"; then
        local duration=$(($(date +%s) - start_time))
        log_success "Brew bundle completed in $(format_duration "$duration")"

        # Save hash after successful installation
        save_hash "$BREWFILE" "$BREWFILE_HASH_FILE"
        log_debug "Brewfile hash saved"
    else
        log_error "Brew bundle failed"
        log_info "Check the output above for errors"
        return 1
    fi
}

# Cleanup old packages
cleanup_brew() {
    log_step "Cleaning up old Homebrew packages..."

    if brew cleanup 2>&1 | while IFS= read -r line; do
        log_debug "$line"
    done; then
        log_success "Homebrew cleanup completed"
    else
        log_warn "Homebrew cleanup had some issues (usually not critical)"
    fi
}

# Verify installations
verify_installations() {
    log_step "Verifying installations..."

    # Check for any broken installations
    if brew doctor >/dev/null 2>&1; then
        log_success "All installations verified"
        return 0
    else
        log_warn "Some installations may have issues"
        log_info "Run 'brew doctor' for details"
        return 1
    fi
}

# Show what changed
show_changes() {
    if [ -f "$BREWFILE_BACKUP" ]; then
        log_info "Comparing with previous Brewfile..."

        local changes
        changes=$(diff -u "$BREWFILE_BACKUP" "$BREWFILE" 2>/dev/null | grep -c '^[+-]\(brew\|cask\|tap\|mas\)' || echo "0")

        if [ "$changes" -gt 0 ]; then
            log_info "Changes detected: $changes package lines modified"
        else
            log_debug "No package changes, possibly version updates"
        fi
    fi
}

main() {
    setup_error_handling

    log_section "Homebrew Bundle Installation"

    # Validate arguments
    if ! validate_brewfile; then
        exit 1
    fi

    # Setup Homebrew
    if ! setup_homebrew; then
        exit 1
    fi

    # Create cache directory
    ensure_dir "$CACHE_DIR" || exit 1

    # Check if Brewfile changed
    if ! brewfile_changed; then
        log_success "No changes detected in Brewfile"
        log_info "All packages are up to date"
        exit 0
    fi

    # Show what changed
    show_changes

    # Run brew bundle
    if ! run_brew_bundle; then
        log_error "Brew bundle installation failed"
        exit 1
    fi

    # Cleanup
    cleanup_brew

    # Verify (non-critical)
    verify_installations || true

    log_success "Brew bundle setup completed successfully"
}

main "$@"
