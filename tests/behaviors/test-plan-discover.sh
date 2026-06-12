#!/usr/bin/env bash
# Behavioral test SC-10: plan discover exits 0 and prints engines to stdout
set -euo pipefail

TOOL="$(cd "$(dirname "$0")/../../" && pwd)/tools/plan"

echo "=== SC-10: plan discover exits 0 and prints to stdout ==="

stdout_file=$(mktemp)
stderr_file=$(mktemp)
set +e
"$TOOL" discover > "$stdout_file" 2>"$stderr_file"
rc=$?
set -euo pipefail

# Must exit 0
if [ "$rc" -ne 0 ]; then
    echo "FAIL: plan discover exit code $rc (expected 0)"
    exit 1
fi

# Must print at least one line to stdout
stdout_lines=$(wc -l < "$stdout_file")
if [ "$stdout_lines" -eq 0 ]; then
    echo "FAIL: stdout empty"
    exit 1
fi

echo "PASS: exit=$rc, stdout=$stdout_lines lines"
rm -f "$stdout_file" "$stderr_file"