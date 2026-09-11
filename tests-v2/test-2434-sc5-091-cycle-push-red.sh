#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-5 — guidelines/091-incremental-build.md
# Per-Item TDD Cycle table + behavioral-variant paragraph encode
# push-before-test ordering for behavioral items
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-5, evidence type: string)
# Plan:   .opencode/.issues/2434/plan.md — Item 5, step 45 (RED)
#
# SC-5: for behavioral items, commit+push precede the behavioral test run —
# the Per-Item TDD Cycle table carries a PUSH step ordered after COMMIT
# (before the next RED), the behavioral-variant paragraph encodes the
# commit+push-before-run ordering, and the PUSH step is scoped to behavioral
# items so the #2433 commit-inline plan pattern (commit last for regular
# items) is not contradicted.
#
# RED state (today): the Per-Item TDD Cycle section ("## Per-Item TDD Cycle",
# lines 24–38) ends its cycle table at COMMIT — the row sequence is
# RED | GREEN | REFACTOR | COMMIT (lines 30–33) and no PUSH row exists. The
# behavioral-variant paragraph (line 35) describes the behavioral test run
# ("Send a real-domain prompt via `opencode run`") but never states
# commit+push before that run — the word "push" does not appear anywhere in
# the section. The assertions below target the DESIRED 091 content, so they
# FAIL today. That non-zero exit IS the RED verdict (RED != FALSE: the check
# executes grep/awk against the live file and observes the missing PUSH step
# and missing ordering — it is not a file-existence or count-only query).
#
# Scope discipline (I4): the check reads ONLY the "Per-Item TDD Cycle"
# section — delimited by the "^## Per-Item TDD Cycle" heading up to the next
# "^## " heading — so the table assertions cannot be satisfied by prose
# elsewhere in 091 and the behavioral-variant paragraph assertions cannot
# leak outside the section.
#
# Artifacts: tmp/2434/artifacts/pipeline-red-sc5-*
# Usage:   bash .opencode/tests-v2/test-2434-sc5-091-cycle-push-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)
#          2 = HARNESS_FAILURE (section or source file not found)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$PROJECT_ROOT/.opencode/guidelines/091-incremental-build.md"
ART_DIR="$PROJECT_ROOT/tmp/2434/artifacts"
mkdir -p "$ART_DIR"

# Idempotence: clear this test's own stale artifacts.
rm -f "$ART_DIR"/pipeline-red-sc5-*

exec > >(tee "$ART_DIR/pipeline-red-sc5-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-sc5-test-output.err" >&2)

