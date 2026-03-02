#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
FAKE_BIN="$TEST_HOME/bin"
OUTPUT_FILE="$TEST_HOME/output.log"
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$FAKE_BIN"

cat > "$FAKE_BIN/df" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [ "$1" != "-g" ]; then
  echo "unexpected args: $*" >&2
  exit 1
fi

case "$2" in
  /System/Volumes/Data)
    cat <<'OUT'
Filesystem     1G-blocks Used Available Capacity iused ifree %iused Mounted on
/dev/disk1s2         465  363        79    83% 1000 1000    1% /System/Volumes/Data
OUT
    ;;
  /)
    cat <<'OUT'
Filesystem     1G-blocks Used Available Capacity iused ifree %iused Mounted on
/dev/disk1s1s1       465   16        79    18% 1000 1000    1% /
OUT
    ;;
  *)
    echo "unexpected mount: $2" >&2
    exit 1
    ;;
esac
EOF

chmod +x "$FAKE_BIN/df"

PATH="$FAKE_BIN:$PATH" zsh "$REPO_DIR/modules/hdd_usage.sh" > "$OUTPUT_FILE"

grep -q 'HDD Usage:.*363 GB out of 465 G' "$OUTPUT_FILE"

echo "test_hdd_usage.sh: PASS"
