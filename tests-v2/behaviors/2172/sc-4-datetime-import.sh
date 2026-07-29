#!/usr/bin/env bash
# SC-4: Generated at runtime via Python's datetime module
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

echo "SC-4: Verifying datetime import in session-init" >&2

if grep -q "from datetime import datetime" .opencode/tools/session-init; then
    echo "PASS: datetime import found in session-init" >&2
else
    echo "FAIL: datetime import not found in session-init" >&2
    exit 1
fi

echo "SC-4 PASS" >&2
