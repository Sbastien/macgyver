# 🍎 macOS Dev Setup

> **Automated macOS development environment setup in one command**

A production-ready script that transforms a fresh Mac into a fully configured development machine.
Optimized for Apple Silicon with smart caching, beautiful logging, and robust error handling.

[![CI](https://github.com/Sbastien/macos-dev-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/Sbastien/macos-dev-setup/actions/workflows/ci.yml)
[![Lint](https://github.com/Sbastien/macos-dev-setup/actions/workflows/lint.yml/badge.svg)](https://github.com/Sbastien/macos-dev-setup/actions/workflows/lint.yml)
[![macOS](https://img.shields.io/badge/macOS-12.0+-blue?logo=apple)](https://www.apple.com/macos)
[![Apple Silicon](https://img.shields.io/badge/Apple_Silicon-Only-orange?logo=apple)](https://www.apple.com/mac/)
[![Shell](https://img.shields.io/badge/Shell-POSIX-green?logo=gnu-bash)](https://pubs.opengroup.org/onlinepubs/9699919799/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

- 🚀 **One-line installation** - From zero to ready in 30 minutes
- 🍎 **Apple Silicon optimized** - Built for Apple Silicon Macs
- 💾 **Smart caching** - SHA-256 hash detection, skip unchanged packages
- 🎨 **Beautiful logging** - Color-coded output with 6 log levels
- 🛡️ **Bulletproof** - Comprehensive error handling with automatic cleanup
- 🔄 **Idempotent** - Safe to run multiple times
- 📦 **47+ packages** - Essential dev tools, CLI utilities, and apps
- ⚙️ **System tweaks** - Sensible macOS defaults for developers

---

## 🚀 Quick Start

### One-Line Bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/Sbastien/macos-dev-setup/main/bootstrap.sh | sh
```

That's it! The script will:

1. ✅ Install Xcode Command Line Tools
2. ✅ Install Homebrew (at /opt/homebrew for Apple Silicon)
3. ✅ Install all packages from Brewfile
4. ✅ Optionally configure macOS system settings

### Manual Installation

```bash
git clone https://github.com/Sbastien/macos-dev-setup.git
cd macos-dev-setup
./setup.sh
```

---

## 📦 What Gets Installed

**47+ carefully selected packages** organized in 8 categories

> 📋 **See the complete list**: [Brewfile](Brewfile) (self-documented with usage guide)
>
> 💡 Includes modern CLI tools (bat, eza, ripgrep, fzf), development tools (Git, Docker, VS Code),
> and productivity apps (Raycast, Rectangle, iTerm2)

---

## 🎯 Usage Examples

### Verbose Mode (for debugging)

```bash
VERBOSE=1 ./setup.sh
```

### Run Individual Scripts

```bash
# Install only Homebrew
./scripts/brew_install.sh

# Install packages from custom Brewfile
./scripts/brew_bundle.sh /path/to/custom/Brewfile

# Configure macOS system defaults
./scripts/macos_defaults.sh
```

### Force Reinstall

```bash
# Clear cache and reinstall all packages
rm -rf ~/.cache/macos-dev-setup
./scripts/brew_bundle.sh ./Brewfile
```

---

## ⚙️ macOS System Configuration

The optional `macos_defaults.sh` script configures sensible defaults:

### 🖥️ UI/UX

- Expand save and print panels by default
- Save to disk (not iCloud) by default
- Disable automatic app termination

### 📁 Finder

- Show all filename extensions
- Show status bar and path bar
- Search current folder by default
- Avoid creating .DS_Store on network volumes

### 🎨 Dock

- Optimized icon size (48px)
- Minimize windows into app icon
- Faster Mission Control animations
- Hide recent applications

### ⌨️ Input

- Enable tap to click on trackpad
- Fast keyboard repeat rate
- Full keyboard access for all controls

### 🔒 Security

- Enable firewall and stealth mode
- Require password immediately after sleep
- Secure keyboard entry in Terminal

> ⚠️ **Note**: Run separately with `./scripts/macos_defaults.sh` and requires restart

---

## 🏗️ Architecture

```text
macos-dev-setup/
├── bootstrap.sh          # Remote installer (curl | sh)
├── setup.sh              # Main orchestrator
├── Brewfile              # Package definitions
├── scripts/
│   ├── lib/
│   │   ├── log_utils.sh      # Logging system
│   │   ├── error_handler.sh  # Error management
│   │   └── utils.sh          # Helper functions
│   ├── install_xcode_cli.sh  # Xcode CLT installer
│   ├── brew_install.sh       # Homebrew installer
│   ├── brew_bundle.sh        # Package installer
│   └── macos_defaults.sh     # System configuration
└── test_posix.sh         # POSIX compliance tests
```

### Key Features Under the Hood

**🎨 Advanced Logging**

```bash
🔍 DEBUG   # Verbose mode only
ℹ️  INFO    # General information
✅ SUCCESS # Operations succeeded
⚠️  WARN    # Non-fatal warnings
❌ ERROR   # Fatal errors
```

**🛡️ Error Handling**

- Automatic cleanup on failure (EXIT, ERR, INT, TERM traps)
- Descriptive error messages with suggested fixes
- Safe execution with comprehensive pre-flight checks

**💾 Smart Caching**

- SHA-256 hash-based change detection
- Skip reinstallation if Brewfile unchanged
- Automatic backup before modifications

**🔄 Network Resilience**

- Exponential backoff retry for downloads
- Internet connectivity checks
- Timeout handling for long operations

---

## 🔧 Advanced Configuration

### Environment Variables

```bash
# Enable debug logging
VERBOSE=1 ./setup.sh

# Custom log level (0=DEBUG, 1=INFO, 2=WARN, 3=ERROR)
LOG_LEVEL=0 ./setup.sh
```

### Customizing Packages

The [Brewfile](Brewfile) is self-documented with:

- Legend explaining symbols (⭐ 🔧 💎 📦)
- Description of each package
- Post-install configuration guide
- Optional packages you can uncomment

Edit it to match your workflow, then run:

```bash
./scripts/brew_bundle.sh ./Brewfile
```

---

## 🧪 Testing

### Shell Compatibility

Scripts use POSIX `sh` with some common extensions supported by all modern shells:

- `local` keyword (universally supported)
- `set -o pipefail` (optional, fails gracefully on unsupported shells)
- `sort -V` for version comparison (GNU extension)

**Syntax validation:**

```bash
# Validate all scripts
sh -n bootstrap.sh
sh -n setup.sh
sh -n scripts/*.sh
sh -n scripts/lib/*.sh
```

**Advanced checking** (optional):

```bash
# Install shellcheck for comprehensive POSIX analysis
brew install shellcheck
shellcheck -s sh *.sh scripts/*.sh scripts/lib/*.sh
```

---

## 🐛 Troubleshooting

### Xcode Command Line Tools Won't Install

```bash
# Manually trigger installation
xcode-select --install

# If that fails, download from Apple Developer
# https://developer.apple.com/download/
```

### Homebrew Not Found After Install

```bash
# Apple Silicon Macs
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add to your shell profile permanently
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
```

### Safari Settings Don't Apply

Safari uses sandboxed containers on modern macOS. Some settings must be configured manually:

1. Quit Safari completely
2. Run `./scripts/macos_defaults.sh`
3. Open Safari > Settings and verify

### Script Fails with Permission Error

**Never** run with `sudo`. The scripts will prompt for your password when needed:

```bash
# ❌ Wrong
sudo ./setup.sh

# ✅ Correct
./setup.sh
```

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](.github/CONTRIBUTING.md) for:

- Code style guidelines
- POSIX compliance requirements
- Testing procedures
- Pull request process

---

## 📋 Requirements

- **Apple Silicon Mac**
- macOS 26.0 or later
- Internet connection
- Administrator access (for sudo prompts)

**No prior installations needed** - the script handles everything!

> ⚠️ **Note**: This script is optimized for Apple Silicon only. Intel Macs are not supported.

---

## 💡 Why This Project?

### 🆚 vs Manual Setup

- ⏱️ **Saves 3-4 hours** of repetitive work
- 🎯 **Reproducible** - exact same setup every time
- 📋 **Documented** - your entire setup in one Brewfile

### 🎯 Perfect For

- 🆕 Setting up a new Mac
- 🔄 Reinstalling macOS (clean slate)
- 👥 Onboarding developers in a team
- 🖥️ Managing multiple Macs with identical setups
- 🎓 Learning shell scripting best practices

---

---

## 📄 License

MIT License - feel free to use and modify for your own setup.

---

## ⭐ Show Your Support

If this project helped you set up your Mac, give it a ⭐️! It helps others discover it.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/Sbastien">Sebastien</a>
</p>

<p align="center">
  <sub>Automate the boring stuff, focus on building amazing things.</sub>
</p>
