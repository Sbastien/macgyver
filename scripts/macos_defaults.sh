#!/bin/sh

# macOS system defaults configuration
# Applies sensible defaults for development

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/log_utils.sh"
. "$SCRIPT_DIR/lib/error_handler.sh"
. "$SCRIPT_DIR/lib/utils.sh"

# Configuration constants
readonly DOCK_ICON_SIZE=48
readonly DOCK_ANIMATION_DURATION=0.1
readonly KEY_REPEAT_RATE=2
readonly KEY_REPEAT_DELAY=15

# Show warning
show_warning() {
    log_section "macOS System Configuration"

    log_warn "This script will modify your macOS system settings"
    log_warn "Some changes require a restart to take effect"

    echo ""
    log_info "The following areas will be configured:"
    log_info "  • General UI/UX improvements"
    log_info "  • Finder settings"
    log_info "  • Dock settings"
    log_info "  • Input (keyboard, trackpad) settings"
    log_info "  • Safari & WebKit settings"
    log_info "  • Terminal settings"
    log_info "  • Activity Monitor settings"
    log_info "  • Security & Privacy settings"
    echo ""

    if ! confirm "Do you want to continue?" "y"; then
        log_info "Configuration cancelled by user"
        exit 0
    fi
}

# Close System Preferences to prevent conflicts
close_system_preferences() {
    log_step "Closing System Preferences to prevent conflicts..."
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
    log_success "System Preferences closed"
}

# General UI/UX
configure_ui_ux() {
    log_section "Configuring UI/UX"

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" " 2>/dev/null || true

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable automatic termination of inactive apps
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

    # Reveal IP address, hostname, OS version when clicking the clock in the login window
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

    log_success "UI/UX configured"
}

# Finder
configure_finder() {
    log_section "Configuring Finder"

    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Use list view in all Finder windows by default
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Show the ~/Library folder
    chflags nohidden ~/Library

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes 2>/dev/null || true

    log_success "Finder configured"
}

# Dock
configure_dock() {
    log_section "Configuring Dock"

    # Set the icon size of Dock items
    defaults write com.apple.dock tilesize -int "$DOCK_ICON_SIZE"

    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true

    # Show indicator lights for open applications
    defaults write com.apple.dock show-process-indicators -bool true

    # Don't animate opening applications from the Dock
    defaults write com.apple.dock launchanim -bool false

    # Speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float "$DOCK_ANIMATION_DURATION"

    # Don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true

    # Don't show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false

    log_success "Dock configured"
}

# Input (Keyboard & Trackpad)
configure_input() {
    log_section "Configuring Input Devices"

    # Trackpad: enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Increase keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int "$KEY_REPEAT_RATE"
    defaults write NSGlobalDomain InitialKeyRepeat -int "$KEY_REPEAT_DELAY"

    # Enable press-and-hold for accented characters (é, è, ê, etc.)
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true

    # Enable full keyboard access for all controls (Tab in modal dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    log_success "Input devices configured"
}

# Screen
configure_screen() {
    log_section "Configuring Screen"

    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    log_success "Screen settings configured"
}

# Safari & WebKit
configure_safari() {
    log_section "Configuring Safari"

    log_warn "Safari uses sandboxed containers on modern macOS"
    log_info "Most settings must be configured manually in Safari > Settings"

    # Warn if Safari is running
    if pgrep -x "Safari" >/dev/null; then
        log_warn "Safari is running. Close Safari and configure manually:"
    else
        log_info "Open Safari > Settings and configure:"
    fi

    echo ""
    log_info "  Privacy:"
    log_info "    - Disable Search Suggestions"
    log_info "    - Enable 'Do Not Track'"
    echo ""
    log_info "  Advanced:"
    log_info "    - Show full URL in address bar"
    log_info "    - Enable 'Show Develop menu'"
    echo ""

    log_success "Safari configuration guidance provided"
}

# Terminal
configure_terminal() {
    log_section "Configuring Terminal"

    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4

    # Enable Secure Keyboard Entry in Terminal.app
    defaults write com.apple.terminal SecureKeyboardEntry -bool true

    log_success "Terminal configured"
}

# Activity Monitor
configure_activity_monitor() {
    log_section "Configuring Activity Monitor"

    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    log_success "Activity Monitor configured"
}

# Security & Privacy
configure_security() {
    log_section "Configuring Security & Privacy"

    # Enable firewall
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2>/dev/null || {
        log_warn "Could not enable firewall (may require manual configuration)"
    }

    # Enable firewall stealth mode
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null || {
        log_warn "Could not enable stealth mode"
    }

    log_success "Security settings configured"
}

# Restart affected applications
restart_apps() {
    log_section "Restarting Applications"

    log_info "Restarting affected applications..."

    for app in "Dock" "Finder" "SystemUIServer"; do
        if killall "$app" 2>/dev/null; then
            log_debug "Restarted $app"
        fi
    done

    log_success "Applications restarted"
}

# Show restart reminder
show_restart_reminder() {
    echo ""
    log_warn "Some changes require a restart to take full effect"
    log_info "It is recommended to restart your Mac now"
    echo ""

    if confirm "Would you like to restart now?" "n"; then
        log_info "Restarting in 10 seconds... (Press Ctrl+C to cancel)"
        sleep 10
        sudo shutdown -r now
    else
        log_info "Please restart your Mac when convenient"
    fi
}

main() {
    setup_error_handling

    # Show warning and get confirmation
    show_warning

    # Pre-flight checks
    check_macos || exit 1

    # Close System Preferences
    close_system_preferences

    # Apply configurations
    configure_ui_ux
    configure_finder
    configure_dock
    configure_input
    configure_screen
    configure_safari
    configure_terminal
    configure_activity_monitor
    configure_security

    # Restart affected applications
    restart_apps

    log_section "Configuration Complete"
    log_success "macOS system defaults have been configured!"

    # Show restart reminder
    show_restart_reminder
}

main "$@"
