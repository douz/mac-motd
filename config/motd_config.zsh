#!/bin/zsh

# User configuration for douz mac-motd.
# Copy this file to ~/.douz.io/motd_config.zsh and customize.

# Modules are loaded in the order listed below.
modulesArray=(
  banner
  temperature
  hdd_usage
  battery
  calendar_events
)

# Optional banner text override.
bannerText="Douz"

# Optional disk override for temperature module.
# Example: MOTD_DISK_DEVICE="/dev/disk3s1"
# MOTD_DISK_DEVICE=""
