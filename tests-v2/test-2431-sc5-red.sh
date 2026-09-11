#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# String-evidence test (SC-5): the authoritative ordering-gate card
# .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
# carries the pointers-ride-alongside timing rule — submodule pointer
# bumps are committed on the parent feature branch AFTER the submodule
# merges land, so the parent PR's squashed commit carries fresh pointers.
#
# Maps to SC-5 from issue #2431 (Phase 3, item 5). Evidence type: string
# (grep against the authoritative card).
#
# RED phase (Phase 3, item 5): at baseline the card's ordering gate has
# the merge-state verification, bounded retry, and both freshness
# assertions (SC-1..SC-4, SC-6, SC-7 language, already GREEN), but no
# pointers-ride-alongside timing rule — nothing states pointer bumps are
# committed after the merges land or that the squashed commit carries
# fresh pointers — so every assertion below FAILS and the test exits
# non-zero (RED). GREEN phase adds the timing rule to the ordering gate;
# this test then PASSES.
#
# The enforcement-gate card is a regular tracked file in the .opencode repo
# (not the .issues/ worktree), so it is read directly with grep.
#
# Note: the only pre-existing "rides ALONGSIDE" text in the card is the
# Step 0.5 Submodule-Bump-Only PR Gate note ("dirty and rides ALONGSIDE
# the next real root-repo change"), which is the pointer-staging rule
# (never a standalone commit), NOT the SC-5 timing rule (no after-merges-
# land semantics, no fresh-pointers language). The patterns below target
# the SC-5 timing language specifically and do not match that text.
# Likewise the Pointer-SHA Ancestry Assertion's "the recorded pointer is
# fresh on the submodule's remote trunk" is ancestry freshness, not the
# SC-5 fresh-pointers-for-the-squashed-commit language.
#
# Usage: bash .opencode/tests-v2/test-2431-sc5-red.sh
# Exit: 0 if the card documents the pointers-ride-alongside timing rule
#       (bumps committed after merges land, squashed commit carries fresh
#       pointers), 1 otherwise

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
echo "=== pointers-ride-alongside timing rule in enforcement-gate.md -- SC-5 (#2431) ==="
echo ""

if [ ! -f "$CARD" ]; then
    echo "FATAL: enforcement-gate card not found at $CARD" >&2
    exit 2
fi

# SC-5 group A: pointers-ride-alongside rule naming.
# The card names the pointers-ride-alongside rule for pointer-bump timing.
# At baseline the rule name does not exist in the card (the Step 0.5 note
# uses the verb phrase "rides ALONGSIDE" for the staging rule, not the
# hyphenated rule name), so every assertion FAILS (RED).
grep_card "SC-5: card names the pointers-ride-alongside rule"     'pointers-ride-alongside'
grep_card_ere "SC-5: card names pointer bumps (bump language)"    'pointer bump|bumps the parent pointer|pointer-bump'

# SC-5 group B: timing semantics — bumps committed AFTER merges land.
# The timing rule requires pointer bumps to be committed on the parent
# feature branch after the submodule merges land. At baseline the card
# has no after-merges-land timing language, so every assertion FAILS
# (RED).
grep_card_ere "SC-5: bumps committed after the merges land" \
    'after (the )?(submodule )?(PR )?merges? (has |have )?land(ed)?'
grep_card_ere "SC-5: bumps committed on the parent feature branch" \
    'committed on the parent feature branch'
grep_card_ere "SC-5: bump-after-merge semantic tie" \
    'bump[^.]*after[^.]*merges?[^.]*land|after[^.]*merges?[^.]*land[^.]*bump'

# SC-5 group C: fresh-pointers outcome for the squashed commit.
# The purpose clause: the parent PR's squashed commit carries fresh
# pointers. At baseline the card has no fresh-pointers language for the
# squashed commit (the ancestry assertion's "the recorded pointer is
# fresh" is a different concept), so every assertion FAILS (RED).
grep_card_ere "SC-5: card names fresh pointers"                   'fresh pointers'
grep_card_ere "SC-5: squashed commit carries fresh pointers" \
    'squashed commit[^.]*fresh|fresh[^.]*squashed commit'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0