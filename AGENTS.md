# AGENTS.md

A declarative description of one macOS development environment. Homebrew does
the work; everything here exists to keep the declaration accurate.

**The regression test:** if a change makes this repository describe the machine
*less* accurately, it is a regression, however convenient it looks.

## The one rule

**Homebrew and mise never manage the same tool.**

| Manager | Owns |
|---|---|
| **Homebrew** | anything needed before mise exists (git, curl, zsh, mise itself), GUI applications, launchd services, system libraries, daily-driver CLIs no project pins |
| **mise** | language runtimes, and any CLI whose exact version a project and its CI must agree on |

Two managers for one tool means two copies on disk and one silently shadowing
the other on `PATH`. That was the state of `postgres`, `redis` and `shellcheck`
before this was written down.

Before adding a tool, answer: **do I want to pin this version?**

- Yes, and a project depends on it → mise
- No, I want it on every machine → Homebrew

"Can mise install it?" is not the question. mise can install almost anything.

Two consequences that look like exceptions and are not:

- **A tool that updates itself still goes in Homebrew.** Homebrew flags these
  `auto_updates true` and skips them on `brew upgrade` unless you pass
  `--greedy`. Declaring one costs nothing and is the only thing that puts it on
  a fresh Mac.
- **Claude Code, the CLI, is declared nowhere.** `cask "claude-code"` exists,
  but is not flagged `auto_updates` while Claude Code rewrites its own binary —
  declaring it would put `brew upgrade` and the tool's own updater on one file.
  (`cask "claude"` is the desktop app, and is declared like everything else.)

## Two repositories, one machine

| Repository | Owns |
|---|---|
| **Brewfile** (this one) | what gets *installed*: formulae, casks, launchd services |
| **dotfiles** (chezmoi) | what gets *configured*: shell, git, editor config, `defaults write`, `~/.config` |

If it is a package name it belongs here. If it is a file in `$HOME` it belongs
there.

`chezmoi` is a Homebrew formula, so it cannot install itself: `install.sh` ends
by handing off to it, never the reverse. The dotfiles call `bin/doctor` by
absolute path, which is why that script finds the Brewfile next to itself
rather than in `$PWD`.

## Layout

```
Brewfile                 the whole environment, one file, commented sections
bin/doctor               audits the machine against the Brewfile
install.sh               the one-liner installer, for a machine with no clone
mise.toml                pinned repo tooling + task definitions
```

One file, no profiles. Split it only when a second machine actually needs a
different subset.

```bash
mise run doctor       # audit this machine (read-only)
mise run ci           # what CI runs: lint + check
mise run check        # parse the Brewfile, resolve every name upstream
mise run lint         # shellcheck + shfmt
mise run fmt          # shfmt in place
mise run install      # brew bundle
```

`mise` is a task runner here as well as a version manager. `mise run install`
shells out to `brew bundle`; mise never installs a Homebrew package. The
tooling in `mise.toml` is scoped to this directory — outside it, `shellcheck`
and `shfmt` are not on `PATH` unless also installed globally.

## Common tasks

**Add a package.** Answer the pin question above first. Then put the line in
the section it belongs to — not at the end of the file — and write the
description yourself. `brew bundle add` writes one from Homebrew's catalogue,
above the line; move it to the end of the line and say why *you* declared the
thing. Finish with `mise run check`.

**Add a server.** It goes in Local Services with `restart_service: :changed`,
which starts it on a fresh Mac and lets `brew bundle check` report it when it
dies. Declaring a server without the directive means a fresh Mac installs it
and never runs it.

**Remove a package.** Delete the line, then `brew uninstall` it by hand.
Nothing here uninstalls anything: `bin/doctor` is read-only and
`brew bundle cleanup` is never called with `--force`.

**Answer a drift report.** `bin/doctor` listing something under "installed but
not declared" is a question, not a failure — declare it or uninstall it. Do not
leave it: a report that always has noise in it stops being read.

## Editing the Brewfile

**Every package carries a description** as a trailing comment, aligned at
column 29 where the name is short enough. The four Nerd Font casks and the
three service lines are longer than that and align among themselves instead:

```ruby
brew "ripgrep"              # grep replacement
```

