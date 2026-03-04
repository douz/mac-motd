# Modules

This directory contains the executable modules loaded by `motd.sh`. The default order is:

```zsh
banner
temperature
hdd_usage
battery
calendar_events
```

## Module Reference

### `banner.sh`

Prints a random-color `figlet` banner using the fonts in `fonts/`.

- Config: `bannerText` (default: `Douz`)
- Requires: `figlet`
- Notes: exits early with a warning if no `.flf` fonts are available

### `temperature.sh`

Prints disk, CPU, and GPU temperatures with threshold-based highlighting.

- Config: `MOTD_DISK_DEVICE` env var (falls back to the root disk detected by `motd.sh`)
- Requires: `smartctl`, `iSMC`
- Notes: `iSMC` is provided by the Homebrew `ismc` formula; disk temperature shows `N/A` if SMART output does not expose a numeric temperature

### `hdd_usage.sh`

Prints writable disk usage and a colorized usage bar.

- Requires: `df`
- Config: `DOUZ_HDD_MOUNT_POINT` env var to override the detected mount point
- Notes: prefers `/System/Volumes/Data` on APFS systems so the output reflects the writable data volume instead of the sealed system volume

### `battery.sh`

Prints current battery percentage and a charge bar for portable Macs.

- Requires: `pmset`
- Notes: exits cleanly on devices without an internal battery

### `calendar_events.sh`

Prints calendar events for today and tomorrow.

- Requires: `icalBuddy`
- Notes: includes title, attendees, and date/time details

### `system_info.sh`

Prints macOS version, hardware details, memory information, and CPU/GPU temperatures.

- Requires: `sw_vers`, `sysctl`, `system_profiler`, `iSMC`
- Notes: `iSMC` is provided by the Homebrew `ismc` formula; module is available in `moduleRequirements` but not enabled by default

## Adding or Changing Modules

When you change anything in this directory:

1. Keep the executable module script in `modules/<name>.sh`.
2. Register command dependencies in `motd.sh` under `moduleRequirements`.
3. Document the module here, including purpose, config knobs, and required commands.
4. Update root docs if the default module set or user configuration flow changes.
