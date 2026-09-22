#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 2 item 4 SC-4 (string).
#
# SC-4: .opencode/skills/executing-plans/SKILL.md SHALL include a
# `## Worktree Mode` section whose body contains exactly the canonical
# direct-branch wording quoted verbatim in Appendix A of the spec:
# "This skill operates in the main repo directory (direct-branch mode). When
# `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with
# `worktree.path`."
#
# RED expectation: this test FAILS (exit 1) — the card currently lacks the
# `## Worktree Mode` section entirely, so neither the heading nor the
# Appendix A canonical sentence is present. The validator confirms the defect
# as a REQ-3 worktree-mode violation for skill_name executing-plans
# (validate_skill_cards.py --json exits 1).
# GREEN expectation: after the remediation edit inserts the section with the
# verbatim sentence, the assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase2-sc4-red.sh
# Exit: 0 if the `## Worktree Mode` section exists and its body contains the
#       Appendix A canonical sentence verbatim, 1 otherwise

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/skills/executing-plans/SKILL.md"

FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

# SC-4 assertion 1: the card SHALL include a `## Worktree Mode` section.
if ! grep -q '^## Worktree Mode$' "$SKILL_MD"; then
  fail "SC-4: no '## Worktree Mode' heading found in $SKILL_MD (REQ-3 worktree-mode violation confirmed by validator)"
  echo "EXIT: 1"
  exit 1
fi

# Isolate the `## Worktree Mode` section body (heading line up to the next
# `## ` heading) so the sentence check cannot be satisfied by text elsewhere
# in the card.
SECTION_BODY=$(awk '/^## Worktree Mode$/{flag=1; next} /^## /{flag=0} flag' "$SKILL_MD")
if [ -z "$SECTION_BODY" ]; then
  fail "SC-4: '## Worktree Mode' section body is empty in $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-4 assertion 2: the section body SHALL contain the Appendix A canonical
# sentence verbatim.
CANONICAL_SENTENCE='This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.'
if ! grep -qF -- "$CANONICAL_SENTENCE" <<<"$SECTION_BODY"; then
  fail "SC-4: '## Worktree Mode' section body does not contain the Appendix A canonical sentence verbatim"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
