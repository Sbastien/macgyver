# MacOS developer setup

A simple and reproducible setup script for configuring macOS for development. This repository combines:

- Essential development tools installation via Homebrew.
- Dotfiles management with [chezmoi](https://www.chezmoi.io/).
- macOS-specific system preferences and tweaks.

## Features

- 🚀 One-command setup: Quickly configure your macOS for development.
- 📦 Managed with Homebrew: Install tools like `git`, `zsh`, `chezmoi`, and more.
- ⚙️ Dotfiles integration: Automatically apply your configurations.

## Usage

Run the following command on a fresh macOS setup:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Sbastien/macos-dev-setup/main/bootstrap.sh)"
```
