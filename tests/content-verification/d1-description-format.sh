#!/usr/bin/env bash
# Content-verification test: D1 description format for verification-before-completion
#
# Asserts the description starts with "Use when" — RED phase expects FAIL.
set -euo pipefail

SKILL_FILE=".opencode/skills/verification-before-completion/SKILL.md"

# SC-1: Description starts with "Use when"
if grep -q '^description: "Use when' "$SKILL_FILE"; then
  echo "PASS: SC-1 — description starts with 'Use when'"
else
  echo "FAIL: SC-1 — description does NOT start with 'Use when'"
  exit 1
fi

echo "All D1 checks PASS"
