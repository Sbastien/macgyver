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

Default to none. A comment earns its place only when it explains why — and
that why isn't already in the code, the specs, or git history.

- **No "what"** — Restating a line, narrating steps ("first we…"), or logging
  history ("used to return nil"). If behavior needs documenting, write a spec;
  git covers what changed.
- **No empty "whys"** — Justifying with an always-true goal (consistency,
  readability, correctness) says nothing.
- **No session leaks** — "as discussed", rejected alternatives, anything
  written for a reader who was in the room.
- **Keep the real why** — A non-obvious choice's reason: external quirk (link
  the issue), timing/ordering constraint, magic number, actionable TODO/FIXME.

When unsure, delete — a missing comment is cheaper than a misleading one.

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
- **VS Code extensions are declared nowhere** — Settings Sync owns them.
- **`~/.config/mise/config.toml` is not managed by chezmoi**, so global mise
  tools are version-controlled nowhere. It belongs in the dotfiles repository.

Run `mise run ci` before committing; it is the task CI runs.
