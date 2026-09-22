#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 2 item 5 SC-5 (string).
#
# SC-5: The Workflows section of .opencode/skills/executing-plans/SKILL.md
# SHALL use the numbered `N. **` format without the `- [ ] ` checkbox prefix.
#
# RED expectation: this test FAILS (exit 1) — the Workflows section currently
# uses `- [ ] 1. **Read the plan file**` and `- [ ] 2. **Execute phases in
# sequence**` checkbox headers, so the `- [ ] N. **` checkbox prefix is
# present and the line-start `N. **` numbered format is absent. The validator
# confirms the defect as a REQ-6 workflows-steps violation for skill_name
# executing-plans (validate_skill_cards.py --json exits 1).
# GREEN expectation: after the remediation edit converts the entries to the
# numbered format, the assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase2-sc5-red.sh
# Exit: 0 if the Workflows section contains no `- [ ] N. **` checkbox prefix
#       and the line-start `N. **` numbered format is present, 1 otherwise

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/skills/executing-plans/SKILL.md"

FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

# Isolate the `## Workflows` section body (heading line up to the next
# `## ` heading) so the format checks cannot be satisfied by text elsewhere
# in the card.
if ! grep -q '^## Workflows$' "$SKILL_MD"; then
  fail "SC-5: no '## Workflows' heading found in $SKILL_MD (REQ-6 workflows violation confirmed by validator)"
  echo "EXIT: 1"
  exit 1
fi

SECTION_BODY=$(awk '/^## Workflows$/{flag=1; next} /^## /{flag=0} flag' "$SKILL_MD")
if [ -z "$SECTION_BODY" ]; then
  fail "SC-5: '## Workflows' section body is empty in $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-5 assertion 1: the Workflows section SHALL NOT contain the
# `- [ ] N. **` checkbox prefix.
if grep -qE '^- \[ \] [0-9]+\. \*\*' <<<"$SECTION_BODY"; then
  fail "SC-5: Workflows section uses the '- [ ] N. **' checkbox prefix — numbered 'N. **' format required (REQ-6 workflows-steps violation confirmed by validator)"
fi

# SC-5 assertion 2: the Workflows section SHALL contain the line-start
# numbered `N. **` dispatch-step format.
if ! grep -qE '^[0-9]+\. \*\*' <<<"$SECTION_BODY"; then
  fail "SC-5: Workflows section missing the line-start numbered 'N. **' dispatch-step format"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
