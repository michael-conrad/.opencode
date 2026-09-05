#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-7 — root AGENTS.md "Testing Lessons Learned"
# section contains a commit/push/fetch cycle lesson
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-7, evidence type: string)
# Plan:   .opencode/.issues/2434/plan.md — Item 7, step 57 (RED)
#
# SC-7: the Testing Lessons Learned section of .opencode/AGENTS.md must contain
# a commit/push/fetch cycle lesson referencing the implemented gate predicate
# and the §4 infrastructure-maintenance carve-out.
#
# RED state (today): the "### Testing Lessons Learned — Failure Patterns"
# section (.opencode/AGENTS.md, line ~157) carries 7 lessons — stale lock
# files, bash tool timeout, missing session.yaml export, fabricated model
# excuses, post-timeout recovery, submodule-only push bypass, wrong repo for
# spec creation — and NONE of them is a commit/push/fetch cycle lesson. The
# only cycle-adjacent vocabulary in the section is the word "push" inside the
# submodule-only push-bypass lesson (a pre-push-hook topic, not the ordered
# commit → push → fetch/verify → run cycle). No lesson references the §4
# carve-out. The assertions below target the DESIRED lesson content, so they
# FAIL today. That non-zero exit IS the RED verdict (RED != FALSE: the check
# executes awk/grep against the live file and observes the cycle lesson
# absent).
#
# Count discipline: the test does NOT hardcode a lesson count (the plan's
# "6 lessons" figure is stale — 7 lessons exist today). The cycle-lesson
# predicate is structural: a bolded-title lesson paragraph whose text contains
# commit AND push AND fetch (case-insensitive, paragraph-level co-occurrence).
# The existing submodule-only push-bypass lesson contains "push" only and must
# NOT satisfy the predicate — verified by the diagnostic output.
#
# Scope discipline (R-6/R-10): all assertions read ONLY the "### Testing
# Lessons Learned — Failure Patterns" section — delimited by that literal
# heading and bounded by the next "^## " heading — so a cycle lesson cannot
# hide elsewhere in AGENTS.md and content from other sections cannot satisfy
# the assertions.
#
# Test structure reused from test-2434-sc4b-s5-hardfail-doc-red.sh (Item 4b,
# SC-4b — string evidence type) with the target retargeted to the root
# AGENTS.md lessons section and the assertions rewritten for cycle-lesson
# presence.
#
# Artifacts: tmp/2434/artifacts/pipeline-red-sc7-*
# Usage:   bash .opencode/tests-v2/test-2434-sc7-lessons-cycle-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)
#          2 = HARNESS_FAILURE (lessons section or source file not found)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$PROJECT_ROOT/.opencode/AGENTS.md"
ART_DIR="$PROJECT_ROOT/tmp/2434/artifacts"
mkdir -p "$ART_DIR"

# Idempotence: clear this test's own stale artifacts.
rm -f "$ART_DIR"/pipeline-red-sc7-*

exec > >(tee "$ART_DIR/pipeline-red-sc7-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-sc7-test-output.err" >&2)

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

echo "== SC-7 RED check: Testing Lessons Learned carries a commit/push/fetch cycle lesson (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Sanity: the doc must exist and carry the lessons heading.
# ---------------------------------------------------------------------------
if [ ! -f "$DOC" ]; then
    echo "HARNESS_FAILURE: $DOC not found" >&2
    exit 2
fi
SEC_START=$(awk '/^### Testing Lessons Learned — Failure Patterns/{print NR; exit}' "$DOC")
SEC_END=$(awk -v s="$SEC_START" 'NR>s && /^## /{print NR; exit}' "$DOC")
if [ -z "$SEC_START" ] || [ -z "$SEC_END" ]; then
    echo "HARNESS_FAILURE: could not locate the Testing Lessons Learned section (heading '### Testing Lessons Learned — Failure Patterns' or the next '^## ' boundary) in .opencode/AGENTS.md" >&2
    exit 2
