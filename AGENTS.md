# AGENTS.md

One macOS development environment, declared. Homebrew does the work. A package
name belongs here; a file in `$HOME` belongs in the
[dotfiles](https://github.com/Sbastien/dotfiles) repository. `Brewfile`,
`install.sh`, `bin/doctor` and `mise.toml` explain themselves at the top — this
file carries only what they cannot.

**The regression test:** if a change makes this repository describe the machine
*less* accurately, it is a regression, however convenient it looks.

## The one rule

**Homebrew and mise never manage the same tool** — two managers means two
copies on disk and one silently shadowing the other on `PATH`. One question
decides it: **do I want to pin this version?** Yes, and a project depends on it
→ mise. No → Homebrew. "Can mise install it?" is not the question.

- **A tool that updates itself still goes in Homebrew.** `auto_updates true`
  makes `brew upgrade` skip it, so declaring it costs nothing and is the only
  thing that puts it on a fresh Mac.
- **Claude Code, the CLI, is declared nowhere.** `cask "claude-code"` is not
  flagged `auto_updates` while Claude Code rewrites its own binary, so
  declaring it would put two updaters on one file. (`cask "claude"` is the
  desktop app, and is declared.)

## Comments

Every declaration in the Brewfile carries a description — that is the file.
Prose comments are for why, and only when that why isn't already in the code
or in another file's header.

- **No "what"** — restating a line, narrating steps.
- **No empty "whys"** — consistency, readability, "costs nothing" say nothing.
- **No second home** — if the Brewfile header or this file already carries the
  rule, do not restate it.
- **No counts in prose** — they only wait to go stale.
- **Keep the real why** — an external quirk, an ordering constraint, or an
  alternative that does not work.

When unsure, keep it: nothing here is tested, so a comment is the only warning
a future editor gets.

## Traps

- **Removing a package takes two steps**: delete the line, then `brew
  uninstall`. Nothing here uninstalls anything.
- **Never `brew bundle cleanup --force`.** A drift report is a question, not a
  failure: declare the thing, or remove it by hand.
- **A third-party tap needs explicit trust**, scoped to one item — `cask
  "someone/tap/thing", trusted: true`. Homebrew 6 otherwise aborts `brew
  bundle` on a fresh machine. Prefer having none.
- **No global `cask_args quarantine: false`.** It lets a cask that fails the
  Gatekeeper check install silently. One that needs it carries
  `args: { quarantine: false }` on its own line, with a reason.
- **Nothing tests `install.sh`.** Change it and run it by hand, with a stub for
  `brew bundle` and `chezmoi` on `PATH`.
- **Squash-merge is disabled on the repository.** GitHub composes the squash
  subject from the pull request title, which would let the merge button rather
  than the author decide whether a commit message is conventional. Rebase, or
  merge and write the subject by hand.
- **VS Code extensions are declared nowhere** — Settings Sync owns them.
- **`~/.config/mise/config.toml` is not managed by chezmoi**, so global mise
  tools are version-controlled nowhere. It belongs in the dotfiles repository.

Run `mise run ci` before committing; it is the task CI runs.
