#!/bin/bash
# Content-Verification Test: Mandatory Invocation
# Issue #161 - Verifies mandatory invocation callouts exist in skill files
# and critical violation text exists in 000-critical-rules.md
#
# SECONDARY enforcement (behavioral is PRIMARY per 091-incremental-build.md)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../behaviors/_find_project_root.sh"
SKILLS_DIR="$(_find_project_root)/.opencode/skills"
GUIDELINES_DIR="$(_find_project_root)/.opencode/guidelines"

OVERALL_RESULT=0

# SC-6: Content-verification test confirms mandatory language in all 10 skill files and critical-rules.md

echo "=== Content-Verification Test: Mandatory Invocation ==="

# Check each skill for mandatory invocation callout
SKILLS=(
  "test-driven-development"
  "spec-auditor"
  "guideline-auditor"
  "skill-creator"
  "sre-runbook"
  "issue-review"
  "verification-before-completion"
  "verification-enforcement"
  "finishing-a-development-branch"
  "git-workflow"
)

for skill in "${SKILLS[@]}"; do
  SKILL_FILE="$SKILLS_DIR/$skill/SKILL.md"
  if [ ! -f "$SKILL_FILE" ]; then
    echo "FAIL: $skill/SKILL.md not found"
    OVERALL_RESULT=1
    continue
  fi

  # Check for mandatory invocation callout pattern
  if grep -q "MANDATORY.*MUST invoke\|MANDATORY.*agent MUST invoke\|MANDATORY: The agent MUST invoke" "$SKILL_FILE"; then
    echo "PASS: $skill — mandatory invocation callout found"
  else
    echo "FAIL: $skill — mandatory invocation callout NOT found"
    OVERALL_RESULT=1
  fi

  # Check for exemption criteria
  if grep -qi "exempt\|exemption" "$SKILL_FILE"; then
    echo "PASS: $skill — exemption criteria documented"
  else
    echo "FAIL: $skill — exemption criteria NOT documented"
    OVERALL_RESULT=1
  fi
done

# Check 000-critical-rules.md for Skipping Mandatory Skill Invocation violation
CRITICAL_RULES="$GUIDELINES_DIR/000-critical-rules.md"
if [ ! -f "$CRITICAL_RULES" ]; then
  echo "FAIL: 000-critical-rules.md not found"
  OVERALL_RESULT=1
else
  if grep -q "Skipping Mandatory Skill Invocation\|Skipping.*mandatory.*skill.*invocation\|skill.*invocation.*critic" "$CRITICAL_RULES"; then
    echo "PASS: 000-critical-rules.md — mandatory skill invocation violation found"
  else
    echo "FAIL: 000-critical-rules.md — mandatory skill invocation violation NOT found"
    OVERALL_RESULT=1
  fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: Content-verification — all mandatory invocation patterns found"
else
    echo "FAIL: Content-verification — some mandatory invocation patterns missing"
fi

exit $OVERALL_RESULT