PASS_COUNT=0
FAIL_COUNT=0
check_pass() {
    echo "  PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}
check_fail() {
    echo "  FAIL: $1 — $2" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "== SC-5 RED check: 091 Per-Item TDD Cycle push-before-test ordering (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Sanity: the doc must exist and carry the Per-Item TDD Cycle section.
# ---------------------------------------------------------------------------
if [ ! -f "$DOC" ]; then
    echo "HARNESS_FAILURE: $DOC not found" >&2
    exit 2
fi
S_START=$(awk '/^## Per-Item TDD Cycle/{print NR; exit}' "$DOC")
if [ -z "$S_START" ]; then
    echo "HARNESS_FAILURE: could not locate '## Per-Item TDD Cycle' heading in 091-incremental-build.md" >&2
    exit 2
fi
S_END=$(awk -v s="$S_START" 'NR>s && /^## /{print NR; exit}' "$DOC")
if [ -z "$S_END" ]; then
    echo "HARNESS_FAILURE: could not locate the next '## ' heading after '## Per-Item TDD Cycle' in 091-incremental-build.md" >&2
    exit 2
fi
echo "  [structural] Per-Item TDD Cycle section spans lines $S_START..$((S_END - 1)) (next heading at $S_END)"

SECTION="$(sed -n "${S_START},$((S_END - 1))p" "$DOC")"
SECTION_LINES=$((S_END - S_START))

# Behavioral-variant paragraph: from its marker line to the end of the section.
BV_START=$(awk -v s="$S_START" -v e="$S_END" 'NR>=s && NR<e && /^\*\*Behavioral variant\*\*/{print NR; exit}' "$DOC")
if [ -z "$BV_START" ]; then
    echo "HARNESS_FAILURE: could not locate the '**Behavioral variant**' paragraph in the Per-Item TDD Cycle section" >&2
    exit 2
fi
BV="$(sed -n "${BV_START},$((S_END - 1))p" "$DOC")"

row_line() { # $1 = phase key; prints first matching table-row line number or empty
    awk -v s="$S_START" -v e="$S_END" -v k="$1" \
        'NR>=s && NR<e && $0 ~ ("^\\|[[:space:]]*" k "([[:space:]]*\\||$)"){print NR; exit}' "$DOC"
}
RED_LINE="$(row_line RED)"
GREEN_LINE="$(row_line GREEN)"
REFACTOR_LINE="$(row_line REFACTOR)"
COMMIT_LINE="$(row_line COMMIT)"
PUSH_LINE="$(row_line PUSH)"
PUSH_ROW=""
if [ -n "$PUSH_LINE" ]; then
    PUSH_ROW="$(sed -n "${PUSH_LINE}p" "$DOC")"
fi

# ---------------------------------------------------------------------------
# Sanity 1 — the cycle table retains the four pre-existing phase rows.
# Sanity assertion — this is the vocabulary the GREEN amendment must preserve.
# Today: PRESENT → PASS (a RED-anchoring sanity check, not a RED target).
# ---------------------------------------------------------------------------
SANITY_ROWS_OK=1
for key in RED GREEN REFACTOR COMMIT; do
    if ! printf '%s\n' "$SECTION" | grep -qE "^\|[[:space:]]*${key}([[:space:]]*\||[[:space:]]*$)"; then
        SANITY_ROWS_OK=0
    fi
done
if [ "$SANITY_ROWS_OK" -eq 1 ]; then
    check_pass "sanity: cycle table retains the RED/GREEN/REFACTOR/COMMIT phase rows (pre-existing anchors for the GREEN amendment)"
else
    check_fail "sanity: cycle table retains the RED/GREEN/REFACTOR/COMMIT phase rows" \
        "a pre-existing phase row vanished — GREEN must preserve the cycle vocabulary (spec R-7)"
fi

# ---------------------------------------------------------------------------
# Sanity 2 — the behavioral-variant paragraph retains its behavioral-test-run
# description (the surface SC-5 targets). Today: PRESENT → PASS.
# ---------------------------------------------------------------------------
if printf '%s\n' "$BV" | grep -qiE 'behavioral|opencode run'; then
    check_pass "sanity: behavioral-variant paragraph is present and describes the behavioral test run (SC-5 surface located)"
else
    check_fail "sanity: behavioral-variant paragraph is present" \
        "the SC-5 paragraph surface vanished — GREEN must amend it, not delete it (spec R-7)"
fi

# ---------------------------------------------------------------------------
# Assertion A — a PUSH step (table row) exists in the Per-Item TDD Cycle.
# Today: the cycle ends at COMMIT, PUSH absent → FAIL.
# ---------------------------------------------------------------------------
if [ -n "$PUSH_LINE" ]; then
    check_pass "cycle table carries a PUSH step (row '$(printf '%s' "$PUSH_ROW" | cut -c1-80)…')"
else
    check_fail "cycle table carries a PUSH step" \
        "no '| PUSH |' row found in the Per-Item TDD Cycle table (lines $S_START..$((S_END - 1))) — the cycle ends at COMMIT (line ${COMMIT_LINE:-?})"
fi

# ---------------------------------------------------------------------------
# Assertion B — ordering: PUSH appears after COMMIT (the cycle encodes
# commit+push before the next RED / the behavioral test run). Today: no PUSH
# row → FAIL.
# ---------------------------------------------------------------------------
if [ -n "$COMMIT_LINE" ] && [ -n "$PUSH_LINE" ] && [ "$PUSH_LINE" -gt "$COMMIT_LINE" ]; then
    check_pass "cycle ordering encodes PUSH after COMMIT (COMMIT at line $COMMIT_LINE, PUSH at line $PUSH_LINE)"
else
    check_fail "cycle ordering encodes PUSH after COMMIT" \
        "PUSH row absent or misordered (COMMIT=${COMMIT_LINE:-none} PUSH=${PUSH_LINE:-none}) — commit+push-before-test ordering not encoded"
fi

# ---------------------------------------------------------------------------
# Assertion C — the behavioral-variant paragraph encodes the ordering: it
# mentions push in relation to the behavioral test run (a push mention plus
# an ordering marker such as before/precede/after). Today: 'push' does not
# appear in the paragraph at all → FAIL.
# ---------------------------------------------------------------------------
BV_PUSH="$(printf '%s\n' "$BV" | grep -ciE 'push' || true)"
BV_MARKER="$(printf '%s\n' "$BV" | grep -ciE 'before|prior to|preced|after|first|then' || true)"
if [ "${BV_PUSH:-0}" -ge 1 ] && [ "${BV_MARKER:-0}" -ge 1 ]; then
    check_pass "behavioral-variant paragraph encodes push-before-test ordering (push mention + ordering marker)"
else
    check_fail "behavioral-variant paragraph encodes push-before-test ordering" \
        "paragraph (line $BV_START..$((S_END - 1))) lacks the ordering (push mentions=${BV_PUSH:-0}, ordering markers=${BV_MARKER:-0}) — the behavioral test run is described with no commit+push precondition"
fi

# ---------------------------------------------------------------------------
# Assertion D — behavioral scoping / #2433 commit-inline non-contradiction:
# the PUSH step is scoped to behavioral items (the PUSH row names behavioral
# items, or the behavioral-variant paragraph carries the push precondition).
# A universal unscoped PUSH row would contradict the #2433 commit-inline plan
# pattern (commit last for regular items). Today: no PUSH row and no push in
# the paragraph → FAIL.
# ---------------------------------------------------------------------------
if [ -n "$PUSH_LINE" ] && printf '%s' "$PUSH_ROW" | grep -qi 'behavioral'; then
    check_pass "PUSH step is scoped to behavioral items in the cycle row (#2433 commit-inline pattern preserved)"
elif [ -n "$PUSH_LINE" ] && printf '%s\n' "$BV" | grep -qiE 'push'; then
    check_pass "PUSH step is behavioral-scoped via the behavioral-variant paragraph (#2433 commit-inline pattern preserved)"
else
    check_fail "PUSH step is scoped to behavioral items (#2433 commit-inline non-contradiction)" \
        "no behavioral-scoped PUSH encoding exists — the cycle table has no PUSH row (${PUSH_LINE:-none}) and the behavioral-variant paragraph never mentions push"
fi

# ---------------------------------------------------------------------------
# Structural evidence
# ---------------------------------------------------------------------------
local_head="$(git -C "$PROJECT_ROOT/.opencode" rev-parse HEAD 2>/dev/null || echo unknown)"
FLAT_SECTION="$(printf '%s' "$SECTION" | tr '\n' ' ')"
PUSH_OFFSET="$(printf '%s' "$FLAT_SECTION" | grep -Eiob 'push' | head -1 | cut -d: -f1 || true)"
COMMIT_OFFSET="$(printf '%s' "$FLAT_SECTION" | grep -Eiob 'commit' | head -1 | cut -d: -f1 || true)"
{
    echo "test: SC-5 091 Per-Item TDD Cycle push-before-test ordering (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-5, string)"
    echo "plan_item: Item 5 step 45 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "doc: .opencode/guidelines/091-incremental-build.md"
    echo "section_start_line: $S_START"
    echo "section_end_line: $((S_END - 1))"
    echo "next_heading_line: $S_END"
    echo "section_line_span: $SECTION_LINES"
    echo "section_char_span: $(printf '%s' "$SECTION" | wc -c | tr -d ' ')"
    echo "section_nonblank_lines: $(printf '%s' "$SECTION" | grep -cv '^[[:space:]]*$' || true)"
    echo "bv_start_line: $BV_START"
    echo "bv_char_span: $(printf '%s' "$BV" | wc -c | tr -d ' ')"
    echo "row_lines: RED=${RED_LINE:-none} GREEN=${GREEN_LINE:-none} REFACTOR=${REFACTOR_LINE:-none} COMMIT=${COMMIT_LINE:-none} PUSH=${PUSH_LINE:-none}"
    echo "flattened_word_offsets: commit=$COMMIT_OFFSET push=${PUSH_OFFSET:-none} (byte offsets in flattened section; push absent today)"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
} > "$ART_DIR/pipeline-red-sc5-structural.txt"

if [ "$FAIL_COUNT" -gt 0 ]; then
    verdict="RED"
    final_rc=1
else
    verdict="GREEN"
    final_rc=0
fi

{
    echo "test: SC-5 091 Per-Item TDD Cycle push-before-test ordering (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-5, string)"
    echo "plan_item: Item 5 step 45 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "doc: .opencode/guidelines/091-incremental-build.md"
    echo "section_start_line: $S_START"
    echo "next_heading_line: $S_END"
    echo "row_lines: RED=${RED_LINE:-none} GREEN=${GREEN_LINE:-none} REFACTOR=${REFACTOR_LINE:-none} COMMIT=${COMMIT_LINE:-none} PUSH=${PUSH_LINE:-none}"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: $verdict"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-sc5-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-sc5-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-sc5-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-sc5-exit-code"
} > "$ART_DIR/pipeline-red-sc5-summary.yaml"

echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$final_rc" -eq 1 ]; then
    echo ""
    echo "RED state confirmed: SC-5 091 ordering amendment not implemented — the"
    echo "Per-Item TDD Cycle table ends at COMMIT (line ${COMMIT_LINE:-?}) with no PUSH"
    echo "row, and the behavioral-variant paragraph (line $BV_START) describes the"
    echo "behavioral test run with no commit+push precondition — the word 'push' does"
    echo "not appear anywhere in the section."
else
    echo ""
    echo "GREEN: all SC-5 assertions pass."
fi
echo "$final_rc" > "$ART_DIR/pipeline-red-sc5-exit-code"
exit "$final_rc"