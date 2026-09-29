#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
#
# Content-verification test - SC-4, issue #2469:
# The 091 behavioral-variant paragraph (Behavioral variant (for
# rule/guideline items)) in .opencode/guidelines/091-incremental-build.md
# MUST be instrument-conditional:
#   (a) `opencode run` instrument for `.opencode`-targeted items
#   (b) strongest available in-repo instrument for OTHER repos (root-repo
#       work SHALL NOT touch the .opencode submodule or its test framework)
#   (c) Read-link to tests-v2/AGENTS.md#scope-anchor (Scope Anchor reference)
#
# RED phase: the guideline currently has NO conditionality text - all 3
# checks FAIL, exit 1.
# GREEN phase: after the conditionality + scope-anchor link is added,
# this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2469-sc4-091-conditionality.sh
# (runs from any CWD - SCRIPT_DIR/REPO_ROOT anchored)
# Exit: 0 if all checks pass, 1 if any check fails

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

GUIDELINE_FILE="$REPO_ROOT/.opencode/guidelines/091-incremental-build.md"

if [ ! -f "$GUIDELINE_FILE" ]; then
    echo "FAIL: guideline file not found: $GUIDELINE_FILE" >&2
    exit 1
fi

# Target the Behavioral variant paragraph block (heading through the end of
# the paragraph) so unrelated sections cannot satisfy the checks.
BV_BLOCK=$(awk '/Behavioral variant/{found=1} found && /^#{1,4} / && !/Behavioral variant/{exit} found{print}' "$GUIDELINE_FILE")

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo "  PASS: $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    echo "  FAIL: $1 -- $2" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== 091 Behavioral-Variant Instrument Conditionality - SC-4 (#2469) ==="
echo ""

if [ -z "$BV_BLOCK" ]; then
    echo "  (Behavioral variant paragraph not present - RED phase)" >&2
fi

# SC-4 #1: behavioral variant paragraph states the `opencode run` instrument condition for `.opencode`-targeted items
if echo "$BV_BLOCK" | grep -qiE "opencode run" && echo "$BV_BLOCK" | grep -qiE "\.opencode.?targeted|opencode.?targeted"; then
    check_pass "conditionality: opencode run instrument for .opencode-targeted items"
else
    check_fail "conditionality: opencode run instrument for .opencode-targeted items" "Behavioral variant paragraph does not scope the opencode run instrument to .opencode-targeted items"
fi

# SC-4 #2: behavioral variant paragraph states the strongest-available in-repo instrument for other repos
if echo "$BV_BLOCK" | grep -qiE "strongest available in.?repo|in.?repo (execution.?based )?instrument|other repos"; then
    check_pass "conditionality: strongest in-repo instrument for other repos"
else
    check_fail "conditionality: strongest in-repo instrument for other repos" "Behavioral variant paragraph does not scope an in-repo instrument condition for non-.opencode repos"
fi

# SC-4 #3: behavioral variant section carries a Read-link to tests-v2/AGENTS.md#scope-anchor
if echo "$BV_BLOCK" | grep -qiE "tests-v2/AGENTS\.md#scope-anchor|AGENTS\.md#scope-anchor"; then
    check_pass "Read-link to tests-v2/AGENTS.md#scope-anchor present"
else
    check_fail "Read-link to tests-v2/AGENTS.md#scope-anchor present" "Behavioral variant section lacks a scope-anchor cross-reference"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
