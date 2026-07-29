#!/usr/bin/env bash
# SC-2: Timestamp appears after Git branch line, before "## CLI Auth Status"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

echo "SC-2: Verifying timestamp position in output" >&2

output=$(bash .opencode/tools/session-init 2>/dev/null || true)

# Check "Git branch:" appears before "Session started:"
branch_line=$(echo "$output" | grep -n "Git branch:" | head -1 | cut -d: -f1)
ts_line=$(echo "$output" | grep -n "Session started:" | head -1 | cut -d: -f1)
cli_line=$(echo "$output" | grep -n "## CLI Auth Status" | head -1 | cut -d: -f1)

if [ -z "$branch_line" ] || [ -z "$ts_line" ] || [ -z "$cli_line" ]; then
    echo "FAIL: Could not find required lines" >&2
    echo "branch_line=$branch_line ts_line=$ts_line cli_line=$cli_line" >&2
    exit 1
fi

if [ "$branch_line" -lt "$ts_line" ] && [ "$ts_line" -lt "$cli_line" ]; then
    echo "PASS: Timestamp appears after Git branch and before CLI Auth Status" >&2
else
    echo "FAIL: Timestamp position incorrect" >&2
    echo "branch_line=$branch_line ts_line=$ts_line cli_line=$cli_line" >&2
    exit 1
fi

echo "SC-2 PASS" >&2
