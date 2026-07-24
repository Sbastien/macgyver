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
profiles/
  base.Brewfile          the baseline every machine gets
  work.Brewfile          service stack, company apps
  personal.Brewfile      media, browsers, non-work
  experimental.Brewfile  kept just in case; deletion candidates

Brewfile                 GENERATED from base. Do not edit.
bin/generate             profiles/ -> Brewfile
bin/validate             syntax, duplicates, conventions
bin/doctor               audits the machine against the profiles
bin/check-deprecated     upstream deprecation, one JSON query
mise.toml                pinned repo tooling + task definitions
```

## Commands

```bash
mise run generate     # rebuild the root Brewfile after editing a profile
mise run validate     # generation freshness + root Brewfile + every profile
mise run doctor       # audit this machine (read-only)
mise run lint         # shellcheck + shfmt
mise run fmt          # shfmt in place
mise run install      # base only
mise run install:work # base + work
```

`mise` is a task runner here as well as a version manager. The install tasks
shell out to `brew bundle`; mise never installs a Homebrew package.

Note the tooling in `mise.toml` is scoped to this directory. Outside it,
`shellcheck` and `shfmt` are not on `PATH` unless also installed globally.

## Conventions

**Never edit the root `Brewfile`.** It is generated. `bin/generate --check`
runs in CI and will fail the build. Edit a profile, then `mise run generate`.

**Every package carries a description** as a trailing comment, aligned at
column 29 where the name is short enough — the four Nerd Font casks are longer
than that and align among themselves instead:

```ruby
brew "ripgrep"              # grep replacement
```

`bin/validate` warns about a package with no description; alignment is not
enforced, only conventional.

**Every section carries an icon annotation** the website knows about:

```ruby
# Modern CLI Tools
# @icon:code
```

Valid names live in the `ICONS` table in `docs/index.html`: `apps` `code`
`cog` `database` `font` `git` `link` `puzzle` `rocket` `shield` `terminal`
`tools` `video` `wrench`. An unknown name renders nothing at all, silently, so
`bin/validate` checks it.

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

## Before committing

```bash
mise run lint && mise run validate
```

CI runs the same scripts, so a green local run means a green CI run. If you
touched a profile, `mise run generate` first or CI will reject the diff.

## Things that look like bugs but are not

- `bash`, `gnupg`, `sqlite` and `tmux` are declared but absent from
  `brew leaves`. They are installed — other packages depend on them.
- Homebrew's `python@3.14` is installed but not declared. It is keg-only and
  pulled in by seven packages; it is not a tool anyone chose.
- `brew bundle check` reports unmet dependencies but says nothing about tap
  trust. Only `brew bundle install` surfaces that.

## Known gaps

- `~/.config/mise/config.toml` is not managed by chezmoi, so global mise tools
  are declared nowhere version-controlled. This is why linters have not been
  moved out of the Brewfile wholesale — the destination is less tracked than
  the source. Fixing it belongs in the dotfiles repository.
- Claude Code is installed by Anthropic's native installer and declared
  nowhere. Deliberate: it self-updates, and pinning it would fight the updater.
