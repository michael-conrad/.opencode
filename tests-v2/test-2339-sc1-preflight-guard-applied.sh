#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2339 SC-1 — every SKILL.md under
# .opencode/skills/ (including platforms/*/SKILL.md) contains the pre-flight
# guard that detects sub-agent context and returns BLOCKED +
# ORCHESTRATOR_ONLY_SKILL_CARD before any routing metadata is consumed.
#
# Maps to SC-1 from issue #2339:
#   Every SKILL.md under .opencode/skills/ (including platforms/*/SKILL.md)
#   contains a pre-flight guard that detects sub-agent context and returns
#   BLOCKED + ORCHESTRATOR_ONLY_SKILL_CARD before any routing metadata is
#   consumed.
#
# Evidence type: string — grep all 51 SKILL.md files for the guard marker
# (ORCHESTRATOR_ONLY_SKILL_CARD) and assert the guard is present in each.
#
# RED state: none of the 51 SKILL.md files currently contain the guard marker.
# The assertions below assert the guard IS present in each; they FAIL now (RED)
# and PASS after the GREEN phase applies the canonical guard to all 51.
#
# Usage: bash .opencode/tests-v2/test-2339-sc1-preflight-guard-applied.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

SKILL_DIR="$PROJECT_DIR/skills"

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
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== SC-1: pre-flight guard applied to all skill cards (#2339) ==="
echo ""

CARDS=()
while IFS= read -r card; do
    CARDS+=("$card")
done < <(find "$SKILL_DIR" -name 'SKILL.md' -type f | sort)

if [ "${#CARDS[@]}" -eq 0 ]; then
    check_fail "SC-1: skill cards discovered" "no SKILL.md files found under $SKILL_DIR"
else
    check_pass "SC-1: ${#CARDS[@]} SKILL.md files discovered under $SKILL_DIR"
fi

for card in "${CARDS[@]}"; do
    name="${card#"$PROJECT_DIR"/}"
    if grep -q 'ORCHESTRATOR_ONLY_SKILL_CARD' "$card"; then
        check_pass "SC-1: $name contains the pre-flight guard"
    else
        check_fail "SC-1: $name contains the pre-flight guard" \
            "guard marker (ORCHESTRATOR_ONLY_SKILL_CARD) absent in $name (RED phase expected)"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (#2339) pre-flight guard not yet applied to all skill cards."
    echo ""
    exit 1
fi
exit 0
