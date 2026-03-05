# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

## [0.1.9] - 2026-03-05

### Fixed
- `motd.sh` now exports variables defined in `~/.douz.io/motd_config.zsh` before module execution, so module scripts consistently read user configuration values.

### Changed
- Updated project and site screenshots to use `images/screen3.png`.
- Extended runtime test coverage to verify config-defined variables are visible inside child module scripts.

## [0.1.8] - 2026-03-04

### Changed
- Refined grouped iSMC temperature selection labels and filtering to avoid non-disk sensors being surfaced as disk temperatures.
- Kept per-sensor, per-row temperature output behavior for CPU, GPU, memory, and disk so color thresholds apply to each value independently.

### Added
- Added test fixtures for both Intel and Apple Silicon iSMC output paths in the temperature module test suite.

## [0.1.7] - 2026-03-04

### Changed
- Temperature modules now use grouped `iSMC` sensor selection for CPU, GPU, and memory instead of first-match parsing, with optional secondary values when available.
- Temperature outputs are normalized to Celsius with 2 decimal places, including disk temperature.
- Added `jq` as a required runtime dependency for JSON-based sensor parsing.

### Added
- Extended system information output to include grouped memory temperature telemetry.

## [0.1.6] - 2026-03-04

### Added
- Added a first-party `ismc` Homebrew formula template under `packaging/homebrew/ismc.rb` for publishing to `douz/homebrew-tap`.

### Changed
- Replaced `smctemp` usage with `iSMC` in temperature modules and module dependency checks.
- Updated Homebrew publishing workflow to sync both `mac-motd.rb` and `ismc.rb` to the tap from local templates.
- Updated install/upgrade documentation (including `motd.douz.io`) to use first-party tap dependencies only.

### Fixed
- Eliminated third-party tap dependency failures by removing `narugit/tap/smctemp` from the install/upgrade path.

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
