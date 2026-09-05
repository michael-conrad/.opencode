#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-4a — tests-v2/AGENTS.md §4 ordered
# precondition cycle with all-runs scope
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-4a, evidence type: string)
# Plan:   .opencode/.issues/2434/plan.md — Item 4a, step 33 (RED)
#
# SC-4a: tests-v2/AGENTS.md §4 documents the ordered precondition cycle
# (commit → push → fetch/verify → run) as required for ALL behavioral runs
# (not only the DEFAULT_TEST_MODEL override), framed as the test-framework
# infrastructure-maintenance carve-out.
#
# RED state (today): §4 ("Running Tests", lines 200–225) scopes the
# push-before-test note to the DEFAULT_TEST_MODEL override only ("⚠️
# DEFAULT_TEST_MODEL override requires the feature branch to be pushed to
# remote."). No ordered cycle appears: there is no "commit → push →
# fetch/verify → run" chain, the word "fetch" does not appear in §4 at all,
# and no all-runs scope statement ("every behavioral run" / "ALL behavioral
# runs") exists. The §5 infrastructure-maintenance carve-out sentence in §4
# ("Test framework changes that fix broken behavior are not implementation —
# they are infrastructure maintenance") authorizes the push but does not
# state the cycle. The assertions below target the DESIRED §4 content, so
# they FAIL today. That non-zero exit IS the RED verdict (RED != FALSE: the
# check executes grep against the live file and observes the missing/under-
# scoped content).
#
# Scope discipline (R-10/D4): the check reads ONLY the §4 section — delimited
# by the literal "^## 4. Running Tests" heading — and never leaks across the
# §5 boundary, so a §4 cycle sentence cannot be satisfied by §5 text and the
# narrow DEFAULT_TEST_MODEL note cannot satisfy the all-runs scope assertion.
#
# Artifacts: tmp/2434/artifacts/pipeline-red-sc4a-*
# Usage:   bash .opencode/tests-v2/test-2434-sc4a-s4-ordered-cycle-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)
#          2 = HARNESS_FAILURE (§4 section or source file not found)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$PROJECT_ROOT/.opencode/tests-v2/AGENTS.md"
ART_DIR="$PROJECT_ROOT/tmp/2434/artifacts"
mkdir -p "$ART_DIR"

# Idempotence: clear this test's own stale artifacts.
rm -f "$ART_DIR"/pipeline-red-sc4a-*

exec > >(tee "$ART_DIR/pipeline-red-sc4a-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-sc4a-test-output.err" >&2)

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

echo "== SC-4a RED check: §4 ordered precondition cycle, all-runs scope (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Sanity: the doc must exist and carry the §4 heading.
# ---------------------------------------------------------------------------
if [ ! -f "$DOC" ]; then
    echo "HARNESS_FAILURE: $DOC not found" >&2
    exit 2
fi
S4_START=$(awk '/^## 4\. Running Tests/{print NR; exit}' "$DOC")
S5_START=$(awk 'NR>1 && /^## 5\. Infrastructure Details/{print NR; exit}' "$DOC")
if [ -z "$S4_START" ] || [ -z "$S5_START" ]; then
    echo "HARNESS_FAILURE: could not locate §4 (## 4. Running Tests) or §5 (## 5. Infrastructure Details) boundaries in tests-v2/AGENTS.md" >&2
    exit 2
fi
echo "  [structural] §4 spans lines $S4_START..$((S5_START - 1)) (§5 starts at $S5_START)"

# Extract §4 exactly (section-local matching — R-10 single-definition surface).
S4="$(sed -n "${S4_START},$((S5_START - 1))p" "$DOC")"
S4_LINES=$((S5_START - S4_START))

# ---------------------------------------------------------------------------
# Assertion 1a — the literal arrow chain (commit → push → fetch/verify → run)
# must appear in §4. Accepts the spec's arrow vocabulary with or without
# spaces, ASCII or unicode arrows, and the "fetch/verify" slash form.
# Today: absent → FAIL.
# ---------------------------------------------------------------------------
if echo "$S4" | grep -qiE 'commit[[:space:]]*(→|->)[[:space:]]*push[[:space:]]*(→|->)[[:space:]]*fetch(/verify)?[[:space:]]*(→|->)[[:space:]]*run'; then
    check_pass "§4 contains the literal ordered cycle (commit → push → fetch/verify → run)"
