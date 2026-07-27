# AGENTS.md

Working notes for this repository, for humans and for AI agents alike.

## What this repository is

A declarative description of a macOS development environment. It installs
nothing clever: Homebrew does the work, and everything here exists to make the
declaration accurate, reviewable and reproducible.

If a change makes the repository describe the machine *less* accurately, it is
a regression regardless of how convenient it looks.

## The one rule that matters

**Homebrew and mise never manage the same tool.**

| Manager | Owns |
|---|---|
| **Homebrew** | Anything needed before mise exists (git, curl, zsh, mise itself), GUI applications, launchd services, system libraries, and daily-driver CLIs no project pins |
| **mise** | Language runtimes, and any CLI whose exact version a project and its CI must agree on |

Two managers for one tool means two installed copies and one silently shadowing
the other on `PATH`. That was the state of `postgres`, `redis` and `shellcheck`
before this was written down.

Before adding a tool, answer: **do I want to pin this version?**

- Yes, and it depends on the project → mise
- No, I want the latest, and the tool updates itself → neither; let it
  self-update (Claude Code, Docker Desktop, browsers)
- No, but I want it on every machine → Homebrew

"Can mise install it?" is not the question. mise can install almost anything.

## Layout

```
Brewfile                 the whole environment, one file, commented sections
bin/doctor               audits the machine against the Brewfile
install.sh               the one-liner installer, for a machine with no clone
_config.yml              three lines; GitHub Pages renders README.md
mise.toml                pinned repo tooling + task definitions
```

There were four profiles and a generator once. Removed: one machine installed
all of them, so the split bought nothing and cost a build artifact, a CI
freshness gate and three install tasks. If a second machine ever needs a
different subset, that is the moment to bring it back — not before.

## Commands

```bash
mise run doctor       # audit this machine (read-only)
mise run lint         # shellcheck + shfmt
mise run fmt          # shfmt in place
mise run install      # brew bundle
```

`mise` is a task runner here as well as a version manager. `mise run install`
shells out to `brew bundle`; mise never installs a Homebrew package.

Note the tooling in `mise.toml` is scoped to this directory. Outside it,
`shellcheck` and `shfmt` are not on `PATH` unless also installed globally.

## Conventions

**Every package carries a description** as a trailing comment, aligned at
column 29 where the name is short enough — the four Nerd Font casks are longer
than that and align among themselves instead:

```ruby
brew "ripgrep"              # grep replacement
```

Nothing enforces this. Descriptions are for whoever reads the file, and the
only reader is a human — so a missing one is a gap in the prose, not a build
failure.

There used to be `@icon:` annotations here too, one per section, and a
`bin/validate` that checked them against a table in `docs/index.html`. They
existed for the website, and they went with it. The conventions that remain
are the ones a reader benefits from; a convention whose only consumer is a
program should live in the program.

**Experimental packages are marked in the section title**, not in a heading of
their own:

```ruby
# Misc (experimental)
```

A heading above the sections looked tidier, but it read as a title for
everything below it. The marker belongs on the section it describes.

**Third-party taps require explicit trust.** Homebrew 6 refuses to load
formulae and casks from non-official taps, which aborts `brew bundle` on a
fresh machine. Do not paper over it with `brew trust` inside a script — declare
it in the file, scoped to one item:

```ruby
cask "someone/tap/thing", trusted: true
```

Prefer having no third-party tap at all. There are currently none.

**No global Gatekeeper bypass.** `cask_args quarantine: false` was removed; it
is what let a cask that fails the Gatekeeper check install silently. A cask
that genuinely needs it carries `args: { quarantine: false }` on its own line,
with a comment saying why.

**The installer orchestrates, it does not wrap.** `install.sh` runs
Homebrew, curl and chezmoi in the foreground, with their output, their prompts
and their exit codes intact. No spinner over them, no redirection to a log, no
`-q`, no `NONINTERACTIVE=1`, and no clearing of the user's screen.

Every flag layered over another tool is a guess about how that tool behaves,
and the guess rots silently — a new warning or caveat upstream simply stops
being shown. Before adding one, ask what it hides on the day the tool changes.

The same reasoning retires steps. There is no `brew cleanup` prompt because
Homebrew already cleans up after every install, and fully every 30 days.

**The scripts are bash, and the two shebangs differ on purpose.** Not zsh:
shellcheck has no zsh dialect at all — `shellcheck -s zsh` answers `Unknown
shell: zsh` — so writing them in zsh would delete the only static analysis
they get, in exchange for nothing a non-interactive script uses. zsh is the
interactive shell here; bash is the scripting one.

`install.sh` carries `#!/bin/bash`, which is Apple's bash 3.2. It runs before
Homebrew exists, so 3.2 is the only bash it can count on, and pinning the
shebang is what keeps that true — `#!/usr/bin/env bash` on a dev machine finds
Homebrew's bash 5 and would hide an accidental `declare -A` or `mapfile`.
`bin/doctor` uses `#!/usr/bin/env bash`: it runs after the install, and has no
reason to be held to 3.2.

## Before committing

```bash
mise run lint && brew bundle list --all --file=Brewfile
```

That is exactly what CI runs, so a green local run means a green CI run.

**CI does not execute `install.sh`.** It is linted, not run. The `--dry-run`
mode that used to let CI exercise it end to end was a third of the script and
existed only to be tested. Change the installer and you test it by hand — a
stub for `brew bundle` and `chezmoi`, then run it. That is how the `/dev/tty`
bug in the rewrite was found.

## Things that look like bugs but are not

- `bash`, `gnupg`, `sqlite` and `tmux` are declared but absent from
  `brew leaves`. They are installed — other packages depend on them. This is
  why `bin/doctor` compares mise against `brew leaves` and not `brew list`.
- Homebrew's `python@3.14` is installed but not declared. It is keg-only and
  pulled in by seven packages; it is not a tool anyone chose.
- `brew bundle check` reports a declared package as "needs to be installed or
  updated" when it is installed at an older version. That is correct — `brew
  bundle install` would upgrade it — but it reads like it is missing.
- `brew bundle check` says nothing about tap trust. Only `brew bundle install`
  surfaces that.
- `brew bundle cleanup` exits 0 whether or not it finds anything, so its
  output has to be read rather than its status. Without `--force` it only
  reports; `bin/doctor` never passes `--force`.

## Known gaps

- `~/.config/mise/config.toml` is not managed by chezmoi, so global mise tools
  are declared nowhere version-controlled. This is why linters have not been
  moved out of the Brewfile wholesale — the destination is less tracked than
  the source. Fixing it belongs in the dotfiles repository.
- Claude Code is installed by Anthropic's native installer and declared
  nowhere. Deliberate: it self-updates, and pinning it would fight the updater.
