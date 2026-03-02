#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"

bash -lc "cd '$REPO_DIR' && ./install.sh"
bash -lc "cd '$REPO_DIR' && ./install.sh"

CONFIG_FILE="$HOME/.douz.io/motd_config.zsh"
ZSHRC_FILE="$HOME/.zshrc"
INSTALL_DIR="$HOME/.local/share/douz-motd"
BACKUP_GLOB="$HOME/.douz.io/motd_config.zsh.bak.*"

[[ -f "$CONFIG_FILE" ]]
[[ -f "$INSTALL_DIR/motd.sh" ]]
[[ -f "$ZSHRC_FILE" ]]

START_COUNT="$(grep -c '^# >>> douz-motd >>>$' "$ZSHRC_FILE")"
END_COUNT="$(grep -c '^# <<< douz-motd <<<$' "$ZSHRC_FILE")"

[[ "$START_COUNT" -eq 1 ]]
[[ "$END_COUNT" -eq 1 ]]

echo "# custom" >> "$CONFIG_FILE"
bash -lc "cd '$REPO_DIR' && ./install.sh"
grep -q '# custom' "$CONFIG_FILE"
if compgen -G "$BACKUP_GLOB" > /dev/null; then
  echo "Did not expect backup files during a normal install"
  exit 1
fi

bash -lc "cd '$REPO_DIR' && ./install.sh --refresh-config"
[[ -f "$CONFIG_FILE" ]]
BACKUP_FILE="$(compgen -G "$BACKUP_GLOB" | head -n 1)"
[[ -n "$BACKUP_FILE" ]]
grep -q '# custom' "$BACKUP_FILE"
if grep -q '# custom' "$CONFIG_FILE"; then
  echo "Expected refreshed config to restore template contents"
  exit 1
fi

echo "test_install.sh: PASS"
