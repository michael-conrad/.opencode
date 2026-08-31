#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: the DEFAULT_TEST_MODEL fallback literal in
# .opencode/tests-v2/default-model.sh equals 'ollama/qwen3.8:27b-256k-gguf4'.
# Maps to SC-1 from issue #2425.
#
# RED phase (Phase 1, SC-1): assert the fallback equals the NEW model. At
# baseline the stale literal 'ollama/qwen3.8:27b-256k' is still present, so
# this assertion FAILS (RED). GREEN phase replaces the fallback literal; this
# test then PASSES.
#
# default-model.sh is a regular tracked file in the .opencode repo (not the
# .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2376-sc1-red.sh
# Exit: 0 if the fallback equals the new model, 1 otherwise

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== default-model.sh DEFAULT_TEST_MODEL fallback -- SC-1 (#2425) ==="
echo ""

MODEL_FILE="$PROJECT_DIR/tests-v2/default-model.sh"
EXPECTED="ollama/qwen3.8:27b-256k-gguf4"

# SC-1: The DEFAULT_TEST_MODEL fallback literal equals the new model. At
# baseline it is the stale model, so this assertion FAILS (RED).
if grep -q "^DEFAULT_TEST_MODEL=\"\${DEFAULT_TEST_MODEL:-$EXPECTED}\"" "$MODEL_FILE" 2>/dev/null; then
    check_pass "SC-1: DEFAULT_TEST_MODEL fallback is $EXPECTED"
else
    check_fail "SC-1: DEFAULT_TEST_MODEL fallback is $EXPECTED" \
        "fallback literal is not $EXPECTED (GREEN not yet applied)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
