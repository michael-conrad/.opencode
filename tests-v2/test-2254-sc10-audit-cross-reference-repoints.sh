#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-10 — audit cross-reference repoints
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-14-audit-cross-reference-repoints — SC-10 (string),
#        `.opencode/skills/audit/tasks/*-role.md`,
#        `.opencode/reference/holistic-dimensions.yaml`.
#
# SC-10 (string): Broken cross-references to non-existent monolithic role-task
#   files (tasks/spec-audit.md, tasks/plan-fidelity.md) SHALL be repointed to
#   the actual role-split files, including in reference/holistic-dimensions.yaml.
#
# RED state: several role task cards and reference/holistic-dimensions.yaml
#   still reference the non-existent monolithic files tasks/spec-audit.md and
#   tasks/plan-fidelity.md. Assertions (a) and (b) FAIL while any monolithic
#   reference remains. GREEN repoints each broken reference to the actual
#   role-split file (spec-audit-evaluator.md, plan-fidelity-evaluator.md, or
#   audit/SKILL.md) and corrects reference/holistic-dimensions.yaml.
#
# Evidence type: SC-10 is a `string` SC. This content-verification test greps
#   audit/tasks/*-role.md and reference/holistic-dimensions.yaml for absence of
#   monolithic refs and presence of role-split refs. It is the primary gate for
#   this content-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc10-audit-cross-reference-repoints.sh
# Exit:  0 if no monolithic refs remain and role-split refs are present (GREEN),
#        1 if any monolithic reference remains or a role-split repoint is
#          missing (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
REF_DIR="$PROJECT_DIR/.opencode/reference"

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
echo "=== SC-10 — audit cross-reference repoints (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $AUDIT_DIR"
echo "Target file: $REF_DIR/holistic-dimensions.yaml"
echo ""

# ---------------------------------------------------------------------------
# SC-10 (string): Broken cross-references to the non-existent monolithic
#   role-task files tasks/spec-audit.md and tasks/plan-fidelity.md SHALL be
#   repointed to the actual role-split files.
#
# (a) No reference to tasks/spec-audit.md remains in audit/tasks/*-role.md or
#     reference/holistic-dimensions.yaml.
# ---------------------------------------------------------------------------
echo "--- SC-10 (a): monolithic tasks/spec-audit.md refs are absent ---"

