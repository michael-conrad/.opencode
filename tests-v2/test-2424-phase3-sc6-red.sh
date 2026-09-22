#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 3 item 6 SC-6 (string).
#
# SC-6: The read-plan dispatch link text in the Workflows section of
# .opencode/skills/executing-plans/SKILL.md SHALL be a purpose condensation
# (`inventory plan phases`), not a path restatement. Every link to
# tasks/read-plan.md in the read-plan entry is checked — both the canonical
# dispatch prompt link label and the `follow [...]` prose link label — and
# each label must: equal `inventory plan phases`, differ from the href path
# stem (`read-plan`), contain no `tasks/`, and not end in `.md`.
#
# RED expectation: this test FAILS (exit 1) — the read-plan entry's prose
# link is `follow [the read-plan procedure](tasks/read-plan.md)`, whose
# label `the read-plan procedure` differs from the required purpose
# condensation `inventory plan phases`.
# GREEN expectation: after the remediation edit rewrites the read-plan
# dispatch link text to `inventory plan phases` (href unchanged), the
# assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase3-sc6-red.sh
#        SKILL_MD_PATH=<path> bash .opencode/tests-v2/test-2424-phase3-sc6-red.sh
#        (optional SKILL_MD_PATH overrides the target file for simulation runs)
# Exit: 0 if every read-plan link label is the purpose condensation, 1 otherwise

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "${SKILL_MD_PATH:-}" ]; then
  SKILL_MD="$SKILL_MD_PATH"
else
  SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/skills/executing-plans/SKILL.md"
fi

REQUIRED_LABEL="inventory plan phases"
PATH_STEM="read-plan"

FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

if [ ! -f "$SKILL_MD" ]; then
  fail "target file not found: $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

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

# SC-6: every markdown link label targeting tasks/read-plan.md in the
# read-plan entry (dispatch prompt link + prose follow link) must be the
# purpose condensation.
LABELS=$(grep -oE '\[[^]]*\]\(tasks/read-plan\.md\)' <<<"$READ_PLAN_LINES" | sed -E 's/^\[([^]]*)\]\(tasks\/read-plan\.md\)$/\1/')
if [ -z "$LABELS" ]; then
  fail "no markdown links to tasks/read-plan.md found in the read-plan entry of $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

while IFS= read -r LABEL; do
  [ -z "$LABEL" ] && continue
  # 1. The label equals the required purpose condensation.
  if [ "$LABEL" != "$REQUIRED_LABEL" ]; then
    fail "SC-6: read-plan link label '$LABEL' differs from the required purpose condensation '$REQUIRED_LABEL'"
  fi
  # 2. The label differs from the href path stem.
  if [ "$LABEL" = "$PATH_STEM" ]; then
    fail "SC-6: read-plan link label equals the href path stem '$PATH_STEM'"
  fi
  # 3. The label contains no 'tasks/'.
  if grep -q 'tasks/' <<<"$LABEL"; then
    fail "SC-6: read-plan link label '$LABEL' contains 'tasks/'"
  fi
  # 4. The label does not end in '.md'.
  case "$LABEL" in
    *.md) fail "SC-6: read-plan link label '$LABEL' ends in '.md'" ;;
  esac
done <<<"$LABELS"

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
