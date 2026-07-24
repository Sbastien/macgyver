# =============================================================================
# What belongs in this file
#
#   Homebrew  anything that must exist before mise does (git, curl, zsh, mise
#             itself), GUI applications, launchd services, system libraries.
#
#   mise      language runtimes, and any CLI whose version a project may need
#             to pin. Declared per project in mise.toml, or globally in
#             ~/.config/mise/config.toml.
#
# Never both. Two managers for one tool means two installed versions and one
# of them silently shadowing the other on PATH.
# =============================================================================

# Options
# @icon:cog
cask_args quarantine: false

# Taps
# @icon:link
tap "nikitabobko/tap"

# Terminal & Shell
# @icon:terminal
brew "zsh"                  # Modern shell
brew "bash"                 # Latest bash version
brew "tmux"                 # Terminal multiplexer
brew "neovim"               # Modern vim
brew "starship"             # Cross-shell prompt
brew "zoxide"               # Smarter cd command
brew "chezmoi"              # Dotfiles manager
brew "thefuck"              # Correct previous command
brew "atuin"                # Shell history search

# Modern CLI Tools
# @icon:code
brew "bat"                  # cat with syntax highlighting
brew "eza"                  # ls replacement
brew "fd"                   # find replacement
brew "ripgrep"              # grep replacement
brew "fzf"                  # Fuzzy finder
brew "tree"                 # Directory tree view
brew "btop"                 # Resource monitor
brew "dust"                 # du replacement
brew "duf"                  # df replacement
brew "procs"                # ps replacement
brew "jq"                   # JSON processor
brew "yq"                   # YAML processor
brew "tlrc"                 # tldr pages client
brew "coreutils"            # GNU core utilities
brew "sd"                   # sed replacement
brew "hyperfine"            # Benchmarking tool
brew "tokei"                # Code statistics
brew "xh"                   # HTTPie replacement

# System Utilities
# @icon:wrench
brew "fastfetch"            # System info display
brew "nmap"                 # Network scanner
brew "trash"                # Safe rm replacement

# Git & Version Control
# @icon:git
brew "git"                  # Version control
brew "git-delta"            # Better git diff
brew "lazygit"              # Git TUI
brew "gh"                   # GitHub CLI
brew "git-lfs"              # Large file storage
brew "gitleaks"             # Git secrets scanner

# Security & Privacy
# @icon:shield
brew "gnupg"                # GPG encryption
brew "git-crypt"            # Git file encryption
brew "age"                  # Modern encryption
brew "sops"                 # Secrets management
brew "lynis"                # Security auditing
brew "trivy"                # Container scanner

# Development Tools
# @icon:tools
# Language runtimes (rust, node, python, ruby, ...) are not installed here.
# They are mise's job: `mise use rust@latest` in a project, or in the global
# ~/.config/mise/config.toml.
brew "mise"                 # Polyglot runtime manager (bootstraps the rest)
brew "direnv"               # Per-directory env vars
brew "watchman"             # File watcher
brew "shellcheck"           # Shell script linter
brew "shfmt"                # Shell script formatter
brew "biome"                # Fast JS/TS linter & formatter
brew "gum"                  # Elegant shell scripts
brew "mas"                  # Mac App Store CLI
brew "pre-commit"           # Git hooks manager
brew "act"                  # Run GitHub Actions locally

# Databases
# @icon:database
# Servers stay with Homebrew rather than mise: they run as launchd services
# via `brew services`, and one global instance is the intent. Pin a different
# version with mise inside a project only when that project actually needs it.
brew "sqlite"               # Lightweight database
brew "redis"                # In-memory data store (brew services start redis)
brew "postgresql@16"        # PostgreSQL server (brew services start postgresql@16)

# Productivity Apps
# @icon:rocket
cask "raycast"              # Spotlight replacement
cask "notion"               # Notes & docs
cask "nikitabobko/tap/aerospace"    # Tiling window manager
cask "hiddenbar"            # Menu bar manager
cask "slack"                # Team chat
cask "bitwarden"            # Password manager
cask "mattermost"           # Team chat (open-source)

# Development Apps
# @icon:apps
cask "iterm2"               # Terminal emulator
cask "warp"                 # Modern terminal
cask "visual-studio-code"   # Code editor
cask "docker-desktop"       # Containers
brew "lazydocker"           # Docker TUI
cask "bruno"                # API client
cask "zen"                  # Privacy browser
cask "tableplus"            # Database GUI
cask "claude"               # Claude AI desktop app

# Utility Apps
# @icon:puzzle
cask "alt-tab"              # Windows-style alt-tab
cask "gas-mask"             # Hosts file manager
cask "utm"                  # Virtual machines
cask "the-unarchiver"       # Archive extraction
cask "appcleaner"           # App uninstaller
cask "stats"                # System monitor menubar
cask "kap"                  # Screen recorder GIF/MP4
cask "scroll-reverser"      # Reverse scroll per device

# Media & Creative
# @icon:video
brew "imagemagick"          # Image manipulation
brew "ffmpeg"               # Video/audio processing
brew "yt-dlp"               # Video downloader

# Fonts
# @icon:font
cask "font-fira-code-nerd-font"       # Fira Code + icons
cask "font-jetbrains-mono-nerd-font"  # JetBrains Mono + icons
cask "font-hack-nerd-font"            # Hack + icons
cask "font-meslo-lg-nerd-font"        # Meslo + icons
