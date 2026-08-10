#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-31 — Workflows explicitly
# orchestrator step-by-step with execution-mode sub-bullets.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-26-workflow-clarity.
#
# SC-31 (string): The workflows in spec-creation/SKILL.md and audit/SKILL.md
#   SHALL clearly indicate they are for the orchestrator to follow step-by-step,
#   with the execution-mode sub-bullet making the inline-vs-dispatch decision
#   explicit.
#
# RED state: Both Workflows sections carry numbered-checkbox steps with
#   `Execution mode:` sub-bullets (from Phase 20), but the Workflows sections
#   themselves do NOT explicitly frame the steps as "for the orchestrator to
#   follow step-by-step". The steps read as bare imperative "Dispatch task(...)"
#   lines with no orchestrator-step framing. The orchestrator-step framing
#   assertion below FAILs on this content.
# GREEN adds explicit orchestrator-step framing to each Workflows section —
#   language stating the orchestrator follows the steps step-by-step — while
#   preserving the execution-mode sub-bullets that make the inline-vs-dispatch
#   decision explicit.
#
# Evidence type: SC-31 is a `string` SC. This content-verification test greps
#   the two SKILL.md Workflows sections for orchestrator-step framing and
#   execution-mode sub-bullets. It is the primary gate for this content-only SC
#   (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc31-workflow-clarity.sh
# Exit:  0 if both Workflows sections carry orchestrator-step framing and
#        execution-mode sub-bullets (GREEN), 1 if either still lacks explicit
#        orchestrator-step framing (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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

echo ""
echo "=== SC-31 — Workflows explicitly orchestrator step-by-step with execution-mode sub-bullets (Spec .opencode#2254) ==="
echo ""

# Extract a Workflows section (from `## Workflows` to the next `## ` heading).
extract_workflows() {
    local file="$1"
    awk '/^## Workflows/{flag=1; next} /^## /{if (flag) exit} flag' "$file"
}

# Assert a Workflows section carries orchestrator-step framing AND
# execution-mode sub-bullets. Returns 0 if both hold, 1 otherwise.
check_workflow_clarity() {
    local sc_label="$1"
    local file="$2"
    local workflows="$3"

    if [ -z "$workflows" ]; then
        check_fail "$sc_label: Workflows section extracted" "no '## Workflows' heading found in $file"
        return 1
    fi

    # --- Orchestrator-step framing ---
    # The Workflows section must clearly indicate the steps are for the
    # orchestrator to follow step-by-step. We require the word "orchestrator"
    # AND a step-by-step / follow-the-steps indicator within the section.
    local has_orchestrator=0
    local has_step_framing=0
    if echo "$workflows" | grep -qi "orchestrator"; then
        has_orchestrator=1
    fi
    if echo "$workflows" | grep -qiE "step-by-step|step by step|follow these steps|follows these steps|follow the steps|follow each step|follows each step|follow the workflow|follows the workflow"; then
        has_step_framing=1
    fi

    if [ "$has_orchestrator" -eq 1 ] && [ "$has_step_framing" -eq 1 ]; then
        check_pass "$sc_label: Workflows explicitly framed for the orchestrator to follow step-by-step"
    else
        local detail=""
        [ "$has_orchestrator" -eq 0 ] && detail="no 'orchestrator' language in Workflows section"
        [ "$has_step_framing" -eq 0 ] && detail="${detail:+$detail; }no step-by-step / follow-the-steps framing in Workflows section"
        check_fail "$sc_label: Workflows explicitly framed for the orchestrator to follow step-by-step" "$detail"
    fi

    # --- Execution-mode sub-bullet ---
    # The execution-mode sub-bullet must make the inline-vs-dispatch decision
    # explicit: `Execution mode: sub-agent dispatch` or `Execution mode: inline`.
    if echo "$workflows" | grep -qiE "execution mode:\** *(sub-agent dispatch|inline)"; then
        check_pass "$sc_label: Workflows has execution-mode sub-bullets making inline-vs-dispatch explicit"
    else
        check_fail "$sc_label: Workflows has execution-mode sub-bullets making inline-vs-dispatch explicit" \
            "no 'Execution mode: sub-agent dispatch' or 'Execution mode: inline' sub-bullet in Workflows section"
    fi
}

# ---------------------------------------------------------------------------
# spec-creation/SKILL.md Workflows section
# ---------------------------------------------------------------------------
SPEC_CREATION="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
echo "Target (SC-31): $SPEC_CREATION"

if [ ! -f "$SPEC_CREATION" ]; then
    check_fail "SC-31: target file exists" "spec-creation/SKILL.md not found"
else
    WORKFLOWS="$(extract_workflows "$SPEC_CREATION")"
    check_workflow_clarity "SC-31 (spec-creation)" "$SPEC_CREATION" "$WORKFLOWS"
fi

echo ""

# ---------------------------------------------------------------------------
# audit/SKILL.md Workflows section
# ---------------------------------------------------------------------------
AUDIT="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
echo "Target (SC-31): $AUDIT"

if [ ! -f "$AUDIT" ]; then
    check_fail "SC-31: target file exists" "audit/SKILL.md not found"
else
    WORKFLOWS="$(extract_workflows "$AUDIT")"
    check_workflow_clarity "SC-31 (audit)" "$AUDIT" "$WORKFLOWS"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-31 not yet implemented."
    echo "Both Workflows sections carry numbered-checkbox steps with"
    echo "'Execution mode:' sub-bullets (from Phase 20), but the Workflows"
    echo "sections themselves do NOT explicitly frame the steps as 'for the"
    echo "orchestrator to follow step-by-step'. The steps read as bare"
    echo "imperative 'Dispatch task(...)' lines with no orchestrator-step"
    echo "framing."
    echo "GREEN adds explicit orchestrator-step framing to each Workflows"
    echo "section — language stating the orchestrator follows the steps"
    echo "step-by-step — while preserving the execution-mode sub-bullets that"
    echo "make the inline-vs-dispatch decision explicit."
    echo ""
    exit 1
fi
echo "SC-31 is GREEN — both spec-creation/SKILL.md and audit/SKILL.md"
echo "Workflows sections are explicitly framed for the orchestrator to follow"
echo "step-by-step, with execution-mode sub-bullets making the inline-vs-dispatch"
echo "decision explicit."
echo ""
exit 0
