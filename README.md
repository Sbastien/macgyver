<h1 align="center">
  <br>
  🍺 Brewfile
  <br>
</h1>

<h4 align="center">My curated macOS dev environment in one command.</h4>

<p align="center">
  <a href="https://github.com/Sbastien/Brewfile/generate"><img src="https://img.shields.io/badge/Use%20this%20template-238636?style=for-the-badge&logo=github&logoColor=white" alt="Use this template"></a>
</p>

<p align="center">
  <a href="https://github.com/Sbastien/Brewfile/actions"><img src="https://img.shields.io/github/actions/workflow/status/Sbastien/Brewfile/lint.yml?style=for-the-badge&label=Lint" alt="Build"></a>
  <a href="https://github.com/Sbastien/Brewfile/commits"><img src="https://img.shields.io/github/last-commit/Sbastien/Brewfile?style=for-the-badge&color=81C784" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/Sbastien/Brewfile?style=for-the-badge&color=81D4FA" alt="License"></a>
</p>

<p align="center">
  <a href="https://www.apple.com/macos"><img src="https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="macOS"></a>
  <a href="https://brew.sh"><img src="https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black" alt="Homebrew"></a>
</p>

<p align="center">
  <!-- stats:start --><!-- written by bin/generate, do not edit -->
  <strong>62 CLI tools · 20 apps · 4 Nerd Fonts</strong>
  <!-- stats:end -->
</p>

<p align="center">
  <a href="https://sbastien.github.io/Brewfile">Website</a> •
  <a href="https://github.com/Sbastien/Brewfile/blob/main/Brewfile">View Brewfile</a> •
  <a href="https://github.com/Sbastien/dotfiles">Dotfiles</a>
</p>

<p align="center">
  <img src="docs/demo.gif" alt="Demo" width="600">
</p>

<br>

> **This is my machine, made public.** Not a framework, not a product. Fork it,
> read it, steal the parts you like — but expect it to change whenever my setup
> changes, and don't expect support. The interesting parts are probably
> `bin/doctor`, the [profile generation](#profiles), and the
> [Homebrew/mise boundary](#tools-managed-by-mise), not my package list.

## Install

```bash
git clone https://github.com/Sbastien/Brewfile && cd Brewfile
mise run install          # base
mise run install:work     # base + work
```

The clone is the real workflow: it is what gives you the profiles,
`mise run doctor`, and the rest of the tasks. See what would happen first
with `./docs/install.sh --dry-run`, which downloads and parses without
changing anything.

<details>
<summary>One-liner, for a quick look</summary>
<br>

```bash
bash <(curl -fsSL https://sbastien.github.io/Brewfile/install.sh)
```

Installs the `base` profile and leaves no repository behind, so no profiles
and no doctor. It also runs whatever `main` says right now — there are no
releases to pin to. Fine for a look, worse than the clone for real use.

Or without the installer, if Homebrew is already present:

```bash
curl -fsSL https://raw.githubusercontent.com/Sbastien/Brewfile/main/Brewfile | brew bundle --file=-
```

</details>

## Profiles

The root `Brewfile` is a build artifact generated from `profiles/base.Brewfile`.
Don't edit it — edit a profile and regenerate.

```bash
mise run generate           # rebuild the root Brewfile from profiles/
mise run install            # base only, what the one-line install gives you
mise run install:work       # base + work
mise run install:personal   # base + personal
```

| Profile | Contents |
|---|---|
| `base` | The baseline every machine gets. Generated into the root `Brewfile`. |
| `work` | Local service stack, company apps, CI clients. |
| `personal` | Media, browsers, everything unrelated to work. |
| `experimental` | Tried once, kept just in case. Candidates for deletion. |

`mise` is only a task runner here — those install tasks shell out to
`brew bundle`. It never installs a Homebrew package itself.

## Doctor

```bash
mise run doctor
```

Read-only. Answers whether this Mac is actually the machine the profiles
describe:

- packages installed but declared in no profile, and the reverse
- any tool claimed by both Homebrew and mise, with the versions and which
  one wins on `PATH`
- running Homebrew services, flagged if undeclared
- a root `Brewfile` that no longer matches `profiles/`
- packages Homebrew has deprecated or disabled

Exits non-zero on a real problem; drift is reported as a warning.

## Tools managed by mise

Homebrew and mise never manage the same tool. The split:

| | Owns |
|---|---|
| **Homebrew** | Anything needed before mise exists (git, curl, zsh, mise), GUI apps, launchd services, system libraries, daily-driver CLIs no project pins |
| **mise** | Language runtimes, and any CLI whose exact version changes its output — linters and formatters above all |

`shellcheck` and `shfmt` are the only CLIs moved out of the Brewfile so far.
This repo pins them in its own `mise.toml`, so having them in both places
meant two installed copies with Homebrew's winning on `PATH`.

Everything else stays with Homebrew for now, including linters a project
might want to pin. Two reasons:

- A mise tool is only on `PATH` once mise activates. Homebrew's `bin` is
  always there, including in scripts and non-interactive shells.
- The global mise config (`~/.config/mise/config.toml`) is **not
  version-controlled**. Moving a tool from this repo to there trades a
  tracked, CI-validated declaration for an untracked one — a net loss for a
  repository whose point is reproducibility.

Fixing the second reason (having chezmoi manage the global mise config) is
the prerequisite for moving anything else.

## Next Step

This Brewfile installs the tools — my [dotfiles](https://github.com/Sbastien/dotfiles) configure them.

```bash
chezmoi init --apply Sbastien
```

## Making it yours

The `work` and `personal` profiles are mine — my employer's service stack, my
music app. Nothing in them is meant to be a recommendation. `base`, `bin/` and
the CI are the reusable parts.

1. Fork it, or click **Use this template** (keep the repo name `Brewfile`)

2. Replace the username in your clone:

   ```bash
   YOUR_USERNAME=your-github-username

   # Prose uses the capitalised form, URLs use the lowercase one, and the
   # name appears in five files including LICENSE — so match both cases
   # everywhere rather than listing files by hand.
   grep -ril sbastien --exclude-dir=.git . | xargs sed -i '' \
     -e "s/Sbastien/$YOUR_USERNAME/g" \
     -e "s/sbastien/$(echo "$YOUR_USERNAME" | tr '[:upper:]' '[:lower:]')/g"
   ```

3. Edit `profiles/*.Brewfile` to add/remove packages, then run `mise run generate`

<br>

---

<p align="center">
  Made with 🍺 by <a href="https://github.com/Sbastien">Sbastien</a>
</p>
