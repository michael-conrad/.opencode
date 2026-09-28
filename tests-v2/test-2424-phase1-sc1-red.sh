#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 1 item 1 SC-1 (string).
#
# SC-1: The read-plan entry's dispatch prompt text in the Workflows section of
# .opencode/skills/executing-plans/SKILL.md SHALL begin with the
# "You are a sub-agent." prefix inside the quoted prompt string, immediately
# before "Follow the instructions in".
#
# RED expectation: this test FAILS (exit 1) — the Workflows section currently
# has no canonical dispatch prompt string for the read-plan entry, so the
# "You are a sub-agent." prefix inside the quote is absent.
# GREEN expectation: after the remediation edit, the assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase1-sc1-red.sh
# Exit: 0 if the read-plan dispatch prompt string carries the prefix, 1 otherwise

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

# Isolate the read-plan entry lines (workflow lines referencing tasks/read-plan.md).
READ_PLAN_LINES=$(grep 'tasks/read-plan\.md' <<<"$SECTION")
if [ -z "$READ_PLAN_LINES" ]; then
  fail "read-plan entry (tasks/read-plan.md) not found in Workflows section of $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-1: the read-plan dispatch prompt string must begin with the
# "You are a sub-agent." prefix inside the quote, immediately before
# "Follow the instructions in".
if ! grep -qE '"You are a sub-agent\. Follow the instructions in ' <<<"$READ_PLAN_LINES"; then
  fail "SC-1: read-plan dispatch prompt string lacks the 'You are a sub-agent.' prefix inside the quote before 'Follow the instructions in'"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
