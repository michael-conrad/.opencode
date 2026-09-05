#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# RED-phase enforcement test: SC-4b — tests-v2/AGENTS.md §5 submodule-checkout
# paragraph describes the hard FAIL with no WARNING-fallback language
#
# Issue: .opencode#2434 — test-framework commit/push/fetch/checkout cycle.
# Spec:   .opencode/.issues/2434/spec.md (SC-4b, evidence type: string)
# Plan:   .opencode/.issues/2434/plan.md — Item 4b, step 39 (RED)
#
# SC-4b: tests-v2/AGENTS.md §5 submodule-checkout paragraph describes the
# hard FAIL with no WARNING-fallback language.
#
# RED state (today): §5 "Submodule Checkout" (#### Submodule Checkout, inside
# ## 5. Infrastructure Details) documents the WARNING fallback verbatim:
#   "If the commit is not pushed to remote, a WARNING is emitted and the
#    remote default branch is used instead."
# No hard-FAIL behavior is described anywhere in the subsection — no exit/non-
# zero/hard-fail language exists there. The assertions below target the DESIRED
# §5 content, so they FAIL today. That non-zero exit IS the RED verdict
# (RED != FALSE: the check executes grep against the live file and observes the
# fallback language present and the hard-FAIL description absent).
#
# Scope discipline (R-6/R-10): the fallback-absence checks read ONLY the §5
# section — delimited by the literal "^## 5. Infrastructure Details" heading —
# so a fallback claim cannot hide in §4 and the §4 cycle text (Item 4a GREEN,
# already landed) cannot satisfy the §5 assertions. The hard-FAIL-description
# and anchor checks are confined further to the "#### Submodule Checkout"
# subsection — the paragraph the SC names — bounded by the next "^#### " heading.
#
# Test structure reused from test-2434-sc4a-s4-ordered-cycle-red.sh (Item 4a,
# SC-4a — same doc, same string evidence type) with the section retargeted to
# §5 and the assertions rewritten for fallback-language absence + hard-FAIL
# description presence.
#
# Artifacts: tmp/2434/artifacts/pipeline-red-sc4b-*
# Usage:   bash .opencode/tests-v2/test-2434-sc4b-s5-hardfail-doc-red.sh
# Exit:    0 = all assertions pass (GREEN state reached)
#          1 = RED state confirmed (expected today)
#          2 = HARNESS_FAILURE (§5 section or source file not found)

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$PROJECT_ROOT/.opencode/tests-v2/AGENTS.md"
ART_DIR="$PROJECT_ROOT/tmp/2434/artifacts"
mkdir -p "$ART_DIR"

# Idempotence: clear this test's own stale artifacts.
rm -f "$ART_DIR"/pipeline-red-sc4b-*

exec > >(tee "$ART_DIR/pipeline-red-sc4b-test-output.log") 2> >(tee "$ART_DIR/pipeline-red-sc4b-test-output.err" >&2)

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

echo "== SC-4b RED check: §5 submodule-checkout hard-FAIL doc, no WARNING fallback (.opencode#2434) =="

# ---------------------------------------------------------------------------
# Sanity: the doc must exist and carry the §5 heading.
# ---------------------------------------------------------------------------
if [ ! -f "$DOC" ]; then
    echo "HARNESS_FAILURE: $DOC not found" >&2
    exit 2
fi
S5_START=$(awk '/^## 5\. Infrastructure Details/{print NR; exit}' "$DOC")
S6_START=$(awk 'NR>1 && /^## 6\. Relationship to Content-Verification Tests/{print NR; exit}' "$DOC")
if [ -z "$S5_START" ] || [ -z "$S6_START" ]; then
    echo "HARNESS_FAILURE: could not locate §5 (## 5. Infrastructure Details) or §6 (## 6. Relationship to Content-Verification Tests) boundaries in tests-v2/AGENTS.md" >&2
    exit 2
fi
echo "  [structural] §5 spans lines $S5_START..$((S6_START - 1)) (§6 starts at $S6_START)"

# Extract §5 exactly (section-local matching — R-6 fallback-absence surface).
S5="$(sed -n "${S5_START},$((S6_START - 1))p" "$DOC")"
S5_LINES=$((S6_START - S5_START))

