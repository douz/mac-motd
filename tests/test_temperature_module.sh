#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
FAKE_BIN="$TEST_HOME/bin"
OUTPUT_FILE="$TEST_HOME/output.log"
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$FAKE_BIN"

cat > "$FAKE_BIN/smartctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

cat <<'OUT'
Temperature: 42 C
OUT
EOF

cat > "$FAKE_BIN/iSMC" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "temp" ]; then
  echo "unexpected command: $*" >&2
  exit 1
fi

cat <<'OUT'
CPU Package [TCAD] 55.2 C
GPU 1 [Tg05] 48.7 C
OUT
EOF

chmod +x "$FAKE_BIN/smartctl" "$FAKE_BIN/iSMC"

PATH="$FAKE_BIN:$PATH" zsh "$REPO_DIR/modules/temperature.sh" > "$OUTPUT_FILE"

grep -q 'Disk Temp\.:.*42' "$OUTPUT_FILE"
grep -q 'CPU Temp\.\.:.*55\.2°C' "$OUTPUT_FILE"
grep -q 'GPU Temp\.\.:.*48\.7°C' "$OUTPUT_FILE"

echo "test_temperature_module.sh: PASS"
