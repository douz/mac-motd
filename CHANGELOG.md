# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

## [0.1.4] - 2026-03-04

### Changed
- Replaced `osx-cpu-temp` with `smctemp` in temperature modules and dependency declarations.
- Documented manual/source install dependency requirements explicitly in the README.

### Fixed
- Temperature modules now handle missing/non-numeric SMC sensor output safely and show `N/A` when values are unavailable.
- `hdd_usage` output formatting now prints compact units (`369GB out of 465GB`).

## [0.1.3] - 2026-03-02

### Changed
- Documented the recommended Homebrew upgrade flow as `brew update`, `brew upgrade mac-motd`, and `mac-motd install`.

### Fixed
- `mac-motd install` now makes config preservation explicit and supports `--refresh-config`, which backs up the existing user config before replacing it with the latest template.

## [0.1.2] - 2026-03-02

### Fixed
- `hdd_usage` now reports the writable APFS data volume on macOS instead of the sealed system volume, which fixes incorrect usage totals like `16 GB out of 465 G` on split-volume systems.

## [0.1.1] - 2026-03-02

### Added
- Governance and community files (`CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`, issue/PR templates).
- Local test suite under `tests/`.
- CI workflow for linting and tests.
- Homebrew tap publishing workflow.
- Install/uninstall command wrappers and config template.

### Changed
- Runtime now supports user config at `~/.douz.io/motd_config.zsh`.
- Module loading now has dependency checks and safer execution behavior.
- Disk-related modules no longer rely on fixed disk identifiers.

### Fixed
- `mac-motd install` now resolves the real installed script path when invoked through the Homebrew symlink, so it runs the packaged `install.sh` instead of looking for `/usr/local/install.sh`.

## [0.1.0] - 2026-02-27

### Added
- Initial public release of `mac-motd`.
