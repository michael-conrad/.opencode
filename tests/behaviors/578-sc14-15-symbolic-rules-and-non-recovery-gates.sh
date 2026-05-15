#!/bin/bash
# SC-14/SC-15: SKILL.md symbolic rules and cross-validate non-recovery gates
#
# Content-verification test for spec #578 dark pattern additions + revised defects.
# SC-14: SKILL.md includes adversarial-audit-013 through adversarial-audit-018 symbolic rules.
# SC-15: cross-validate.md has Non-Recovery Gates section with terminal BLOCKED language.
#
# RED: Expect FAIL against dev baseline (rules 013-018 don't exist; no non-recovery gates).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc14-15-symbolic-rules-and-non-recovery-gates"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/adversarial-audit/SKILL.md"
CV_FILE="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks/cross-validate.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# SC-14: Six new symbolic rules (adversarial-audit-013 through -018)
if [ ! -f "$SKILL_FILE" ]; then
    echo "FAIL: SC-14 — SKILL.md not found at $SKILL_FILE"
    OVERALL_RESULT=1
else
    RULE_COUNT=0
    for RULE_NUM in 013 014 015 016 017 018; do
        if grep -q "adversarial-audit-${RULE_NUM}" "$SKILL_FILE"; then
            RULE_COUNT=$((RULE_COUNT + 1))
        else
            echo "FAIL: SC-14 — adversarial-audit-${RULE_NUM} not found in SKILL.md"
            OVERALL_RESULT=1
        fi
    done

    if [ "$RULE_COUNT" -eq 6 ]; then
        echo "PASS: SC-14 — All 6 symbolic rules (013-018) found in SKILL.md"
    else
        echo "FAIL: SC-14 — Found $RULE_COUNT/6 symbolic rules in SKILL.md"
        OVERALL_RESULT=1
    fi
fi

# SC-15: Non-Recovery Gates section in cross-validate.md
if [ ! -f "$CV_FILE" ]; then
    echo "FAIL: SC-15 — cross-validate.md not found"
    OVERALL_RESULT=1
else
    # Assertion 1: "Non-Recovery Gates" section exists
    if grep -qi "Non-Recovery Gates\|Non-recovery Gates\|Non-Recovery" "$CV_FILE"; then
        echo "PASS: SC-15 — cross-validate.md has Non-Recovery Gates section"
    else
        echo "FAIL: SC-15 — cross-validate.md missing Non-Recovery Gates section"
        OVERALL_RESULT=1
    fi

    # Assertion 2: "NO fallback" language
    if grep -qi "NO fallback\|no fallback\|NO single-auditor mode\|no alternative" "$CV_FILE"; then
        echo "PASS: SC-15 — Non-Recovery Gates contain 'NO fallback' language"
    else
        echo "FAIL: SC-15 — Missing 'NO fallback' language in Non-Recovery Gates"
        OVERALL_RESULT=1
    fi

    # Assertion 3: "ONLY valid path" language
    if grep -qi "ONLY valid path\|only valid path.*resolve-models\|resolve-models.*cross-validate.*result" "$CV_FILE"; then
        echo "PASS: SC-15 — Non-Recovery Gates contain 'ONLY valid path' language"
    else
        echo "FAIL: SC-15 — Missing 'ONLY valid path' language in Non-Recovery Gates"
        OVERALL_RESULT=1
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT