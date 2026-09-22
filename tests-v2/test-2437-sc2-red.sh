#!/usr/bin/env bash
# RED test for issue .opencode#2437 item 2, SC-2 (string grep — content-verification).
#
# SC-2: The `git-workflow-pr` skill card's `pr-creation` workflow step states the
# classification `task-card` with a citation of the canonical dispatch-vocabulary
# table in `.opencode/reference/skill-card-description-standards.md`, consistent
# with the Mandatory Task Discipline clause (R-2, R-6).
#
# Scope note: assertions run against the "Create a PR" workflow STEP BODY only
# (lines between the `### Create a PR` heading and the next `### ` heading) —
# not the whole card. The Mandatory Task Discipline clause already mentions
# `task-card` card-wide; the SC requires the classification ON the step itself.
#
# RED expectation: this test FAILS (exit non-zero) against the current file
# because the pr-creation step carries no `task-card` classification and cites
# no canonical table. GREEN: after the step is marked with the `task-card`
# classification citing the canonical table (with no contradictory marker text
# remaining), all assertions pass and the test exits 0.

set -u

SKILL="$(cd "$(dirname "$0")/.." && pwd)/skills/git-workflow-pr/SKILL.md"
FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

if [ ! -f "$SKILL" ]; then
  fail "skill card not found: $SKILL"
  echo "EXIT: 1"
  exit 1
fi

# Extract the pr-creation workflow step body: from the "### Create a PR"
# heading through the line before the next "### " heading.
STEP_BODY=$(awk '/^### Create a PR$/{f=1;next} /^### /{f=0} f' "$SKILL")
if [ -z "$STEP_BODY" ]; then
  fail "pr-creation workflow step body not found (no '### Create a PR' section)"
  echo "EXIT: 1"
  exit 1
fi

# SC-2: step body states the classification `task-card`
if ! grep -q 'task-card' <<<"$STEP_BODY"; then
  fail "SC-2: pr-creation step body does not state the 'task-card' classification"
fi

# SC-2: step body cites the canonical dispatch-vocabulary table file
if ! grep -q 'skill-card-description-standards.md' <<<"$STEP_BODY"; then
  fail "SC-2: pr-creation step body does not cite the canonical dispatch-vocabulary table (.opencode/reference/skill-card-description-standards.md)"
fi

# SC-2 (R-6): no contradictory marker text remains in the step body
if grep -q 'Execution mode: sub-agent dispatch' <<<"$STEP_BODY"; then
  fail "SC-2 R-6: contradictory marker 'Execution mode: sub-agent dispatch' still present in pr-creation step body"
fi
if grep -q 'task(subagent_type=' <<<"$STEP_BODY"; then
  fail "SC-2 R-6: contradictory sub-agent-dispatch task() prompt still present in pr-creation step body"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0
