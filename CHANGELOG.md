# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

### Added
- Governance and community files (`CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`, issue/PR templates).
- Local test suite under `tests/`.
- Install/uninstall command wrappers and config template.
- Module documentation under `modules/README.md`.

### Changed
- Runtime now supports user config at `~/.douz.io/motd_config.zsh`.
- Module loading now has dependency checks and safer execution behavior.
- Disk-related modules no longer rely on fixed disk identifiers.
- Documentation now uses `images/screen2.png` to show the MOTD output.

### Removed
- Dependabot configuration for GitHub Actions.
- CI workflow automation.
- Homebrew tap packaging and publishing automation.

## [0.1.0] - 2026-02-27

### Added
- Initial public release of `mac-motd`.
