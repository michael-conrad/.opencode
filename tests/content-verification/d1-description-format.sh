#!/usr/bin/env bash
# Content-verification test: D1 description format for verification-before-completion
#
# Asserts the description uses the agent-intent pattern (not old "Use when" pattern).
set -euo pipefail

SKILL_FILE=".opencode/skills/verification-before-completion/SKILL.md"

# SC-1: Description does NOT start with "Use when" (old pattern)
if grep -q '^description: "Use when' "$SKILL_FILE"; then
  echo "FAIL: SC-1 — description starts with 'Use when' (old pattern)"
  exit 1
else
  echo "PASS: SC-1 — description does NOT start with 'Use when'"
fi

# SC-2: Description contains "Dispatch when" (agent-intent pattern)
if grep -q 'Dispatch when' "$SKILL_FILE"; then
  echo "PASS: SC-2 — description contains 'Dispatch when'"
else
  echo "FAIL: SC-2 — description missing 'Dispatch when'"
  exit 1
fi

# SC-3: Description contains "User phrases:" (new label)
if grep -q 'User phrases:' "$SKILL_FILE"; then
  echo "PASS: SC-3 — description contains 'User phrases:'"
else
  echo "FAIL: SC-3 — description missing 'User phrases:'"
  exit 1
fi

echo "All D1 checks PASS"
