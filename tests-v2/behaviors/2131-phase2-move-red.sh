#!/usr/bin/env bash
# RED test for Issue 2131, Phase 2 — Move
# SC-3: Enforcement Test Mandate moved to test-driven-development skill card
# SC-8: Moved content preserves all normative rules
#
# This test asserts the "Enforcement Test Mandate" section EXISTS in
# test-driven-development/SKILL.md. It should FAIL because the section
# has not been moved there yet (RED phase).

set -euo pipefail

SKILL_FILE=".opencode/skills/test-driven-development/SKILL.md"
SECTION_HEADER="## Enforcement Test Mandate for Guideline and Skill Changes"

if grep -q "$SECTION_HEADER" "$SKILL_FILE"; then
  echo "PASS: Section found in $SKILL_FILE"
  exit 0
else
  echo "FAIL: Section '$SECTION_HEADER' not found in $SKILL_FILE"
  echo "Expected RED failure — section has not been moved yet."
  exit 1
fi
