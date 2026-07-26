# Brewfile Installer Demo
#
# Record with:
#   mise exec ttyd@latest vhs@latest -- vhs docs/demo.tape
#
# This runs the real installer against the published script. On a machine
# where everything is already installed `brew bundle` is a no-op and takes
# about a second, so the recording captures the whole run.
#
# The two optional steps at the end — `brew cleanup --prune=all` and
# `chezmoi init --apply` — are answered "n" rather than left hanging. An
# unattended recording is the wrong place to run either, and gum confirm
# takes y/n directly, so declining is explicit instead of relying on the
# capture ending in time.

Output demo.gif
Output demo.webm

Set Shell "bash"
Set FontSize 18
Set Width 900
Set Height 700
Set Theme "Catppuccin Mocha"
Set Padding 30
Set Framerate 60
Set PlaybackSpeed 1

Hide
Type "clear"
Enter
Sleep 500ms
Show

Type "bash <(curl -fsSL https://sbastien.github.io/Brewfile/install.sh)"
Sleep 500ms
Enter
Sleep 4s

# Confirm "Continue with installation?"
Enter
Sleep 8s

# Decline "Run 'brew cleanup'?"
Type "n"
Sleep 1500ms

# Decline "Configure your shell with dotfiles?"
Type "n"
Sleep 3s
