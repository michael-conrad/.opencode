#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: the pre-2425 default literal
# 'ollama/qwen3.8:27b-256k' is ABSENT from the parent root AGENTS.md.
# Maps to SC-8 from issue #2425.
#
# RED phase (Phase 7, SC-8): assert the stale literal is absent from the
# parent root AGENTS.md. At baseline the stale literal is present, so this
# assertion FAILS (RED). GREEN phase replaces the stale literal with the new
# model; this test then PASSES.
#
# The parent root AGENTS.md is a regular tracked file in the parent repo
# (the parent of the .opencode submodule), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2376-sc8-red.sh
# Exit: 0 if the stale literal is absent from the parent root AGENTS.md, 1 otherwise

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

PARENT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== parent root AGENTS.md stale literal absence -- SC-8 (#2425) ==="
echo ""

DOC_FILE="$PARENT_DIR/AGENTS.md"
STALE="qwen3.8:27b-256k"

# SC-8: The pre-2425 default literal is absent from the parent root AGENTS.md.
# The parent root AGENTS.md references the model in the bare form
# 'qwen3.8:27b-256k' (no 'ollama/' prefix). Match a standalone old-literal
# occurrence (not the '-gguf4' prefix of the new value). At baseline the stale
# literal is present, so this FAILS (RED).
if grep -qP 'qwen3\.8:27b-256k(?!-gguf4)' "$DOC_FILE" 2>/dev/null; then
    check_fail "SC-8: stale literal '$STALE' absent from parent root AGENTS.md" \
        "stale literal was found in $DOC_FILE (GREEN not yet applied)"
else
    check_pass "SC-8: stale literal '$STALE' absent from parent root AGENTS.md"
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
