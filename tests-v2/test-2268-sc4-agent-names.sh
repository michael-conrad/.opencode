#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: agent names are exactly vision-agent and visual-design-agent
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2268 — Add vision-agent and visual-design-agent sub-agent cards.
#
# SC-4: The agent names are exactly `vision-agent` and `visual-design-agent`
#       (no suffix).
#
# Evidence type: string (filename check).
#
# RED state: before the GREEN phase, the card files do not exist yet — the
# existence and filename checks FAIL. This is the expected RED.
#
# Usage: bash .opencode/tests-v2/test-2268-sc4-agent-names.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AGENTS_DIR="$PROJECT_DIR/.opencode/agents"

EXPECTED_CARDS=(
    "vision-agent.md"
    "visual-design-agent.md"
)
PRE_EXISTING_FILE="steps-value-analysis.md"

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
echo "=== SC-4: agent names are exactly vision-agent and visual-design-agent ==="
echo ""
echo "Agents directory: $AGENTS_DIR"
echo ""

# SC-4: the agents directory must exist
if [ -d "$AGENTS_DIR" ]; then
    check_pass "SC-4: agents directory exists"
else
    check_fail "SC-4: agents directory exists" "directory not found (expected RED — created in GREEN phase)"
fi

# SC-4: each expected agent card must exist with the exact canonical filename (no suffix)
for card in "${EXPECTED_CARDS[@]}"; do
    if [ -f "$AGENTS_DIR/$card" ]; then
        check_pass "SC-4: '$card' exists with exact canonical name"
    else
        check_fail "SC-4: '$card' exists with exact canonical name" \
            "file not found (expected RED — file created in GREEN phase)"
    fi
done

# SC-4: no suffixed variants of the agent cards may exist.
# Enumerate every .md file in the agents directory; the set MUST be exactly
# the two new cards plus the pre-existing steps-value-analysis.md. Any extra
# .md file is either a suffixed variant of a new card or an unexpected addition.
if [ -d "$AGENTS_DIR" ]; then
    for f in "$AGENTS_DIR"/*.md; do
        [ -e "$f" ] || continue
        name="$(basename "$f")"
        case "$name" in
            vision-agent.md|visual-design-agent.md|"$PRE_EXISTING_FILE")
                check_pass "SC-4: '$name' is an expected .md file (no suffix variant)"
                ;;
            *)
                check_fail "SC-4: no suffixed/unexpected .md files in agents dir" \
                    "unexpected file '$name' present (suffixed variant or unexpected addition)"
                ;;
        esac
    done
fi

# SC-4: the pre-existing steps-value-analysis.md must be present
if [ -f "$AGENTS_DIR/$PRE_EXISTING_FILE" ]; then
    check_pass "SC-4: '$PRE_EXISTING_FILE' present"
else
    check_fail "SC-4: '$PRE_EXISTING_FILE' present" "pre-existing file missing (regression invariant violated)"
fi

# SC-4: steps-value-analysis.md must be unmodified relative to git HEAD.
# git diff --quiet exits 0 when the file is unchanged, 1 when modified.
if [ -f "$AGENTS_DIR/$PRE_EXISTING_FILE" ] && git -C "$PROJECT_DIR/.opencode" diff --quiet -- "agents/$PRE_EXISTING_FILE"; then
    check_pass "SC-4: '$PRE_EXISTING_FILE' unmodified (matches git HEAD)"
else
    check_fail "SC-4: '$PRE_EXISTING_FILE' unmodified" \
        "file is modified relative to git HEAD (regression invariant violated)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-4 (exact agent names) not yet satisfied."
    echo "The card files do not exist or carry a suffixed/incorrect filename;"
    echo "the content-verification test fails until the GREEN phase confirms"
    echo "the exact canonical names and the untouched steps-value-analysis.md."
    echo ""
    exit 1
fi
exit 0
