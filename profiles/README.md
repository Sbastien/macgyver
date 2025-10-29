# 📦 MacGyver Profiles

MacGyver supports **customizable installation profiles** - use our starter profiles or bring your own!

---

## 🚀 Quick Start

### One-Liner Bootstrap (Fresh Mac)

```bash
# Full installation (default)
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh

# Minimal installation
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh -s -- --profile=minimal

# With your dotfiles URL
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh -s -- --profile=https://raw.githubusercontent.com/YOU/dotfiles/main/Brewfile
```

### Using Built-in Profiles (Already Cloned)

```bash
# Minimal installation (only git)
./setup.sh --profile=minimal

# Full installation (default)
./setup.sh
```

### Using Your Own Brewfile

```bash
# Local file
./setup.sh --profile=~/my-tools.brewfile

# From your dotfiles repo (recommended!)
./setup.sh --profile=https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/Brewfile

# From a GitHub Gist
./setup.sh --profile=https://gist.githubusercontent.com/user/abc123/raw/my.brewfile
```

---

## 📋 Built-in Profiles

All profiles are in the `profiles/` directory:

| Profile | Description | Tools | Use Case |
|---------|-------------|-------|----------|
| **default.brewfile** | Full MacGyver experience | 47+ | One-click everything - used by default |
| **minimal.brewfile** | Bare essentials | 1 (git) | DIY setup - build your own from scratch |

**Philosophy:** We provide two extremes. You customize to your needs.

---

## 🛠️ Create Your Own Profile

### Method 1: Start from Scratch

```bash
# 1. Create your Brewfile
touch ~/my-setup.brewfile

# 2. Add packages you need
cat << 'EOF' >> ~/my-setup.brewfile
# Essential tools
brew "git"
brew "neovim"
brew "tmux"

# Your favorite apps
cask "visual-studio-code"
cask "docker-desktop"
EOF

# 3. Install it
./setup.sh --profile=~/my-setup.brewfile
```

### Method 2: Start from Default

```bash
# 1. Copy the default profile
cp profiles/default.brewfile ~/my-setup.brewfile

# 2. Edit it - comment out what you don't need
vim ~/my-setup.brewfile

# 3. Install your customized version
./setup.sh --profile=~/my-setup.brewfile
```

### Method 3: Export Your Current Setup

```bash
# Already have tools installed? Export them!
brew bundle dump --file=~/my-current-setup.brewfile

# Review and clean up
vim ~/my-current-setup.brewfile

# Use it
./setup.sh --profile=~/my-current-setup.brewfile
```

---

## 🌐 Share Your Setup

### Option 1: GitHub Gist (Quick & Easy)

1. Create a Gist at <https://gist.github.com>
2. Upload your Brewfile
3. Get the "Raw" URL
4. Share: `./setup.sh --profile=YOUR_GIST_URL`

**Example:**

```bash
./setup.sh --profile=https://gist.githubusercontent.com/user/abc123/raw/my.brewfile
```

### Option 2: Dotfiles Repo (Recommended)

Most developers keep their configs in a "dotfiles" repository:

```bash
# 1. Create/use your dotfiles repo
mkdir ~/dotfiles
cd ~/dotfiles
git init

# 2. Add your Brewfile
cp ~/my-setup.brewfile Brewfile
git add Brewfile
git commit -m "Add Mac setup"
git push

# 3. Use on any Mac
./setup.sh --profile=https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/Brewfile
```

**Benefits:**

- ✅ Version control your entire setup
- ✅ Track changes over time
- ✅ Share with teammates
- ✅ Use across multiple Macs
- ✅ One-line setup on new machines

### Option 3: Team Setup

Keep a shared Brewfile for your team:

```bash
# In your company/team repo
company-devtools/
└── Brewfile    # Team-standard tools

# New team member onboarding = one command
./setup.sh --profile=https://raw.githubusercontent.com/company/devtools/main/Brewfile
```

---

## 💡 Tips & Best Practices

### 1. Start Small, Grow as Needed

```bash
# Day 1: Minimal
./setup.sh --profile=minimal

# Day 2-7: Add tools as you discover you need them
echo 'brew "ripgrep"' >> ~/my-setup.brewfile
./scripts/brew_bundle.sh ~/my-setup.brewfile
```

### 2. Document Your Choices

```ruby
# In your Brewfile, explain WHY you chose each tool
brew "neovim"     # My primary editor - faster than Vim
brew "ripgrep"    # Blazing fast search - replaced grep
cask "raycast"    # Spotlight replacement - saved me hours
```

