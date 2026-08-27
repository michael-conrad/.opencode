#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2339 SC-6 — the skill card template
# generator (init_skill.py) includes the pre-flight guard in the generated
# SKILL_TEMPLATE so new cards are born with the guard.
#
# Maps to SC-6 from issue #2339:
#   The skill card template generator (init_skill.py) includes the pre-flight
#   guard in the generated SKILL_TEMPLATE so new cards are born with the guard.
#
# Evidence type: behavioral — run the template generator on init_skill.py and
# inspect its output; generate a card from the template and assert the guard is
# present.
#
# RED state: the SKILL_TEMPLATE in init_skill.py does not currently contain the
# pre-flight guard. The assertions below assert the generated card DOES contain
# the guard marker (ORCHESTRATOR_ONLY_SKILL_CARD); they FAIL now (RED) and PASS
# after the GREEN phase adds the guard section to the SKILL_TEMPLATE.
#
# Usage: bash .opencode/tests-v2/test-2339-sc6-template-generator-guard.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

INIT_SKILL="$PROJECT_DIR/skills/skill-creator/scripts/init_skill.py"
GUARD_MARKER="ORCHESTRATOR_ONLY_SKILL_CARD"

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
echo "=== SC-6: template generator emits pre-flight guard (#2339) ==="
echo ""

if [ ! -f "$INIT_SKILL" ]; then
    check_fail "SC-6: init_skill.py exists" "missing $INIT_SKILL"
    echo ""
    echo "FAILED: $FAIL_COUNT"
    exit 1
fi

# Generate a throwaway skill in a temp dir under the project so the template
# string can be inspected. Use a unique skill name to avoid collisions.
TMP_DIR="$(mktemp -d "$PROJECT_DIR/tmp/test-2339-sc6-XXXXXX")"
TEST_SKILL="sc6-guard-test"

if command -v uv &>/dev/null; then
    UV_RUN=(uv run)
else
    UV_RUN=()
fi

if "${UV_RUN[@]}" python "$INIT_SKILL" "$TEST_SKILL" --path "$TMP_DIR" >/dev/null 2>&1; then
    check_pass "SC-6: template generator runs successfully"
else
    check_fail "SC-6: template generator runs successfully" \
        "init_skill.py failed to generate a skill (RED phase expected if template broken)"
fi

GENERATED_CARD="$TMP_DIR/$TEST_SKILL/SKILL.md"

if [ -f "$GENERATED_CARD" ]; then
    check_pass "SC-6: generated SKILL.md exists"
else
    check_fail "SC-6: generated SKILL.md exists" "generated card not found at $GENERATED_CARD"
fi

if grep -q "$GUARD_MARKER" "$GENERATED_CARD"; then
    check_pass "SC-6: generated SKILL.md contains the guard marker ($GUARD_MARKER)"
else
    check_fail "SC-6: generated SKILL.md contains the guard marker ($GUARD_MARKER)" \
        "guard marker absent in generated card (RED phase expected)"
fi

# Guard must appear BEFORE any routing metadata (Trigger Dispatch Table) in the
# generated card, matching the pre-flight positioning.
if grep -q "## Pre-Flight Guard (Mandatory)" "$GENERATED_CARD"; then
    guard_line="$(grep -n '^## Pre-Flight Guard (Mandatory)' "$GENERATED_CARD" | head -1 | cut -d: -f1)"
    tdt_line="$(grep -n '^## Trigger Dispatch Table' "$GENERATED_CARD" | head -1 | cut -d: -f1)"
    if [ -n "$guard_line" ] && [ -n "$tdt_line" ] && [ "$guard_line" -lt "$tdt_line" ]; then
        check_pass "SC-6: guard positioned before routing metadata in generated card"
    else
        check_fail "SC-6: guard positioned before routing metadata in generated card" \
            "guard (line $guard_line) is not before Trigger Dispatch Table (line $tdt_line)"
    fi
else
    check_fail "SC-6: generated SKILL.md contains Pre-Flight Guard heading" \
        "Pre-Flight Guard heading absent in generated card (RED phase expected)"
fi

# Also assert the template string directly contains the guard marker.
if grep -q "$GUARD_MARKER" "$INIT_SKILL"; then
    check_pass "SC-6: SKILL_TEMPLATE in init_skill.py contains the guard marker"
else
    check_fail "SC-6: SKILL_TEMPLATE in init_skill.py contains the guard marker" \
        "guard marker absent in init_skill.py (RED phase expected)"
fi

# Clean up the throwaway skill.
rm -rf "$TMP_DIR"

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-6 (#2339) template generator does not yet emit the guard."
    echo ""
    exit 1
fi
exit 0
