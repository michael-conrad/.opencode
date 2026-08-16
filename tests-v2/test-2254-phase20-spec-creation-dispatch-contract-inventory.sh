#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 20 — spec-creation SKILL.md dispatch contract inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 20 — spec-creation dispatch contract inventory (prep),
#        target `.opencode/skills/spec-creation/SKILL.md`.
#
# Phase 20 (preparation, no SC): Produce the dispatch-contract inventory
#   artifact enumerating the Context passed to each spec-creation task in the
#   `Create a new spec` and `Revise an existing spec` Workflows sections
#   (prep). Depends on Phase 19 (the spec-creation workflow inventory
#   artifact enumerating the Workflows steps and their Context passed).
#
# The dispatch-contract inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/spec-creation-dispatch-contract-inventory.yaml`;
#   (b) declare the dispatch-contract scope (`dispatch_contract_name:
#       spec-creation`) and enumerate each spec-creation task under `tasks`;
#   (c) cross-reference each task's accepted Context subset against the
#       on-disk `**Context passed:**` values in the spec-creation Workflows
#       section (`task_contracts`), where each entry records the task
#       (`analyze`/`create`/`reconcile-push`/`validate`/`revise`) and the
#       subset of Context params the task's Workflows step passes
#       (`context_passed`), matching the on-disk Context passed for that task;
#   (d) record that `issue_number` is passed to every spec-creation task
#       (present in every task's `context_passed` subset).
#
# RED state: the dispatch-contract inventory artifact does not exist yet.
#   Assertions (a), (b), (c), and (d) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating each
#   spec-creation task's Context passed subset.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the dispatch-contract inventory
#   artifact. It is the RED/GREEN gate for the Phase 20 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase20-spec-creation-dispatch-contract-inventory.sh
# Exit:  0 if the dispatch-contract inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/spec-creation-dispatch-contract-inventory.yaml"

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

# Extract the on-disk Context passed to a given spec-creation task from the
# Workflows section of SKILL.md. For each `Dispatch task(...)` step whose
# prompt references `spec-creation/tasks/<task>.md`, capture the following
# `**Context passed:**` value. Returns the sorted unique union of params
# across both workflows (space-separated). Live, independent of the artifact.
on_disk_context() {
    local task="$1"
    awk -v t="$task" '
        /^### (Create a new spec|Revise an existing spec)/ { in_workflow=1; next }
        /^### / { in_workflow=0 }
        in_workflow && /Dispatch/ && index($0, "spec-creation/tasks/" t ".md") { cur=t }
        in_workflow && cur==t && /Context passed:/ {
            match($0, /\{[^}]*\}/)
            s=substr($0, RSTART+1, RLENGTH-2)
            gsub(/,/, " ", s)
            print s
            cur=""
        }
    ' "$SKILL_FILE" | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' ' | sed 's/ $//'
}

