#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-19 + SC-20 — Create Exec-Summary Body
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-05-create-exec-summary-body — SC-19, SC-20 (string),
#        `.opencode/skills/spec-creation/tasks/create.md`.
#
# SC-19 (string): spec-creation/tasks/create.md SHALL route the remote issue body
#   to the canonical exec-summary body format (Spec Reference Blockquote, Problem,
#   Scope, Approach, Impact) defined in issue-operations-core/tasks/creation.md
#   Step 5.
#
# SC-20 (string): spec-creation/tasks/create.md SHALL include the forward-reference
#   Spec Reference Blockquote link in the remote issue body, pointing to the
#   issues-data branch URL.
#
# RED state: create.md Step 4 ("Write full spec to remote issue body") does not
#   reference the canonical exec-summary body format (creation.md Step 5), and the
#   forward-reference Spec Reference Blockquote / issues-data link is not included
#   in the remote issue body. Assertions (a) and (b) FAIL. GREEN routes the remote
#   issue body to the canonical exec-summary body format and includes the
#   forward-reference Spec Reference Blockquote / issues-data link in the remote
#   issue body.
#
# Evidence type: SC-19 and SC-20 are `string` SCs. This content-verification test
#   greps spec-creation/tasks/create.md for the required patterns. It is the primary
#   gate for these content-only SCs (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc19-sc20-create-exec-summary-body.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC-19/SC-20).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

CREATE_MD="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/create.md"

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
echo "=== SC-19 + SC-20 — Create Exec-Summary Body (Spec .opencode#2254) ==="
echo ""
echo "Target file: $CREATE_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-19 (string): spec-creation/tasks/create.md SHALL route the remote issue body
#   to the canonical exec-summary body format (Spec Reference Blockquote, Problem,
#   Scope, Approach, Impact) defined in issue-operations-core/tasks/creation.md
#   Step 5.
#
# (a) create.md references the canonical exec-summary body format / creation.md
#     Step 5. RED-now: Step 4 ("Write full spec to remote issue body") does not
#     reference creation.md Step 5 or the canonical exec-summary body format.
# ---------------------------------------------------------------------------
echo "--- SC-19 (a): create.md references the canonical exec-summary body format / creation.md Step 5 ---"

CREATION_STEP5_COUNT=$(grep -c 'creation\.md' "$CREATE_MD" 2>/dev/null || true)
if [ "$CREATION_STEP5_COUNT" -gt 0 ]; then
    check_pass "SC-19: create.md references issue-operations-core/tasks/creation.md ($CREATION_STEP5_COUNT reference(s))"
else
    check_fail "SC-19: create.md references issue-operations-core/tasks/creation.md" \
        "no reference to creation.md found in $CREATE_MD (remote issue body is not routed to the canonical exec-summary body format)"
fi

# ---------------------------------------------------------------------------
# SC-20 (string): spec-creation/tasks/create.md SHALL include the forward-reference
#   Spec Reference Blockquote link in the remote issue body, pointing to the
#   issues-data branch URL.
#
# (b) create.md includes the forward-reference Spec Reference Blockquote / issues-data
#     link in the remote issue body (Step 4). RED-now: the blockquote exists only in
#     the local spec section (Step 5/6), not in the remote issue body (Step 4).
#     The remote issue body is written in Step 4, which precedes Step 5
#     ("Write local spec"). The issues-data link must appear before Step 5.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-20 (b): create.md includes the forward-reference Spec Reference Blockquote / issues-data link in the remote issue body ---"

REMOTE_BODY_SECTION=$(awk '/### Step 4: Write full spec to remote issue body/,/### Step 5: Write local spec/' "$CREATE_MD" 2>/dev/null || true)
ISSUES_DATA_COUNT=$(printf '%s' "$REMOTE_BODY_SECTION" | grep -c 'issues-data' 2>/dev/null || true)
if [ "$ISSUES_DATA_COUNT" -gt 0 ]; then
    check_pass "SC-20: create.md includes the forward-reference Spec Reference Blockquote / issues-data link in the remote issue body ($ISSUES_DATA_COUNT reference(s))"
else
    check_fail "SC-20: create.md includes the forward-reference Spec Reference Blockquote / issues-data link in the remote issue body" \
        "no issues-data link found in the Step 4 remote issue body section of $CREATE_MD (forward-reference Spec Reference Blockquote missing from the remote issue body)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-19/SC-20 (create exec-summary body) not yet implemented."
    echo "spec-creation/tasks/create.md Step 4 does not route the remote issue body to"
    echo "the canonical exec-summary body format (creation.md Step 5), and the"
    echo "forward-reference Spec Reference Blockquote / issues-data link is not"
    echo "included in the remote issue body."
    echo "GREEN routes the remote issue body to the canonical exec-summary body format"
    echo "and includes the forward-reference Spec Reference Blockquote / issues-data link."
    echo ""
    exit 1
fi
echo "SC-19/SC-20 are GREEN — create.md routes the remote issue body to the canonical"
echo "exec-summary body format and includes the forward-reference Spec Reference"
echo "Blockquote / issues-data link."
echo ""
exit 0
