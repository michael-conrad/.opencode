#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: the pre-2425 default literal
# 'ollama/qwen3.8:27b-256k' is ABSENT from .opencode/AGENTS.md.
# Maps to SC-7 from issue #2425.
#
# RED phase (Phase 6, SC-7): assert the stale literal is absent from
# .opencode/AGENTS.md. At baseline the stale literal is present, so this
# assertion FAILS (RED). GREEN phase replaces the stale literal with the new
# model; this test then PASSES.
#
# .opencode/AGENTS.md is a regular tracked file in the .opencode repo (not
# the .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2376-sc7-red.sh
# Exit: 0 if the stale literal is absent from AGENTS.md, 1 otherwise

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
echo "=== AGENTS.md stale literal absence -- SC-7 (#2425) ==="
echo ""

DOC_FILE="$PROJECT_DIR/AGENTS.md"
STALE="qwen3.8:27b-256k"

# SC-7: The pre-2425 default literal is absent from .opencode/AGENTS.md.
# The stale literal appears in the bare form 'qwen3.8:27b-256k' (no
# 'ollama/' prefix). Match a standalone old-literal occurrence (not the
# '-gguf4' prefix of the new value). At baseline the stale literal is
# present, so this FAILS (RED).
if grep -qP 'qwen3\.8:27b-256k(?!-gguf4)' "$DOC_FILE" 2>/dev/null; then
    check_fail "SC-7: stale literal '$STALE' absent from AGENTS.md" \
        "stale literal was found in $DOC_FILE (GREEN not yet applied)"
else
    check_pass "SC-7: stale literal '$STALE' absent from AGENTS.md"
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
