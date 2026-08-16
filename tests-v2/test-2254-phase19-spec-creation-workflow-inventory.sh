#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 19 — spec-creation SKILL.md workflow inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 19 — spec-creation SKILL.md workflow inventory (prep),
#        target `.opencode/skills/spec-creation/SKILL.md`.
#
# Phase 19 (preparation, no SC): Produce the workflow inventory artifact
#   enumerating the spec-creation Workflows steps (prep). Depends on Phase 18
#   (the spec-creation task-card surface inventory enumerating the 5 task cards:
#   analyze, create, reconcile-push, validate, revise).
#
# The workflow inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/spec-creation-workflow-inventory.yaml`;
#   (b) declare the workflow name (`workflow_name: spec-creation`) and enumerate
#       each Workflows section (`Create a new spec` and `Revise an existing
#       spec`) in order under `workflows`, where each workflow records its name
#       (`name`), its step count (`workflow_steps`), and its step list
#       (`workflow_steps_list`). Each enumerated step records its step name
#       (`step`), its dispatch prompt (`dispatch_prompt`), its context passed
#       (`context_passed`), its returns (`returns`), and its execution mode
#       (`execution_mode`);
#   (c) cover all Workflows steps: `Create a new spec` has 5 steps
#       (analyze/create/reconcile-push/validate/revise) and `Revise an existing
#       spec` has 2 steps (revise/validate).
#
# RED state: the workflow inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating the
#   spec-creation Workflows section steps.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the workflow inventory artifact.
#   It is the RED/GREEN gate for the Phase 19 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase19-spec-creation-workflow-inventory.sh
# Exit:  0 if the workflow inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/spec-creation-workflow-inventory.yaml"

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
echo "=== Phase 19 — spec-creation SKILL.md workflow inventory (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the spec-creation Workflows section steps, independent of
# the artifact. Each step is a `- [ ] N. <Step>` checkbox line under the
# `### Create a new spec` or `### Revise an existing spec` heading.
# ---------------------------------------------------------------------------
declare -A WORKFLOW_STEPS
WORKFLOW_STEPS["Create a new spec"]="analyze create reconcile-push validate revise"
WORKFLOW_STEPS["Revise an existing spec"]="revise validate"

echo "On-disk: 2 spec-creation Workflows sections"
echo "  Create a new spec:     5 steps (analyze/create/reconcile-push/validate/revise)"
echo "  Revise an existing spec: 2 steps (revise/validate)"
echo ""

# ---------------------------------------------------------------------------
# (a) The workflow inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): workflow inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 19: workflow inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 19: workflow inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the spec-creation workflow inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact declares the workflow name and enumerates each Workflows
#     step with its step name, dispatch prompt, context passed, returns, and
#     execution mode.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates the spec-creation Workflows steps ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "workflow_name: spec-creation" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 19: artifact declares workflow_name 'spec-creation'"
    else
        check_fail "Phase 19: artifact declares workflow_name 'spec-creation'" \
            "no 'workflow_name: spec-creation' key in $ARTIFACT"
    fi

    if grep -q "^workflows:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 19: artifact declares workflows list"
    else
        check_fail "Phase 19: artifact declares workflows list" \
            "no 'workflows:' key in $ARTIFACT"
    fi

    for wf in "${!WORKFLOW_STEPS[@]}"; do
        if grep -q "name: $wf" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 19: artifact enumerates workflow '$wf'"
        else
            check_fail "Phase 19: artifact enumerates workflow '$wf'" \
                "no 'name: $wf' entry in workflows in $ARTIFACT"
            continue
        fi

        for step in ${WORKFLOW_STEPS[$wf]}; do
            if grep -q "^  - step: $step$" "$ARTIFACT" 2>/dev/null; then
                check_pass "Phase 19: '$wf' enumerates workflow step $step"
            else
                check_fail "Phase 19: '$wf' enumerates workflow step $step" \
                    "no '  - step: $step' entry in workflow_steps_list in $ARTIFACT"
                continue
            fi

            for field in dispatch_prompt context_passed returns execution_mode; do
                if grep -q "^    $field:" "$ARTIFACT" 2>/dev/null; then
                    check_pass "Phase 19: '$wf' step $step records $field"
                else
                    check_fail "Phase 19: '$wf' step $step records $field" \
                        "no '    $field:' entry under the $step step in $ARTIFACT"
                fi
            done
        done
    done
