#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: SC-2 (#2413) — dependency_contract schema
# agreement between spec-creation (Phase 1, analyze.md Step 5.1 item 5)
# and writing-plans (Phase 2, research.md step 9).
#
# Asserts that both the producer (analyze.md) and consumer (research.md)
# agree on the dependency_contract section structure: a YAML block with
# `description` and `entries`, each entry containing `source`, `target`,
# `type`, and `constraint` fields extracted from the spec's interfaces,
# removed_interfaces, and breaking_changes keys.
#
# Evidence type: SC-2 is structural (grep-based). Both analyze.md and
# research.md are regular tracked files read directly with grep.
#
# Assertions:
#   1. Both analyze.md and research.md define the same 4 entry-fields
#      (source, target, type, constraint).
#   2. The field-to-source mapping is consistent: source from interfaces,
#      target from removed_interfaces or implied coupling, type="artifact schema",
#      constraint from breaking_changes or implied coupling.
#
# Usage: bash .opencode/tests-v2/test-2413-sc2-dependency-contract-schema.sh
# Exit:  0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANALYZE_MD="$SCRIPT_DIR/../skills/spec-creation/tasks/analyze.md"
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
echo "=== SC-2: dependency_contract schema agreement (#2413) ==="
echo ""
echo "analyze.md:  $ANALYZE_MD"
echo "research.md: $RESEARCH_MD"
echo ""

# ----- Assertion 1: Both files define the same 4 entry-fields -----
REQUIRED_FIELDS=("source" "target" "type" "constraint")

for field in "${REQUIRED_FIELDS[@]}"; do
    if grep -qi "$field" <(grep -A20 'dependency_contract' "$ANALYZE_MD" 2>/dev/null) 2>/dev/null; then
        check_pass "SC-2: analyze.md dependency_contract contains field '$field'"
    else
        check_fail "SC-2: analyze.md dependency_contract contains field '$field'" \
            "'$field' not found in analyze.md dependency_contract section"
    fi
done

# research.md step 9 uses the same fields for auto-backfill
for field in "${REQUIRED_FIELDS[@]}"; do
    if grep -qi "$field" <(grep -A20 'dependency_contract' "$RESEARCH_MD" 2>/dev/null) 2>/dev/null; then
        check_pass "SC-2: research.md dependency_contract contains field '$field'"
    else
        check_fail "SC-2: research.md dependency_contract contains field '$field'" \
            "'$field' not found in research.md dependency_contract section"
    fi
done

# ----- Assertion 2: Field-to-source mapping consistency -----
# analyze.md: source from interfaces, target from removed_interfaces,
#             type="artifact schema", constraint from breaking_changes
if grep -q 'source.*interfaces' "$ANALYZE_MD" 2>/dev/null; then
    check_pass "SC-2: analyze.md maps source from interfaces key"
else
    check_fail "SC-2: analyze.md maps source from interfaces key" \
        "no 'source.*interfaces' mapping found in analyze.md"
fi

if grep -q 'target.*removed_interfaces' "$ANALYZE_MD" 2>/dev/null; then
    check_pass "SC-2: analyze.md maps target from removed_interfaces key"
else
    check_fail "SC-2: analyze.md maps target from removed_interfaces key" \
        "no 'target.*removed_interfaces' mapping found in analyze.md"
fi

if grep -q 'constraint.*breaking_changes' "$ANALYZE_MD" 2>/dev/null; then
    check_pass "SC-2: analyze.md maps constraint from breaking_changes key"
else
    check_fail "SC-2: analyze.md maps constraint from breaking_changes key" \
        "no 'constraint.*breaking_changes' mapping found in analyze.md"
fi

# research.md uses the same mapping for auto-backfill
if grep -q 'source.*interface' "$RESEARCH_MD" 2>/dev/null; then
    check_pass "SC-2: research.md maps source from interface names"
else
    check_fail "SC-2: research.md maps source from interface names" \
        "no 'source.*interface' mapping found in research.md"
fi

if grep -q 'target.*removed_interfaces' "$RESEARCH_MD" 2>/dev/null; then
    check_pass "SC-2: research.md maps target from removed_interfaces key"
else
    check_fail "SC-2: research.md maps target from removed_interfaces key" \
        "no 'target.*removed_interfaces' mapping found in research.md"
fi

if grep -q 'constraint.*breaking_changes' "$RESEARCH_MD" 2>/dev/null; then
    check_pass "SC-2: research.md maps constraint from breaking_changes key"
else
    check_fail "SC-2: research.md maps constraint from breaking_changes key" \
        "no 'constraint.*breaking_changes' mapping found in research.md"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "SCHEMA MISMATCH detected between spec-creation and writing-plans."
    echo "Phase 3 requires alignment: both sides must use the same"
    echo "dependency_contract section structure."
    exit 1
fi
exit 0
