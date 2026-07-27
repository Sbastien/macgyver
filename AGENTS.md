# AGENTS.md

One macOS development environment, declared. Homebrew does the work.

**The regression test:** if a change makes this repository describe the machine
*less* accurately, it is a regression, however convenient it looks.

`Brewfile`, `install.sh` and `bin/doctor` explain themselves at the top. This
file carries only what they do not say.

## The one rule

**Homebrew and mise never manage the same tool** — two managers means two
copies on disk and one silently shadowing the other on `PATH`.

| Manager | Owns |
|---|---|
| **Homebrew** | anything needed before mise exists, GUI applications, launchd services, system libraries, daily-driver CLIs no project pins |
| **mise** | language runtimes, and any CLI whose exact version a project and its CI must agree on |

Before adding a tool, answer: **do I want to pin this version?** Yes, and a
project depends on it → mise. No → Homebrew. "Can mise install it?" is not the
question.

Two cases that look like exceptions and are not:

- **A tool that updates itself still goes in Homebrew.** `auto_updates true`
  makes `brew upgrade` skip it, so declaring it costs nothing and is the only
  thing that puts it on a fresh Mac.
- **Claude Code, the CLI, is declared nowhere.** `cask "claude-code"` exists
  but is not flagged `auto_updates` while Claude Code rewrites its own binary,
  so declaring it would put two updaters on one file. (`cask "claude"` is the
  desktop app, and is declared.)

## Two repositories

| Repository | Owns |
|---|---|
| **Brewfile** (this one) | what gets *installed* |
| **dotfiles** (chezmoi) | what gets *configured* — shell, git, `defaults write`, `~/.config` |

A package name belongs here. A file in `$HOME` belongs there.

## Traps

- **Removing a package takes two steps**: delete the line, then `brew
  uninstall`. Nothing here uninstalls anything.
- **A drift report is a question, not a failure.** Declare the thing or remove
  it by hand. Never `brew bundle cleanup --force`.
- **A third-party tap needs explicit trust**, scoped to one item — Homebrew 6
  otherwise aborts `brew bundle` on a fresh machine. Prefer having none.

  ```ruby
  cask "someone/tap/thing", trusted: true
  ```
- **No global `cask_args quarantine: false`.** It lets a cask that fails the
  Gatekeeper check install silently. One that needs it carries
  `args: { quarantine: false }` on its own line, with a reason.
- **Nothing tests `install.sh`.** Change it and run it by hand, with a stub for
  `brew bundle` and `chezmoi` on `PATH`.

Run `mise run ci` before committing; it is the task CI runs.

## Known gaps — deliberate, do not "fix"

- **Nothing runs `bin/doctor` on a schedule.** Drift accumulates on the days
  you forget. Automating it is the open question.
- **A renamed package is invisible.** CI resolves every declared name but
  cannot tell it is no longer the current one — a renamed cask keeps resolving
  while its alias lives.
- **`~/.config/mise/config.toml` is not managed by chezmoi**, so global mise
  tools are version-controlled nowhere. That is why the linters have not moved
  out of the Brewfile wholesale. It belongs in the dotfiles repository.
- **VS Code extensions are declared nowhere.** Settings Sync owns them.
