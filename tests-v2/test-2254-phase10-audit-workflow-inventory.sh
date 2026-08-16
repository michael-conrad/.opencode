#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 10 — audit SKILL.md workflow inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 10 — audit SKILL.md workflow inventory (prep),
#        target `.opencode/skills/audit/SKILL.md`.
#
# Phase 10 (preparation, no SC): Produce the workflow inventory artifact
#   enumerating the `Run an audit` Workflows section steps (prep). Depends on
#   Phase 1 (the audit role-card surface inventory artifact enumerates the 48
#   role-split cards).
#
# The workflow inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-workflow-inventory.yaml`;
#   (b) declare the workflow name (`workflow_name: Run an audit`) and enumerate
#       the `Run an audit` Workflows section steps in order
#       (`workflow_steps_list`), where each enumerated step records its role
#       (`investigator`/`validator`/`evaluator`/`arbiter`), its dispatch prompt
#       (`dispatch_prompt`), its context passed (`context_passed`), its returns
#       (`returns`), and its execution mode (`execution_mode`);
#   (c) cover all 4 `Run an audit` Workflows steps (`workflow_steps: 4`).
#
# RED state: the workflow inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating the `Run an
#   audit` Workflows section steps (Investigator → Validator → Evaluator →
#   Arbiter).
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the workflow inventory artifact.
#   It is the RED/GREEN gate for the Phase 10 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase10-audit-workflow-inventory.sh
# Exit:  0 if the workflow inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-workflow-inventory.yaml"

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

# Extract the dispatch prompt recorded for a given role in the artifact.
artifact_dispatch_prompt() {
    local role="$1"
    awk -v r="$role" '
        $0 ~ "^  - role: " r "$" { in_step=1; next }
        in_step && /^    dispatch_prompt:/ {
            line=$0
            sub(/^[[:space:]]*dispatch_prompt:[[:space:]]*/, "", line)
            print line
            in_step=0
        }
    ' "$ARTIFACT"
}

echo ""
echo "=== Phase 10 — audit SKILL.md workflow inventory (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the 4 `Run an audit` Workflows section steps
# (Investigator → Validator → Evaluator → Arbiter), independent of the
# artifact. Each step is a `- [ ] N. <Role>` checkbox line under the
# `### Run an audit` heading.
# ---------------------------------------------------------------------------
WORKFLOW_ROLES=(investigator validator evaluator arbiter)
WORKFLOW_COUNT="${#WORKFLOW_ROLES[@]}"

echo "On-disk: $WORKFLOW_COUNT \`Run an audit\` Workflows steps (investigator/validator/evaluator/arbiter)."
echo ""

# ---------------------------------------------------------------------------
# (a) The workflow inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): workflow inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 10: workflow inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 10: workflow inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit workflow inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact declares the workflow name and enumerates each `Run an
#     audit` Workflows step with its role, dispatch prompt, context passed,
#     returns, and execution mode.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates the \`Run an audit\` Workflows steps ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "workflow_name: Run an audit" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 10: artifact declares workflow_name 'Run an audit'"
    else
        check_fail "Phase 10: artifact declares workflow_name 'Run an audit'" \
            "no 'workflow_name: Run an audit' key in $ARTIFACT"
    fi

    if grep -q "workflow_steps_list:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 10: artifact declares workflow_steps_list"
    else
        check_fail "Phase 10: artifact declares workflow_steps_list" \
            "no 'workflow_steps_list:' key in $ARTIFACT"
    fi

    for role in "${WORKFLOW_ROLES[@]}"; do
        if grep -q "^  - role: $role$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 10: artifact enumerates workflow step $role"
        else
            check_fail "Phase 10: artifact enumerates workflow step $role" \
                "no '  - role: $role' entry in workflow_steps_list in $ARTIFACT"
            continue
        fi

        for field in dispatch_prompt context_passed returns execution_mode; do
            if grep -q "^    $field:" "$ARTIFACT" 2>/dev/null; then
                check_pass "Phase 10: $role step records $field"
            else
                check_fail "Phase 10: $role step records $field" \
                    "no '    $field:' entry under the $role step in $ARTIFACT"
            fi
        done
    done
else
    check_fail "Phase 10: artifact enumerates the \`Run an audit\` Workflows steps" \
        "artifact missing — cannot verify the $WORKFLOW_COUNT workflow steps are inventoried"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 4 `Run an audit` Workflows steps.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all 4 \`Run an audit\` Workflows steps ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "workflow_steps: $WORKFLOW_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 10: artifact records $WORKFLOW_COUNT workflow steps"
    else
        check_fail "Phase 10: artifact records $WORKFLOW_COUNT workflow steps" \
            "expected 'workflow_steps: $WORKFLOW_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 10: artifact covers all 4 workflow steps" \
        "artifact missing — cannot verify workflow-step coverage"
fi

# ---------------------------------------------------------------------------
# (d) The artifact parses as valid YAML. Defect guard: workflow_steps_list
#     must be well-formed YAML mappings (each item a {role, dispatch_prompt,
#     context_passed, returns, execution_mode} mapping), not scalar items mixed
#     with mapping keys at the same indentation. This assertion uses a real
#     YAML parser so this defect class cannot recur.
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
lst = data.get('workflow_steps_list')
if not isinstance(lst, list):
    print('workflow_steps_list is not a list', file=sys.stderr)
    sys.exit(1)
for item in lst:
    if not isinstance(item, dict):
        print('workflow_steps_list item is not a mapping: %r' % (item,), file=sys.stderr)
        sys.exit(1)
    for field in ('role', 'dispatch_prompt', 'context_passed', 'returns', 'execution_mode'):
        if field not in item:
            print('workflow_steps_list item missing field %r: %r' % (field, item), file=sys.stderr)
            sys.exit(1)
sys.exit(0)
"; then
        check_pass "Phase 10: artifact parses as valid YAML (workflow_steps_list is well-formed {role, dispatch_prompt, context_passed, returns, execution_mode} mappings)"
    else
        check_fail "Phase 10: artifact parses as valid YAML" \
            "artifact is not valid YAML — workflow_steps_list must be well-formed {role, dispatch_prompt, context_passed, returns, execution_mode} mappings (see stderr)"
    fi
else
    check_fail "Phase 10: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 10 (audit SKILL.md workflow inventory) not yet"
    echo "implemented. The workflow inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating the $WORKFLOW_COUNT"
    echo "\`Run an audit\` Workflows section steps"
    echo "(investigator/validator/evaluator/arbiter)."
    echo ""
    exit 1
fi
echo "Phase 10 is GREEN — the audit workflow inventory artifact enumerates the"
echo "$WORKFLOW_COUNT \`Run an audit\` Workflows section steps"
echo "(investigator/validator/evaluator/arbiter)."
echo ""
exit 0
