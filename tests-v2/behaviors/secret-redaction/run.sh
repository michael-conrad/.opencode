#!/bin/bash
# Run all secret-redaction behavioral test scripts (SC-5 through SC-8).
# Exits 0 only if all scripts produce artifacts successfully.
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OVERALL_RESULT=0

for script in "$SCRIPT_DIR"/SC-5.sh "$SCRIPT_DIR"/SC-6.sh "$SCRIPT_DIR"/SC-7.sh "$SCRIPT_DIR"/SC-8.sh; do
    echo "Running $(basename "$script")..."
    if bash "$script"; then
        echo "  PASS: $(basename "$script")"
    else
        echo "  FAIL: $(basename "$script")"
        OVERALL_RESULT=1
    fi
done

exit $OVERALL_RESULT
