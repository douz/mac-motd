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

[[ -f "$CONFIG_FILE" ]]
[[ -f "$INSTALL_DIR/motd.sh" ]]
[[ -f "$ZSHRC_FILE" ]]

START_COUNT="$(grep -c '^# >>> douz-motd >>>$' "$ZSHRC_FILE")"
END_COUNT="$(grep -c '^# <<< douz-motd <<<$' "$ZSHRC_FILE")"

[[ "$START_COUNT" -eq 1 ]]
[[ "$END_COUNT" -eq 1 ]]

echo "test_install.sh: PASS"
