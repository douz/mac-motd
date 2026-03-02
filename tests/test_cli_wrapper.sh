#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
PREFIX_DIR="$TEST_HOME/prefix"
LIBEXEC_DIR="$PREFIX_DIR/libexec"
BIN_DIR="$PREFIX_DIR/bin"
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$LIBEXEC_DIR" "$BIN_DIR"
cp -R "$REPO_DIR"/. "$LIBEXEC_DIR/"
rm -rf "$LIBEXEC_DIR/.git"
ln -s "$LIBEXEC_DIR/bin/mac-motd" "$BIN_DIR/mac-motd"

HOME="$TEST_HOME/home" "$BIN_DIR/mac-motd" install

[[ -f "$TEST_HOME/home/.local/share/douz-motd/motd.sh" ]]
[[ -f "$TEST_HOME/home/.douz.io/motd_config.zsh" ]]

echo "test_cli_wrapper.sh: PASS"
