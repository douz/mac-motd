# Modules

This directory contains the shell modules loaded by `motd.sh`.

## Included Modules

### `banner.sh`

Prints a random-color `figlet` banner using the text from the `bannerText` configuration variable and a random font from `fonts/`.

### `battery.sh`

Reads the internal battery percentage with `pmset` and renders a color-coded charge bar.

### `calendar_events.sh`

Uses `icalBuddy` to show calendar events for today and tomorrow.

### `hdd_usage.sh`

Reads disk usage information for the root volume and renders a usage bar.

### `system_info.sh`

Displays macOS version, hardware model, processor details, memory information, and CPU/GPU temperatures.

### `temperature.sh`

Uses `smartctl` and `osx-cpu-temp` to show disk, CPU, and GPU temperatures with warning colors.

## Adding Modules

1. Add a new script in `modules/`.
2. Add the module name to `modulesArray` in `~/.douz.io/motd_config.zsh`.
3. Document the module in this file.
