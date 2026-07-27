#!/bin/bash
set -euo pipefail

# =============================================================================
# Brewfile installer
# https://github.com/Sbastien/Brewfile
#
# Bootstraps a fresh Mac: Homebrew if it is missing, then the package list.
#
# It orchestrates; it does not wrap. Homebrew, curl and chezmoi run in the
# foreground with their own output, their own prompts and their own exit codes.
# Nothing is redirected to a log, nothing hides behind a spinner, no `-q` is
# added. Every flag layered over someone else's tool is a guess about how that
# tool behaves, and the guess rots: a new warning or caveat upstream simply
# stops being shown.
#
# `#!/bin/bash` rather than `/usr/bin/env bash` on purpose. On a Mac that has
# never seen Homebrew, /bin/bash 3.2 is the only bash there is, so this script
# has to run under it — and pinning the shebang is what proves it still does.
# Nothing below uses a bash 4 feature.
# =============================================================================

readonly BREWFILE_URL="https://raw.githubusercontent.com/Sbastien/Brewfile/main/Brewfile"
readonly DOTFILES_REPO="Sbastien"

die() {
    printf '\n  ✗ %s\n\n' "$1" >&2
    exit 1
}

[[ "$(uname -s)" == "Darwin" ]] || die "This installer only supports macOS."

# Put brew on PATH when it is installed but this shell does not know it yet —
# which is the state right after Homebrew's installer finishes. Apple Silicon
# uses /opt/homebrew and Intel /usr/local; asking both is shorter and more
# honest than branching on `uname -m`.
activate_brew() {
    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [[ -x "$candidate" ]] || continue
        eval "$("$candidate" shellenv)"
        return 0
    done
    return 1
}

command -v brew &>/dev/null || activate_brew || {
    # Homebrew's own installer, unmodified. It lists the directories it will
    # create, asks for confirmation and requests sudo itself, with its own
    # explanation. NONINTERACTIVE=1 would suppress all of that, including any
    # warning a future version adds.
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ||
        die "Homebrew installation failed."

    activate_brew || die "Homebrew was installed but brew is not where it was expected."
}

# Download to a temporary file, install from it, delete it. There is no
# ~/.Brewfile: a second copy of the list has exactly one job, which is to fall
# quietly out of date with the repository that owns it.
brewfile=$(mktemp -t brewfile)
trap 'rm -f "$brewfile"' EXIT

curl -fsSL "$BREWFILE_URL" -o "$brewfile" || die "Failed to download $BREWFILE_URL"
[[ -s "$brewfile" ]] || die "The downloaded Brewfile is empty."

# `install` is the default subcommand, but brew bundle has a fistful of them
# and naming the one you mean costs nothing. It upgrades what is already there.
brew bundle install --file="$brewfile" || die "Some packages failed to install."

printf '\n  🍺 Your dev environment is ready.\n\n'

# Reads from /dev/tty rather than stdin: under `curl ... | bash`, stdin is the
# script itself. No terminal means no question — the packages are installed,
# which is the part that matters.
#
# Opening the device is the test. `[[ -r /dev/tty ]]` only reads permission
# bits, which are satisfied even with no controlling terminal, and the
# redirection then fails with "Device not configured" on the user's screen.
#
# The braces matter: redirections apply left to right, so a bare
# `exec 3</dev/tty 2>/dev/null` prints the failure before it silences it.
# `{ }` is not a subshell, so the descriptor outlives the group.
if { exec 3</dev/tty; } 2>/dev/null; then
    # printf rather than `read -p`, whose prompt goes to stderr — visible
    # here, but the first thing a caller redirecting stderr would lose.
    printf '  Configure your shell with dotfiles? [y/N] '

    reply=""
    read -r reply <&3 || true
    exec 3<&-

    if [[ "$reply" == [yY]* ]]; then
        # Foreground on purpose: chezmoi may prompt for template data, and a
        # backgrounded prompt is a deadlock nobody can see.
        chezmoi init --apply "$DOTFILES_REPO" || die "chezmoi failed to apply dotfiles."
    fi
fi
