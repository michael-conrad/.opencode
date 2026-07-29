#!/usr/bin/env bash
# SC-6: Staleness warning emitted after timestamp
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

echo "SC-6: Verifying staleness warning after timestamp" >&2

output=$(bash .opencode/tools/session-init 2>/dev/null || true)

# Check for staleness warning line
if echo "$output" | grep -q "stale\|training data"; then
    echo "PASS: Staleness warning found in output" >&2
else
    echo "FAIL: No staleness warning found in output" >&2
    echo "This is expected to FAIL (RED phase) - feature not yet implemented" >&2
    exit 1
fi

# Check it appears after "Session started:"
ts_line=$(echo "$output" | grep -n "Session started:" | head -1 | cut -d: -f1)
stale_line=$(echo "$output" | grep -n "stale\|training data" | head -1 | cut -d: -f1)

if [ -n "$ts_line" ] && [ -n "$stale_line" ] && [ "$ts_line" -lt "$stale_line" ]; then
    echo "PASS: Staleness warning appears after timestamp" >&2
else
    echo "FAIL: Staleness warning position incorrect" >&2
    exit 1
fi

echo "SC-6 PASS" >&2
