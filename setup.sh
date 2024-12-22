#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/scripts/log_utils.sh"

CHEZMOI_DIR="$SCRIPT_DIR/chezmoi"
BREWFILE="$SCRIPT_DIR/Brewfile"

# Install Xcode Command Line Tools
"$SCRIPT_DIR/scripts/install_xcode_cli.sh"

# Install Homebrew
"$SCRIPT_DIR/scripts/brew_install.sh"

# Install Homebrew packages
"$SCRIPT_DIR/scripts/brew_bundle.sh" "$BREWFILE"

# "$SCRIPT_DIR/scripts/macos_defaults.sh"