# Extract the context_passed list for a given task from the artifact's
# task_contracts. Returns the params sorted, space-separated.
artifact_task_params() {
    local task="$1"
    awk -v t="$task" '
        $0 ~ "^  - task: " t "$" { in_task=1; next }
        in_task && /^    context_passed:/ {
            line=$0
            sub(/^    context_passed:[[:space:]]*\[/, "", line)
            sub(/\].*$/, "", line)
            gsub(/,/, " ", line)
            gsub(/[[:space:]]+/, " ", line)
            print line
            in_task=0
        }
    ' "$ARTIFACT" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

echo ""
echo "=== Phase 20 — spec-creation SKILL.md dispatch contract inventory (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_FILE"
echo "Artifact:    $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the Context passed to each spec-creation task in the
# Workflows section, independent of the artifact.
# ---------------------------------------------------------------------------
TASKS=(analyze create reconcile-push validate revise)

echo "On-disk: ${#TASKS[@]} spec-creation tasks (analyze/create/reconcile-push/validate/revise)."
echo ""

# ---------------------------------------------------------------------------
# (a) The dispatch-contract inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): dispatch-contract inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 20: dispatch-contract inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 20: dispatch-contract inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the spec-creation dispatch-contract inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact declares the dispatch-contract scope and a task_contracts
#     list.
# ---------------------------------------------------------------------------
echo "--- (b): artifact declares the dispatch-contract scope and task_contracts ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "dispatch_contract_name: spec-creation" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 20: artifact declares dispatch_contract_name 'spec-creation'"
    else
        check_fail "Phase 20: artifact declares dispatch_contract_name 'spec-creation'" \
            "no 'dispatch_contract_name: spec-creation' key in $ARTIFACT"
    fi

    if grep -q "task_contracts:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 20: artifact declares a task_contracts list"
    else
        check_fail "Phase 20: artifact declares a task_contracts list" \
            "no 'task_contracts:' key in $ARTIFACT"
    fi
else
    check_fail "Phase 20: artifact declares the dispatch-contract scope and task_contracts" \
        "artifact missing — cannot verify the dispatch-contract scope"
fi

# ---------------------------------------------------------------------------
# (c) The artifact cross-references each task's accepted Context subset against
#     the on-disk `**Context passed:**` values in the Workflows section.
# ---------------------------------------------------------------------------
echo "--- (c): artifact cross-references each task's Context passed subset ---"

if [ -f "$ARTIFACT" ]; then
    for task in "${TASKS[@]}"; do
        if grep -q "^  - task: $task$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 20: artifact cross-references task $task"
        else
            check_fail "Phase 20: artifact cross-references task $task" \
                "no '  - task: $task' entry in task_contracts in $ARTIFACT"
            continue
        fi

        expected="$(on_disk_context "$task")"
        actual="$(artifact_task_params "$task")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 20: $task context_passed matches on-disk ($expected)"
        else
            check_fail "Phase 20: $task context_passed matches on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 20: artifact cross-references each task's Context passed subset" \
        "artifact missing — cannot verify the ${#TASKS[@]} tasks' Context passed subsets"
fi

# ---------------------------------------------------------------------------
# (d) The artifact records that issue_number is passed to every spec-creation
#     task (present in every task's context_passed subset).
# ---------------------------------------------------------------------------
echo "--- (d): artifact records issue_number passed to every task ---"

if [ -f "$ARTIFACT" ]; then
    # Live cross-check: issue_number must be in every task's on-disk Context.
    all_have_issue_number=1
    for task in "${TASKS[@]}"; do
        expected="$(on_disk_context "$task")"
        if ! printf '%s' "$expected" | tr ' ' '\n' | grep -qx 'issue_number'; then
            all_have_issue_number=0
            check_fail "Phase 20: on-disk $task Context passed includes issue_number" \
                "issue_number not found in the on-disk Context passed for $task"
        fi
    done
    if [ "$all_have_issue_number" -eq 1 ]; then
        check_pass "Phase 20: on-disk Context passed includes issue_number for every task"
    fi

    # The artifact must declare the issue_number_passed_to_all finding.
    if grep -q "issue_number_passed_to_all: true" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 20: artifact records issue_number_passed_to_all: true"
    else
        check_fail "Phase 20: artifact records issue_number_passed_to_all: true" \
            "no 'issue_number_passed_to_all: true' key in $ARTIFACT"
    fi

    # issue_number must be present in every task's context_passed in the artifact.
    for task in "${TASKS[@]}"; do
        actual="$(artifact_task_params "$task")"
        if printf '%s' "$actual" | tr ' ' '\n' | grep -qx 'issue_number'; then
            check_pass "Phase 20: $task context_passed includes issue_number"
        else
            check_fail "Phase 20: $task context_passed includes issue_number" \
                "issue_number is NOT in the $task context_passed subset in $ARTIFACT"
        fi
    done
else
    check_fail "Phase 20: artifact records issue_number passed to every task" \
        "artifact missing — cannot verify the issue_number finding"
fi

# ---------------------------------------------------------------------------
# (e) The artifact parses as valid YAML. Defect guard: task_contracts must be
#     well-formed YAML structures, not scalar items mixed with mapping keys at
#     the same indentation.
# ---------------------------------------------------------------------------
echo "--- (e): artifact parses as valid YAML ---"

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
if data.get('dispatch_contract_name') != 'spec-creation':
    print('dispatch_contract_name is not spec-creation', file=sys.stderr)
    sys.exit(1)
tc = data.get('task_contracts')
if not isinstance(tc, list):
    print('task_contracts is not a list', file=sys.stderr)
    sys.exit(1)
for item in tc:
    if not isinstance(item, dict):
        print('task_contracts item is not a mapping: %r' % (item,), file=sys.stderr)
        sys.exit(1)
    for field in ('task', 'context_passed'):
        if field not in item:
            print('task_contracts item missing field %r: %r' % (field, item), file=sys.stderr)
            sys.exit(1)
    if not isinstance(item['context_passed'], list):
        print('task_contracts item context_passed is not a list: %r' % (item,), file=sys.stderr)
        sys.exit(1)
sys.exit(0)
"; then
        check_pass "Phase 20: artifact parses as valid YAML (task_contracts well-formed)"
    else
        check_fail "Phase 20: artifact parses as valid YAML" \
            "artifact is not valid YAML — task_contracts must be well-formed (see stderr)"
    fi
else
    check_fail "Phase 20: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 20 (spec-creation SKILL.md dispatch contract inventory) not yet"
    echo "implemented. The dispatch-contract inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating each spec-creation"
    echo "task's Context passed subset (analyze/create/reconcile-push/validate/revise),"
    echo "recording that issue_number is passed to every task."
    echo ""
    exit 1
fi
echo "Phase 20 is GREEN — the spec-creation dispatch-contract inventory artifact enumerates"
echo "each spec-creation task's Context passed subset (analyze/create/reconcile-push/"
echo "validate/revise), recording that issue_number is passed to every task."
echo ""
exit 0
