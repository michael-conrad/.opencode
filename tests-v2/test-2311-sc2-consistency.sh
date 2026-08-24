#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: SC-2 (#2311) — consistency-check enforcement test.
# Asserts that the producer (`writing-plans/tasks/backfill.md` step 4) and the
# consumer (`writing-plans/tasks/research.md` step 9) task files agree on the
# `interface-compatibility.yaml` schema — specifically that BOTH reference the
# `dependency_contract` section.
#
# Evidence type: SC-2 is structural (grep-based). Both task files are regular
# tracked files in the .opencode repo (not the .issues/ worktree), so they are
# read directly with grep.
#
# Assertions:
#   1. backfill.md step 4 instructs including a `dependency_contract` section
#      for `interface-compatibility.yaml`.
#   2. research.md step 9 extracts the `dependency_contract` section.
#   3. Both must be present — if either is missing, the test fails (exit 1).
#
# GREEN state: both files currently reference `dependency_contract` (see
# skills/writing-plans/tasks/backfill.md:33 and
# skills/writing-plans/tasks/research.md:41,43), so the test passes (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2311-sc2-consistency.sh
# Exit:  0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKFILL_MD="$SCRIPT_DIR/../skills/writing-plans/tasks/backfill.md"
RESEARCH_MD="$SCRIPT_DIR/../skills/writing-plans/tasks/research.md"

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
echo "=== SC-2: Producer/consumer consistency on interface-compatibility.yaml dependency_contract (#2311) ==="
echo ""
echo "backfill.md : $BACKFILL_MD"
echo "research.md: $RESEARCH_MD"
echo ""

# 1. Producer: backfill.md step 4 for interface-compatibility.yaml MUST include a
#    dependency_contract section.
if grep -q 'dependency_contract' "$BACKFILL_MD" 2>/dev/null; then
    check_pass "SC-2: backfill.md step 4 includes a dependency_contract section for interface-compatibility.yaml"
else
    check_fail "SC-2: backfill.md step 4 includes a dependency_contract section" \
        "no dependency_contract reference found in $BACKFILL_MD"
fi

# 2. Consumer: research.md step 9 MUST extract the dependency_contract section.
if grep -q 'dependency_contract' "$RESEARCH_MD" 2>/dev/null; then
    check_pass "SC-2: research.md step 9 extracts the dependency_contract section"
else
    check_fail "SC-2: research.md step 9 extracts the dependency_contract section" \
        "no dependency_contract reference found in $RESEARCH_MD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: producer/consumer schema disagreement on the"
    echo "dependency_contract section of interface-compatibility.yaml."
    echo ""
    exit 1
fi
exit 0
