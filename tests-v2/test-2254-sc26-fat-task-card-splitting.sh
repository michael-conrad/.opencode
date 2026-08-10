#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-26 — no task card procedure in
# spec-creation or audit requires internal sub-agent dispatch; any task card
# whose procedure would require internal dispatch is split into multiple task
# cards, and the SKILL.md workflow dispatches each split task card as a
# separate step.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-22-fat-task-card-splitting.
#
# SC-26 (semantic): No task card procedure in spec-creation or audit SHALL
#   require internal sub-agent dispatch; any task card whose procedure would
#   require internal dispatch SHALL be split into multiple task cards, and
#   the SKILL.md workflow SHALL dispatch each split task card as a separate
#   step.
#
# RED state: spec-creation/tasks/create.md Step 7 instructs the sub-agent to
#   "Dispatch `push-artifacts` via `task(..., prompt: ...)`" — an internal
#   sub-agent dispatch call inside a task-card Procedure. Sub-agents have
#   `task: deny` hardcoded and cannot call `task()`, so this procedure is
#   unexecutable by its consumer. The assertions below FAIL on this content.
# GREEN splits create.md into create.md + reconcile-push.md, removes the
#   internal `task(...)` dispatch from the create.md Procedure, and adds a
#   separate reconcile-push step to the spec-creation SKILL.md workflow.
#
# Evidence type: SC-26 is a `semantic` SC. This content-verification test
#   greps the target files for internal dispatch calls in task-card
#   Procedures and for the split task card + separate workflow step. It is a
#   supplementary sanity check; the primary gate is the sub-agent analytical
#   read per the spec's verification method.
#
# Usage: bash .opencode/tests-v2/test-2254-sc26-fat-task-card-splitting.sh
# Exit:  0 if all targets conform (GREEN), 1 if any target is non-conformant (RED).

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
echo "=== SC-26 — no task-card Procedure requires internal sub-agent dispatch; fat task cards split (Spec .opencode#2254) ==="
echo ""

# ---------------------------------------------------------------------------
# SC-26 (semantic): No task-card Procedure in spec-creation or audit SHALL
#   require internal sub-agent dispatch (no `task(...)` / `skill({` calls).
# ---------------------------------------------------------------------------
INTERNAL_DISPATCH=0
for skill_dir in spec-creation audit; do
    dir="$PROJECT_DIR/.opencode/skills/$skill_dir/tasks"
    if [ ! -d "$dir" ]; then
        check_fail "SC-26: $skill_dir/tasks dir exists" "tasks directory not found"
        INTERNAL_DISPATCH=$((INTERNAL_DISPATCH + 1))
        continue
    fi
    for f in "$dir"/*.md; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        # Extract the Procedure section (from `## Procedure` to the next `## `).
        section="$(awk '/^## Procedure/{flag=1; next} /^## /{if (flag) exit} flag' "$f")"
        # An internal dispatch call is an actual `task(...)` / `skill({` invocation
        # in the Procedure. Prose that says "does NOT dispatch" is not a call.
        if echo "$section" | grep -qE "task\(\.\.\.|task\(subagent|task\(\"|skill\(\{"; then
            check_fail "SC-26: $skill_dir/$name Procedure has no internal sub-agent dispatch" \
                "found a task()/skill() dispatch call in the Procedure section"
            INTERNAL_DISPATCH=$((INTERNAL_DISPATCH + 1))
        fi
    done
done

if [ "$INTERNAL_DISPATCH" -eq 0 ]; then
    check_pass "SC-26: no task-card Procedure in spec-creation or audit requires internal sub-agent dispatch"
fi

echo ""

# ---------------------------------------------------------------------------
# SC-26 (semantic): The split task card exists and the SKILL.md workflow
#   dispatches it as a separate step.
# ---------------------------------------------------------------------------
RECONCILE="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/reconcile-push.md"
if [ -f "$RECONCILE" ]; then
    check_pass "SC-26: split task card reconcile-push.md exists"
else
    check_fail "SC-26: split task card reconcile-push.md exists" "reconcile-push.md not found"
fi

SKILL="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
if grep -q "reconcile-push" "$SKILL"; then
    check_pass "SC-26: spec-creation SKILL.md workflow dispatches reconcile-push as a separate step"
else
    check_fail "SC-26: spec-creation SKILL.md workflow dispatches reconcile-push as a separate step" \
        "no reconcile-push reference in spec-creation/SKILL.md"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-26 not yet implemented."
    echo "spec-creation/tasks/create.md Step 7 still instructs the sub-agent to"
    echo "dispatch push-artifacts via task(...) — an internal sub-agent dispatch"
    echo "call inside a task-card Procedure."
    echo "GREEN splits create.md into create.md + reconcile-push.md, removes the"
    echo "internal task(...) dispatch from the create.md Procedure, and adds a"
    echo "separate reconcile-push step to the spec-creation SKILL.md workflow."
    echo ""
    exit 1
fi
echo "SC-26 is GREEN — no task-card Procedure in spec-creation or audit requires"
echo "internal sub-agent dispatch; the fat create.md task card is split into"
echo "create.md + reconcile-push.md, and the spec-creation SKILL.md workflow"
echo "dispatches reconcile-push as a separate step."
echo ""
exit 0
