#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
TEST_CONFIG="$TEST_HOME/test_config.zsh"
TEST_MODULE="$REPO_DIR/modules/test_probe.sh"
TEST_OUTPUT="$TEST_HOME/output.log"
PROBE_FILE="$TEST_HOME/probe.out"
trap 'rm -rf "$TEST_HOME"; rm -f "$TEST_MODULE"' EXIT

cat > "$TEST_CONFIG" <<'CFG'
modulesArray=(test_probe does_not_exist)
probeValue="from-config"
CFG

cat > "$TEST_MODULE" <<'MOD'
#!/bin/zsh
print -r -- "probe:ok"
print -r -- "probe:value=${probeValue:-missing}"
MOD
chmod +x "$TEST_MODULE"

HOME="$TEST_HOME" DOUZ_MOTD_CONFIG="$TEST_CONFIG" "$REPO_DIR/motd.sh" > "$TEST_OUTPUT" 2>&1 || {
  cat "$TEST_OUTPUT"
  exit 1
}

grep -q 'probe:ok' "$TEST_OUTPUT"
grep -q 'probe:value=from-config' "$TEST_OUTPUT"
grep -q 'Warning: module does_not_exist not found' "$TEST_OUTPUT"

echo "test_motd_runtime.sh: PASS"
