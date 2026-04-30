#!/bin/bash
# Content-Verification Test: MANDATORY TASKS Checklist Sections
# Issue #219 - Verifies MANDATORY TASKS sections exist in priority skill cards
# with `- [ ] MANDATORY:` checkbox format
#
# SECONDARY enforcement (behavioral is PRIMARY per 091-incremental-build.md)
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../behaviors/_find_project_root.sh"
SKILLS_DIR="$(_find_project_root)/.opencode/skills"

OVERALL_RESULT=0

echo "=== Content-Verification Test: MANDATORY TASKS Checklist Sections ==="

# The 8 priority skills from issue #219 Phase 1
PRIORITY_SKILLS=(
  "spec-creation"
  "writing-plans"
  "issue-operations"
  "spec-auditor"
  "approval-gate"
  "divide-and-conquer"
  "verification-before-completion"
  "git-workflow"
)

for skill in "${PRIORITY_SKILLS[@]}"; do
  SKILL_FILE="$SKILLS_DIR/$skill/SKILL.md"
  if [ ! -f "$SKILL_FILE" ]; then
    echo "FAIL: $skill/SKILL.md not found"
    OVERALL_RESULT=1
    continue
  fi

  # Check for ## MANDATORY TASKS section heading
  if grep -q "^## MANDATORY TASKS" "$SKILL_FILE"; then
    echo "PASS: $skill — MANDATORY TASKS section heading found"
  else
    echo "FAIL: $skill — MANDATORY TASKS section heading NOT found"
    OVERALL_RESULT=1
    continue
  fi

  # Check for at least one `- [ ] MANDATORY:` checkbox
  COUNT=$(grep -c "^- \[ \] MANDATORY:" "$SKILL_FILE" 2>/dev/null || true)
  COUNT=${COUNT:-0}
  COUNT=$(echo "$COUNT" | head -1 | tr -d '[:space:]')
  if [ "$COUNT" -ge 1 ]; then
    echo "PASS: $skill — $COUNT MANDATORY checkbox items found"
  else
    echo "FAIL: $skill — no MANDATORY checkbox items found"
    OVERALL_RESULT=1
  fi

  # Check for traceability references (guideline or skill references)
  if grep -q "^- \[ \] MANDATORY:.*per §\|^- \[ \] MANDATORY:.*per " "$SKILL_FILE"; then
    echo "PASS: $skill — traceability references found in MANDATORY items"
  else
    echo "FAIL: $skill — no traceability references in MANDATORY items"
    OVERALL_RESULT=1
  fi
done

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: Content-verification — all 8 priority skills have MANDATORY TASKS sections"
else
    echo "FAIL: Content-verification — some MANDATORY TASKS sections missing or incomplete"
fi

exit $OVERALL_RESULT