else
    check_fail "Phase 19: artifact enumerates the spec-creation Workflows steps" \
        "artifact missing — cannot verify the spec-creation Workflows steps are inventoried"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all Workflows steps per workflow.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all spec-creation Workflows steps ---"

if [ -f "$ARTIFACT" ]; then
    for wf in "${!WORKFLOW_STEPS[@]}"; do
        expected_count=$(echo "${WORKFLOW_STEPS[$wf]}" | wc -w)
        if grep -q "name: $wf" "$ARTIFACT" 2>/dev/null; then
            if grep -q "workflow_steps: $expected_count" "$ARTIFACT" 2>/dev/null; then
                check_pass "Phase 19: '$wf' records $expected_count workflow steps"
            else
                check_fail "Phase 19: '$wf' records $expected_count workflow steps" \
                    "expected 'workflow_steps: $expected_count' for '$wf' in $ARTIFACT"
            fi
        else
            check_fail "Phase 19: '$wf' records $expected_count workflow steps" \
                "workflow '$wf' missing from $ARTIFACT"
        fi
    done
else
    check_fail "Phase 19: artifact covers all spec-creation Workflows steps" \
        "artifact missing — cannot verify workflow-step coverage"
fi

# ---------------------------------------------------------------------------
# (d) The artifact parses as valid YAML. Defect guard: each workflow's
#     workflow_steps_list must be well-formed YAML mappings (each item a
#     {step, dispatch_prompt, context_passed, returns, execution_mode} mapping),
#     not scalar items mixed with mapping keys at the same indentation. This
#     assertion uses a real YAML parser so this defect class cannot recur.
# ---------------------------------------------------------------------------
echo "--- (d): artifact parses as valid YAML ---"

if [ -f "$ARTIFACT" ]; then
    if python3 -c "
import sys, yaml
try:
    with open('$ARTIFACT') as f:
        data = yaml.safe_load(f)
except Exception as e:
    print('YAML parse error: %s' % e, file=sys.stderr)
    sys.exit(1)
if not isinstance(data, dict):
    print('YAML root is not a mapping', file=sys.stderr)
    sys.exit(1)
if data.get('workflow_name') != 'spec-creation':
    print('workflow_name is not spec-creation', file=sys.stderr)
    sys.exit(1)
wfs = data.get('workflows')
if not isinstance(wfs, list):
    print('workflows is not a list', file=sys.stderr)
    sys.exit(1)
for wf in wfs:
    if not isinstance(wf, dict):
        print('workflows item is not a mapping: %r' % (wf,), file=sys.stderr)
        sys.exit(1)
    lst = wf.get('workflow_steps_list')
    if not isinstance(lst, list):
        print('workflow_steps_list is not a list: %r' % (wf.get('name'),), file=sys.stderr)
        sys.exit(1)
    for item in lst:
        if not isinstance(item, dict):
            print('workflow_steps_list item is not a mapping: %r' % (item,), file=sys.stderr)
            sys.exit(1)
        for field in ('step', 'dispatch_prompt', 'context_passed', 'returns', 'execution_mode'):
            if field not in item:
                print('workflow_steps_list item missing field %r: %r' % (field, item), file=sys.stderr)
                sys.exit(1)
sys.exit(0)
"; then
        check_pass "Phase 19: artifact parses as valid YAML (workflow_steps_list is well-formed {step, dispatch_prompt, context_passed, returns, execution_mode} mappings)"
    else
        check_fail "Phase 19: artifact parses as valid YAML" \
            "artifact is not valid YAML — workflow_steps_list must be well-formed {step, dispatch_prompt, context_passed, returns, execution_mode} mappings (see stderr)"
    fi
else
    check_fail "Phase 19: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 19 (spec-creation SKILL.md workflow inventory) not yet"
    echo "implemented. The workflow inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating the spec-creation"
    echo "Workflows section steps (Create a new spec:"
    echo "analyze/create/reconcile-push/validate/revise; Revise an existing spec:"
    echo "revise/validate)."
    echo ""
    exit 1
fi
echo "Phase 19 is GREEN — the spec-creation workflow inventory artifact enumerates the"
echo "spec-creation Workflows section steps (Create a new spec:"
echo "analyze/create/reconcile-push/validate/revise; Revise an existing spec:"
echo "revise/validate)."
echo ""
exit 0
