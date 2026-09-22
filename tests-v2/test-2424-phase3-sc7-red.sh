#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 3 item 7 SC-7 (string).
#
# SC-7: The execute-phase dispatch link text in the Workflows section of
# .opencode/skills/executing-plans/SKILL.md SHALL be a purpose condensation
# (`dispatch one plan phase`), not a path restatement. Every link to
# tasks/execute-phase.md in the execute-phase entry is checked — both the
# canonical dispatch prompt link label and the `follow [...]` prose link
# label — and each label must: equal `dispatch one plan phase`, differ from
# the href path stem (`execute-phase`), contain no `tasks/`, and not end
# in `.md`.
#
# RED expectation: this test FAILS (exit 1) — the execute-phase entry's prose
# link is `follow [the execute-phase procedure](tasks/execute-phase.md)` and
# its dispatch prompt link is `[execute plan phase](tasks/execute-phase.md)`;
# both labels differ from the required purpose condensation
# `dispatch one plan phase`.
# GREEN expectation: after the remediation edit rewrites the execute-phase
# dispatch link text to `dispatch one plan phase` (href unchanged), the
# assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase3-sc7-red.sh
#        SKILL_MD_PATH=<path> bash .opencode/tests-v2/test-2424-phase3-sc7-red.sh
#        (optional SKILL_MD_PATH overrides the target file for simulation runs)
# Exit: 0 if every execute-phase link label is the purpose condensation, 1 otherwise

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "${SKILL_MD_PATH:-}" ]; then
  SKILL_MD="$SKILL_MD_PATH"
else
  SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/skills/executing-plans/SKILL.md"
fi

REQUIRED_LABEL="dispatch one plan phase"
PATH_STEM="execute-phase"

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

# Isolate the execute-phase entry lines (workflow lines referencing tasks/execute-phase.md).
EXECUTE_PHASE_LINES=$(grep 'tasks/execute-phase\.md' <<<"$SECTION")
if [ -z "$EXECUTE_PHASE_LINES" ]; then
  fail "execute-phase entry (tasks/execute-phase.md) not found in Workflows section of $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-7: every markdown link label targeting tasks/execute-phase.md in the
# execute-phase entry (dispatch prompt link + prose follow link) must be the
# purpose condensation.
LABELS=$(grep -oE '\[[^]]*\]\(tasks/execute-phase\.md\)' <<<"$EXECUTE_PHASE_LINES" | sed -E 's/^\[([^]]*)\]\(tasks\/execute-phase\.md\)$/\1/')
if [ -z "$LABELS" ]; then
  fail "no markdown links to tasks/execute-phase.md found in the execute-phase entry of $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

while IFS= read -r LABEL; do
  [ -z "$LABEL" ] && continue
  # 1. The label equals the required purpose condensation.
  if [ "$LABEL" != "$REQUIRED_LABEL" ]; then
    fail "SC-7: execute-phase link label '$LABEL' differs from the required purpose condensation '$REQUIRED_LABEL'"
  fi
  # 2. The label differs from the href path stem.
  if [ "$LABEL" = "$PATH_STEM" ]; then
    fail "SC-7: execute-phase link label equals the href path stem '$PATH_STEM'"
  fi
  # 3. The label contains no 'tasks/'.
  if grep -q 'tasks/' <<<"$LABEL"; then
    fail "SC-7: execute-phase link label '$LABEL' contains 'tasks/'"
  fi
  # 4. The label does not end in '.md'.
  case "$LABEL" in
    *.md) fail "SC-7: execute-phase link label '$LABEL' ends in '.md'" ;;
  esac
done <<<"$LABELS"

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
