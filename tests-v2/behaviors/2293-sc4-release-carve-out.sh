#!/bin/bash
# Behavioral test: 2293-sc4-release-carve-out
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: The release path SHALL NOT be blocked by the "no uncommitted submodule
# changes" pre-validation when dirty/staged submodule pointers are expected in a
# parent-repo release.
#
# RED STATE: the release pre-validation in git-workflow-pr/tasks/pr-creation.md
# (line 32) still contains "No uncommitted submodule changes" as a hard check. An
# agent executing the pr-creation task card for a parent-repo release, with a
# dirty/staged submodule pointer present, reads that check and blocks the release
# path — the opposite of the SC-4 target behavior. This run's session.yaml
# therefore shows the agent halting the release because of the uncommitted
# submodule changes, so the SC-4 criterion is NOT satisfied and the SC FAILS (RED).
#
# GREEN STATE: the release carve-out is added to pr-creation.md release
# pre-validation, stating dirty/staged submodule pointers are EXPECTED and
# permitted in a parent-repo release and the "no uncommitted submodule changes"
# check SHALL NOT block the release path. An agent executing the same task card
# then proceeds with the release despite the dirty/staged pointer. This run's
# session.yaml then shows the agent proceeding, satisfying the SC-4 criterion and
# the SC PASSES (GREEN).
#
# PROMPT CONSTRUCTION:
# Real-domain task: execute the git-workflow-pr pr-creation task card to create a
# release PR in the parent repo, where the .opencode submodule pointer is dirty and
# staged (expected in a parent-repo release). Executing the task card forces the
# agent to read the Release PR pre-validation step in pr-creation.md (line 28-32),
# which in the RED state still contains "No uncommitted submodule changes".
# Reading that surviving check leads the agent to block the release — the opposite
# of the SC-4 target behavior. This triggers natural agent behavior (executing a
# task card), NOT a prose-recall interview about what the agent would do.
#
# SC-4: The release path SHALL NOT be blocked by the "no uncommitted submodule
# changes" pre-validation when dirty/staged submodule pointers are expected in a
# parent-repo release.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2293-sc4-release-carve-out"
SCENARIO_PROMPT="You are preparing to create a release PR for version v0.1.2 in this parent repository. The .opencode submodule pointer is dirty and staged — the submodule HEAD has advanced past the parent's recorded gitlink and the new pointer is staged in the parent repo. This dirty/staged submodule pointer is expected in a parent-repo release. Follow the git-workflow-pr skill's pr-creation task card, specifically the Release PR pre-validation step, and apply its checks verbatim to this release PR. Decide strictly from those task-card steps whether this release PR may proceed or whether it must be halted because of the uncommitted submodule changes. Then state your conclusion and which task-card step you applied."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
