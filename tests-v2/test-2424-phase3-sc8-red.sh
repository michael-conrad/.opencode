#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2424 phase 3 item 8 SC-8 (string).
#
# SC-8: .opencode/skills/executing-plans/SKILL.md SHALL include a
# `## Mandatory Task Discipline` section whose body contains the deck's
# canonical four-item checklist (numbered checklist, per the conforming form
# in .opencode/skills/completion-core/SKILL.md):
#   1. every task mandatory;
#   2. no skipping/combining/inline delegation work;
#   3. execute each workflow step in the orchestrator's own context per the
#      Dispatch value, dispatching a step's task card via `task()` only where
#      the Dispatch value is `task-card`;
#   4. return only routing-significant data.
#
# RED expectation: this test FAILS (exit 1) — the card currently lacks the
# `## Mandatory Task Discipline` section entirely, so neither the heading nor
# the four checklist items is present. The validator confirms the defect as a
# REQ-5 admonishment violation for skill_name executing-plans
# (validate_skill_cards.py --json exits 1).
# GREEN expectation: after the remediation edit inserts the section with the
# canonical four-item checklist (conforming form of completion-core/SKILL.md),
# the assertions pass (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2424-phase3-sc8-red.sh
#        SKILL_MD_PATH=<path> bash .opencode/tests-v2/test-2424-phase3-sc8-red.sh
#        (optional SKILL_MD_PATH overrides the target file for simulation runs)
# Exit: 0 if the `## Mandatory Task Discipline` section exists and its body
#       contains the canonical four-item checklist, 1 otherwise

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "${SKILL_MD_PATH:-}" ]; then
  SKILL_MD="$SKILL_MD_PATH"
else
  SKILL_MD="$(cd "$SCRIPT_DIR/.." && pwd)/skills/executing-plans/SKILL.md"
fi

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

# SC-8 assertion 1: the card SHALL include a `## Mandatory Task Discipline`
# section.
if ! grep -q '^## Mandatory Task Discipline$' "$SKILL_MD"; then
  fail "SC-8: no '## Mandatory Task Discipline' heading found in $SKILL_MD (REQ-5 admonishment violation confirmed by validator)"
  echo "EXIT: 1"
  exit 1
fi

# Isolate the `## Mandatory Task Discipline` section body (heading line up to
# the next `## ` heading) so the checklist checks cannot be satisfied by text
# elsewhere in the card.
SECTION_BODY=$(awk '/^## Mandatory Task Discipline$/{flag=1; next} /^## /{flag=0} flag' "$SKILL_MD")
if [ -z "$SECTION_BODY" ]; then
  fail "SC-8: '## Mandatory Task Discipline' section body is empty in $SKILL_MD"
  echo "EXIT: 1"
  exit 1
fi

# SC-8 assertion 2: the section body SHALL contain exactly four numbered
# checklist items (canonical `- [ ] N.` form, per the conforming form in
# completion-core/SKILL.md).
ITEM_COUNT=$(grep -cE '^- \[ \] [0-9]+\. ' <<<"$SECTION_BODY" || true)
if [ "$ITEM_COUNT" -ne 4 ]; then
  fail "SC-8: '## Mandatory Task Discipline' section contains $ITEM_COUNT numbered checklist items (expected 4)"
fi

# SC-8 assertion 3: each of the four canonical checklist items SHALL be
# present with its key content, bound to its numbered item block. An item
# block is its `- [ ] N.` line plus any continuation lines up to the next
# numbered item.
check_item() {
  local NUM="$1"
  shift
  local ITEM_TEXT
  ITEM_TEXT=$(awk -v target="$NUM" '
    /^- \[ \] [0-9]+\. / { cur++; printing = (cur == target) }
    printing { print }
  ' <<<"$SECTION_BODY")
  if [ -z "$ITEM_TEXT" ]; then
    fail "SC-8: numbered checklist item $NUM not found in the '## Mandatory Task Discipline' section of $SKILL_MD"
    return
  fi
  local PHRASE
  for PHRASE in "$@"; do
    if ! grep -qiF -- "$PHRASE" <<<"$ITEM_TEXT"; then
      fail "SC-8: checklist item $NUM does not contain the canonical content '$PHRASE'"
    fi
  done
}

# Item 1: every task mandatory.
check_item 1 "every task" "mandatory"
# Item 2: no skipping/combining/inline delegation work.
check_item 2 "skipping" "combining" "inline"
# Item 3: execute each workflow step in the orchestrator's own context per
# the Dispatch value; dispatch a step's task card via task() only where the
# Dispatch value is task-card.
check_item 3 "own context" "dispatch value" 'task()' "task-card"
# Item 4: return only routing-significant data.
check_item 4 "routing-significant data"

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