# Locate the Submodule Checkout subsection inside §5 (paragraph the SC names).
SUB_START=$(awk 'NR>1 && /^#### Submodule Checkout/{print NR; exit}' "$DOC")
if [ -z "$SUB_START" ]; then
    echo "HARNESS_FAILURE: could not locate '#### Submodule Checkout' subsection in §5" >&2
    exit 2
fi
SUB_END=$(awk -v s="$SUB_START" 'NR>s && /^#### /{print NR; exit}' "$DOC")
[ -n "$SUB_END" ] || SUB_END="$S6_START"
SUB="$(sed -n "${SUB_START},$((SUB_END - 1))p" "$DOC")"
echo "  [structural] Submodule Checkout subsection spans lines $SUB_START..$((SUB_END - 1))"

# ---------------------------------------------------------------------------
# Assertion 1 — §5 contains NO "using remote default branch" WARNING-fallback
# claim (§5-wide, per the SC verification method). Matches BOTH forms:
#   (a) literal harness-message form: "using remote default branch"
#   (b) doc-prose fallback form: "remote default branch" co-occurring on the
#       same line with WARNING/is used/used instead/instead continuation
#       semantics (today's §5 line: "...a WARNING is emitted and the remote
#       default branch is used instead.")
# Today: present at the Submodule Checkout paragraph → FAIL.
# ---------------------------------------------------------------------------
fallback_lit=$(printf '%s\n' "$S5" | grep -ci 'using remote default branch' || true)
fallback_prose=$(printf '%s\n' "$S5" | grep -i 'remote default branch' | grep -ciE '(a )?warning|is used|used instead|instead' || true)
fallback_count=$((fallback_lit + fallback_prose))
echo "  [structural] WARNING-fallback claims in §5: $fallback_count (literal form: $fallback_lit, prose form: $fallback_prose)"
if [ "$fallback_count" -eq 0 ]; then
    check_pass "§5 contains no 'using remote default branch' WARNING-fallback claim"
else
    check_fail "§5 contains no 'using remote default branch' WARNING-fallback claim" \
        "$fallback_count occurrence(s) in §5 lines $S5_START..$((S6_START - 1)) (literal: $fallback_lit, prose: $fallback_prose) — the WARNING fallback is documented as live behavior"
fi

# ---------------------------------------------------------------------------
# Assertion 2 — the Submodule Checkout subsection emits no WARNING fallback:
# neither "a WARNING is emitted" nor the harness message form
# "WARNING: could not checkout". Today: present → FAIL.
# ---------------------------------------------------------------------------
warn_emitted=$(printf '%s\n' "$SUB" | grep -ci 'WARNING is emitted' || true)
warn_msg=$(printf '%s\n' "$SUB" | grep -ci 'WARNING: could not checkout' || true)
echo "  [structural] 'WARNING is emitted' in subsection: $warn_emitted; 'WARNING: could not checkout' in subsection: $warn_msg"
if [ "$warn_emitted" -eq 0 ] && [ "$warn_msg" -eq 0 ]; then
    check_pass "Submodule Checkout subsection documents no WARNING emission/fallback"
else
    check_fail "Submodule Checkout subsection documents no WARNING emission/fallback" \
        "WARNING-fallback language present (emission claims: $warn_emitted, harness-message form: $warn_msg) — the degraded run is documented instead of the hard FAIL"
fi

# ---------------------------------------------------------------------------
# Assertion 3 — the subsection DESCRIBES the hard FAIL: exit/non-zero/fail
# language must be present (the SC's "FAIL behavior described" element).
# Today: the subsection carries no fail/exit language at all → FAIL.
# ---------------------------------------------------------------------------
if printf '%s\n' "$SUB" | grep -qiE '(hard[ -]?fail|exit(s|ing)?[^.]*non-?zero|non-?zero[^.]*exit|FAILS|exits non-zero|exit 1)'; then
    check_pass "Submodule Checkout subsection describes the hard-FAIL checkout behavior"
else
    check_fail "Submodule Checkout subsection describes the hard-FAIL checkout behavior" \
        "no hard-fail/exit-non-zero language in the subsection (lines $SUB_START..$((SUB_END - 1))) — only the WARNING fallback is documented"