fi
echo "  [structural] lessons section spans lines $SEC_START..$((SEC_END - 1)) (next '^## ' heading at $SEC_END)"

# Extract the lessons section exactly (section-local matching — R-6 surface).
SEC="$(sed -n "${SEC_START},$((SEC_END - 1))p" "$DOC")"

# Lesson paragraphs: bolded-title entries (**Title:** ...). Paragraph mode via
# awk RS=""; the heading paragraph and blank-line-separated prose are filtered
# by the leading '**' marker that every lesson entry carries.
LESSON_COUNT=$(printf '%s\n' "$SEC" | awk 'BEGIN{RS=""; FS="\n"} $1 ~ /^\*\*/{c++} END{print c+0}')
echo "  [structural] lesson paragraphs (bolded-title entries) in section: $LESSON_COUNT"

# ---------------------------------------------------------------------------
# Assertion 1 (sanity, RED-anchoring) — the section exists and carries at
# least one lesson entry. Today: 7 lessons → PASS. This anchors the RED state
# in a live, populated section (the section is not empty; the cycle lesson is
# simply missing from it).
# ---------------------------------------------------------------------------
if [ "$LESSON_COUNT" -ge 1 ]; then
    check_pass "sanity: Testing Lessons Learned section exists and carries lesson entries ($LESSON_COUNT lessons)"
else
    check_fail "sanity: Testing Lessons Learned section exists and carries lesson entries" \
        "0 lesson paragraphs found in section lines $SEC_START..$((SEC_END - 1)) — section missing or malformed"
fi

# ---------------------------------------------------------------------------
# Assertion 2 (sanity, GREEN-rewrite anchor) — the existing stale-lock lesson
# is retained. GREEN (step 58) must ADD the cycle lesson without removing
# existing entries. Today: present → PASS.
# ---------------------------------------------------------------------------
if printf '%s\n' "$SEC" | grep -qi 'Stale lock files'; then
    check_pass "sanity: existing stale-lock lesson retained (anchor for the GREEN addition)"
else
    check_fail "sanity: existing stale-lock lesson retained" \
        "the '**Stale lock files:**' entry vanished — GREEN must preserve existing lessons (spec R-6 context)"
fi

