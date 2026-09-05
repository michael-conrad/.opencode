#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-6 — skills/test-driven-development/SKILL.md
# Per-Change TDD Pattern + RED-Phase Ordering encode a PUSH step between
# COMMIT and the next RED for behavioral items
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-6, evidence type: string)
# Plan:   .opencode/.issues/2434/plan.md — Item 6, step 51 (RED)
#
# SC-6: for behavioral items, a PUSH step appears between COMMIT and the
# next RED in BOTH the Per-Change TDD Pattern table and the RED-Phase
# Ordering numbered list, with ordering identical to 091 (no contradiction
# with the #2433 commit-inline plan pattern — PUSH scoped to behavioral
# items, regular items keep commit-last).
#
# RED state (today): the Per-Change TDD Pattern section ("### Per-Change
# TDD Pattern", lines 261–268) ends its cycle table at **COMMIT** (line
# 268) — the row sequence is RED | GREEN | REFACTOR | COMMIT and no
# **PUSH** row exists. The RED-Phase Ordering section ("### RED-Phase
# Ordering (BEHAVIORAL PRIMARY) — MANDATORY", lines 330–337) ends its
# numbered list at "4. **COMMIT**" (line 337) and no step 5 exists. The
# assertions below target the DESIRED SKILL.md content, so they FAIL
# today. That non-zero exit IS the RED verdict (RED != FALSE: the check
# executes grep/awk against the live file and observes the missing PUSH
# step and missing ordering — it is not a file-existence or count-only
# query).
#
# Scope discipline (I4): each section is delimited by its "### " heading up
# to the next heading, so table/list assertions cannot be satisfied by prose
# elsewhere in the skill and cannot leak across sections.
#
# Artifacts: tmp/2434/artifacts/pipeline-red-sc6-*
# Usage:   bash .opencode/tests-v2/test-2434-sc6-skill-push-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)
#          2 = HARNESS_FAILURE (section or source file not found)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$PROJECT_ROOT/.opencode/skills/test-driven-development/SKILL.md"
ART_DIR="$PROJECT_ROOT/tmp/2434/artifacts"
mkdir -p "$ART_DIR"

# Idempotence: clear this test's own stale artifacts.
rm -f "$ART_DIR"/pipeline-red-sc6-*

exec > >(tee "$ART_DIR/pipeline-red-sc6-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-sc6-test-output.err" >&2)

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

echo "== SC-6 RED check: TDD SKILL.md PUSH step between COMMIT and next RED (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Sanity: the doc must exist and carry both target sections.
# ---------------------------------------------------------------------------
if [ ! -f "$DOC" ]; then
    echo "HARNESS_FAILURE: $DOC not found" >&2
    exit 2
fi

resolve_section() { # $1 = heading regex; sets S_START/S_END globals
    S_START=$(awk -v h="$1" '$0 ~ h{print NR; exit}' "$DOC")
    if [ -z "$S_START" ]; then
        return 1
    fi
    S_END=$(awk -v s="$S_START" 'NR>s && (/^## / || /^### /){print NR; exit}' "$DOC")
    if [ -z "$S_END" ]; then
        return 1
    fi
    return 0
}

if ! resolve_section '^### Per-Change TDD Pattern$'; then
    echo "HARNESS_FAILURE: could not locate '### Per-Change TDD Pattern' heading in SKILL.md" >&2
    exit 2
fi
P1_START="$S_START"
P1_END="$S_END"

if ! resolve_section '^### RED-Phase Ordering'; then
    echo "HARNESS_FAILURE: could not locate '### RED-Phase Ordering' heading in SKILL.md" >&2
    exit 2
fi
P2_START="$S_START"
P2_END="$S_END"

echo "  [structural] Per-Change TDD Pattern spans lines $P1_START..$((P1_END - 1)) (next heading at $P1_END)"
echo "  [structural] RED-Phase Ordering spans lines $P2_START..$((P2_END - 1)) (next heading at $P2_END)"

P1="$(sed -n "${P1_START},$((P1_END - 1))p" "$DOC")"
P2="$(sed -n "${P2_START},$((P2_END - 1))p" "$DOC")"

