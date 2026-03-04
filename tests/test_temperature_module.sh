#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
FAKE_BIN="$TEST_HOME/bin"
OUTPUT_INTEL="$TEST_HOME/output_intel.log"
OUTPUT_SILICON="$TEST_HOME/output_silicon.log"
INTEL_JSON="$TEST_HOME/intel.json"
SILICON_JSON="$TEST_HOME/silicon.json"
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$FAKE_BIN"

cat > "$INTEL_JSON" <<'EOF_INTEL'
{
  "CPU Diode Filtered 1": {"key":"TC0F","quantity":55.2,"unit":"°C"},
  "CPU Core 2": {"key":"TC1C","quantity":53.0,"unit":"°C"},
  "GPU AMD Radeon": {"key":"TGDD","quantity":48.7,"unit":"°C"},
  "GPU Proximity 1": {"key":"TG0P","quantity":47.1,"unit":"°C"},
  "Memory Proximity": {"key":"Ts0S","quantity":41.3,"unit":"°C"},
  "Mem Bank A1": {"key":"TM0P","quantity":40.8,"unit":"°C"},
  "Drive 0 OOBv3 Absolute Raw B": {"key":"TH0b","quantity":39.9,"unit":"°C"}
}
EOF_INTEL

cat > "$SILICON_JSON" <<'EOF_SILICON'
{
  "CPU Performance Core 1": {"key":"Tf04","quantity":64.6,"unit":"°C"},
  "CPU Performance Core 2": {"key":"Tf4E","quantity":71.2,"unit":"°C"},
  "CPU Efficiency Core 1": {"key":"Te05","quantity":52.1,"unit":"°C"},
  "GPU 1": {"key":"Tf14","quantity":60.5,"unit":"°C"},
  "GPU Proximity 1": {"key":"TG0P","quantity":58.4,"unit":"°C"},
  "Memory Proximity": {"key":"Ts0S","quantity":44.4,"unit":"°C"},
  "Memory 1": {"key":"Tm02","quantity":42.2,"unit":"°C"},
  "NAND": {"key":"TH0x","quantity":37.6,"unit":"°C"}
}
EOF_SILICON

cat > "$FAKE_BIN/smartctl" <<'EOF_SMARTCTL'
#!/usr/bin/env bash
set -euo pipefail

cat <<'OUT'
Temperature: 42 C
OUT
EOF_SMARTCTL

cat > "$FAKE_BIN/iSMC" <<'EOF_ISMC'
#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "temp" ] || [ "${2:-}" != "-o" ] || [ "${3:-}" != "json" ]; then
  echo "unexpected command: $*" >&2
  exit 1
fi

case "${TEST_ARCH:-intel}" in
  intel)
    cat "$INTEL_JSON_PATH"
    ;;
  silicon)
    cat "$SILICON_JSON_PATH"
    ;;
  *)
    echo "unknown TEST_ARCH=${TEST_ARCH:-}" >&2
    exit 1
    ;;
esac
EOF_ISMC

chmod +x "$FAKE_BIN/smartctl" "$FAKE_BIN/iSMC"

PATH="$FAKE_BIN:$PATH" INTEL_JSON_PATH="$INTEL_JSON" SILICON_JSON_PATH="$SILICON_JSON" TEST_ARCH="intel" zsh "$REPO_DIR/modules/temperature.sh" > "$OUTPUT_INTEL"

grep -q 'Disk Temp\.:.*42\.00°C (SMART).*39\.90°C' "$OUTPUT_INTEL"
grep -q 'CPU Temp\.\.:.*55\.20°C.*53\.00°C' "$OUTPUT_INTEL"
grep -q 'GPU Temp\.\.:.*48\.70°C.*47\.10°C' "$OUTPUT_INTEL"
grep -q 'Mem Temp\.\.:.*41\.30°C.*40\.80°C' "$OUTPUT_INTEL"

PATH="$FAKE_BIN:$PATH" INTEL_JSON_PATH="$INTEL_JSON" SILICON_JSON_PATH="$SILICON_JSON" TEST_ARCH="silicon" zsh "$REPO_DIR/modules/temperature.sh" > "$OUTPUT_SILICON"

grep -q 'Disk Temp\.:.*42\.00°C (SMART).*37\.60°C' "$OUTPUT_SILICON"
grep -q 'CPU Temp\.\.:.*71\.20°C' "$OUTPUT_SILICON"
grep -q 'GPU Temp\.\.:.*60\.50°C.*58\.40°C' "$OUTPUT_SILICON"
grep -q 'Mem Temp\.\.:.*44\.40°C.*42\.20°C' "$OUTPUT_SILICON"

echo "test_temperature_module.sh: PASS"
