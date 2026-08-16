#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 26 — workflow clarity verification
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 26 — workflow clarity verification (prep, no SC).
# Targets: .opencode/skills/spec-creation/SKILL.md,
#          .opencode/skills/audit/SKILL.md
#
# Phase 26 (preparation, no SC): Verify both Workflows sections are explicitly
#   orchestrator step-by-step with execution-mode sub-bullets per step (prep for
#   SC-32, SC-33). Every checkbox step (following `### Create a new spec`,
#   `### Revise an existing spec`, or `### Run an audit`) MUST have an
#   `Execution mode: <mode>` sub-bullet.
#
# This content-verification test asserts that every step in the Workflows
# sections of spec-creation/SKILL.md and audit/SKILL.md carries an explicit
# Execution-mode sub-bullet.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of execution-mode sub-bullets.
#   It is the RED/GREEN gate for the Phase 26 workflow-clarity deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase26-workflow-clarity.sh
# Exit:  0 if both Workflows sections have execution-mode sub-bullets (GREEN),
#        1 if any step is missing an execution-mode sub-bullet (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SPEC_CREATION_SKILL="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
AUDIT_SKILL="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"

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
echo "=== Phase 26 — Workflow clarity verification (Spec .opencode#2254) ==="
echo ""
echo "Target files:"
echo "  $SPEC_CREATION_SKILL"
echo "  $AUDIT_SKILL"
echo ""

# ---------------------------------------------------------------------------
# Helper: extract checkbox steps from a Workflows section and verify each has
# an execution-mode sub-bullet.
#
# Approach: scan for lines matching `- [ ] <N>. <name> — ` (checkbox step),
# then scan following lines for `Execution mode:` within the same indentation
# block (until next checkbox step or end of section).
#
# A step line is: /^\s*- \[ \] \d+\.\s+\S+.*$/
# An execution-mode line is: /^\s+- \*\*Execution mode:\*\*/
# ---------------------------------------------------------------------------
check_workflow_clarity() {
    local skill_file="$1"
    local skill_label="$2"
    local file_basename
    file_basename="$(basename "$skill_file")"

    echo "--- $skill_label: every Workflows step has Execution mode sub-bullet ---"

    # Extract only the Workflows section: between "## Workflows" and the next
    # top-level heading (or end of file). Use awk to extract the section.
    local tmpfile
    tmpfile=$(mktemp)
    # shellcheck disable=SC2064
    trap "rm -f '$tmpfile'" RETURN

    # Extract Workflows section from the SKILL.md
    local section_lines
    section_lines=$(awk '
        /^## Workflows/ { found=1; next }
        /^## [A-Z]/ && found { exit }
        found { print }
    ' "$skill_file" 2>/dev/null) || true

    # Write section to temp file for processing
    printf '%s\n' "$section_lines" > "$tmpfile" 2>/dev/null || true

    # Count more precisely by checking each step line
    # and looking for Execution mode in subsequent lines (up to next step)
    local total_steps=0
    local steps_with_mode=0
    local in_step=false
    local step_has_mode=false
    local step_text=""

    while IFS= read -r line; do
        if echo "$line" | grep -qE '^\s*- \[ \] [0-9]'; then
            # New step found — record previous step check
            if [ "$in_step" = true ]; then
                total_steps=$((total_steps + 1))
                if [ "$step_has_mode" = true ]; then
                    steps_with_mode=$((steps_with_mode + 1))
                fi
            fi
            in_step=true
            step_has_mode=false
            step_text="$line"
        fi
        if [ "$in_step" = true ] && echo "$line" | grep -qE 'Execution mode:'; then
            step_has_mode=true
        fi
    done <<< "$section_lines"

    # Check the last step
    if [ "$in_step" = true ]; then
        total_steps=$((total_steps + 1))
        if [ "$step_has_mode" = true ]; then
            steps_with_mode=$((steps_with_mode + 1))
        fi
    fi

    # Report results per skill file
    if [ "$total_steps" -eq 0 ]; then
        check_fail "$skill_label: Workflows section" \
            "no checkbox steps found under ## Workflows in $file_basename"
        return
    fi

    if [ "$total_steps" -eq "$steps_with_mode" ]; then
        check_pass "$skill_label: all $total_steps steps have Execution-mode sub-bullets"
    else
        check_fail "$skill_label: $steps_with_mode/$total_steps steps have Execution-mode sub-bullets" \
            "some steps in $file_basename are missing Execution-mode sub-bullets"
    fi

    # Also detect if the header preamble exists (the descriptive text below
    # ## Workflows that explains the step-by-step, orchestator-discipline
    # pattern). The preamble is the first non-empty, non-heading line after
    # ## Workflows — it should describe execution-mode sub-bullets.
    local has_preamble=false
    local preamble_line
    preamble_line=$(awk '
        /^## Workflows/ { found=1; next }
        found && /^[^#]/ && !/^\s*$/ { print; exit }
    ' "$skill_file" 2>/dev/null) || true
    if echo "$preamble_line" | grep -qiE 'execution.?mode|orchestrator.*step.*step|inline.*dispatch'; then
        has_preamble=true
    fi

    if $has_preamble; then
        check_pass "$skill_label: Workflows preamble describes step-by-step with execution-mode"
    else
        check_fail "$skill_label: Workflows preamble describes step-by-step with execution-mode" \
            "no preamble introducing execution-mode sub-bullets in $file_basename"
    fi
}

# ---------------------------------------------------------------------------
# 1. spec-creation/SKILL.md Workflows clarity
# ---------------------------------------------------------------------------
check_workflow_clarity "$SPEC_CREATION_SKILL" "spec-creation"
echo ""

# ---------------------------------------------------------------------------
# 2. audit/SKILL.md Workflows clarity
# ---------------------------------------------------------------------------
check_workflow_clarity "$AUDIT_SKILL" "audit"
echo ""

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED: Workflows section clarity is not yet compliant — some steps are missing"
    echo "Execution-mode sub-bullets, or the Workflows preamble describing the"
    echo "step-by-step orchestator-discipline execution-mode pattern is absent."
    echo ""
    echo "Target files:"
    echo "  .opencode/skills/spec-creation/SKILL.md"
    echo "  .opencode/skills/audit/SKILL.md"
    echo ""
    exit 1
fi

echo "GREEN: Both Workflows sections have explicit orchestrator step-by-step with"
echo "execution-mode sub-bullets per step."
echo ""
exit 0
