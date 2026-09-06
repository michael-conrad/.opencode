#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# String-evidence test (SC-2): the authoritative ordering-gate card
# .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
# documents the in-scope submodule set enumeration — the set is derived from
# changed submodule paths relative to the trunk base.
#
# Maps to SC-2 from issue #2431 (Phase 1, item 2). Evidence type: string
# (grep against the authoritative card).
#
# RED phase (Phase 1, item 2): at baseline the enumeration requirement does
# not exist in the card, so every assertion below FAILS and the test exits
# non-zero (RED). GREEN phase adds the enumeration language to the ordering
# gate; this test then PASSES.
#
# The enforcement-gate card is a regular tracked file in the .opencode repo
# (not the .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2431-sc2-red.sh
# Exit: 0 if the card documents in-scope-set enumeration language, 1 otherwise

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

CARD="$PROJECT_DIR/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md"

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

grep_card() {
    # grep_card <label> <pattern>
    local label="$1"
    local pattern="$2"
    if grep -qi -- "$pattern" "$CARD" 2>/dev/null; then
        check_pass "$label"
    else
        check_fail "$label" \
            "no match for pattern '$pattern' in enforcement-gate.md (GREEN not yet applied)"
    fi
}

echo ""
echo "=== in-scope submodule set enumeration in enforcement-gate.md -- SC-2 (#2431) ==="
echo ""

if [ ! -f "$CARD" ]; then
    echo "FATAL: enforcement-gate card not found at $CARD" >&2
    exit 2
fi

# SC-2: The ordering gate documents the in-scope submodule set enumeration.
# The set is derived from changed submodule paths relative to the trunk base.
# At baseline none of this language exists, so every assertion FAILS (RED).
grep_card "SC-2: card names the in-scope submodule set"        'in-scope'
grep_card "SC-2: card states the enumeration requirement"      'enumerat'
grep_card "SC-2: set derived from changed submodule paths"     'changed submodule path'
grep_card "SC-2: set anchored relative to the trunk base"      'trunk base'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0