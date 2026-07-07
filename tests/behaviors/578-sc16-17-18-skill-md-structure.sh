#!/bin/bash
# SC-16/SC-17/SC-18: SKILL.md structural requirements
#
# Content-verification test for spec #578 Revision A (Defects 7–10).
# SC-16: SKILL.md has valid YAML front-matter with name, description (starting with "Use when"), license.
# SC-17: Task Context Audit table lists auditor_verdicts in cross-validate Context column.
# SC-18: Task Context Audit table lists "orchestrator reasoning" in cross-validate Exclusions column.
#
# RED: Expect FAIL against dev baseline (SKILL.md missing front-matter; table uses old columns).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc16-17-18-skill-md-structure"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_FILE="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

if [ ! -f "$SKILL_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — SKILL.md not found at $SKILL_FILE"
    OVERALL_RESULT=1
else
    # SC-16: SKILL.md starts with --- front-matter delimiter
    FIRST_LINE=$(head -1 "$SKILL_FILE")
    if [ "$FIRST_LINE" = "---" ]; then
        echo "PASS: SC-16 — SKILL.md starts with --- front-matter delimiter"
    else
        echo "FAIL: SC-16 — SKILL.md does not start with --- delimiter (got: $(echo "$FIRST_LINE" | head -c 40))"
        OVERALL_RESULT=1
    fi

    # SC-16: SKILL.md has name field
    if grep -q "^name:" "$SKILL_FILE"; then
        echo "PASS: SC-16 — SKILL.md has name field"
    else
        echo "FAIL: SC-16 — SKILL.md missing name field"
        OVERALL_RESULT=1
    fi

    # SC-16: SKILL.md description starts with "Use when"
    if grep -qi "^description:.*Use when\|^description:.*Use when" "$SKILL_FILE"; then
        echo "PASS: SC-16 — SKILL.md description starts with 'Use when'"
    else
        echo "FAIL: SC-16 — SKILL.md description does not start with 'Use when'"
        OVERALL_RESULT=1
    fi

    # SC-16: SKILL.md has license field
    if grep -q "^license:" "$SKILL_FILE"; then
        echo "PASS: SC-16 — SKILL.md has license field"
    else
        echo "FAIL: SC-16 — SKILL.md missing license field"
        OVERALL_RESULT=1
    fi

    # SC-17: cross-validate Task Context Audit row has auditor_verdicts in Context
    if grep -i "cross-validate.*auditor_verdicts\|auditor_verdicts.*cross-validate" "$SKILL_FILE"; then
        echo "PASS: SC-17 — cross-validate Task Context Audit row has auditor_verdicts in Context"
    else
        echo "FAIL: SC-17 — cross-validate Task Context Audit row missing auditor_verdicts in Context"
        OVERALL_RESULT=1
    fi

    # SC-18: cross-validate Task Context Audit row has "orchestrator reasoning" in Exclusions
    if grep -i "cross-validate.*orchestrator reasoning\|orchestrator reasoning" "$SKILL_FILE" | grep -i "exclusion\|Exclusion" > /dev/null 2>&1; then
        echo "PASS: SC-18 — cross-validate Exclusions column contains 'orchestrator reasoning'"
    else
        echo "FAIL: SC-18 — cross-validate Exclusions column missing 'orchestrator reasoning'"
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