for file in "$AUDIT_DIR"/*.md "$REF_DIR"/holistic-dimensions.yaml; do
    if grep -q "tasks/spec-audit\.md" "$file" 2>/dev/null; then
        check_fail "SC-10: monolithic spec-audit ref remains" \
            "$file still references tasks/spec-audit.md (must be repointed to a role-split file)"
    else
        check_pass "SC-10: no monolithic spec-audit ref in $(basename "$file")"
    fi
done

# ---------------------------------------------------------------------------
# SC-10 (b): No reference to tasks/plan-fidelity.md remains in audit/tasks/
#   *-role.md or reference/holistic-dimensions.yaml.
# ---------------------------------------------------------------------------
echo "--- SC-10 (b): monolithic tasks/plan-fidelity.md refs are absent ---"

for file in "$AUDIT_DIR"/*.md "$REF_DIR"/holistic-dimensions.yaml; do
    if grep -q "tasks/plan-fidelity\.md" "$file" 2>/dev/null; then
        check_fail "SC-10: monolithic plan-fidelity ref remains" \
            "$file still references tasks/plan-fidelity.md (must be repointed to a role-split file)"
    else
        check_pass "SC-10: no monolithic plan-fidelity ref in $(basename "$file")"
    fi
done

# ---------------------------------------------------------------------------
# SC-10 (c): The spec-audit role cards reference the actual role-split
#   spec-audit-evaluator.md as the Evaluator role.
# ---------------------------------------------------------------------------
echo "--- SC-10 (c): spec-audit role-split refs are present ---"

if grep -q "tasks/spec-audit-evaluator\.md" "$AUDIT_DIR/spec-audit-investigator.md" 2>/dev/null; then
    check_pass "SC-10: spec-audit-investigator references spec-audit-evaluator.md"
else
    check_fail "SC-10: spec-audit-investigator missing role-split ref" \
        "$AUDIT_DIR/spec-audit-investigator.md does not reference tasks/spec-audit-evaluator.md"
fi

if grep -q "tasks/spec-audit-evaluator\.md" "$AUDIT_DIR/spec-audit-validator.md" 2>/dev/null; then
    check_pass "SC-10: spec-audit-validator references spec-audit-evaluator.md"
else
    check_fail "SC-10: spec-audit-validator missing role-split ref" \
        "$AUDIT_DIR/spec-audit-validator.md does not reference tasks/spec-audit-evaluator.md"
fi

# ---------------------------------------------------------------------------
# SC-10 (d): The plan-fidelity role cards reference the actual role-split
#   plan-fidelity-evaluator.md as the Evaluator role.
# ---------------------------------------------------------------------------
echo "--- SC-10 (d): plan-fidelity role-split refs are present ---"

if grep -q "tasks/plan-fidelity-evaluator\.md" "$AUDIT_DIR/plan-fidelity-investigator.md" 2>/dev/null; then
    check_pass "SC-10: plan-fidelity-investigator references plan-fidelity-evaluator.md"
else
    check_fail "SC-10: plan-fidelity-investigator missing role-split ref" \
        "$AUDIT_DIR/plan-fidelity-investigator.md does not reference tasks/plan-fidelity-evaluator.md"
fi

if grep -q "tasks/plan-fidelity-evaluator\.md" "$AUDIT_DIR/plan-fidelity-validator.md" 2>/dev/null; then
    check_pass "SC-10: plan-fidelity-validator references plan-fidelity-evaluator.md"
else
    check_fail "SC-10: plan-fidelity-validator missing role-split ref" \
        "$AUDIT_DIR/plan-fidelity-validator.md does not reference tasks/plan-fidelity-evaluator.md"
fi

# ---------------------------------------------------------------------------
# SC-10 (e): reference/holistic-dimensions.yaml repoints the audit_gates
#   spec-audit and plan-fidelity entries to the role-split evaluator files.
# ---------------------------------------------------------------------------
echo "--- SC-10 (e): holistic-dimensions.yaml repoints are present ---"

if grep -q "tasks/spec-audit-evaluator\.md" "$REF_DIR/holistic-dimensions.yaml" 2>/dev/null; then
    check_pass "SC-10: holistic-dimensions.yaml references spec-audit-evaluator.md"
else
    check_fail "SC-10: holistic-dimensions.yaml missing spec-audit repoint" \
        "$REF_DIR/holistic-dimensions.yaml does not reference tasks/spec-audit-evaluator.md"
fi

if grep -q "tasks/plan-fidelity-evaluator\.md" "$REF_DIR/holistic-dimensions.yaml" 2>/dev/null; then
    check_pass "SC-10: holistic-dimensions.yaml references plan-fidelity-evaluator.md"
else
    check_fail "SC-10: holistic-dimensions.yaml missing plan-fidelity repoint" \
        "$REF_DIR/holistic-dimensions.yaml does not reference tasks/plan-fidelity-evaluator.md"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-10 (audit cross-reference repoints) not yet"
    echo "implemented. Broken cross-references to the non-existent monolithic"
    echo "files tasks/spec-audit.md and tasks/plan-fidelity.md remain in the"
    echo "spec-audit / plan-fidelity role cards and reference/holistic-dimensions.yaml."
    echo "GREEN repoints each to the actual role-split evaluator file."
    echo ""
    exit 1
fi
echo "SC-10 is GREEN — all broken cross-references to monolithic role-task files"
echo "are repointed to the actual role-split files."
echo ""
exit 0
