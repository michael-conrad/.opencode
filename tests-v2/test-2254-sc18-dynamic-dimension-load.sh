#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-18 — Dynamic Dimension Loading
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-04-dynamic-dimension-loading — SC-18 (string),
#        `.opencode/skills/spec-creation/tasks/validate.md`.
#
# SC-18 (string): spec-creation/tasks/validate.md SHALL load the 11 holistic
#   dimensions dynamically from reference/holistic-dimensions.yaml rather than
#   a hardcoded divergent list.
#
# RED state: spec-creation/tasks/validate.md Step 2 hardcodes the 11 holistic
#   dimensions in a table and does not reference reference/holistic-dimensions.yaml.
#   Assertion (a) FAILS. GREEN replaces the hardcoded list with a dynamic load.
#
# Evidence type: SC-18 is a `string` SC. This content-verification test greps
#   spec-creation/tasks/validate.md for a dynamic reference to
#   reference/holistic-dimensions.yaml. It is the primary gate for this
#   content-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc18-dynamic-dimension-load.sh
# Exit:  0 if the check passes (GREEN), 1 if it fails (expected RED on SC-18).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

VALIDATE_MD="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/validate.md"

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
echo "=== SC-18 — Dynamic Dimension Loading (Spec .opencode#2254) ==="
echo ""
echo "Target file: $VALIDATE_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-18 (string): spec-creation/tasks/validate.md SHALL load the 11 holistic
#   dimensions dynamically from reference/holistic-dimensions.yaml rather than
#   a hardcoded divergent list.
#
# (a) validate.md references reference/holistic-dimensions.yaml. RED-now:
#     no reference present — the 11 dimensions are hardcoded in Step 2.
# ---------------------------------------------------------------------------
echo "--- SC-18 (a): validate.md references reference/holistic-dimensions.yaml ---"

REF_COUNT=$(grep -c 'holistic-dimensions\.yaml' "$VALIDATE_MD" 2>/dev/null || true)
if [ "$REF_COUNT" -gt 0 ]; then
    check_pass "SC-18: validate.md references reference/holistic-dimensions.yaml ($REF_COUNT reference(s))"
else
    check_fail "SC-18: validate.md references reference/holistic-dimensions.yaml" \
        "no reference to holistic-dimensions.yaml found in $VALIDATE_MD (dimensions are hardcoded)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-18 (dynamic dimension loading) not yet implemented."
    echo "spec-creation/tasks/validate.md hardcodes the 11 holistic dimensions."
    echo "GREEN loads the 11 holistic dimensions dynamically from"
    echo "reference/holistic-dimensions.yaml."
    echo ""
    exit 1
fi
echo "SC-18 is GREEN — validate.md loads dimensions dynamically from"
echo "reference/holistic-dimensions.yaml."
echo ""
exit 0
