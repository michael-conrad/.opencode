#!/bin/bash
# SC-21: ALL skill cards have correct YAML frontmatter
#
# Content-verification test for spec #578 SC-21.
# SC-21: Every .opencode/skills/*/SKILL.md file has valid YAML frontmatter
#   with name, description (starting with "Use when"), and license fields.
#
# RED: Expect FAIL against dev baseline (approval-gate and completion-core lack proper frontmatter).
# GREEN: Expect PASS after remediation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc21-skill-card-frontmatter"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILLS_DIR="$PROJECT_DIR/.opencode/skills"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="
echo "Checking all SKILL.md files in $SKILLS_DIR"
echo ""

OVERALL_RESULT=0
TOTAL_FILES=0
PASS_COUNT=0
FAIL_LIST=""

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_file="$skill_dir/SKILL.md"
    if [ ! -f "$skill_file" ]; then
        continue
    fi

    skill_name=$(basename "$skill_dir")
    TOTAL_FILES=$((TOTAL_FILES + 1))
    FILE_RESULT=0

    # Check 1: File starts with --- opening delimiter
    FIRST_LINE=$(head -1 "$skill_file")
    if [ "$FIRST_LINE" != "---" ]; then
        echo "FAIL: SC-21 — $skill_name: does not start with --- delimiter (got: $(echo "$FIRST_LINE" | head -c 50))"
        FILE_RESULT=1
    fi

    # Check 2: Has name field
    NAME_FOUND=$(grep -c "^name:" "$skill_file" || true)
    if [ "$NAME_FOUND" -eq 0 ]; then
        echo "FAIL: SC-21 — $skill_name: missing name field in frontmatter"
        FILE_RESULT=1
    fi

    # Check 3: description starts with "Use when"
    DESC_MATCH=$(grep -ci "^description:.*Use when" "$skill_file" || true)
    if [ "$DESC_MATCH" -eq 0 ]; then
        # Get the actual description line for diagnostics
        DESC_LINE=$(grep -i "^description:" "$skill_file" | head -1 || true)
        echo "FAIL: SC-21 — $skill_name: description does not start with 'Use when' (got: $(echo "$DESC_LINE" | head -c 80))"
        FILE_RESULT=1
    fi

    # Check 4: Has license field
    LICENSE_FOUND=$(grep -c "^license:" "$skill_file" || true)
    if [ "$LICENSE_FOUND" -eq 0 ]; then
        echo "FAIL: SC-21 — $skill_name: missing license field in frontmatter"
        FILE_RESULT=1
    fi

    # Check 5: Closing --- delimiter exists (within first 20 lines to stay in frontmatter)
    CLOSING_DELIM=$(head -20 "$skill_file" | grep -c "^---" || true)
    # Opening --- counts as first match, need at least 2 for frontmatter
    if [ "$CLOSING_DELIM" -lt 2 ]; then
        echo "FAIL: SC-21 — $skill_name: no closing --- delimiter found in frontmatter"
        FILE_RESULT=1
    fi

    if [ "$FILE_RESULT" -eq 0 ]; then
        echo "PASS: SC-21 — $skill_name: frontmatter valid"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        FAIL_LIST="$FAIL_LIST $skill_name"
    fi

    OVERALL_RESULT=$((OVERALL_RESULT | FILE_RESULT))
done

echo ""
echo "Summary: $PASS_COUNT/$TOTAL_FILES skill cards have valid frontmatter"

if [ -n "$FAIL_LIST" ]; then
    echo "Failing skills:$FAIL_LIST"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT