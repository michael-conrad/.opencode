#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 1 item 2 SC-2 (string).
#
# SC-2: The execute-phase entry's dispatch prompt text in the Workflows section
# of .opencode/skills/executing-plans/SKILL.md SHALL begin with the
# "You are a sub-agent." prefix inside the quoted prompt string, immediately
# before "Follow the instructions in".
#
# RED expectation: this test FAILS (exit 1) — the Workflows section currently
# has no canonical dispatch prompt string for the execute-phase entry, so the
# "You are a sub-agent." prefix inside the quote is absent.
# GREEN expectation: after the remediation edit, the assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase1-sc2-red.sh
# Exit: 0 if the execute-phase dispatch prompt string carries the prefix, 1 otherwise

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/skills/executing-plans/SKILL.md"

FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

# Extract the Workflows section (from '## Workflows' up to the next '## ' heading).
SECTION=$(sed -n '/^## Workflows$/,/^## /p' "$SKILL_MD" | sed '$d')
if [ -z "$SECTION" ]; then
  fail "Workflows section not found in $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# Isolate the execute-phase entry lines (workflow lines referencing tasks/execute-phase.md).
EXECUTE_PHASE_LINES=$(grep 'tasks/execute-phase\.md' <<<"$SECTION")
if [ -z "$EXECUTE_PHASE_LINES" ]; then
  fail "execute-phase entry (tasks/execute-phase.md) not found in Workflows section of $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-2: the execute-phase dispatch prompt string must begin with the
# "You are a sub-agent." prefix inside the quote, immediately before
# "Follow the instructions in".
if ! grep -qE '"You are a sub-agent\. Follow the instructions in ' <<<"$EXECUTE_PHASE_LINES"; then
  fail "SC-2: execute-phase dispatch prompt string lacks the 'You are a sub-agent.' prefix inside the quote before 'Follow the instructions in'"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
