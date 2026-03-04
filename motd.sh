#!/bin/zsh

# Resolve repository directories.
export baseDir="$(cd "$(dirname "$0")" && pwd)"
export modulesDir="${baseDir}/modules"
export fontsDir="${baseDir}/fonts"

# User-level config location.
configDir="${DOUZ_CONFIG_DIR:-$HOME/.douz.io}"
configFile="${DOUZ_MOTD_CONFIG:-$configDir/motd_config.zsh}"

# Defaults can be overridden by user config.
typeset -a modulesArray
modulesArray=(banner temperature hdd_usage battery calendar_events)

typeset -A moduleRequirements
moduleRequirements=(
  banner "figlet"
  battery "pmset"
  calendar_events "icalBuddy"
  hdd_usage "df"
  system_info "sw_vers sysctl system_profiler iSMC jq"
  temperature "smartctl iSMC jq"
  fastfetch "fastfetch"
)

resolve_root_disk() {
  local identifier
  identifier="$(diskutil info / 2>/dev/null | awk -F: '/Device Identifier/ { gsub(/[[:space:]]/, "", $2); print $2; exit }')"
  if [ -n "$identifier" ]; then
    echo "/dev/${identifier}"
  else
    echo "/dev/disk1s1"
  fi
}

missing_commands() {
  local cmd
  local -a missing
  missing=()
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done
  echo "${missing[*]}"
}

if [ -f "$configFile" ]; then
  # shellcheck disable=SC1090
  source "$configFile"
fi

export MOTD_DISK_DEVICE="${MOTD_DISK_DEVICE:-$(resolve_root_disk)}"

for module in "${modulesArray[@]}"; do
  modulePath="${modulesDir}/${module}.sh"
  if [ ! -f "$modulePath" ]; then
    echo "Warning: module ${module} not found at ${modulePath}"
    continue
  fi

  required="${moduleRequirements[$module]}"
  if [ -n "$required" ]; then
    missing="$(missing_commands ${=required})"
    if [ -n "$missing" ]; then
      echo "Warning: skipping module ${module}; missing dependencies: ${missing}"
      continue
    fi
  fi

  "$modulePath"
done
