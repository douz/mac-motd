#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"

bash -lc "cd '$REPO_DIR' && ./install.sh"
bash -lc "cd '$REPO_DIR' && ./uninstall.sh"

[[ ! -d "$HOME/.local/share/douz-motd" ]]
[[ -f "$HOME/.douz.io/motd_config.zsh" ]]
[[ -f "$HOME/.zshrc" ]]
if grep -q 'douz-motd' "$HOME/.zshrc"; then
  echo "Expected zshrc hook to be removed"
  exit 1
fi

bash -lc "cd '$REPO_DIR' && ./install.sh"
bash -lc "cd '$REPO_DIR' && ./uninstall.sh --purge-config"

[[ ! -e "$HOME/.douz.io/motd_config.zsh" ]]

echo "test_uninstall.sh: PASS"
