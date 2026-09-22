#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 2 item 3 SC-3 (string).
#
# SC-3: The byline in .opencode/skills/executing-plans/SKILL.md SHALL use the
# placeholder form "Co-authored with AI: <AgentName> (<ModelId>)" instead of
# the hardcoded "OpenCode (deepseek-v4-flash)".
#
# RED expectation: this test FAILS (exit 1) — the byline currently reads
# "Co-authored with AI: OpenCode (deepseek-v4-flash)", so the placeholder form
# is absent and the hardcoded identity value is present. The validator
# confirms the defect as a REQ-2 placeholder violation for skill_name
# executing-plans.
# GREEN expectation: after the remediation edit, the assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase2-sc3-red.sh
# Exit: 0 if the byline uses the <AgentName> (<ModelId>) placeholder form and
#       the hardcoded OpenCode (deepseek-v4-flash) is absent, 1 otherwise

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/skills/executing-plans/SKILL.md"

FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

# Isolate the byline line (the "Co-authored with AI:" line) from the card.
BYLINE=$(grep '^Co-authored with AI:' "$SKILL_MD")
if [ -z "$BYLINE" ]; then
  fail "SC-3: no 'Co-authored with AI:' byline line found in $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-3 assertion 1: the byline SHALL use the placeholder form
# "Co-authored with AI: <AgentName> (<ModelId>)".
if ! grep -qE '^Co-authored with AI: <AgentName> \(<ModelId>\)$' <<<"$BYLINE"; then
  fail "SC-3: byline does not use the placeholder form 'Co-authored with AI: <AgentName> (<ModelId>)' (found: $BYLINE)"
fi

# SC-3 assertion 2: the hardcoded 'OpenCode (deepseek-v4-flash)' SHALL be
# absent from the card.
if grep -q 'OpenCode (deepseek-v4-flash)' "$SKILL_MD"; then
  fail "SC-3: hardcoded 'OpenCode (deepseek-v4-flash)' is present in $SKILL_MD — must be replaced with the placeholder form"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
