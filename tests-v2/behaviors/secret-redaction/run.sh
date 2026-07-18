#!/bin/bash
# Run all behavioral test scripts for .opencode#1974 secret redaction plugin.
# Exits 0 only if all tests pass.
#
# Usage: bash .opencode/tests-v2/behaviors/secret-redaction/run.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OVERALL_RESULT=0

echo "=== Running SC-5: Pre-request redaction ==="
bash "$SCRIPT_DIR/SC-5.sh" || { echo "FAIL: SC-5"; OVERALL_RESULT=1; }

echo "=== Running SC-6: Pre-tool restoration ==="
bash "$SCRIPT_DIR/SC-6.sh" || { echo "FAIL: SC-6"; OVERALL_RESULT=1; }

echo "=== Running SC-7: Historical redaction ==="
bash "$SCRIPT_DIR/SC-7.sh" || { echo "FAIL: SC-7"; OVERALL_RESULT=1; }

echo "=== Running SC-8: Streaming edge case ==="
bash "$SCRIPT_DIR/SC-8.sh" || { echo "FAIL: SC-8"; OVERALL_RESULT=1; }

if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "=== All behavioral tests PASS ==="
else
  echo "=== Some behavioral tests FAILED ==="
fi

exit $OVERALL_RESULT
