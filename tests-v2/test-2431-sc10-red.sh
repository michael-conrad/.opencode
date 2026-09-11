#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# String-evidence test (SC-10): the authoritative ordering-gate card
# .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md
# carries per-submodule blocking-reason reporting covering the four
# categories (unmerged PR, inconclusive state, stale pointer,
# +-prefixed working tree), naming the submodule and its PR for every
# block, with mixed states enumerating every pending or inconclusive
# submodule.
#
# Maps to SC-10 from issue #2431 (Phase 4, item 10). Evidence type: string
# (grep against the authoritative card).
#
# RED phase (Phase 4, item 10): at baseline the card's ordering gate has
# the in-scope enumeration, live-API merge-state verification, bounded
# retry, both freshness assertions, the pointers-ride-alongside timing
# rule, and the waiting-behavior language (SC-1..SC-7, SC-11 language,
# already GREEN), but no four-category blocking-reason reporting scheme —
# the result contract carries no blocking_reason field, no exact
# category tokens (unmerged_pr, inconclusive_state, stale_pointer,
# plus-prefixed), no mixed-state completeness language, and no
# category/submodule-PR tie — so every assertion below FAILS and the
# test exits non-zero (RED). GREEN phase adds the four-category
# per-submodule blocking-reason reporting to the result contract; this
# test then PASSES.
#
# The enforcement-gate card is a regular tracked file in the .opencode
# repo (not the .issues/ worktree), so it is read directly with grep.
#
# Pre-existing match hazards checked at RED time (none matches any
# assertion below):
# - Line 145 prose "unmerged-PR rule" — hyphenated prose noun; the
#   assertion uses the exact underscore token 'unmerged_pr'.
# - Lines 189/199 prose "stale-pointer parent PR" / "unmerged pointer
#   state" — hyphenated prose; the assertion uses the exact underscore
#   token 'stale_pointer'.
# - Lines 143/161/180 prose "failure category" / "separate failure
#   categories" — the separate-checks disambiguation language from the
#   SC-6/SC-7 assertions, NOT a four-category reporting scheme; no bare
#   'category' assertion is used, and the scheme assertions require the
#   exact 'blocking_reason' token and the co-enumeration of all four
#   category tokens on a single line, which the prose does not have.
# - SUBMODULE_PR_MISSING (lines 43/76) — the #2313 Step 0 failure code;
#   unchanged by SC-10 and not a four-category scheme assertion.
#
# Usage: bash .opencode/tests-v2/test-2431-sc10-red.sh
# Exit: 0 if the card documents the four-category per-submodule
#       blocking-reason reporting (unmerged PR, inconclusive state,
#       stale pointer, +-prefixed working tree; submodule + PR named;
#       mixed states enumerated), 1 otherwise
#
# Revision 2 (BAD_TEST_NEEDS_REVISION, .opencode#2431 item 10): the
# original assertion A1 used grep_card (BRE) with the pattern
# 'blocking[ _-]?reason'. In BRE the '?' is a LITERAL character, so the
# pattern could never match any card state — the test failed against
# the GREEN card too, which is a bad test, not a RED signal. The
# pattern is now run through grep_card_ere (ERE), where '? means
# zero-or-one, so the assertion matches 'blocking reason',
# 'blocking-reason', and 'blocking_reason'. RED validity re-verified
# against the baseline card at commit c06c73b8 (git show):
# grep -qiE 'blocking[ _-]?reason' finds no match in the baseline, so
# the assertion still FAILS in true RED state; against the GREEN card
# (working tree, uncommitted) it PASSES.

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
echo "=== per-submodule blocking-reason reporting in enforcement-gate.md -- SC-10 (#2431) ==="
echo ""

if [ ! -f "$CARD" ]; then
    echo "FATAL: enforcement-gate card not found at $CARD" >&2
    exit 2
fi

# SC-10 group A: four-category blocking-reason reporting scheme naming.
# The result contract carries per-submodule blocking-reason reporting
# with the exact 'blocking_reason' field and the four category tokens.
# At baseline the card has no blocking_reason field and no exact
# category tokens (hyphenated prose nouns do not match underscore
# tokens), so every assertion FAILS (RED).
# Revision 2: A1 switched from grep_card (BRE — '?' is a literal, making
# the pattern unmatchable in any card state) to grep_card_ere (ERE —
# '? is the zero-or-one quantifier, matching 'blocking reason',
# 'blocking-reason', and 'blocking_reason'). Verified RED-valid: no
# ERE match in the baseline card at c06c73b8; GREEN-valid: ERE match
# in the working-tree card.
grep_card_ere "SC-10: card carries per-submodule blocking-reason reporting scheme" 'blocking[ _-]?reason'
grep_card "SC-10: category token unmerged PR"                                  'unmerged_pr'
grep_card "SC-10: category token inconclusive state"                           'inconclusive_state'
grep_card "SC-10: category token stale pointer"                                'stale_pointer'
grep_card_ere "SC-10: category token +-prefixed working tree"                  'plus[ _-]?prefixed'
grep_card_ere "SC-10: result contract carries blocking_reason field"           '^[[:space:]]*blocking[ _-]?reason:'

# SC-10 group B: mixed-state completeness. Mixed states enumerate every
# pending or inconclusive submodule. At baseline the card has no
# mixed-state enumeration language, so every assertion FAILS (RED).
grep_card_ere "SC-10: mixed states enumerated"                                 'mixed states'
grep_card      "SC-10: mixed-state scope names every pending or inconclusive submodule" 'pending or inconclusive submodule'
grep_card      "SC-10: every pending or inconclusive submodule covered"        'every pending'

# SC-10 group C: category/submodule-PR tie. Each blocking report names
# the submodule and its PR with its category — the reporting language
# ties the category token to the submodule and its PR. At baseline the
# card carries no such tie (the bounded-retry chat report is a bare
# instruction, not a category-token report contract), so every
# assertion FAILS (RED).
grep_card_ere "SC-10: unmerged PR report names submodule and PR"               'unmerged_pr.*submodule'
grep_card_ere "SC-10: stale pointer report names submodule and PR"             'stale_pointer.*submodule'
grep_card_ere "SC-10: four categories co-enumerated on one line"               'unmerged.*inconclusive.*stale.*prefixed'

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0