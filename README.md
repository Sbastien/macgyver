<h1 align="center">
  <br>
  🍺 Brewfile
  <br>
</h1>

<h4 align="center">My macOS dev environment, in one file.</h4>

<p align="center">
  <a href="https://github.com/Sbastien/Brewfile/generate"><img src="https://img.shields.io/badge/Use%20this%20template-238636?style=for-the-badge&logo=github&logoColor=white" alt="Use this template"></a>
</p>

<p align="center">
  <a href="https://github.com/Sbastien/Brewfile/actions"><img src="https://img.shields.io/github/actions/workflow/status/Sbastien/Brewfile/ci.yml?style=for-the-badge&label=CI" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Sbastien/Brewfile?style=for-the-badge&color=81D4FA" alt="License"></a>
</p>

<p align="center">
  <a href="https://github.com/Sbastien/Brewfile/blob/main/Brewfile">The Brewfile</a> •
  <a href="https://github.com/Sbastien/dotfiles">Dotfiles</a>
</p>

<br>

> **This is my machine, made public.** Not a framework, not a product. Fork it,
> read it, take the parts you like — but expect it to change whenever my setup
> changes, and don't expect support.

## Install

```bash
git clone https://github.com/Sbastien/Brewfile && cd Brewfile
brew bundle
```

Clone rather than curl: it is what gives you `mise run doctor` and the rest of
the tasks. And `brew bundle` rather than `mise run install`, because mise is
one of the things this file is about to install.

<details>
<summary>One-liner, for a fresh Mac with no clone</summary>
<br>

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sbastien/Brewfile/main/install.sh)
```

Installs Homebrew if it is missing, then the packages, then offers the
dotfiles. It leaves no repository behind, so no doctor and no tasks, and it
runs whatever `main` says right now — there are no releases to pin to.

The script exists for one reason: Homebrew has no `chezmoi init`. `brew
bundle --file` takes a local path only — point it at a URL and it answers
`No Brewfile found` — so nothing native can bootstrap a Mac that has no brew
yet. Once Homebrew is there, it can:

```bash
curl -fsSL https://raw.githubusercontent.com/Sbastien/Brewfile/main/Brewfile | brew bundle --file=-
```

</details>

## What's in here

`Brewfile` is the environment: every package in one file, grouped into
commented sections, one description each. Around it, two scripts and the
config to lint them.

| | |
|---|---|
| `install.sh` | bootstraps a fresh Mac — Homebrew, then the packages |
| `bin/doctor` | audits this Mac against the Brewfile — read-only |
| `mise.toml` | pinned linters and the task definitions |
| `.github/` | one CI job, and dependabot for the action pins |

There is no profile system. There was one — four files and a generator — and
it went away, because one machine installed all four.

There is no website either. There was one, a thousand lines that fetched the
Brewfile over HTTP and re-rendered it, and it is why the Brewfile used to
carry `@icon:` annotations and why a validator existed to check them. GitHub
renders this README on the repository page already; a second copy of it on
Pages only added a duplicated title.

## Homebrew or mise?

Both can install the same Rust CLI. Doing so means two copies on disk and one
silently shadowing the other on `PATH`, which is what had happened here to
`postgres`, `redis` and `shellcheck`.

So there is one rule: **they never manage the same tool.** What decides it is
a single question — *do I want to pin this version?*

- **Yes**, and a project depends on it → mise
- **No**, I want it on every machine → Homebrew

That second branch covers apps that update themselves, which is most of the
casks here. Declaring `google-chrome` or `docker-desktop` is what puts them on
a fresh Mac; Homebrew marks them `auto_updates true` and then leaves them
alone on `brew upgrade`, so the declaration never fights the app's own
updater. Leaving them out would only mean a new machine never gets them.

Nothing is declared nowhere unless Homebrew has no formula or cask for it at
all — Claude Code, the CLI, which Anthropic's own installer puts in
`~/.local/bin`. (The `claude` cask in the Brewfile is the desktop app, a
different thing.)

Today only `shellcheck` and `shfmt` live in mise, because this repo pins them
in its own `mise.toml`. Everything else stays with Homebrew, for two reasons:
a mise tool is only on `PATH` once mise has activated, and
`~/.config/mise/config.toml` is not version-controlled yet — moving a tool
there would trade a tracked declaration for an untracked one.

## Doctor

```bash
mise run doctor
```

Read-only. It answers one question: is this Mac still the machine the Brewfile
describes?

- declared but not installed, via `brew bundle check` — including a declared
  service that is not running
- installed but not declared, via `brew bundle cleanup` — formulae, casks and
  third-party taps in one pass
- any tool claimed by both Homebrew and mise, with versions and which one wins

The first two are Homebrew's own answers, printed as it gives them: a diff in
opposite directions, never applied here — `brew bundle install` applies one,
`brew bundle cleanup --force` the other.

The third is the only part this repository computes, and the only one that
exits non-zero: drift is a decision waiting to be made, two managers owning
one tool is a bug. It is also not a diff. Nothing in the Brewfile mentions
mise, so a file that matches the machine perfectly can still fail it.

## Keeping the list current

```bash
brew bundle add ripgrep     # or just edit the Brewfile
mise run doctor             # what drifted since last time
```

`brew bundle add` now writes a description of its own, above the line, taken
from Homebrew's catalogue. Move it to the end of the line and rewrite it to
say why *you* declared the thing — a bare catalogue blurb is not something
anyone rereads.

## The installer does not hide Homebrew

`install.sh` orchestrates; it does not wrap. Homebrew, curl and chezmoi
run in the foreground with their own output, their own prompts and their own
exit codes — no spinner over them, no log file they get redirected into, no
`-q` added on their behalf.

Every flag layered over someone else's tool is a guess about how that tool
behaves, and the guess rots quietly. The day Homebrew adds a warning, a prompt
or a caveat worth reading, you want to see it.

## Make it yours

The package list is mine — my employer's stack, my music app. Nothing in it is
a recommendation. The two scripts and the CI are the reusable parts.

1. Fork it, or click **Use this template** (keep the repository name `Brewfile`)

2. Replace the username in your clone:

   ```bash
   YOUR_USERNAME=your-github-username

   # Prose uses the capitalised form and URLs the lowercase one, and the name
   # appears in three files including LICENSE — so match both cases everywhere
   # rather than listing files by hand.
   grep -ril sbastien --exclude-dir=.git . | xargs sed -i '' \
     -e "s/Sbastien/$YOUR_USERNAME/g" \
     -e "s/sbastien/$(echo "$YOUR_USERNAME" | tr '[:upper:]' '[:lower:]')/g"
   ```

3. Edit the `Brewfile`, then `mise run doctor`

## Then: dotfiles

This repository installs the tools. My
[dotfiles](https://github.com/Sbastien/dotfiles) configure them. If it is a
package name it lives here; if it is a file in `$HOME` it lives there — which
is why there is not a single `defaults write` in this repository.

`chezmoi` is a Homebrew formula, so it cannot install itself. This repository
bootstraps the other one, never the reverse.

```bash
chezmoi init --apply Sbastien
```

<br>

---

<p align="center">
  Made with 🍺 by <a href="https://github.com/Sbastien">Sbastien</a>
</p>
