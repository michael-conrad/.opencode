#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-1 — Canonical Dispatch Format
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-01-spec-creation-dispatch — SC-1 (string),
#        `.opencode/skills/spec-creation/SKILL.md`.
#
# SC-1 (string): spec-creation/SKILL.md SHALL use the canonical dispatch prompt
#   format `Follow the instructions in [<skill>/tasks/<task>.md](...)` for all
#   task() dispatches, with zero occurrences of the deprecated `execute X from Y`
#   coded strings.
#
# RED state: spec-creation/SKILL.md currently has 6 deprecated `execute X from Y`
#   dispatch prompt strings (analyze, create, validate, revise) in the Workflows
#   section. Assertions (a) and (b) FAIL. GREEN converts the 6 deprecated strings to
#   the canonical `Follow the instructions in [<skill>/tasks/<task>.md](...)` format.
#
# Evidence type: SC-1 is a `string` SC. This content-verification test greps
#   spec-creation/SKILL.md for the required patterns. It is the primary gate for
#   this content-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc1-canonical-dispatch.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC-1).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_MD="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"

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
echo "=== SC-1 — Canonical Dispatch Format (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-1 (string): spec-creation/SKILL.md uses the canonical dispatch prompt format
#   `Follow the instructions in [<skill>/tasks/<task>.md](...)` for all task()
#   dispatches, with zero deprecated `execute X from Y` coded strings.
#
# (a) Zero deprecated `execute .* from` coded strings. RED-now: 6 such strings exist
#     in the Workflows section (analyze, create, validate, revise).
# ---------------------------------------------------------------------------
echo "--- SC-1 (a): zero deprecated 'execute X from Y' coded strings ---"

DEPRECATED_COUNT=$(grep -cE 'execute [^"]* from ' "$SKILL_MD" 2>/dev/null || true)
if [ "$DEPRECATED_COUNT" -eq 0 ]; then
    check_pass "SC-1: zero deprecated 'execute .* from' coded strings"
else
    check_fail "SC-1: zero deprecated 'execute .* from' coded strings" \
        "found $DEPRECATED_COUNT deprecated 'execute X from Y' string(s) in $SKILL_MD"
fi

# ---------------------------------------------------------------------------
# (b) Canonical `Follow the instructions in [<skill>/tasks/<task>.md](...)`
#     format is present for all task() dispatches. Each of the 4 task cards
#     (analyze, create, validate, revise) must be dispatched via the canonical
#     prompt format. RED-now: none use the canonical format.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-1 (b): canonical 'Follow the instructions in [<skill>/tasks/<task>.md](...)' format present ---"

CANONICAL_COUNT=$(grep -cE 'Follow the instructions in \[spec-creation/tasks/[a-z]+\.md\]' "$SKILL_MD" 2>/dev/null || true)
if [ "$CANONICAL_COUNT" -ge 4 ]; then
    check_pass "SC-1: canonical dispatch format present for task cards"
else
    check_fail "SC-1: canonical dispatch format present for task cards" \
        "found $CANONICAL_COUNT canonical dispatch reference(s), expected at least 4"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (canonical dispatch format) not yet implemented."
    echo "spec-creation/SKILL.md still uses $DEPRECATED_COUNT deprecated 'execute X from Y'"
    echo "dispatch prompt strings and does not use the canonical"
    echo "'Follow the instructions in [<skill>/tasks/<task>.md](...)' format."
    echo "GREEN converts the deprecated strings to the canonical dispatch format."
    echo ""
    exit 1
fi
echo "SC-1 is GREEN — spec-creation/SKILL.md uses the canonical dispatch format."
echo ""
exit 0
