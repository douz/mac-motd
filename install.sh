#!/bin/zsh
set -euo pipefail

repoDir="$(cd "$(dirname "$0")" && pwd)"
installDir="${HOME}/.local/share/douz-motd"
configDir="${HOME}/.douz.io"
configFile="${configDir}/motd_config.zsh"
zshrcFile="${HOME}/.zshrc"
startMarker="# >>> douz-motd >>>"
endMarker="# <<< douz-motd <<<"

mkdir -p "${installDir}" "${configDir}"

rsync -a --delete \
  --exclude '.git' \
  --exclude '.github' \
  --exclude 'images' \
  --exclude 'packaging' \
  "${repoDir}/" "${installDir}/"

if [ ! -f "${configFile}" ]; then
  cp "${repoDir}/config/motd_config.zsh" "${configFile}"
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
echo "Reopen terminal or run: source ~/.zshrc"