p1_row_line() { # $1 = phase key; prints first matching **KEY** table-row line number or empty
    awk -v s="$P1_START" -v e="$P1_END" -v k="$1" \
        'NR>=s && NR<e && $0 ~ ("^\\|[[:space:]]*\\*\\*" k "\\*\\*([[:space:]]*\\||$)"){print NR; exit}' "$DOC"
}
p2_step_line() { # $1 = step number + phase key; prints first matching numbered-step line number or empty
    awk -v s="$P2_START" -v e="$P2_END" -v k="$1" \
        'NR>=s && NR<e && $0 ~ ("^[[:space:]]*[0-9]+\\.[[:space:]]*\\*\\*" k "\\*\\*"){print NR; exit}' "$DOC"
}

# ---------------------------------------------------------------------------
# Sanity 1 — the Per-Change TDD Pattern table retains the four pre-existing
# phase rows. Sanity assertion — this is the vocabulary the GREEN amendment
# must preserve. Today: PRESENT → PASS (RED-anchoring sanity, not a target).
# ---------------------------------------------------------------------------
SANITY1_OK=1
for key in RED GREEN REFACTOR COMMIT; do
    if ! printf '%s\n' "$P1" | grep -qE "^\|[[:space:]]*\*\*${key}\*\*([[:space:]]*\||[[:space:]]*$)"; then
        SANITY1_OK=0
    fi
done
if [ "$SANITY1_OK" -eq 1 ]; then
    check_pass "sanity: Per-Change TDD Pattern retains the RED/GREEN/REFACTOR/COMMIT phase rows (pre-existing anchors for the GREEN amendment)"
else
    check_fail "sanity: Per-Change TDD Pattern retains the RED/GREEN/REFACTOR/COMMIT phase rows" \
        "a pre-existing phase row vanished — GREEN must preserve the cycle vocabulary (spec R-7)"
fi

# ---------------------------------------------------------------------------
# Sanity 2 — the RED-Phase Ordering list retains its four numbered steps.
# Today: PRESENT → PASS.
# ---------------------------------------------------------------------------
SANITY2_OK=1
for key in RED GREEN REFACTOR COMMIT; do
    if ! printf '%s\n' "$P2" | grep -qE "^[[:space:]]*[0-9]+\\.[[:space:]]*\\*\\*${key}\\*\\*"; then
        SANITY2_OK=0
    fi
done
if [ "$SANITY2_OK" -eq 1 ]; then
    check_pass "sanity: RED-Phase Ordering retains the numbered RED/GREEN/REFACTOR/COMMIT steps (pre-existing anchors for the GREEN amendment)"
else
    check_fail "sanity: RED-Phase Ordering retains the numbered RED/GREEN/REFACTOR/COMMIT steps" \
        "a pre-existing numbered step vanished — GREEN must preserve the cycle vocabulary (spec R-7)"
fi

# ---------------------------------------------------------------------------
# Assertion A — a PUSH step (table row) exists in the Per-Change TDD Pattern.
# Today: the table ends at COMMIT, PUSH absent → FAIL.
# ---------------------------------------------------------------------------
P1_PUSH_LINE="$(p1_row_line PUSH)"
P1_PUSH_ROW=""
if [ -n "$P1_PUSH_LINE" ]; then
    P1_PUSH_ROW="$(sed -n "${P1_PUSH_LINE}p" "$DOC")"
fi
if [ -n "$P1_PUSH_LINE" ]; then
    check_pass "Per-Change TDD Pattern carries a PUSH step (row '$(printf '%s' "$P1_PUSH_ROW" | cut -c1-80)…')"
else
    check_fail "Per-Change TDD Pattern carries a PUSH step" \
        "no '| **PUSH** |' row found in the Per-Change TDD Pattern table (lines $P1_START..$((P1_END - 1))) — the pattern ends at COMMIT (line $(p1_row_line COMMIT))"
fi

# ---------------------------------------------------------------------------
# Assertion B — ordering in the table: PUSH appears after COMMIT (between
# COMMIT and the next RED). Today: no PUSH row → FAIL.
# ---------------------------------------------------------------------------
P1_COMMIT_LINE="$(p1_row_line COMMIT)"
if [ -n "$P1_COMMIT_LINE" ] && [ -n "$P1_PUSH_LINE" ] && [ "$P1_PUSH_LINE" -gt "$P1_COMMIT_LINE" ]; then
    check_pass "Per-Change TDD Pattern ordering encodes PUSH after COMMIT (COMMIT at line $P1_COMMIT_LINE, PUSH at line $P1_PUSH_LINE)"
