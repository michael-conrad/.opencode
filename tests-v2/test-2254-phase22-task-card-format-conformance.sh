#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 22 — task-card format conformance
# verification for spec-creation and audit task cards.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 22 — task-card format conformance verification (prep,
#        after SC-25/SC-43), target `.opencode/skills/spec-creation/tasks/*.md`
#        and `.opencode/skills/audit/tasks/*.md`. Depends on Phase 21.
#
# Phase 22 (preparation, no SC): Produce the task-card format conformance
#   verification artifact confirming all spec-creation and audit task cards use
#   the canonical numbered-checkbox Procedure format (`- [ ] N.`) and that NO
#   plain numbered list (`N. ` at line start) remains in any task-card
#   Procedure section.
#
# The conformance verification artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/task-card-format-conformance-inventory.yaml`;
#   (b) enumerate every spec-creation and audit task card and record whether its
#       Procedure section is conformant (`numbered-checkbox`) or non-conformant
#       (`plain-numbered-list`);
#   (c) declare the total task-card count and the non-conformant (plain-numbered-list)
#       count.
#
# RED state: (1) the conformance verification artifact does not exist yet; and
#   (2) the following task cards still contain plain numbered list items in
#   their `## Procedure` sections (so "no plain numbered lists remain" is FALSE):
#     - spec-creation/tasks/analyze.md
#     - spec-creation/tasks/revise.md
#     - spec-creation/tasks/validate.md
#     - audit/tasks/spec-audit-evaluator.md
#     - audit/tasks/spec-audit-validator.md
#     - audit/tasks/verification-audit-evaluator.md
#   GREEN converts every remaining plain-numbered-list Procedure to the canonical
#   numbered-checkbox format and produces the conformance verification artifact
#   declaring all cards conformant.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the on-disk Procedure format of every spec-creation/audit task card
#   and the existence/completeness of the conformance verification artifact.
#   It is the RED/GREEN gate for the Phase 22 conformance deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase22-task-card-format-conformance.sh
# Exit:  0 if every task-card Procedure is numbered-checkbox AND the conformance
#        artifact is complete (GREEN),
#        1 otherwise (RED).
#
# Co-authored with AI: OpenCode (deepseek-ai/DeepSeek-V4-Flash-0731)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/task-card-format-conformance-inventory.yaml"

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
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# Detect whether a task card's `## Procedure` section contains a plain numbered
# list item (`N. ` at line start). A conformant card uses numbered-checkbox
# markers (`- [ ] N.`) and has NO plain numbered list items.
has_plain_numbered_list() {
    local f="$1"
    local section
    section="$(awk '/^## Procedure/{flag=1; next} /^## /{if (flag) exit} flag' "$f")"
    if echo "$section" | grep -qE '^[[:space:]]*[0-9]+\. '; then
        return 0
    fi
    return 1
}

echo ""
echo "=== Phase 22 — task-card format conformance verification (Spec .opencode#2254) ==="
echo ""
echo "Target dirs: .opencode/skills/spec-creation/tasks, .opencode/skills/audit/tasks"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# (1) On-disk conformance: NO plain numbered list remains in ANY spec-creation
#     or audit task-card Procedure section. This is the core RED assertion.
# ---------------------------------------------------------------------------
echo "--- (1): no plain numbered list remains in any task-card Procedure section ---"

NON_CONFORMANT=0
declare -a PLAIN_CARDS=()
for skill_dir in spec-creation audit; do
    dir="$PROJECT_DIR/.opencode/skills/$skill_dir/tasks"
    if [ ! -d "$dir" ]; then
        check_fail "Phase 22: $skill_dir/tasks dir exists" "tasks directory not found"
        NON_CONFORMANT=$((NON_CONFORMANT + 1))
        continue
    fi
    for f in "$dir"/*.md; do
        [ -e "$f" ] || continue
        rel="$skill_dir/tasks/$(basename "$f")"
        if has_plain_numbered_list "$f"; then
            check_fail "Phase 22: $rel Procedure uses numbered-checkbox format (no plain numbered list)" \
                "plain numbered list item ('N. ') remains in the Procedure section"
            NON_CONFORMANT=$((NON_CONFORMANT + 1))
            PLAIN_CARDS+=("$rel")
        else
            check_pass "Phase 22: $rel Procedure uses numbered-checkbox format (no plain numbered list)"
        fi
    done
done

if [ "$NON_CONFORMANT" -eq 0 ]; then
    check_pass "Phase 22: no plain numbered list remains in any spec-creation/audit task-card Procedure section"
fi

# ---------------------------------------------------------------------------
# (2) The conformance verification artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (2): task-card format conformance verification artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 22: conformance verification artifact exists at $ARTIFACT"
else
    check_fail "Phase 22: conformance verification artifact exists" \
        "missing $ARTIFACT (GREEN must produce the task-card format conformance verification artifact)"
fi

# ---------------------------------------------------------------------------
# (3) The artifact enumerates every spec-creation and audit task card and
#     records its Procedure format.
# ---------------------------------------------------------------------------
echo "--- (3): artifact enumerates every spec-creation/audit task card ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "task_cards:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 22: artifact declares a task_cards list"
    else
        check_fail "Phase 22: artifact declares a task_cards list" \
            "no 'task_cards:' key in $ARTIFACT"
    fi

    for skill_dir in spec-creation audit; do
        dir="$PROJECT_DIR/.opencode/skills/$skill_dir/tasks"
        [ -d "$dir" ] || continue
        for f in "$dir"/*.md; do
            [ -e "$f" ] || continue
            rel="$skill_dir/tasks/$(basename "$f")"
            if grep -q "card: $rel" "$ARTIFACT" 2>/dev/null; then
                check_pass "Phase 22: artifact inventories task card $rel"
            else
                check_fail "Phase 22: artifact inventories task card $rel" \
                    "no 'card: $rel' entry in $ARTIFACT"
            fi
        done
    done

    # ---------------------------------------------------------------------------
    # (4) The artifact declares the non-conformant (plain-numbered-list) count.
    # ---------------------------------------------------------------------------
    echo "--- (4): artifact declares the plain-numbered-list count ---"
    if grep -q "plain_numbered_list_count:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 22: artifact declares a plain_numbered_list_count"
    else
        check_fail "Phase 22: artifact declares a plain_numbered_list_count" \
            "no 'plain_numbered_list_count:' key in $ARTIFACT"
    fi
else
    check_fail "Phase 22: artifact enumerates every task card" \
        "artifact missing — cannot verify task-card conformance coverage"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 22 (task-card format conformance verification)"
    echo "not yet implemented. The conformance verification artifact at $ARTIFACT"
    echo "is missing, and the following task cards still contain plain numbered"
    echo "list items in their Procedure sections:"
    for c in "${PLAIN_CARDS[@]:-}"; do
        echo "  - $c"
    done
    echo "GREEN converts every remaining plain-numbered-list Procedure to the"
    echo "canonical numbered-checkbox format and produces the conformance"
    echo "verification artifact declaring all cards conformant."
    echo ""
    exit 1
fi
echo "Phase 22 is GREEN — every spec-creation and audit task-card Procedure uses"
echo "the canonical numbered-checkbox format (no plain numbered list remains),"
echo "and the conformance verification artifact enumerates all cards as conformant."
echo ""
exit 0
