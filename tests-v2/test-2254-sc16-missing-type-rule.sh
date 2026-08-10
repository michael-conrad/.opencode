#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-16 — missing evidence-type
# declaration is a hard FAIL routed to remediation.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-17-missing-type-rule — SC-16 (semantic),
#        `.opencode/reference/spec-structure-standards.md`.
#
# SC-16 (semantic): A missing evidence-type declaration in
#   reference/spec-structure-standards.md SHALL be a hard FAIL routed to the
#   remediation workflow, not a default-to-string/warn/backwards-compat tier.
#
# RED state: reference/spec-structure-standards.md §Evidence Type Taxonomy
#   "EVIDENCE_TYPE_MISMATCH rules" contains the line
#   `- Default to \`string\` if no evidence type declared`, which is the
#   default-to-string escape hatch that tolerates a missing evidence-type
#   declaration. Assertions below FAIL on this content. GREEN replaces the
#   default-to-string tier with a hard-FAIL rule routed to the remediation
#   workflow.
#
# Evidence type: SC-16 is a `semantic` SC. The primary verification is a
#   clean-room sub-agent analytical judgment of the reference doc. This
#   content-verification test is a supplementary gate that asserts the
#   forbidden default-to-string escape hatch is absent and the hard-FAIL
#   remediation routing is present.
#
# Usage: bash .opencode/tests-v2/test-2254-sc16-missing-type-rule.sh
# Exit:  0 if the default-to-string escape hatch is absent and the hard-FAIL
#        remediation rule is present (GREEN), 1 otherwise (RED on SC-16).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

REF_FILE="$PROJECT_DIR/.opencode/reference/spec-structure-standards.md"

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
echo "=== SC-16 — missing evidence-type declaration is a hard FAIL (Spec .opencode#2254) ==="
echo ""
echo "Target file: $REF_FILE"
echo ""

if [ ! -f "$REF_FILE" ]; then
    check_fail "SC-16: target file exists" "reference/spec-structure-standards.md not found"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    echo ""
    exit 1
fi

# ---------------------------------------------------------------------------
# SC-16 (semantic): a missing evidence-type declaration SHALL be a hard FAIL
#   routed to the remediation workflow, not a default-to-string/warn/
#   backwards-compat tier.
#
# (a) The default-to-string escape hatch MUST be ABSENT. Current content has
#     `- Default to \`string\` if no evidence type declared`, which tolerates a
#     missing declaration. RED-now: present.
# (b) A hard-FAIL rule for a missing evidence-type declaration MUST be PRESENT,
#     routed to the remediation workflow. RED-now: absent.
# ---------------------------------------------------------------------------

echo "--- SC-16 (a): default-to-string escape hatch is absent ---"
if grep -qi 'Default to `string` if no evidence type declared' "$REF_FILE"; then
    check_fail "SC-16: default-to-string escape hatch absent" \
        "found a default-to-string escape hatch for a missing evidence-type declaration in $REF_FILE"
else
    check_pass "SC-16: default-to-string escape hatch absent"
fi

echo "--- SC-16 (b): missing evidence-type is a hard FAIL routed to remediation ---"
if grep -qiE 'missing (evidence[- ]?type|an evidence type).*(hard FAIL|FAIL).*remediat' "$REF_FILE"; then
    check_pass "SC-16: missing evidence-type is a hard FAIL routed to remediation"
else
    check_fail "SC-16: missing evidence-type is a hard FAIL routed to remediation" \
        "no hard-FAIL remediation rule for a missing evidence-type declaration found in $REF_FILE"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-16 (missing-type rule) not yet implemented."
    echo "reference/spec-structure-standards.md still defaults a missing"
    echo "evidence-type declaration to \`string\` instead of making it a hard FAIL"
    echo "routed to the remediation workflow."
    echo ""
    exit 1
fi
echo "SC-16 is GREEN — reference/spec-structure-standards.md makes a missing"
echo "evidence-type declaration a hard FAIL routed to the remediation workflow,"
echo "with zero default-to-string escape hatch."
echo ""
exit 0
