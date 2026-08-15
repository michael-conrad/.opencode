#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: no stale cross-references (V-SC-7 checklist)
# Maps to SC-7 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL NOT contain
# cross-references to files that are not preloaded in agent context
# (opencode.jsonc instructions array, load_when fields in guideline frontmatter).
#
# The three V-SC-7 checks are absence checks: no cross-reference to
# session_context_triggers.py, no cross-reference to session-enforcement.ts,
# and no cross-reference to any non-preloaded file.
#
# RED phase: the guideline still cross-references session_context_triggers.py
# and session-enforcement.ts (source files that are not preloaded in agent
# context) — so this test FAILS.
# GREEN phase: after the stale cross-references are removed, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc7-no-stale-cross-references.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== No Stale Cross-References -- SC-7 (V-SC-7, #2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# V-SC-7 #1: no cross-reference to session_context_triggers.py.
if grep -q "session_context_triggers.py" "$GUIDELINE_FILE"; then
    check_fail "V-SC-7 #1: no cross-reference to session_context_triggers.py" "cross-reference to session_context_triggers.py still present in the guideline"
else
    check_pass "V-SC-7 #1: no cross-reference to session_context_triggers.py"
fi

# V-SC-7 #2: no cross-reference to session-enforcement.ts.
if grep -q "session-enforcement.ts" "$GUIDELINE_FILE"; then
    check_fail "V-SC-7 #2: no cross-reference to session-enforcement.ts" "cross-reference to session-enforcement.ts still present in the guideline"
else
    check_pass "V-SC-7 #2: no cross-reference to session-enforcement.ts"
fi

# V-SC-7 #3: any cross-reference to a file targets only files in the preloaded
# context. Preloaded files are the guideline .md files loaded via the
# opencode.jsonc instructions array or the load_when fields in guideline
# frontmatter. Source files (.py, .ts) are NOT preloaded — a cross-reference to
# any non-preloaded file is a stale reference.
if grep -qE "\.py|\.ts" "$GUIDELINE_FILE"; then
    check_fail "V-SC-7 #3: cross-references target only preloaded files" "cross-reference to a non-preloaded source file (.py/.ts) still present in the guideline"
else
    check_pass "V-SC-7 #3: cross-references target only preloaded files"
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
