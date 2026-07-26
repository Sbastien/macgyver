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
> `bin/doctor`, the [shared local/CI checks](#doctor), and the
> [Homebrew/mise boundary](#tools-managed-by-mise), not my package list.

## Install

```bash
git clone https://github.com/Sbastien/Brewfile && cd Brewfile
mise run install
```

The clone is the real workflow: it is what gives you `mise run doctor` and
the rest of the tasks. See what would happen first with
`./docs/install.sh --dry-run`, which downloads and parses without changing
anything.

<details>
<summary>One-liner, for a quick look</summary>
<br>

```bash
bash <(curl -fsSL https://sbastien.github.io/Brewfile/install.sh)
```

Installs the packages and leaves no repository behind, so no doctor and no
tasks. It also runs whatever `main` says right now — there are no
releases to pin to. Fine for a look, worse than the clone for real use.

Or without the installer, if Homebrew is already present:

```bash
curl -fsSL https://raw.githubusercontent.com/Sbastien/Brewfile/main/Brewfile | brew bundle --file=-
```

</details>

## One file

Everything lives in a single `Brewfile`, grouped into commented sections.

There used to be four profiles — `base`, `work`, `personal`, `experimental` —
with a generator that concatenated them. It was removed: this repository
serves one machine, that machine installs all of them, so the split cost a
generator, a committed build artifact, a CI freshness gate and three install
tasks to express a distinction nothing acted on. `personal` held two packages.

The `Experimental` section survives as a section, because its value was never
installation — it is a named place for "not sure I still need this", which
makes removal a decision rather than inertia.

## Doctor

```bash
mise run doctor
```

Read-only. Answers whether this Mac is actually the machine the Brewfile
describes:

- packages installed but declared in no profile, and the reverse
- any tool claimed by both Homebrew and mise, with the versions and which
  one wins on `PATH`
- running Homebrew services, flagged if undeclared
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

The package list is mine — my employer's service stack, my music app. Nothing
in it is meant to be a recommendation. `bin/` and the CI are the reusable
parts.

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

3. Edit the `Brewfile` to add or remove packages

<br>

---

<p align="center">
  Made with 🍺 by <a href="https://github.com/Sbastien">Sbastien</a>
</p>
