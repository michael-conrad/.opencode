#!/usr/bin/env bash
# RED test for issue .opencode#2437 item 5, SC-5 (string grep — content-verification).
#
# SC-5: The `git-workflow` skill card's "Create a PR" workflow entry contains the
# `task-card` classification vocabulary and does not contain the prohibited old
# sub-agent-dispatch prompt text (R-5: same classification vocabulary as R-2 —
# `task-card` citing the canonical dispatch-vocabulary table in
# `.opencode/reference/skill-card-description-standards.md`).
#
# Scope note: assertions run against the "Create a PR" workflow ENTRY body only
# (lines between the `### Create a PR` heading and the next `### ` heading) —
# not the whole card. The Mandatory Task Discipline clause already mentions
# `task-card` card-wide; the SC requires the classification ON the entry itself.
#
# RED expectation: this test FAILS (exit non-zero) against the current file
# because the entry carries no `task-card` classification, cites no canonical
# table, and still carries the old sub-agent-dispatch prompt text (the verbatim
# pr-creation prompt quoted in SC-5 plus the generic `task(subagent_type=`
# / "You are a sub-agent." / `sub-agent dispatch` markers on all three entry
# steps). GREEN: after the entry is aligned to the `task-card` classification
# citing the canonical table with no old sub-agent-dispatch prompt text
# remaining, all assertions pass and the test exits 0.

set -u

SKILL="$(cd "$(dirname "$0")/.." && pwd)/skills/git-workflow/SKILL.md"
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

# Extract the "Create a PR" workflow entry body: from the "### Create a PR"
# heading through the line before the next "### " heading.
ENTRY_BODY=$(awk '/^### Create a PR$/{f=1;next} /^### /{f=0} f' "$SKILL")
if [ -z "$ENTRY_BODY" ]; then
  fail "Create a PR workflow entry body not found (no '### Create a PR' section)"
  echo "EXIT: 1"
  exit 1
fi

# SC-5 (R-5): entry body states the `task-card` classification vocabulary
if ! grep -q 'task-card' <<<"$ENTRY_BODY"; then
  fail "SC-5: 'Create a PR' entry body does not state the 'task-card' classification vocabulary"
fi

# SC-5 (R-5 -> R-2): entry body cites the canonical dispatch-vocabulary table
if ! grep -q 'skill-card-description-standards.md' <<<"$ENTRY_BODY"; then
  fail "SC-5: 'Create a PR' entry body does not cite the canonical dispatch-vocabulary table (.opencode/reference/skill-card-description-standards.md)"
fi

# SC-5: the verbatim prohibited old sub-agent-dispatch prompt text (quoted in
# SC-5) is absent from the entry body
PROHIBITED_PROMPT='task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [create pull request](.opencode/skills/git-workflow-pr/tasks/pr-creation.md). branch_name: ", branch_name, ", spec_summary: ", spec_summary, ", is_release: ", is_release))'
if grep -qF "$PROHIBITED_PROMPT" <<<"$ENTRY_BODY"; then
  fail "SC-5: prohibited old sub-agent-dispatch prompt text still present in 'Create a PR' entry body"
fi

# SC-5: generic old sub-agent-dispatch markers are absent from the entry body
if grep -q 'task(subagent_type=' <<<"$ENTRY_BODY"; then
  fail "SC-5: old sub-agent-dispatch task() prompt still present in 'Create a PR' entry body"
fi
if grep -q 'You are a sub-agent' <<<"$ENTRY_BODY"; then
  fail "SC-5: old sub-agent-dispatch persona line still present in 'Create a PR' entry body"
fi
if grep -q 'sub-agent dispatch' <<<"$ENTRY_BODY"; then
  fail "SC-5: old 'sub-agent dispatch' execution-mode marker still present in 'Create a PR' entry body"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "EXIT: 1"
  exit 1
fi
echo "EXIT: 0"
exit 0

# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
