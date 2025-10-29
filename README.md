# 🔧 MacGyver

> **Your Mac setup problem solver**

One command transforms your fresh Mac into a fully-equipped dev machine. Like the legend himself,
MacGyver solves complex setup problems with elegant shell scripts. No duct tape required.

[![CI](https://github.com/Sbastien/macgyver/actions/workflows/ci.yml/badge.svg)](https://github.com/Sbastien/macgyver/actions/workflows/ci.yml)
[![Lint](https://github.com/Sbastien/macgyver/actions/workflows/lint.yml/badge.svg)](https://github.com/Sbastien/macgyver/actions/workflows/lint.yml)
[![macOS](https://img.shields.io/badge/macOS-26.0+-blue?logo=apple)](https://www.apple.com/macos)
[![Apple Silicon](https://img.shields.io/badge/Apple_Silicon-Only-orange?logo=apple)](https://www.apple.com/mac/)
[![Shell](https://img.shields.io/badge/Shell-POSIX-green?logo=gnu-bash)](https://pubs.opengroup.org/onlinepubs/9699919799/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

- 🚀 **One-line installation** - From zero to ready in 30 minutes
- 🎯 **Customizable profiles** - Use built-in profiles or bring your own Brewfile (local or remote)
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
# Full installation (default - 47+ tools)
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh

# Minimal installation (git only)
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh -s -- --profile=minimal

# With your own Brewfile URL
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh -s -- --profile=https://raw.githubusercontent.com/YOU/dotfiles/main/Brewfile
```

That's it! The script will:

1. ✅ Install Xcode Command Line Tools
2. ✅ Install Homebrew (at /opt/homebrew for Apple Silicon)
3. ✅ Install packages from your chosen profile
4. ✅ Optionally configure macOS system settings

### Manual Installation

```bash
git clone https://github.com/Sbastien/macgyver.git
cd macgyver
./setup.sh
```

### 🎯 Customize Your Setup

MacGyver supports **using your own Brewfile** - use ours as a starting point or bring your own!

```bash
# Full installation (recommended for new users)
./setup.sh

# Minimal (git only - build your own from scratch)
./setup.sh --profile=minimal

# Use your own Brewfile
./setup.sh --profile=~/my-tools.brewfile

# Use from your dotfiles repo (recommended!)
./setup.sh --profile=https://raw.githubusercontent.com/YOU/dotfiles/main/Brewfile
```

**📚 Full customization guide:** [profiles/README.md](profiles/README.md)

**Philosophy:** We provide the framework (Xcode, Homebrew, config). You bring your tools.

---

## 📦 What Gets Installed

**47+ carefully selected packages** organized in 8 categories

> 📋 **See the complete list**: [profiles/default.brewfile](profiles/default.brewfile) (self-documented with usage guide)
>
> 💡 Includes modern CLI tools (bat, eza, ripgrep, fzf), development tools (Git, Docker, VS Code),
> and productivity apps (Raycast, Rectangle, iTerm2)

---

## 🎯 Usage Examples

### Custom Brewfiles

```bash
# Use your own local Brewfile
./setup.sh --profile=~/my-tools.brewfile

# Use from your dotfiles repo
./setup.sh --profile=https://raw.githubusercontent.com/username/dotfiles/main/Brewfile

# Use from a Gist
./setup.sh --profile=https://gist.githubusercontent.com/user/abc123/raw/my.brewfile

# Combine multiple Brewfiles
./setup.sh --profile=minimal
./scripts/brew_bundle.sh ~/my-personal-tools.brewfile
./scripts/brew_bundle.sh https://raw.githubusercontent.com/team/tools/main/Brewfile
```

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
rm -rf ~/.cache/macgyver
./scripts/brew_bundle.sh profiles/default.brewfile
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
macgyver/
├── bootstrap.sh          # Remote installer (curl | sh)
├── setup.sh              # Main orchestrator (supports --profile flag)
├── profiles/
│   ├── default.brewfile      # Full installation (47+ tools)
│   ├── minimal.brewfile      # Minimal profile (git only)
│   └── README.md             # Customization guide
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

**Option 1: Use your own Brewfile** (recommended)

```bash
# Create your own from scratch
touch ~/my-setup.brewfile
echo 'brew "git"' >> ~/my-setup.brewfile
echo 'brew "neovim"' >> ~/my-setup.brewfile
./setup.sh --profile=~/my-setup.brewfile

# Or start from the default
cp profiles/default.brewfile ~/my-setup.brewfile
vim ~/my-setup.brewfile  # Comment out what you don't need
./setup.sh --profile=~/my-setup.brewfile

# Or use from your dotfiles repo
./setup.sh --profile=https://raw.githubusercontent.com/YOU/dotfiles/main/Brewfile
```

**Option 2: Edit the default Brewfile**

The [profiles/default.brewfile](profiles/default.brewfile) is self-documented with:

- Legend explaining symbols (⭐ 🔧 💎 📦)
- Description of each package
- Post-install configuration guide
- Optional packages you can uncomment

Edit it to match your workflow, then run:

```bash
./scripts/brew_bundle.sh profiles/default.brewfile
```

**📚 Full customization guide:** [profiles/README.md](profiles/README.md)

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
