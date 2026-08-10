#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-13 — completion task routing
# corrected to the actual 3-step verify-authorization workflow.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-18-completion-routing — SC-13 (string),
#        `.opencode/skills/audit/tasks/completion.md`.
#
# SC-13 (string): audit/tasks/completion.md SHALL route to the actual 3-step
#   verify-authorization workflow and SHALL NOT reference the dangling
#   `approval-gate --task verify-authorization`.
#
# RED state: completion.md's Pipeline Signal section still emits the dangling
#   `approval-gate --task verify-authorization` reference. The assertions below
#   FAIL on this content. GREEN corrects the routing to the actual 3-step
#   verify-authorization workflow (resolve-scope -> apply-label -> route) and
#   removes the dangling reference.
#
# Evidence type: SC-13 is a `string` SC. This content-verification test greps
#   audit/tasks/completion.md for the dangling reference and the actual 3-step
#   workflow task names. It is the primary gate for this content-only SC (no
#   runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc13-completion-routing.sh
# Exit:  0 if the dangling reference is absent and the 3-step workflow is
#        present (GREEN), 1 if the dangling reference remains or a 3-step
#        workflow task is missing (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TARGET="$PROJECT_DIR/.opencode/skills/audit/tasks/completion.md"

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
echo "=== SC-13 — completion task routing corrected to the actual 3-step verify-authorization workflow (Spec .opencode#2254) ==="
echo ""
echo "Target file: $TARGET"
echo ""

if [ ! -f "$TARGET" ]; then
    check_fail "SC-13: target file exists" "audit/tasks/completion.md not found"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    echo ""
    exit 1
fi

# ---------------------------------------------------------------------------
# SC-13 (string): audit/tasks/completion.md SHALL route to the actual 3-step
#   verify-authorization workflow and SHALL NOT reference the dangling
#   `approval-gate --task verify-authorization`.
#
# The actual 3-step verify-authorization workflow is defined in
# approval-gate/SKILL.md §Workflows "Verify authorization (3-step path)":
#   1. resolve-scope
#   2. apply-label
#   3. route
# The dangling reference is the non-existent `approval-gate --task
# verify-authorization` task (approval-gate has no `verify-authorization` task
# card; its tasks are resolve-scope.md, apply-label.md, route.md).
# ---------------------------------------------------------------------------

# --- Dangling reference must be ABSENT ---
if grep -q "approval-gate --task verify-authorization" "$TARGET"; then
    check_fail "SC-13: dangling verify-authorization reference absent" \
        "found 'approval-gate --task verify-authorization' in $TARGET"
else
    check_pass "SC-13: dangling verify-authorization reference absent"
fi

# --- Actual 3-step workflow task names must be PRESENT ---
for step in resolve-scope apply-label route; do
    if grep -q "$step" "$TARGET"; then
        check_pass "SC-13: 3-step workflow task present ($step)"
    else
        check_fail "SC-13: 3-step workflow task present" \
            "$step not found in $TARGET"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-13 (completion routing) not yet implemented."
    echo "audit/tasks/completion.md still references the dangling"
    echo "'approval-gate --task verify-authorization' and does not route to the"
    echo "actual 3-step verify-authorization workflow (resolve-scope ->"
    echo "apply-label -> route)."
    echo "GREEN corrects the routing and removes the dangling reference."
    echo ""
    exit 1
fi
echo "SC-13 is GREEN — audit/tasks/completion.md routes to the actual 3-step"
echo "verify-authorization workflow (resolve-scope -> apply-label -> route) and"
echo "contains zero dangling 'approval-gate --task verify-authorization'"
echo "references."
echo ""
exit 0
