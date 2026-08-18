#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: dispatch link [text] MUST be a purpose condensation
# Maps to SC-1 from issue #2296: every dispatch link [text] across the affected
# SKILL.md files SHALL be a condensation of the linked task card's Purpose
# statement, NOT a path restatement. The URL remains the task path.
#
# RED phase: all dispatch link [text] values currently restate the path (e.g.,
# [approval-gate/tasks/resolve-scope.md] == URL path). This test FAILS because
# a path-restatement [text] is present.
# GREEN phase: after the 48 SKILL.md files have [text] rewritten to purpose
# condensations, this test PASSES (no [text] equals its URL path).
#
# Usage: bash .opencode/tests-v2/test-2296-sc1-condensation-format.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILLS_DIR="$PROJECT_DIR/.opencode/skills"

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
echo "=== Dispatch link [text] purpose-condensation format -- SC-1 (#2296) ==="
echo ""
echo "Target: dispatch links in $SKILLS_DIR/*/SKILL.md"
echo ""

# ---------------------------------------------------------------------------
# SC-1: Every dispatch link [text] SHALL be a purpose condensation, not a path
# restatement. A dispatch link is a markdown link whose URL is a task card path
# under .opencode/skills/<skill>/tasks/<task>.md. The [text] MUST NOT equal the
# URL path (which is the dead-weight path-restatement pattern this spec
# eliminates). The URL itself is preserved as the task path.
# ---------------------------------------------------------------------------

# Collect all dispatch links and flag those whose [text] equals their URL path.
# Use find to cover nested platform SKILL.md files (e.g. issue-operations/platforms/*),
# not just one-level skills/*/SKILL.md. This matches all 48 affected files / 255 links.
PATH_RESTATEMENTS=$(find "$SKILLS_DIR" -name 'SKILL.md' -exec grep -hoE '\[[^]]*\]\(\.opencode/skills/[^)]*tasks/[^)]*\.md\)' {} + 2>/dev/null \
    | python3 -c "
import sys, re
lines = [l.strip() for l in sys.stdin if l.strip()]
violations = []
for l in lines:
    m = re.match(r'\[([^]]*)\]\(\.opencode/skills/([^)]*)\)', l)
    if not m:
        continue
    text, path = m.group(1), m.group(2)
    if text == path:
        violations.append(l)
print(len(lines))
print('\n'.join(violations))
" || true)

TOTAL_LINKS="$(printf '%s\n' "$PATH_RESTATEMENTS" | sed -n '1p')"
VIOLATIONS="$(printf '%s\n' "$PATH_RESTATEMENTS" | sed -n '2,$p' | grep -c '^\[' || true)"

if [ -z "$TOTAL_LINKS" ]; then
    TOTAL_LINKS=0
fi
if [ -z "$VIOLATIONS" ]; then
    VIOLATIONS=0
fi

echo "Total dispatch links found: $TOTAL_LINKS"
echo "Path-restatement [text] violations: $VIOLATIONS"
echo ""

if [ "$VIOLATIONS" -gt 0 ]; then
    check_fail "SC-1: dispatch link [text] is a purpose condensation, not a path restatement" \
        "$VIOLATIONS of $TOTAL_LINKS dispatch links have [text] equal to their URL path"
else
    check_pass "SC-1: dispatch link [text] is a purpose condensation, not a path restatement"
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
