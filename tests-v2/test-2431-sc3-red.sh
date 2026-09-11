#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# String-evidence test (SC-3): the authoritative ordering-gate card
# .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
# verifies each in-scope submodule PR's merge state via a LIVE PLATFORM API
# call using the merge-state fields, and carries the explicit prohibition on
# inferring merge state from local checkout state or git merge-base ancestry.
#
# Maps to SC-3 from issue #2431 (Phase 1, item 3). Evidence type: string
# (grep against the authoritative card).
#
# RED phase (Phase 1, item 3): at baseline the card's Merge-State Blocking
# Condition only states the blocking outcome (SC-1 language) with no
# live-API verification language and no never-inferred prohibition, so
# every assertion below FAILS and the test exits non-zero (RED). GREEN
# phase adds the live-API language and the prohibition to the ordering
# gate; this test then PASSES.
#
# The enforcement-gate card is a regular tracked file in the .opencode repo
# (not the .issues/ worktree), so it is read directly with grep.
#
# Note: the only pre-existing "live" text in the card is "liveness" from the
# #2313 Step 0 reachability check (SHA comparison), which is NOT live-API
# merge-state verification; the "ancestor" text there is the #2313
# merged-commit reachability command, NOT the SC-3 never-inferred
# prohibition. The patterns below target the SC-3 language specifically.
#
# Usage: bash .opencode/tests-v2/test-2431-sc3-red.sh
# Exit: 0 if the card documents live-API merge-state verification plus the
#       never-inferred prohibition, 1 otherwise

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
echo "=== live-API merge-state verification + never-inferred prohibition in enforcement-gate.md -- SC-3 (#2431) ==="
echo ""

if [ ! -f "$CARD" ]; then
    echo "FATAL: enforcement-gate card not found at $CARD" >&2
    exit 2
fi

# SC-3 group A: live-API merge-state verification language.
# The gate verifies each in-scope submodule PR's merge state via a live
# platform API call using the merge-state fields. At baseline none of this
# language exists, so every assertion FAILS (RED).
grep_card_ere "SC-3: card names a live platform API (or live-API) verification" \
    'live[- ]platform API|live[- ]API|live platform'
grep_card "SC-3: card names the merge-state fields"              'merge-state field'
grep_card "SC-3: card names the merged merge-state field"        'merged_at'
grep_card "SC-3: card names the platform API invocation"         'gh api'

# SC-3 group B: never-inferred prohibition language.
# Merge state is never inferred from local checkout state or from
# git merge-base ancestry. At baseline the card carries no prohibition, so
# every assertion FAILS (RED).
grep_card "SC-3: prohibition uses never-inferred language"       'never inferred'
grep_card "SC-3: prohibition names local checkout state"         'local checkout state'
grep_card_ere "SC-3: prohibition ties inference ban to ancestry" \
    '(never|not|no)[^.]*inferr[^.]*ancestry|ancestry[^.]*inferr'
grep_card "SC-3: prohibition names git merge-base ancestry"      'merge-base ancestry'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0