else
    check_fail "§4 contains the literal ordered cycle (commit → push → fetch/verify → run)" \
        "no 'commit → push → fetch/verify → run' chain found in §4 lines $S4_START..$((S5_START - 1))"
fi

# ---------------------------------------------------------------------------
# Assertion 1b — single-line ordered variant (backtick-cycle or heading form).
# Today: absent → FAIL.
# ---------------------------------------------------------------------------
if echo "$S4" | grep -Ei '(commit.*push.*fetch.*run|commit/push/fetch.*run)' | grep -qv 'requires the feature branch'; then
    check_pass "§4 contains an ordered-cycle phrase (commit…push…fetch…run) on one line"
else
    check_fail "§4 contains an ordered-cycle phrase (commit…push…fetch…run) on one line" \
        "no single-line commit/push/fetch/run ordering present in §4"
fi

# ---------------------------------------------------------------------------
# Assertion 1c — flattened word-order cycle across a sentence: commit < push <
# fetch < run in reading order within the section (whitespace-flattened).
# This catches a two-line wrapped cycle sentence. Today: 'fetch' is entirely
# absent from §4 and 'run' never appears as a standalone word → FAIL.
# ---------------------------------------------------------------------------
FLAT_S4="$(echo "$S4" | tr '\n' ' ')"
COMMIT_POS="$(printf '%s' "$FLAT_S4" | grep -Eiob 'commit' | head -1 | cut -d: -f1 || true)"
PUSH_POS="$(printf '%s' "$FLAT_S4" | grep -Eiob 'push' | awk -v c="${COMMIT_POS:--1}" -F: '$1 > c {print $1; exit}' || true)"
FETCH_POS="$(printf '%s' "$FLAT_S4" | grep -Eiob 'fetch' | awk -v p="${PUSH_POS:--1}" -F: '$1 > p {print $1; exit}' || true)"
RUN_POS="$(printf '%s' "$FLAT_S4" | grep -Eiow 'run' | awk -v f="${FETCH_POS:--1}" -F: '$1 > f {print $1; exit}' || true)"
if [ -n "$COMMIT_POS" ] && [ -n "$PUSH_POS" ] && [ -n "$FETCH_POS" ] && [ -n "$RUN_POS" ]; then
    check_pass "§4 carries the cycle in word order (commit < push < fetch < run) across the flattened section text"
else
    check_fail "§4 carries the cycle in word order (commit < push < fetch < run)" \
        "flattened §4 lacks the ordered words (commit=$COMMIT_POS push=${PUSH_POS:-none} fetch=${FETCH_POS:-none} run=${RUN_POS:-none}) — 'fetch' never appears in §4 today"
fi

# ---------------------------------------------------------------------------
# Assertion 2 — all-runs scope: the cycle is required for ALL behavioral runs,
# not only the DEFAULT_TEST_MODEL override. Today: the only scope statement is
# the narrow override note → FAIL.
# ---------------------------------------------------------------------------
if echo "$S4" | grep -qiE '(all|every)[[:space:]]+(behavioral[[:space:]]+)?(test[[:space:]]+)?runs?' || \
   echo "$S4" | grep -qiE 'for[[:space:]]+all[[:space:]]+behavioral'; then
    check_pass "§4 states the cycle applies to all/every behavioral run (all-runs scope)"
else
    check_fail "§4 states the cycle applies to all/every behavioral run (all-runs scope)" \
        "no all-runs scope statement in §4 — the push requirement is scoped only to the DEFAULT_TEST_MODEL override (line ~222)"
fi

# ---------------------------------------------------------------------------
# Assertion 3 — the override-scoped framing must not be the ONLY cycle
# framing: the DEFAULT_TEST_MODEL line must not be the sole place the word
# "push" appears. Today: the narrow note is the only push mention → FAIL.
# ---------------------------------------------------------------------------
NONOVERRIDE_CYCLE_PUSHES="$(echo "$S4" | grep -v 'DEFAULT_TEST_MODEL' | grep -Eci 'push' || true)"
if [ "$NONOVERRIDE_CYCLE_PUSHES" -ge 1 ]; then
    check_pass "§4 encodes push-before-test outside the DEFAULT_TEST_MODEL override note (all-runs scope not override-only)"