Nothing enforces this. The only reader is a human, so a missing description is
a gap in the prose, not a build failure — and a convention whose only consumer
would be a program should live in the program, not here.

**Experimental packages are marked in the section title**, not in a heading of
their own — a heading reads as a title for everything below it:

```ruby
# Misc (experimental)
```

The marker means: kept just in case, or tried once and never removed. Anything
carrying it is a candidate for deletion at the next review.

**Third-party taps require explicit trust.** Homebrew 6 refuses to load
formulae and casks from non-official taps, which aborts `brew bundle` on a
fresh machine. Do not paper over it with `brew trust` inside a script — declare
it in the file, scoped to one item:

```ruby
cask "someone/tap/thing", trusted: true
```

Prefer having no third-party tap at all.

**No global Gatekeeper bypass.** A global `cask_args quarantine: false` lets a
cask that fails the Gatekeeper check install silently. A cask that genuinely
needs it carries `args: { quarantine: false }` on its own line, with a comment
saying why.

## Editing the scripts

**They are bash, not zsh.** shellcheck has no zsh dialect — `shellcheck -s zsh`
answers `Unknown shell: zsh` — so writing them in zsh would delete the only
static analysis they get, in exchange for nothing a non-interactive script
uses. zsh is the interactive shell here; bash is the scripting one.

**The two shebangs differ on purpose.** `install.sh` carries `#!/bin/bash`,
Apple's bash 3.2: it runs before Homebrew exists, so 3.2 is the only bash it
can count on, and pinning the shebang is what keeps an accidental `declare -A`
or `mapfile` from slipping through on a dev machine. `bin/doctor` uses
`#!/usr/bin/env bash` — it runs after the install.

**`install.sh` orchestrates, it does not wrap.** Homebrew, curl and chezmoi run
in the foreground with their output, their prompts and their exit codes intact.
No spinner over them, no redirection to a log, no `-q`, no `NONINTERACTIVE=1`,
no clearing of the user's screen.

Every flag layered over another tool is a guess about how that tool behaves,
and the guess rots silently — a new warning or caveat upstream simply stops
being shown. Before adding one, ask what it hides on the day the tool changes.

## Before committing

```bash
mise run ci
```

`ci.yml` runs the same task, so a green local run means a green CI run.

**CI does not execute `install.sh`.** It is linted, not run. Change the
installer and you test it by hand: a stub for `brew bundle` and `chezmoi` on
`PATH`, then run it. Nothing else exercises its control flow.

## Gotchas

- `bash`, `gnupg`, `sqlite` and `tmux` are declared but absent from
  `brew leaves` — other packages depend on them. This is why `bin/doctor`
  compares mise against `brew leaves` and not `brew list`.
- `python@3.14` is installed, not declared, and not an overlap with mise's
  python. Seven declared packages depend on it, so it cannot be un-chosen.
- `brew bundle cleanup` exits 0 whether or not it finds anything, so read its
  output rather than its status — and read the *verbs*: it also lists cache
  files, which have nothing to do with drift.
- `brew bundle check` says nothing about tap trust. Only `brew bundle install`
  surfaces that.
- `bin/doctor` passes `--no-upgrade` to `brew bundle check`. Without it, a
  package one bottle behind reads as missing.

## Known gaps

- **Nothing runs `bin/doctor` on a schedule.** It is a command you have to
  remember, and drift accumulates on the days you do not. Automating it — a
  cron, a chezmoi `run_onchange`, a monthly shell check — is the open question.
- **A renamed package is invisible.** CI resolves every declared name, but
  cannot tell that a name is no longer the current one: a renamed cask
  (`docker` became `docker-desktop`) keeps resolving for as long as the alias
  lives.
- **`~/.config/mise/config.toml` is not managed by chezmoi**, so global mise
  tools are declared nowhere version-controlled. This is why linters have not
  been moved out of the Brewfile wholesale — the destination is less tracked
  than the source. Fixing it belongs in the dotfiles repository.
- **VS Code extensions are declared nowhere.** Settings Sync owns them; a
  second declaration here would be the two-managers problem again. Signing into
  the account is the one manual step on a fresh Mac.
