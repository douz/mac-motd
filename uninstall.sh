#!/bin/zsh
set -euo pipefail

installDir="${HOME}/.local/share/douz-motd"
configDir="${HOME}/.douz.io"
configFile="${configDir}/motd_config.zsh"
zshrcFile="${HOME}/.zshrc"
startMarker="# >>> douz-motd >>>"
endMarker="# <<< douz-motd <<<"
purgeConfig=0

if [ "${1:-}" = "--purge-config" ]; then
  purgeConfig=1
fi

if [ -f "${zshrcFile}" ]; then
  awk -v start="${startMarker}" -v end="${endMarker}" '
    $0 == start {skip=1; next}
    $0 == end {skip=0; next}
    skip != 1 {print}
  ' "${zshrcFile}" > "${zshrcFile}.tmp"
  mv "${zshrcFile}.tmp" "${zshrcFile}"
fi

rm -rf "${installDir}"

if [ "${purgeConfig}" -eq 1 ]; then
  rm -f "${configFile}"
  rmdir "${configDir}" 2>/dev/null || true
fi

echo "mac-motd uninstalled."
if [ "${purgeConfig}" -eq 1 ]; then
  echo "Config removed: ${configFile}"
else
  echo "Config preserved: ${configFile}"
  echo "Run './uninstall.sh --purge-config' to remove it too."
fi
