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
the tasks. `brew bundle` rather than `mise run install`, because mise is one of
the things this file installs.

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

## Homebrew or mise?

Both can install the same Rust CLI. Doing so means two copies on disk and one
silently shadowing the other on `PATH`. So there is one rule: **they never
manage the same tool.** What decides it is a single question — *do I want to
pin this version?*

- **Yes**, and a project depends on it → mise
- **No**, I want it on every machine → Homebrew

Today only `shellcheck` and `shfmt` live in mise, because this repo pins them
in its own `mise.toml`. Everything else is Homebrew's, including the casks
that update themselves — declaring `google-chrome` is what puts it on a fresh
Mac, and Homebrew leaves it alone from then on.

The longer version, and the exceptions, are in
[AGENTS.md](AGENTS.md#the-one-rule).

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

The first two are Homebrew's own answers, printed as it gives them. The third
is the only part this repository has to compute, and it is the only one that
exits non-zero: drift is a decision waiting to be made, two managers owning
one tool is a bug.

## Keeping the list current

```bash
brew bundle add ripgrep     # or just edit the Brewfile
mise run doctor             # what drifted since last time
```

`brew bundle add` writes a description of its own, above the line, taken from
Homebrew's catalogue. Move it to the end of the line and rewrite it in your
own words.

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
package name it lives here; if it is a file in `$HOME` it lives there.

```bash
chezmoi init --apply Sbastien
```

<br>

---

<p align="center">
  Made with 🍺 by <a href="https://github.com/Sbastien">Sbastien</a>
</p>
