#!/bin/bash
# Behavioral test: 2320-sc3b-pr-creation-prepush-pointer-rides-alongside
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3b: pr-creation.md §Pre-Push Submodule Pointer Verification uses unambiguous
# pointer-rides-alongside language: a merged submodule PR does NOT resolve the root
# pointer; the pointer rides ALONGSIDE the next real root change.
#
# RED phase: the current pr-creation.md §Pre-Push (lines 48-60) verifies dirty pointers
# are included in staged changes ONLY alongside real code changes, but it does NOT
# contain explicit language stating that "a merged submodule PR does NOT resolve the root
# pointer; the pointer rides alongside the next real root change." So an agent reading
# pr-creation.md §Pre-Push before pushing a branch that has a real root change plus a
# submodule whose PR was just merged may treat the merged submodule as having resolved the
# root pointer (and drop it / leave it uncommitted) rather than verifying the pointer
# rides alongside the root change. The session.yaml records the agent's actual tool calls —
# a clean-room evaluator judges whether the agent verified the pointer is committed
# alongside the real root change and did NOT treat the submodule merge as resolving it.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2320-sc3b-pr-creation-prepush-pointer-rides-alongside"
SCENARIO_PROMPT="The .opencode submodule PR was just merged, advancing the submodule to new commits. I have a real source change committed (src/real.txt) on this feature branch and I'm about to push it. Read .opencode/skills/git-workflow-pr/tasks/pr-creation.md §Pre-Push Submodule Pointer Verification and follow its procedure before pushing. Report what you find about the submodule pointer state and what (if anything) must be done before pushing."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
