#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: SC-1 scope-anchor statement in tests-v2/AGENTS.md
# Maps to SC-1 from issue #2469: .opencode/tests-v2/AGENTS.md SHALL gain a
# scope-anchor statement declaring (1) the harness and `opencode run` mechanics
# apply ONLY to .opencode-targeted work — for all other spec targets the
# framework is out of scope and .opencode SHALL NOT be modified — and
# (2) the R-6 routing directive: deck defects route via issue-operations to
# michael-conrad/.opencode; agents do NOT patch local .opencode copies to
# escape a mis-scoped mandate.
#
# RED phase: the anchor does not exist yet — this test FAILS (non-zero exit).
# GREEN phase: after the anchor is added to .opencode/tests-v2/AGENTS.md,
# this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2469-sc1-scope-anchor.sh
# Exit: 0 if all checks pass, 1 if any check fails (RED = exit 1)

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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

TARGET="$PROJECT_DIR/.opencode/tests-v2/AGENTS.md"

# Extract the scope-anchor section if its heading exists; otherwise the anchor
# block is empty (RED).
if grep -qi "scope anchor" "$TARGET" 2>/dev/null; then
    ANCHOR_BLOCK=$(awk 'BEGIN{IGNORECASE=1} /scope anchor/{found=1} found && /^#{1,4} / && tolower($0) !~ /scope anchor/{exit} found{print}' "$TARGET")
else
    ANCHOR_BLOCK=""
fi

echo ""
echo "=== tests-v2 Scope Anchor -- SC-1 (#2469) ==="
echo "Target: $TARGET"
echo ""

# SC-1 check 1: the scope-anchor section exists.
if [ -n "$ANCHOR_BLOCK" ]; then
    check_pass "SC-1: scope-anchor section present"
else
    check_fail "SC-1: scope-anchor section present" "no scope-anchor section found in $TARGET (RED: anchor does not exist yet)"
fi

# SC-1 check 2: harness scope conditionality — applies only to
# .opencode-targeted work; other work out of scope; .opencode not modified.
if echo "$ANCHOR_BLOCK" | grep -qiE "only.{0,60}opencode.-targeted|out of scope|SHALL NOT be modified"; then
    check_pass "SC-1: harness scope conditionality stated"
else
    check_fail "SC-1: harness scope conditionality stated" "anchor does not state harness scope conditionality"
fi

# SC-1 check 3: R-6 routing directive — deck defects route to .opencode issue
# tracker.
if echo "$ANCHOR_BLOCK" | grep -qiE "route.{0,80}michael-conrad/\.opencode"; then
    check_pass "SC-1: R-6 routing directive present (deck defects route to .opencode tracker)"
else
    check_fail "SC-1: R-6 routing directive present" "anchor does not route deck defects to michael-conrad/.opencode"
fi

# SC-1 check 4: R-6 no-local-patching prohibition.
if echo "$ANCHOR_BLOCK" | grep -qiE "do NOT patch|not patch"; then
    check_pass "SC-1: R-6 no-local-patching prohibition present"
else
    check_fail "SC-1: R-6 no-local-patching prohibition present" "anchor does not prohibit patching local .opencode copies"
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
