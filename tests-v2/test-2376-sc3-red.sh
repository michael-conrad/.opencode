#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: zero occurrences of the old default-model literal
# 'ollama/qwen3.6:35b-256k' across the five documentation files from issue
# #2376. Maps to SC-3.
#
# RED phase (Phase 3, SC-3): assert the OLD literal is ABSENT across all five
# documentation files. At baseline at least one stale reference remains, so
# this assertion FAILS (RED). GREEN phase replaces all stale literals with
# 'ollama/qwen3.8:27b-256k'; this test then PASSES.
#
# The five documentation files:
#   .opencode/AGENTS.md
#   .opencode/docs/model-dependency.md
#   .opencode/README.md
#   .opencode/tests-v2/AGENTS.md
#   AGENTS.md (parent repo root)
#
# All files are regular tracked files (the four submodule docs live in the
# .opencode repo, the root AGENTS.md lives in the parent repo), so they are
# read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2376-sc3-red.sh
# Exit: 0 if zero occurrences of the old literal across all five files,
#       1 otherwise

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
echo "=== documentation default-model references -- SC-3 (#2376) ==="
echo ""

# The old default-model literal appears in two forms across the five files:
# the fully-qualified 'ollama/qwen3.6:35b-256k' (model-dependency.md, README.md,
# tests-v2/AGENTS.md) and the bare 'qwen3.6:35b-256k' (opencode AGENTS.md and
# root AGENTS.md). GREEN updates the model reference in all five files, so the
# RED assertion detects the old model literal in either form via the shared
# 'qwen3.6:35b-256k' substring.
OLD_LITERAL="qwen3.6:35b-256k"

declare -A DOC_FILES=(
    ["opencode AGENTS.md"]="$PROJECT_DIR/AGENTS.md"
    ["opencode docs/model-dependency.md"]="$PROJECT_DIR/docs/model-dependency.md"
    ["opencode README.md"]="$PROJECT_DIR/README.md"
    ["opencode tests-v2/AGENTS.md"]="$PROJECT_DIR/tests-v2/AGENTS.md"
    ["root AGENTS.md"]="$PARENT_DIR/AGENTS.md"
)

for label in "${!DOC_FILES[@]}"; do
    path="${DOC_FILES[$label]}"
    if [ -f "$path" ] && grep -qF "$OLD_LITERAL" "$path" 2>/dev/null; then
        check_fail "$label: contains stale literal $OLD_LITERAL" \
            "stale default-model reference remains (GREEN not yet applied)"
    else
        check_pass "$label: no occurrence of $OLD_LITERAL"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
