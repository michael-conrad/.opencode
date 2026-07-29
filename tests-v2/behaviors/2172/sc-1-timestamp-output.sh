#!/usr/bin/env bash
# SC-1: session-init emits human-readable datetime
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

echo "SC-1: Verifying session-init emits human-readable datetime" >&2

# Run session-init and capture output
output=$(bash .opencode/tools/session-init 2>/dev/null || true)

# Check for "Session started:" pattern
if echo "$output" | grep -q "Session started:"; then
    echo "PASS: session-init emits 'Session started:' line" >&2
else
    echo "FAIL: session-init does not emit 'Session started:' line" >&2
    echo "Output was: $output" >&2
    exit 1
fi

# Check for day-of-week, month, day, year, time, timezone
if echo "$output" | grep -qP "Session started: \w+, \w+ \d+, \d{4} at \d{2}:\d{2} [AP]M \w+"; then
    echo "PASS: Timestamp format is human-readable (day, date, time, timezone)" >&2
else
    echo "FAIL: Timestamp format not human-readable" >&2
    echo "Output was: $output" >&2
    exit 1
fi

echo "SC-1 PASS" >&2
