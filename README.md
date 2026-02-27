# mac-motd

Modular MOTD for macOS + zsh, with user config in `~/.douz.io/motd_config.zsh`.

## What This Repo Provides

- `motd.sh`: runtime module loader.
- `modules/*.sh`: output modules.
- `install.sh`: idempotent installer (shell hook + user config).
- `uninstall.sh`: clean uninstaller (`--purge-config` supported).
- `bin/mac-motd`: command wrapper (`run`, `install`, `uninstall`, `doctor`).
- `packaging/homebrew/mac-motd.rb`: formula template for your tap.

## Installation

### Option 1: Homebrew Tap (recommended)

Use your tap (hosted in GitHub, documented under `brew.douz.io`):

```bash
brew tap douz/tap
brew install mac-motd
mac-motd install
```

### Option 2: Local/Source install

```bash
git clone git@github.com:douz/mac-motd.git
cd mac-motd
./install.sh
```

## User Config Location

The installer creates:

```bash
~/.douz.io/motd_config.zsh
```

Default content is sourced from `config/motd_config.zsh`.

Example:

```zsh
modulesArray=(
  banner
  temperature
  hdd_usage
  battery
  calendar_events
)

bannerText="Douz"
```

## Commands

```bash
mac-motd run
mac-motd install
mac-motd uninstall
mac-motd uninstall --purge-config
mac-motd doctor
```

## Uninstall

### Easy uninstall

```bash
mac-motd uninstall
```

This removes the shell hook and installed runtime files, but keeps your config.

### Full uninstall (including config)

```bash
mac-motd uninstall --purge-config
```

### If installed via Homebrew

```bash
brew uninstall mac-motd
```

Then optionally remove shell hook/config if still present:

```bash
mac-motd uninstall --purge-config
```

## Dependencies

The following tools are used by modules and should be installed when needed:

- `figlet`
- `ical-buddy`
- `osx-cpu-temp`
- `smartmontools`

Install with:

```bash
brew install figlet ical-buddy osx-cpu-temp smartmontools
```

The runtime skips modules whose dependencies are missing and prints a warning.

## Local Testing

Run the local test suite:

```bash
./tests/run.sh
```

What is covered:

- install idempotency (`install.sh` can run repeatedly without duplicate hooks)
- uninstall behavior (preserve vs purge config)
- runtime behavior for missing modules/dependencies

## CI

GitHub Actions workflow:

- `.github/workflows/ci.yml`

CI runs on PRs and `master` pushes:

- zsh syntax checks
- `shellcheck`
- `./tests/run.sh`
- Dependabot updates for GitHub Actions are configured in `.github/dependabot.yml`.

## Packaging and Sharing via `brew.douz.io`

Use `brew.douz.io` as your documentation/index domain for all future taps.

Recommended setup:

1. Create tap repo (for example `douz/homebrew-tap`).
2. Create repository secret `HOMEBREW_TAP_TOKEN` in `douz/mac-motd` with write access to `douz/homebrew-tap`.
3. Publish a tagged release in this repo (for example `v0.1.0`).
4. Let the publish workflow update tap formula automatically.
5. In DNS, point `brew.douz.io` to your Pages/docs host and publish install docs for all taps.

This pattern keeps one stable domain (`brew.douz.io`) for discovery while using GitHub tap repos for actual package distribution.

## Homebrew Tap Publish Action

Workflow:

- `.github/workflows/publish-homebrew-tap.yml`

Triggers:

- push tag `v*` (for example `v0.1.0`)
- manual `workflow_dispatch` with a tag input

What it does:

1. Downloads release tarball for the selected tag.
2. Calculates SHA256.
3. Checks out `douz/homebrew-tap`.
4. Generates/updates `Formula/mac-motd.rb`.
5. Commits and pushes the formula update.

Manual trigger example:

1. Open **Actions** -> **Publish Homebrew Tap Formula**.
2. Click **Run workflow**.
3. Enter tag like `v0.1.0`.

## Release Process

1. Update `CHANGELOG.md` under `[Unreleased]`.
2. Create and push a version tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

3. GitHub Actions will:
   - create a GitHub Release with generated notes (`.github/workflows/release.yml`)
   - update the Homebrew tap formula (`.github/workflows/publish-homebrew-tap.yml`)

## Project Ownership and Support

- Maintainer details: `MAINTAINERS.md`
- Community support expectations: `SUPPORT.md`
- Vulnerability reporting: `SECURITY.md`
- License: `LICENSE` (MIT)

## Module Development

Add new modules in `modules/<name>.sh`, then include them in `modulesArray` inside `~/.douz.io/motd_config.zsh`.

If a module requires commands, add its dependencies in `motd.sh` under `moduleRequirements`.

## Community and Governance

This repository includes:

- `LICENSE` (MIT)
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- GitHub issue templates and PR template under `.github/`

These files define contribution workflow, behavior standards, and private security reporting.
