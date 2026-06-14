#!/bin/bash
# Behavioral test: solve-state-merge
# SC-1159-1: solve state update must preserve multiple variables
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SOLVE_TOOL="$SCRIPT_DIR/../../tools/solve"
TEST_DIR=$(mktemp -p /tmp -d solve-test-XXXXX)
trap 'rm -rf "$TEST_DIR"' EXIT
"$SOLVE_TOOL" state init "$TEST_DIR"
"$SOLVE_TOOL" state update "$TEST_DIR" --var-name first_var --var-value alpha --var-name second_var --var-value beta

STATE=$("$SOLVE_TOOL" state status "$TEST_DIR")
echo "$STATE" | grep -q "first_var: alpha" || { echo "FAIL: first_var lost"; exit 1; }
echo "$STATE" | grep -q "second_var: beta" || { echo "FAIL: second_var lost"; exit 1; }
echo "PASS: both variables preserved"