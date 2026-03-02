# mac-motd

Modular MOTD for macOS + zsh, with user config in `~/.douz.io/motd_config.zsh`.

## How It Looks

![mac-motd screenshot](images/screen2.png)

## What This Repo Provides

- `motd.sh`: runtime module loader.
- `modules/*.sh`: output modules.
- `install.sh`: idempotent installer (shell hook + user config).
- `uninstall.sh`: clean uninstaller (`--purge-config` supported).
- `bin/mac-motd`: command wrapper (`run`, `install`, `uninstall`, `doctor`).

## Installation

Install from source:

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

## Release Process

1. Update `CHANGELOG.md` under `[Unreleased]`.
2. Create and push a version tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

3. GitHub Actions will create a GitHub Release with generated notes (`.github/workflows/release.yml`).

## Project Ownership and Support

- Maintainer details: `MAINTAINERS.md`
- Community support expectations: `SUPPORT.md`
- Vulnerability reporting: `SECURITY.md`
- License: `LICENSE` (MIT)

## Module Development

Add new modules in `modules/<name>.sh`, then include them in `modulesArray` inside `~/.douz.io/motd_config.zsh`.

If a module requires commands, add its dependencies in `motd.sh` under `moduleRequirements`.

Module descriptions and maintenance notes live in `modules/README.md`.

## Community and Governance

This repository includes:

- `LICENSE` (MIT)
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- GitHub issue templates and PR template under `.github/`

These files define contribution workflow, behavior standards, and private security reporting.
