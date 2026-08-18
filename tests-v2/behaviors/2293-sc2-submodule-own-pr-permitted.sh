#!/bin/bash
# Behavioral test: 2293-sc2-submodule-own-pr-permitted
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: A submodule repo filing its own PR for its own changes SHALL be
# unambiguously permitted.
#
# RED STATE: the surviving task-card references still say "submodule-only PR is
# FORBIDDEN in ANY context" (git-workflow-commit/tasks/implementation.md line 39,
# git-workflow-pr/tasks/pr-creation.md line 54, git-workflow-cleanup/SKILL.md line 51,
# git-workflow-cleanup/tasks/cleanup/branch-cleanup.md lines 172, 319). An agent
# asked whether a submodule repo may file its own PR for its own change reads these
# references and concludes the PR is NOT permitted. This run's session.yaml therefore
# shows the agent blocking the submodule repo's own PR, so the SC-2 criterion is NOT
# satisfied and the SC FAILS (RED).
#
# GREEN STATE: the surviving task-card references are reworded to be parent-repo +
# action-scoped, and explicitly state a submodule repo filing its own PR for its own
# changes is normal and NOT covered by the prohibition. An agent asked whether a
# submodule repo may file its own PR concludes it IS permitted. This run's session.yaml
# then shows the agent permitting the PR, satisfying the SC-2 criterion and the SC
# PASSES (GREEN).
#
# PROMPT CONSTRUCTION:
# Real-domain task: resolve whether the SHARED-DAO submodule repo may file a PR for its
# own AGENTS.md change, in a repo that carries the .opencode submodule and the
# surviving task-card prohibition references. This triggers natural agent behavior —
# reading the loaded task cards to reach a decision — NOT a prose-recall interview
# about what the agent would do.
#
# SC-2: A submodule repo filing its own PR for its own changes SHALL be unambiguously
# permitted.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2293-sc2-submodule-own-pr-permitted"
SCENARIO_PROMPT="This repository's .opencode directory is a git submodule (see .gitmodules). The SHARED-DAO submodule repo (a sibling of .opencode, also a submodule here) needs to file its own pull request for its own change — an edit to its own AGENTS.md that lives entirely inside the SHARED-DAO repo. Is the SHARED-DAO submodule repo permitted to file its own PR for its own AGENTS.md change, or does the submodule-only-PR prohibition in the loaded task cards apply here? Consult the loaded guidelines and task cards to decide, then state whether SHARED-DAO may proceed with its own PR."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
