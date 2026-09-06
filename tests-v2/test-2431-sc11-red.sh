#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# String-evidence test (SC-11): the authoritative ordering-gate card
# .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
# carries the waiting-behavior language — while waiting, the parent
# branch sits idle: no new commits, pushes, or PR mutations occur on
# the parent branch until all in-scope submodule PRs land.
#
# Maps to SC-11 from issue #2431 (Phase 3, item 11). Evidence type: string
# (grep against the authoritative card).
#
# RED phase (Phase 3, item 11): at baseline the card's ordering gate has
# the in-scope enumeration, merge-state verification, bounded retry, both
# freshness assertions, and the SC-5 pointers-ride-alongside timing rule
# (SC-1..SC-7 language, already GREEN), but no waiting-behavior statement —
# nothing states the parent branch sits idle, and nothing bars new
# commits, pushes, or PR mutations on the parent branch during the wait —
# so every assertion below FAILS and the test exits non-zero (RED).
# GREEN phase adds the waiting-behavior statement to the ordering gate;
# this test then PASSES.
#
# The enforcement-gate card is a regular tracked file in the .opencode repo
# (not the .issues/ worktree), so it is read directly with grep.
#
# Note: the only pre-existing "wait" text in the card is the Step 1.5d
# merge-conflict line ("Wait and retry, or determine mergeability
# locally..."), which is the PR-mergeability retry for OPEN PRs, NOT the
# SC-11 submodule-PR wait — it carries no idle language, no barred-activity
# enumeration (no new commits, pushes, or PR mutations), and no
# until-in-scope-PRs-land scope. The patterns below target the SC-11
# waiting-behavior language specifically and do not match that line.
# Likewise the SC-5 timing rule ("While any in-scope submodule PR is
# unmerged, no pointer bump is committed on the parent branch") bars
# pointer-bump commits only — it does not state the branch sits idle nor
# bar new commits, pushes, or PR mutations generally, and the Step 1
# check-table "Branch pushed to remote" uses "pushed", not the
# commits/pushes/PR-mutations triple.
#
# Usage: bash .opencode/tests-v2/test-2431-sc11-red.sh
# Exit: 0 if the card documents the waiting-behavior language (parent
#       branch sits idle; no new commits, pushes, or PR mutations until
#       all in-scope submodule PRs land), 1 otherwise

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
echo "=== waiting-behavior language in enforcement-gate.md -- SC-11 (#2431) ==="
echo ""

if [ ! -f "$CARD" ]; then
    echo "FATAL: enforcement-gate card not found at $CARD" >&2
    exit 2
fi

# SC-11 group A: idle wait naming.
# The card states the parent branch sits idle during the wait. At baseline
# the card has no idle language at all, so every assertion FAILS (RED).
grep_card "SC-11: card names the idle state"                       'idle'
grep_card_ere "SC-11: card states the parent branch sits idle"     'sit(s)? idle|idle wait|waits? idle'

# SC-11 group B: barred activity during the wait — no new commits,
# pushes, or PR mutations occur on the parent branch. At baseline the
# card has no such enumeration (the SC-5 timing rule bars pointer-bump
# commits only; Step 1.5d is a mergeability retry), so every assertion
# FAILS (RED).
grep_card "SC-11: no new commits language"                         'no new commits'
grep_card_ere "SC-11: commits/pushes/PR-mutations triple"          'commits?, pushes, (or|and) PR mutations'
grep_card_ere "SC-11: PR mutations barred"                         'PR mutations?'

# SC-11 group C: wait-scope tie — the barred activity lasts until all
# in-scope submodule PRs land. At baseline the card has no 'until'
# language at all, so every assertion FAILS (RED).
grep_card_ere "SC-11: wait lasts until in-scope submodule PRs land" \
    'until (all )?in-scope submodule PRs? (has |have )?land(ed)?|until[^.]*submodule PRs?[^.]*land'
grep_card_ere "SC-11: idle/until-land semantic tie" \
    '(idle|waiting|wait)[^.]*until[^.]*land(ed)?|until[^.]*land(ed)?[^.]*(idle|waiting)'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0