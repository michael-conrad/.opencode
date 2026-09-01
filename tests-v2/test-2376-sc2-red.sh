#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: the seed_model_config() fallback literal in
# .opencode/tests-v2/with-test-home equals 'ollama/qwen3.8:27b-256k-gguf4'.
# Maps to SC-2 from issue #2425.
#
# RED phase (Phase 2, SC-2): assert the seed_model_config fallback equals the
# NEW model. At baseline the stale literal 'ollama/qwen3.8:27b-256k' is still
# present in the seed fallback, so this assertion FAILS (RED). GREEN phase
# replaces the seed fallback literal; this test then PASSES.
#
# with-test-home is a regular tracked file in the .opencode repo (not the
# .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2376-sc2-red.sh
# Exit: 0 if the seed fallback equals the new model, 1 otherwise

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
echo "=== with-test-home seed_model_config fallback -- SC-2 (#2425) ==="
echo ""

HARNESS_FILE="$PROJECT_DIR/tests-v2/with-test-home"
EXPECTED="ollama/qwen3.8:27b-256k-gguf4"

# SC-2: The seed_model_config fallback literal equals the new model. At
# baseline it is the stale model, so this assertion FAILS (RED).
if grep -q 'DEFAULT_TEST_MODEL:-'"$EXPECTED" "$HARNESS_FILE" 2>/dev/null; then
    check_pass "SC-2: seed_model_config fallback is $EXPECTED"
else
    check_fail "SC-2: seed_model_config fallback is $EXPECTED" \
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
