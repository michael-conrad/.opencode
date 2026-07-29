#!/usr/bin/env bash
# SC-3: Natural English prose format with day, date, time, timezone
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

echo "SC-3: Verifying natural English prose format" >&2

output=$(bash .opencode/tools/session-init 2>/dev/null || true)
ts_line=$(echo "$output" | grep "Session started:" | head -1)

# Expected: "Session started: Wednesday, July 29, 2026 at 08:31 AM EDT"
# Pattern: day-of-week, month day, year at HH:MM AM/PM TZ
if echo "$ts_line" | grep -qP "Session started: [A-Z][a-z]+, [A-Z][a-z]+ \d+, \d{4} at \d{2}:\d{2} [AP]M [A-Z]{2,4}"; then
    echo "PASS: Timestamp uses natural English prose format" >&2
else
    echo "FAIL: Timestamp format not natural English prose" >&2
    echo "Line was: $ts_line" >&2
    exit 1
fi

echo "SC-3 PASS" >&2
