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

# Terminal & Shell
brew "zsh"                  # Modern shell
brew "bash"                 # Latest bash version
brew "tmux"                 # Terminal multiplexer
brew "neovim"               # Modern vim
brew "starship"             # Cross-shell prompt
brew "zoxide"               # Smarter cd command
brew "chezmoi"              # Dotfiles manager
brew "atuin"                # Shell history search

# Modern CLI Tools
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
brew "fastfetch"            # System info display
brew "nmap"                 # Network scanner
brew "trash"                # Safe rm replacement
brew "curl"                 # Newer than the system one
brew "wget"                 # Recursive downloader
brew "openssh"              # Newer than the system one
brew "unar"                 # Archive extraction (CLI)

# Git & Version Control
brew "git"                  # Version control
brew "git-delta"            # Better git diff
brew "lazygit"              # Git TUI
brew "gh"                   # GitHub CLI
brew "git-lfs"              # Large file storage
brew "gitleaks"             # Git secrets scanner
brew "git-filter-repo"      # History rewriting

# Security & Privacy
brew "gnupg"                # GPG encryption
brew "git-crypt"            # Git file encryption
brew "age"                  # Modern encryption
brew "sops"                 # Secrets management
brew "lynis"                # Security auditing
brew "trivy"                # Container scanner

# Development Tools
# Language runtimes (rust, node, python, ruby, ...) are not installed here.
# They are mise's job: `mise use rust@latest` in a project, or in the global
# ~/.config/mise/config.toml.
#
# shellcheck and shfmt are absent on purpose: this repository pins them in its
# own mise.toml, which is tracked.
#
# Other CLIs stay with Homebrew even where a project might want to pin them.
# A mise tool is only on PATH once mise activates, and the global mise config
# is not version-controlled today — moving a tool there would trade a tracked
# declaration for an untracked one. See "Homebrew or mise?" in the README.
brew "mise"                 # Polyglot runtime manager (bootstraps the rest)
brew "direnv"               # Per-directory env vars
brew "watchman"             # File watcher
brew "biome"                # Fast JS/TS linter & formatter
brew "uv"                   # Python package manager
brew "gum"                  # Elegant shell scripts
brew "pre-commit"           # Git hooks manager
brew "act"                  # Run GitHub Actions locally
brew "cmake"                # Build system
brew "pkgconf"              # Build flag helper
brew "rtk"                  # Token-optimised CLI proxy

# Databases
# Database *servers* live in the Local Services section: they run as launchd
# services and are started deliberately. sqlite is a library, not a service,
# so it stays here.
brew "sqlite"               # Lightweight database

# Productivity Apps
cask "raycast"              # Spotlight replacement
cask "notion"               # Notes & docs
cask "hiddenbar"            # Menu bar manager
cask "bitwarden"            # Password manager

# Development Apps
cask "ghostty"              # Terminal emulator
cask "visual-studio-code"   # Code editor
cask "docker-desktop"       # Containers
brew "lazydocker"           # Docker TUI
cask "bruno"                # API client
cask "zen"                  # Privacy browser
cask "google-chrome"        # Cross-browser testing
cask "firefox"              # Cross-browser testing
cask "tableplus"            # Database GUI
cask "claude"               # Claude AI desktop app

# Utility Apps
cask "alt-tab"              # Windows-style alt-tab
cask "utm"                  # Virtual machines
cask "the-unarchiver"       # Archive extraction
cask "appcleaner"           # App uninstaller
cask "stats"                # System monitor menubar
cask "kap"                  # Screen recorder GIF/MP4
cask "scroll-reverser"      # Reverse scroll per device

# Media & Creative
brew "imagemagick"          # Image manipulation
brew "ffmpeg"               # Video/audio processing
brew "yt-dlp"               # Video downloader

# Fonts
cask "font-fira-code-nerd-font"       # Fira Code + icons
cask "font-jetbrains-mono-nerd-font"  # JetBrains Mono + icons
cask "font-hack-nerd-font"            # Hack + icons
cask "font-meslo-lg-nerd-font"        # Meslo + icons

# Local Services
# Servers stay with Homebrew rather than mise: they run as launchd services
# via `brew services`, and one global instance is the intent. Pin a different
# version with mise inside a project only when that project actually needs it.
#
# The ones that run permanently say so. `restart_service: :changed` starts
# them on a fresh Mac, and lets `brew bundle check` notice one that died.
brew "meilisearch"          # Search engine
brew "mailpit"              # Captures outgoing mail in development

brew "postgresql@16", restart_service: :changed  # PostgreSQL server
brew "redis", restart_service: :changed          # In-memory data store
brew "caddy", restart_service: :changed          # Reverse proxy for local worktrees

# Work Tooling
brew "worktrunk"            # Git worktree manager
brew "overmind"             # Procfile process manager
brew "herdr"                # Local environment helper
brew "glab"                 # GitLab CLI
brew "cloudflared"          # Cloudflare tunnels

# Work Apps
cask "slack"                # Team chat
cask "mattermost"           # Team chat (open-source)
cask "figma"                # Design handoff
cask "cyberduck"            # SFTP / cloud storage client
cask "chatgpt"              # ChatGPT desktop app

# Personal Apps
cask "spotify"              # Music
cask "vivaldi"              # Browser

# Document Toolchain (experimental)
# "experimental" in a section title means: kept just in case, or tried once
# and never removed. It sits in the title rather than in a heading of its own
# so the rest of the file stays honest — anything carrying the marker is a
# candidate for deletion at the next review rather than something to carry
# forever.
#
# All five are standalone: `brew uses --installed` reports nothing depending
# on any of them, so they were installed deliberately rather than pulled in.
# Whether they are still needed is the open question.
brew "pandoc"               # Document converter
brew "weasyprint"           # HTML to PDF
brew "ghostscript"          # PostScript / PDF interpreter
brew "poppler"              # PDF utilities
cask "basictex"             # Minimal TeX distribution

# Misc (experimental)
brew "figlet"               # ASCII art banners