else
    check_fail "§4 encodes push-before-test outside the DEFAULT_TEST_MODEL override note" \
        "the only push-before-test mention in §4 is the DEFAULT_TEST_MODEL override warning — the cycle is override-scoped, not all-runs"
fi

# ---------------------------------------------------------------------------
# Assertion 4 — fetch/verify step present: the cycle's fetch/verify element
# (fresh fetch validating the commit is on remote before the run) must be
# named in §4. Today: 'fetch' absent from §4 → FAIL.
# ---------------------------------------------------------------------------
if echo "$S4" | grep -qiE 'fetch(/verify)?'; then
    check_pass "§4 names the fetch/verify precondition step of the cycle"
else
    check_fail "§4 names the fetch/verify precondition step" \
        "the word 'fetch' does not appear anywhere in §4 — the verify-before-run element is undocumented"
fi

# ---------------------------------------------------------------------------
# Assertion 5 — infrastructure-maintenance carve-out framing present
# (pre-existing: the FORBIDDEN authorization-solicitation block). Sanity
# assertion — this is the framing the GREEN rewrite must preserve.
# Today: PRESENT → PASS (a RED-anchoring sanity check, not a RED target).
# ---------------------------------------------------------------------------
if echo "$S4" | grep -qi 'infrastructure[- ]maintenance'; then
    check_pass "sanity: §4 retains the infrastructure-maintenance carve-out framing (pre-existing anchor for the GREEN rewrite)"
else
    check_fail "sanity: §4 retains the infrastructure-maintenance carve-out framing" \
        "the pre-existing carve-out framing vanished — GREEN must preserve it (spec R-6)"
fi

# ---------------------------------------------------------------------------
# Structural evidence
# ---------------------------------------------------------------------------
local_head="$(git -C "$PROJECT_ROOT/.opencode" rev-parse HEAD 2>/dev/null || echo unknown)"
{
    echo "test: SC-4a tests-v2/AGENTS.md §4 ordered cycle, all-runs scope (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-4a, string)"
    echo "plan_item: Item 4a step 33 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "doc: .opencode/tests-v2/AGENTS.md"
    echo "s4_start_line: $S4_START"
    echo "s5_start_line: $S5_START"
    echo "s4_line_span: $S4_LINES"
    echo "s4_char_span: $(printf '%s' "$S4" | wc -c | tr -d ' ')"
    echo "s4_nonblank_lines: $(printf '%s' "$S4" | grep -cv '^[[:space:]]*$' || true)"
    echo "cycle_word_order: commit=$COMMIT_POS push=${PUSH_POS:-none} fetch=${FETCH_POS:-none} run=${RUN_POS:-none} (byte offsets in flattened §4)"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
} > "$ART_DIR/pipeline-red-sc4a-structural.txt"

{
    echo "test: SC-4a tests-v2/AGENTS.md §4 ordered cycle, all-runs scope (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-4a, string)"
    echo "plan_item: Item 4a step 33 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "s4_start_line: $S4_START"
    echo "s5_start_line: $S5_START"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: ${verdict:-RED}"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4a-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4a-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4a-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4a-exit-code"
} > "$ART_DIR/pipeline-red-sc4a-summary.yaml"

echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "RED state confirmed: SC-4a §4 rewrite not implemented — tests-v2/AGENTS.md"
    echo "§4 scopes the push-before-test note to the DEFAULT_TEST_MODEL override only;"
    echo "the ordered precondition cycle (commit → push → fetch/verify → run) is absent,"
    echo "'fetch' never appears in §4, and no all-runs scope statement exists."
    verdict="RED"
    final_rc=1
else
    echo ""
    echo "GREEN: all SC-4a assertions pass."
    verdict="GREEN"
    final_rc=0
fi

sed -i 's/^verdict: .*$/verdict: '"$verdict"'/' "$ART_DIR/pipeline-red-sc4a-summary.yaml"
echo "$final_rc" > "$ART_DIR/pipeline-red-sc4a-exit-code"
exit "$final_rc"