else
    check_fail "Per-Change TDD Pattern ordering encodes PUSH after COMMIT" \
        "PUSH row absent or misordered (COMMIT=${P1_COMMIT_LINE:-none} PUSH=${P1_PUSH_LINE:-none}) — PUSH between COMMIT and next RED not encoded"
fi

# ---------------------------------------------------------------------------
# Assertion C — behavioral scoping in the table row (#2433 commit-inline
# non-contradiction, I4 identical to 091): the PUSH row names behavioral
# items so regular items keep commit-last. Today: no PUSH row → FAIL.
# ---------------------------------------------------------------------------
if [ -n "$P1_PUSH_LINE" ] && printf '%s' "$P1_PUSH_ROW" | grep -qi 'behavioral'; then
    check_pass "Per-Change TDD Pattern PUSH step is scoped to behavioral items (#2433 commit-inline pattern preserved)"
else
    check_fail "Per-Change TDD Pattern PUSH step is scoped to behavioral items (#2433 commit-inline non-contradiction)" \
        "no behavioral-scoped PUSH row exists (row line ${P1_PUSH_LINE:-none}) — a universal unscoped PUSH step would contradict the #2433 commit-inline plan pattern"
fi

# ---------------------------------------------------------------------------
# Assertion D — a PUSH step (numbered list entry) exists in the RED-Phase
# Ordering. Today: the list ends at 4. **COMMIT**, PUSH absent → FAIL.
# ---------------------------------------------------------------------------
P2_PUSH_LINE="$(p2_step_line PUSH)"
P2_PUSH_ROW=""
if [ -n "$P2_PUSH_LINE" ]; then
    P2_PUSH_ROW="$(sed -n "${P2_PUSH_LINE}p" "$DOC")"
fi
if [ -n "$P2_PUSH_LINE" ]; then
    check_pass "RED-Phase Ordering carries a PUSH step ('$(printf '%s' "$P2_PUSH_ROW" | cut -c1-80)…')"
else
    check_fail "RED-Phase Ordering carries a PUSH step" \
        "no numbered PUSH step found in the RED-Phase Ordering list (lines $P2_START..$((P2_END - 1))) — the cycle ends at COMMIT ('4. **COMMIT**' at line $(p2_step_line COMMIT))"
fi

# ---------------------------------------------------------------------------
# Assertion E — ordering in the list: PUSH appears after COMMIT (between
# COMMIT and the next RED). Today: no PUSH step → FAIL.
# ---------------------------------------------------------------------------
P2_COMMIT_LINE="$(p2_step_line COMMIT)"
if [ -n "$P2_COMMIT_LINE" ] && [ -n "$P2_PUSH_LINE" ] && [ "$P2_PUSH_LINE" -gt "$P2_COMMIT_LINE" ]; then
    check_pass "RED-Phase Ordering encodes PUSH after COMMIT (COMMIT step at line $P2_COMMIT_LINE, PUSH step at line $P2_PUSH_LINE)"
else
    check_fail "RED-Phase Ordering encodes PUSH after COMMIT" \
        "PUSH step absent or misordered (COMMIT=${P2_COMMIT_LINE:-none} PUSH=${P2_PUSH_LINE:-none}) — PUSH between COMMIT and next RED not encoded"
fi

# ---------------------------------------------------------------------------
# Assertion F — behavioral scoping in the list step (#2433 commit-inline
# non-contradiction, I4 identical to 091): the PUSH step names behavioral
# items so regular items keep commit-last. Today: no PUSH step → FAIL.
# ---------------------------------------------------------------------------
if [ -n "$P2_PUSH_LINE" ] && printf '%s' "$P2_PUSH_ROW" | grep -qi 'behavioral'; then
    check_pass "RED-Phase Ordering PUSH step is scoped to behavioral items (#2433 commit-inline pattern preserved)"
else
    check_fail "RED-Phase Ordering PUSH step is scoped to behavioral items (#2433 commit-inline non-contradiction)" \
        "no behavioral-scoped PUSH step exists (step line ${P2_PUSH_LINE:-none}) — a universal unscoped PUSH step would contradict the #2433 commit-inline plan pattern"
fi

