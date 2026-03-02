#!/bin/zsh
set -euo pipefail

repoDir="$(cd "$(dirname "$0")" && pwd)"
installDir="${HOME}/.local/share/douz-motd"
configDir="${HOME}/.douz.io"
configFile="${configDir}/motd_config.zsh"
zshrcFile="${HOME}/.zshrc"
startMarker="# >>> douz-motd >>>"
endMarker="# <<< douz-motd <<<"
refreshConfig=0
configStatus=""
backupFile=""

if [ "${1:-}" = "--refresh-config" ]; then
  refreshConfig=1
fi

mkdir -p "${installDir}" "${configDir}"

rsync -a --delete \
  --exclude '.git' \
  --exclude '.github' \
  --exclude 'images' \
  --exclude 'packaging' \
  "${repoDir}/" "${installDir}/"

if [ ! -f "${configFile}" ]; then
  cp "${repoDir}/config/motd_config.zsh" "${configFile}"
  configStatus="created"
elif [ "${refreshConfig}" -eq 1 ]; then
  backupFile="${configFile}.bak.$(date +%Y%m%d%H%M%S)"
  cp "${configFile}" "${backupFile}"
  cp "${repoDir}/config/motd_config.zsh" "${configFile}"
  configStatus="refreshed"
else
  configStatus="preserved"
fi

if [ ! -f "${zshrcFile}" ]; then
  touch "${zshrcFile}"
fi

if ! grep -Fq "${startMarker}" "${zshrcFile}"; then
  {
    echo ""
    echo "${startMarker}"
    echo "if [ -f \"${installDir}/motd.sh\" ]; then"
    echo "  \"${installDir}/motd.sh\""
    echo "fi"
    echo "${endMarker}"
  } >> "${zshrcFile}"
fi

echo "mac-motd installed."
echo "Config: ${configFile}"
if [ "${configStatus}" = "created" ]; then
  echo "Config status: created from template"
elif [ "${configStatus}" = "refreshed" ]; then
  echo "Config status: refreshed from template"
  echo "Backup: ${backupFile}"
else
  echo "Config status: preserved existing file"
fi
echo "Reopen terminal or run: source ~/.zshrc"
