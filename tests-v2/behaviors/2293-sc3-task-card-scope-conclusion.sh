#!/bin/bash
# Behavioral test: 2293-sc3-task-card-scope-conclusion
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: No agent reading the guidelines SHALL be able to reasonably conclude that
# submodule repos cannot file their own PRs.
#
# RED STATE: the surviving task-card references still say "submodule-only PR is
# FORBIDDEN in ANY context" (git-workflow-commit/tasks/implementation.md line 39,
# git-workflow-pr/tasks/pr-creation.md line 54, git-workflow-cleanup/SKILL.md line 51,
# git-workflow-cleanup/tasks/cleanup/branch-cleanup.md lines 172, 319). An agent asked
# in a parent-repo PR-creation context whether it may file a PR for a submodule repo's
# own change reads these references and reasonably concludes the submodule repo cannot
# file its own PR — the opposite of the SC-3 target behavior. This run's session.yaml
# therefore shows the agent concluding a submodule repo cannot file its own PR, so the
# SC-3 criterion is NOT satisfied and the SC FAILS (RED).
#
# GREEN STATE: the surviving task-card references are reworded to be parent-repo +
# action-scoped, explicitly stating the prohibition applies ONLY to a parent-repo PR
# whose sole change is bumping submodule pointers, and that a submodule repo filing its
# own PR for its own changes is normal and NOT covered. An agent asked the same question
# then concludes a submodule repo CAN file its own PR. This run's session.yaml then
# shows the agent reaching the correct conclusion, satisfying the SC-3 criterion and the
# SC PASSES (GREEN).
#
# PROMPT CONSTRUCTION:
# Real-domain task: execute the git-workflow-pr pr-creation task card to create a PR
# in the parent repo, where the change under review is a sibling submodule repo's own
# AGENTS.md edit. Executing the task card forces the agent to read the Pre-Push
# Submodule Pointer Verification step in pr-creation.md (line 54), which in the RED
# state still contains "Creating a submodule-only PR is FORBIDDEN in ANY context".
# Reading that surviving wording leads the agent to conclude the submodule repo's own
# PR is a forbidden submodule-only PR — the opposite of the SC-3 target behavior. This
# triggers natural agent behavior (executing a task card), NOT a prose-recall interview
# about what the agent would do.
#
# SC-3: No agent reading the guidelines SHALL be able to reasonably conclude that
# submodule repos cannot file their own PRs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2293-sc3-task-card-scope-conclusion"
SCENARIO_PROMPT="You are preparing to create a pull request in this parent repository for a change that lives entirely inside the sibling .opencode submodule (an edit to the submodule's own AGENTS.md). The ONLY staged change for this PR is that submodule edit. Follow the git-workflow-pr skill's pr-creation task card, specifically the Pre-Push Submodule Pointer Verification step, and apply its submodule-pointer checks verbatim to this PR. Decide strictly from those task-card steps whether this PR may proceed or whether it is a forbidden submodule-only PR that must be halted. Then state your conclusion and which task-card step you applied."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
