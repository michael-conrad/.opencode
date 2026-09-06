#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# String-evidence test (SC-4): the authoritative ordering-gate card
# .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
# carries the bounded-retry parameters (up to 3 probes at 60-second
# intervals) and the inconclusive-block handling — block with a clear
# reason reported in chat naming the inconclusive submodule and its PR.
#
# Maps to SC-4 from issue #2431 (Phase 1, item 4). Evidence type: string
# (grep against the authoritative card).
#
# RED phase (Phase 1, item 4): at baseline the card's Merge-State Blocking
# Condition verifies merge state via a live platform API call (SC-3
# language, already GREEN) but states no bounded-retry parameters and no
# inconclusive-block handling, so every assertion below FAILS and the test
# exits non-zero (RED). GREEN phase adds the bounded retry/report path
# language to the ordering gate; this test then PASSES.
#
# The enforcement-gate card is a regular tracked file in the .opencode repo
# (not the .issues/ worktree), so it is read directly with grep.
#
# Note: the only pre-existing "retry" text in the card is "Wait and retry"
# in the Step 1.5d merge-conflict mergeability check, which is NOT the
# SC-4 bounded-retry language (no probe count, no 60-second interval, no
# inconclusive-block semantics). The patterns below target the SC-4
# language specifically and do not match that pre-existing text.
#
# Usage: bash .opencode/tests-v2/test-2431-sc4-red.sh
# Exit: 0 if the card documents the bounded-retry parameters plus the
#       chat-reported inconclusive block, 1 otherwise

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

grep_card_ere() {
    # grep_card_ere <label> <extended-regex>
    local label="$1"
    local pattern="$2"
    if grep -qiE -- "$pattern" "$CARD" 2>/dev/null; then
        check_pass "$label"
    else
        check_fail "$label" \
            "no match for regex '$pattern' in enforcement-gate.md (GREEN not yet applied)"
    fi
}

echo ""
echo "=== bounded-retry parameters + chat-reported inconclusive block in enforcement-gate.md -- SC-4 (#2431) ==="
echo ""

if [ ! -f "$CARD" ]; then
    echo "FATAL: enforcement-gate card not found at $CARD" >&2
    exit 2
fi

# SC-4 group A: bounded-retry parameters.
# The gate probes up to 3 times at 60-second intervals before blocking on
# inconclusive merge state. At baseline none of this language exists, so
# every assertion FAILS (RED).
grep_card "SC-4: card names the bounded retry"                   'bounded retry'
grep_card "SC-4: card names the probe count (3 probes)"          '3 probes'
grep_card_ere "SC-4: card names the 60-second interval" \
    '60[- ]second[s]? interval|interval[s]? of 60'
grep_card "SC-4: card names probing (probe/probes)"              'probe'

# SC-4 group B: inconclusive-block handling.
# Inconclusive API merge state blocks PR creation with a clear reason
# reported in chat naming the inconclusive submodule and its PR
# (fail-closed). At baseline the card carries no inconclusive-block
# language, so every assertion FAILS (RED).
grep_card "SC-4: card names inconclusive state"                  'inconclusive'
grep_card_ere "SC-4: inconclusive state blocks (block semantics)" \
    'inconclusive[^.]*block|block[^.]*inconclusive'
grep_card "SC-4: clear reason reported in chat"                  'in chat'
grep_card_ere "SC-4: block names the inconclusive submodule and its PR" \
    'naming the inconclusive submodule|names the inconclusive submodule|naming the inconclusive submodule and its PR'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0