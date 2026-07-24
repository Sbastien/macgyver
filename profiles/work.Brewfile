# =============================================================================
# work — tools tied to a job: local service stack, company apps, CI clients.
#
# Not part of the root Brewfile. Install on top of base with:
#
#   mise run install:work
#
# Rule of thumb: if a new machine used only for personal projects would not
# want it, it belongs here rather than in base.
# =============================================================================

# Services
# @icon:database
# Servers stay with Homebrew rather than mise: they run as launchd services
# via `brew services`, and one global instance is the intent. Pin a different
# version with mise inside a project only when that project actually needs it.
brew "postgresql@16"        # PostgreSQL server (brew services start postgresql@16)
brew "redis"                # In-memory data store (brew services start redis)
brew "meilisearch"          # Search engine
brew "mailpit"              # Captures outgoing mail in development
brew "caddy"                # Reverse proxy for local worktrees

# Development Tools
# @icon:tools
brew "worktrunk"            # Git worktree manager
brew "overmind"             # Procfile process manager
brew "herdr"                # Local environment helper
brew "glab"                 # GitLab CLI
brew "cloudflared"          # Cloudflare tunnels

# Apps
# @icon:apps
cask "slack"                # Team chat
cask "mattermost"           # Team chat (open-source)
cask "figma"                # Design handoff
cask "cyberduck"            # SFTP / cloud storage client
cask "chatgpt"              # ChatGPT desktop app
