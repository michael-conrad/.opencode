#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: SC-1 (#2413) — spec-creation analyze.md
# dependency_contract section.
# Asserts that the forward spec-creation artifact-generation step (Step 5.1
# item 5 in analyze.md) instructs the sub-agent to include a
# `dependency_contract` section in interface-compatibility.yaml, populated
# with concrete dependency data.
#
# Evidence type: SC-1 is structural (grep-based). analyze.md is a regular
# tracked file in the .opencode repo, read directly with grep.
#
# Assertions:
#   1. analyze.md Step 5.1 item 5 references `dependency_contract`.
#   2. The reference instructs including entries for `source`, `target`,
#      `type`, and `constraint`.
#
# GREEN state: analyze.md Step 5.1 item 5 includes the dependency_contract
# instruction (skills/spec-creation/tasks/analyze.md:68).
#
# Usage: bash .opencode/tests-v2/test-2413-sc1-analyze-dependency-contract.sh
# Exit:  0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANALYZE_MD="$SCRIPT_DIR/../skills/spec-creation/tasks/analyze.md"

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
echo "=== SC-1: analyze.md dependency_contract section (#2413) ==="
echo ""
echo "analyze.md: $ANALYZE_MD"
echo ""

# 1. analyze.md Step 5.1 item 5 MUST reference dependency_contract.
if grep -q 'dependency_contract' "$ANALYZE_MD" 2>/dev/null; then
    check_pass "SC-1: analyze.md Step 5.1 item 5 references dependency_contract"
else
    check_fail "SC-1: analyze.md Step 5.1 item 5 references dependency_contract" \
        "no dependency_contract reference found in $ANALYZE_MD"
fi

# 2. The reference MUST include source, target, type, and constraint entries.
if grep -q 'source.*target.*type.*constraint' <(grep 'dependency_contract' "$ANALYZE_MD" 2>/dev/null) 2>/dev/null; then
    check_pass "SC-1: analyze.md dependency_contract includes source/target/type/constraint entry mapping"
else
    check_fail "SC-1: analyze.md dependency_contract includes source/target/type/constraint entry mapping" \
        "dependency_contract reference in $ANALYZE_MD missing source/target/type/constraint fields"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "Expected RED phase failures — analyze.md was missing the"
    echo "dependency_contract section before the #2413 fix."
    echo ""
    exit 1
fi
exit 0