fi

# ---------------------------------------------------------------------------
# Assertion 4 (sanity, RED-anchoring) — the subsection retains the
# clone-from-remote + checkout-local-submodule-HEAD semantics. This is the
# pre-existing content the GREEN rewrite must preserve while replacing the
# WARNING sentence with hard-FAIL language. Today: PRESENT → PASS.
# ---------------------------------------------------------------------------
if printf '%s\n' "$SUB" | grep -qi 'clone' && printf '%s\n' "$SUB" | grep -qi 'remote'; then
    check_pass "sanity: subsection retains clone-from-remote semantics (pre-existing anchor for the GREEN rewrite)"
else
    check_fail "sanity: subsection retains clone-from-remote semantics" \
        "the clone/remote description vanished — GREEN must preserve it (spec R-6 context)"
fi

if printf '%s\n' "$SUB" | grep -qiE 'checkout|checks out' && printf '%s\n' "$SUB" | grep -qi 'submodule HEAD'; then
    check_pass "sanity: subsection retains checkout-local-submodule-HEAD semantics (pre-existing anchor for the GREEN rewrite)"
else
    check_fail "sanity: subsection retains checkout-local-submodule-HEAD semantics" \
        "the checkout-local-HEAD description vanished — GREEN must preserve it (spec R-6 context)"
fi

# ---------------------------------------------------------------------------
# Structural evidence
# ---------------------------------------------------------------------------
local_head="$(git -C "$PROJECT_ROOT/.opencode" rev-parse HEAD 2>/dev/null || echo unknown)"
{
    echo "test: SC-4b tests-v2/AGENTS.md §5 submodule-checkout hard-FAIL doc, no WARNING fallback (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-4b, string)"
    echo "plan_item: Item 4b step 39 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "doc: .opencode/tests-v2/AGENTS.md"
    echo "s5_start_line: $S5_START"
    echo "s6_start_line: $S6_START"
    echo "s5_line_span: $S5_LINES"
    echo "submodule_checkout_subsection_lines: $SUB_START..$((SUB_END - 1))"
    echo "fallback_phrase_count_s5: $fallback_count (literal: $fallback_lit, prose: $fallback_prose)"
    echo "warning_emission_count_subsection: $warn_emitted"
    echo "warning_message_count_subsection: $warn_msg"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
} > "$ART_DIR/pipeline-red-sc4b-structural.txt"

echo ""
echo "== Results =="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "RED state confirmed: SC-4b §5 rewrite not implemented — tests-v2/AGENTS.md"
    echo "§5 Submodule Checkout documents the WARNING fallback ('a WARNING is emitted"
    echo "and the remote default branch is used instead') and describes no hard-FAIL"
    echo "checkout behavior."
    verdict="RED"
    final_rc=1
else
    echo ""
    echo "GREEN: all SC-4b assertions pass."
    verdict="GREEN"
    final_rc=0
fi

{
    echo "test: SC-4b tests-v2/AGENTS.md §5 submodule-checkout hard-FAIL doc, no WARNING fallback (.opencode#2434)"
    echo "spec: .opencode/.issues/2434/spec.md (SC-4b, string)"
    echo "plan_item: Item 4b step 39 (RED)"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "s5_start_line: $S5_START"
    echo "s6_start_line: $S6_START"
    echo "submodule_checkout_subsection_lines: $SUB_START..$((SUB_END - 1))"
    echo "live_submodule_head: $local_head"
    echo "passed: $PASS_COUNT"
    echo "failed: $FAIL_COUNT"
    echo "verdict: ${verdict:-RED}"
    echo "evidence:"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4b-test-output.log"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4b-test-output.err"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4b-structural.txt"
    echo "  - tmp/2434/artifacts/pipeline-red-sc4b-exit-code"
} > "$ART_DIR/pipeline-red-sc4b-summary.yaml"

sed -i 's/^verdict: .*$/verdict: '"$verdict"'/' "$ART_DIR/pipeline-red-sc4b-summary.yaml"
echo "$final_rc" > "$ART_DIR/pipeline-red-sc4b-exit-code"
exit "$final_rc"