### 3. Organize with Categories

```ruby
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🌐 Web Development
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
brew "node"
brew "yarn"
cask "docker-desktop"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🛠️  DevOps
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
brew "kubectl"
brew "terraform"
```

### 4. Keep Optional Tools Commented

```ruby
brew "git"
brew "neovim"

# Tools I'm evaluating
# brew "helix"        # Alternative editor
# cask "warp"         # Alternative terminal

# Tools for specific projects
# brew "postgresql"   # Uncomment when working on Rails
# brew "redis"        # Uncomment when working on Rails
```

### 5. Version Control Everything

```bash
# Track your setup evolution
git log --oneline -- Brewfile

# See what changed
git diff HEAD~5 Brewfile

# Rollback if needed
git checkout HEAD~1 -- Brewfile
```

---

## 📚 Brewfile Syntax Reference

```ruby
# Formulae (CLI tools)
brew "git"
brew "neovim"
brew "python@3.12"

# Casks (GUI applications)
cask "visual-studio-code"
cask "docker-desktop"
cask "google-chrome"

# Mac App Store apps (requires 'mas')
mas "Xcode", id: 497799835

# Taps (third-party repositories)
tap "homebrew/cask-fonts"
cask "font-fira-code-nerd-font"
```

**Find packages:**

- Search: `brew search <keyword>`
- Formulae: <https://formulae.brew.sh>
- Casks: `brew search --casks <name>`

---

## 🔄 Combine Multiple Profiles

Run MacGyver multiple times with different profiles:

```bash
# Base setup
./setup.sh --profile=minimal

# Add team tools
./scripts/brew_bundle.sh https://raw.githubusercontent.com/company/team-tools/main/Brewfile

# Add personal preferences
./scripts/brew_bundle.sh ~/my-personal-tools.brewfile
```

MacGyver's **hash-based caching** ensures tools are only installed once!

---

## 🎯 Example Workflows

### Workflow 1: "Fresh Mac"

```bash
# One-liner complete setup
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh
```

### Workflow 2: "Custom Setup"

```bash
# Clone MacGyver
git clone https://github.com/Sbastien/macgyver.git && cd macgyver

# Use your dotfiles
./setup.sh --profile=https://raw.githubusercontent.com/YOU/dotfiles/main/Brewfile
```

### Workflow 3: "Team Onboarding"

```bash
# New team member gets:
# 1. MacGyver for the framework
# 2. Team's standard tools
curl -fsSL https://raw.githubusercontent.com/Sbastien/macgyver/main/bootstrap.sh | sh
./setup.sh --profile=https://raw.githubusercontent.com/company/devtools/main/Brewfile
```

### Workflow 4: "Gradual Migration"

```bash
# Export current setup
brew bundle dump --file=~/current.brewfile

# Review and clean
vim ~/current.brewfile

# Start using MacGyver
git clone https://github.com/Sbastien/macgyver.git && cd macgyver
./setup.sh --profile=~/current.brewfile
```

---

## 🆘 Troubleshooting

### Profile not found?

```bash
# Check if file exists
ls -la ~/my-setup.brewfile

# Use absolute path
./setup.sh --profile=/Users/yourname/my-setup.brewfile
```

### Remote profile fails to download?

```bash
# Test URL manually
curl -fsSL YOUR_URL

# Check URL is "raw" format for GitHub
# ✅ Good: https://raw.githubusercontent.com/user/repo/main/Brewfile
# ❌ Bad:  https://github.com/user/repo/blob/main/Brewfile
```

### Want to preview before installing?

```bash
# View remote Brewfile
curl -fsSL URL | less

# Download for inspection
curl -fsSL URL > /tmp/preview.brewfile
cat /tmp/preview.brewfile
```

---

## 🤝 Contributing

Have a great tip or example? Submit a PR to improve this guide!

**Ideas we'd love:**

- Example Brewfiles for specific roles/technologies
- Tips for managing team setups
- Integration with other dotfile managers
- Your creative workflows!

---

## 📖 Learn More

- **Homebrew Bundle:** <https://github.com/Homebrew/homebrew-bundle>
- **Brewfile Format:** <https://github.com/Homebrew/homebrew-bundle#usage>
- **Package Search:** <https://formulae.brew.sh>
- **Dotfiles Guide:** <https://dotfiles.github.io>

---

**Philosophy:** MacGyver gives you the framework. You bring your tools. 🔧