# ---------------------------------------------------------------------------
# Structural evidence
# ---------------------------------------------------------------------------
local_head="$(git -C "$PROJECT_ROOT/.opencode" rev-parse HEAD 2>/dev/null || echo unknown)"
P1_COMMIT_OFFSET="$(printf '%s' "$P1" | grep -Eiob 'commit' | head -1 | cut -d: -f1 || true)"
P1_PUSH_OFFSET="$(printf '%s' "$P1" | grep -Eiob 'push' | head -1 | cut -d: -f1 || true)"
P2_COMMIT_OFFSET="$(printf '%s' "$P2" | grep -Eiob 'commit' | head -1 | cut -d: -f1 || true)"
P2_PUSH_OFFSET="$(printf '%s' "$P2" | grep -Eiob 'push' | head -1 | cut -d: -f1 || true)"
{
    echo "test: SC-6 TDD SKILL.md PUSH step between COMMIT and next RED (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-6, string)"
    echo "plan_item: Item 6 step 51 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "doc: .opencode/skills/test-driven-development/SKILL.md"
    echo "pattern_section_start_line: $P1_START"
    echo "pattern_section_end_line: $((P1_END - 1))"
    echo "pattern_next_heading_line: $P1_END"
    echo "ordering_section_start_line: $P2_START"
    echo "ordering_section_end_line: $((P2_END - 1))"
    echo "ordering_next_heading_line: $P2_END"
    echo "pattern_row_lines: RED=$(p1_row_line RED) GREEN=$(p1_row_line GREEN) REFACTOR=$(p1_row_line REFACTOR) COMMIT=$(p1_row_line COMMIT) PUSH=${P1_PUSH_LINE:-none}"
    echo "ordering_step_lines: RED=$(p2_step_line RED) GREEN=$(p2_step_line GREEN) REFACTOR=$(p2_step_line REFACTOR) COMMIT=$(p2_step_line COMMIT) PUSH=${P2_PUSH_LINE:-none}"
    echo "flattened_word_offsets: pattern_commit=$P1_COMMIT_OFFSET pattern_push=${P1_PUSH_OFFSET:-none} ordering_commit=$P2_COMMIT_OFFSET ordering_push=${P2_PUSH_OFFSET:-none} (byte offsets in flattened sections; push absent today)"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
} > "$ART_DIR/pipeline-red-sc6-structural.txt"

if [ "$FAIL_COUNT" -gt 0 ]; then
    verdict="RED"
    final_rc=1
else
    verdict="GREEN"
    final_rc=0
fi

{
    echo "test: SC-6 TDD SKILL.md PUSH step between COMMIT and next RED (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-6, string)"
    echo "plan_item: Item 6 step 51 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "doc: .opencode/skills/test-driven-development/SKILL.md"
    echo "pattern_section_start_line: $P1_START"
    echo "ordering_section_start_line: $P2_START"
    echo "pattern_row_lines: RED=$(p1_row_line RED) GREEN=$(p1_row_line GREEN) REFACTOR=$(p1_row_line REFACTOR) COMMIT=$(p1_row_line COMMIT) PUSH=${P1_PUSH_LINE:-none}"
    echo "ordering_step_lines: RED=$(p2_step_line RED) GREEN=$(p2_step_line GREEN) REFACTOR=$(p2_step_line REFACTOR) COMMIT=$(p2_step_line COMMIT) PUSH=${P2_PUSH_LINE:-none}"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: $verdict"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-sc6-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-sc6-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-sc6-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-sc6-exit-code"
} > "$ART_DIR/pipeline-red-sc6-summary.yaml"

echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$final_rc" -eq 1 ]; then
    echo ""
    echo "RED state confirmed: SC-6 SKILL.md PUSH-step amendment not implemented — the"
    echo "Per-Change TDD Pattern table ends at **COMMIT** (line ${P1_COMMIT_LINE:-?}) with no PUSH"
    echo "row, and the RED-Phase Ordering list ends at '4. **COMMIT**' (line ${P2_COMMIT_LINE:-?})"
    echo "with no step 5 — PUSH between COMMIT and the next RED is absent from both sections."
else
    echo ""
    echo "GREEN: all SC-6 assertions pass."
fi
echo "$final_rc" > "$ART_DIR/pipeline-red-sc6-exit-code"
exit "$final_rc"