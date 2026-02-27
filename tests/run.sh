#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for test_file in "$SCRIPT_DIR"/test_*.sh; do
  echo "==> Running $(basename "$test_file")"
  "$test_file"
done

echo "All tests passed."
