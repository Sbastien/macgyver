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
  <strong>50+ CLI tools · 15+ apps · 4 Nerd Fonts</strong>
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

## Quick Install

```bash
bash <(curl -fsSL https://sbastien.github.io/Brewfile/install.sh)
```

<details>
<summary>Direct install (without interactive prompts)</summary>
<br>

Requires [Homebrew](https://brew.sh) to be installed first.

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

## Next Step

This Brewfile installs the tools — my [dotfiles](https://github.com/Sbastien/dotfiles) configure them.

```bash
chezmoi init --apply Sbastien
```

## Use as Template

1. Click **Use this template** above (keep the repo name `Brewfile`)

2. Replace the username in your clone:

   ```bash
   sed -i '' "s/Sbastien/$YOUR_USERNAME/g" docs/index.html docs/install.sh
   ```

3. Edit `profiles/*.Brewfile` to add/remove packages, then run `mise run generate`

<br>

---

<p align="center">
  Made with 🍺 by <a href="https://github.com/Sbastien">Sbastien</a>
</p>
