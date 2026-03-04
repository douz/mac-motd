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

if [ "${1:-}" != "temp" ] || [ "${2:-}" != "-o" ] || [ "${3:-}" != "json" ]; then
  echo "unexpected command: $*" >&2
  exit 1
fi

cat <<'OUT'
{
  "CPU Diode Filtered 1": {"key":"TC0F","quantity":55.2,"unit":"°C"},
  "CPU Core 2": {"key":"TC1C","quantity":53.0,"unit":"°C"},
  "GPU AMD Radeon": {"key":"TGDD","quantity":48.7,"unit":"°C"},
  "GPU Proximity 1": {"key":"TG0P","quantity":47.1,"unit":"°C"},
  "Memory Proximity": {"key":"Ts0S","quantity":41.3,"unit":"°C"},
  "Mem Bank A1": {"key":"TM0P","quantity":40.8,"unit":"°C"},
  "Drive 0 OOBv3 Absolute Raw B": {"key":"TH0b","quantity":39.9,"unit":"°C"}
}
OUT
EOF

chmod +x "$FAKE_BIN/smartctl" "$FAKE_BIN/iSMC"

PATH="$FAKE_BIN:$PATH" zsh "$REPO_DIR/modules/temperature.sh" > "$OUTPUT_FILE"

grep -q 'Disk Temp\.:.*42\.00°C (SMART).*39\.90°C' "$OUTPUT_FILE"
grep -q 'CPU Temp\.\.:.*55\.20°C.*53\.00°C' "$OUTPUT_FILE"
grep -q 'GPU Temp\.\.:.*48\.70°C.*47\.10°C' "$OUTPUT_FILE"
grep -q 'Mem Temp\.\.:.*41\.30°C.*40\.80°C' "$OUTPUT_FILE"

echo "test_temperature_module.sh: PASS"
