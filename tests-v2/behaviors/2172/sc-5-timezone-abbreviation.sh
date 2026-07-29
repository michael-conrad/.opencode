#!/usr/bin/env bash
# SC-5: Local time with local timezone abbreviation (not bare UTC)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

echo "SC-5: Verifying timezone abbreviation (not bare UTC)" >&2

output=$(bash .opencode/tools/session-init 2>/dev/null || true)
ts_line=$(echo "$output" | grep "Session started:" | head -1)

# Extract timezone part (last word after AM/PM)
tz=$(echo "$ts_line" | grep -oP '[AP]M \K[A-Z]{2,4}$')

if [ -z "$tz" ]; then
    echo "FAIL: No timezone abbreviation found" >&2
    echo "Line was: $ts_line" >&2
    exit 1
fi

if [ "$tz" = "UTC" ]; then
    echo "FAIL: Timezone is bare UTC, expected local timezone abbreviation" >&2
    exit 1
fi

echo "PASS: Timezone abbreviation is '$tz' (not bare UTC)" >&2
echo "SC-5 PASS" >&2