# ---------------------------------------------------------------------------
# Assertion 3 (THE RED assertion) — at least one lesson paragraph contains
# the commit/push/fetch cycle vocabulary (all three words, case-insensitive,
# co-occurring in one bolded-title lesson paragraph). Today: 0 such
# paragraphs → FAIL.
# ---------------------------------------------------------------------------
CYCLE_LESSONS=$(printf '%s\n' "$SEC" | awk '
    BEGIN{RS=""; FS="\n"}
    $1 ~ /^\*\*/ {
        text=tolower($0)
        if (text ~ /commit/ && text ~ /push/ && text ~ /fetch/) { c++ }
    }
    END{print c+0}
')
echo "  [structural] cycle-lesson paragraphs (commit+push+fetch co-occurrence): $CYCLE_LESSONS"
if [ "$CYCLE_LESSONS" -ge 1 ]; then
    check_pass "Testing Lessons Learned contains a commit/push/fetch cycle lesson"
else
    check_fail "Testing Lessons Learned contains a commit/push/fetch cycle lesson" \
        "0 of $LESSON_COUNT lesson paragraphs mention commit+push+fetch together — no cycle lesson exists in the section (lines $SEC_START..$((SEC_END - 1)))"
fi

# ---------------------------------------------------------------------------
# Assertion 4 — the cycle lesson references the §4 infrastructure-maintenance
# carve-out (the authorization basis for agent commit+push remediation, per
# the plan's GREEN step: 'referencing the implemented gate behavior and the
# §4 carve-out'). Searched within cycle-lesson paragraphs; falls back to
# section-wide §4/infrastructure-maintenance reference when a cycle lesson
# exists but defers to a section-wide reference. Today: neither exists → FAIL.
# ---------------------------------------------------------------------------
CARVEOUT_IN_CYCLE=$(printf '%s\n' "$SEC" | awk '
    BEGIN{RS=""; FS="\n"}
    $1 ~ /^\*\*/ {
        text=tolower($0)
        if (text ~ /commit/ && text ~ /push/ && text ~ /fetch/ && (text ~ /§4/ || text ~ /infrastructure-maintenance/)) { c++ }
    }
    END{print c+0}
')
CARVEOUT_IN_SECTION=$(printf '%s\n' "$SEC" | grep -ciE '§4|infrastructure-maintenance' || true)
echo "  [structural] §4 carve-out reference in cycle lesson: $CARVEOUT_IN_CYCLE; anywhere in section: $CARVEOUT_IN_SECTION"
if [ "$CYCLE_LESSONS" -ge 1 ] && [ "$CARVEOUT_IN_CYCLE" -ge 1 ]; then
    check_pass "cycle lesson references the §4 infrastructure-maintenance carve-out"
elif [ "$CYCLE_LESSONS" -ge 1 ] && [ "$CARVEOUT_IN_SECTION" -ge 1 ]; then
    check_pass "cycle lesson present with section-wide §4 carve-out reference"
else
    check_fail "cycle lesson references the §4 infrastructure-maintenance carve-out" \
        "no cycle lesson exists and no §4/infrastructure-maintenance reference anywhere in the lessons section — the GREEN lesson must reference the §4 carve-out (plan step 58)"
fi

# ---------------------------------------------------------------------------
# Structural evidence
# ---------------------------------------------------------------------------
local_head="$(git -C "$PROJECT_ROOT/.opencode" rev-parse HEAD 2>/dev/null || echo unknown)"
{
    echo "test: SC-7 Testing Lessons Learned carries a commit/push/fetch cycle lesson (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-7, string)"
    echo "plan_item: Item 7 step 57 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "doc: .opencode/AGENTS.md"
    echo "section_start_line: $SEC_START"
    echo "section_end_line: $((SEC_END - 1))"
    echo "lesson_count: $LESSON_COUNT (not hardcoded — structural predicate)"
    echo "cycle_lesson_count: $CYCLE_LESSONS"
    echo "carveout_in_cycle_lesson: $CARVEOUT_IN_CYCLE"
    echo "carveout_in_section: $CARVEOUT_IN_SECTION"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
} > "$ART_DIR/pipeline-red-sc7-structural.txt"

echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "RED state confirmed: SC-7 lessons entry not implemented — .opencode/AGENTS.md"
    echo "'Testing Lessons Learned — Failure Patterns' carries $LESSON_COUNT lessons, none of"
    echo "which is a commit/push/fetch cycle lesson (no lesson paragraph co-mentions"
    echo "commit+push+fetch; no §4 carve-out reference)."
    verdict="RED"
    final_rc=1
else
    echo ""
    echo "GREEN: all SC-7 assertions pass."
    verdict="GREEN"
    final_rc=0
fi

{
    echo "test: SC-7 Testing Lessons Learned carries a commit/push/fetch cycle lesson (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-7, string)"
    echo "plan_item: Item 7 step 57 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "section_start_line: $SEC_START"
    echo "section_end_line: $((SEC_END - 1))"
    echo "lesson_count: $LESSON_COUNT"
    echo "cycle_lesson_count: $CYCLE_LESSONS"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: ${verdict:-RED}"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-sc7-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-sc7-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-sc7-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-sc7-exit-code"
} > "$ART_DIR/pipeline-red-sc7-summary.yaml"

sed -i 's/^verdict: .*$/verdict: '"$verdict"'/' "$ART_DIR/pipeline-red-sc7-summary.yaml"
echo "$final_rc" > "$ART_DIR/pipeline-red-sc7-exit-code"
exit "$final_rc"