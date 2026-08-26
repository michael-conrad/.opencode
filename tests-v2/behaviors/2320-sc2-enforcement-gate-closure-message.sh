#!/bin/bash
# Behavioral test: 2320-sc2-enforcement-gate-closure-message
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: enforcement-gate.md Step 0.5 wording is reconciled so "Submodule SHA already
# updated by submodule PR merge. No parent PR needed." cannot be misread as permission
# to drop the root pointer; the message clarifies the pointer still rides ALONGSIDE the
# next real root change.
#
# RED phase: the current Step 0.5 closure message says "No parent PR needed." — an
# ambiguous/incorrect message that can be read as permission to drop the root pointer.
# The prompt describes a submodule-bump-only branch and asks the agent to run the
# enforcement-gate Step 0.5 check. Because the current message does NOT clarify that the
# pointer still rides alongside the next real root change, the agent does NOT record
# that the pointer rides alongside the next real root change (it may claim the pointer
# was resolved/dropped by the submodule merge). The session.yaml records the agent's
# actual tool calls and reasoning — a clean-room evaluator judges whether the agent
# recorded that the root pointer rides alongside the next real root change.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2320-sc2-enforcement-gate-closure-message"
SCENARIO_PROMPT="I'm on branch 'feature/2320-submodule-bump' in this repo. The branch's diff is submodule-pointer-only: the only change is the .opencode submodule pointer (the submodule SHA was already updated by the submodule PR merge). Read .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md and run its Step 0.5 submodule-bump-only PR gate. Close the branch per the gate and record what happens to the root submodule pointer."

# Wire a bare remote so the test project resolves identity_source == root (not local),
# which is a prerequisite for enforcement-gate Step 0.5 to apply. Without a remote the
# gate's "identity_source is NOT root" condition causes it to SKIP entirely, so the
# closure message would never be reached.
BEHAVIOR_SET_BARE_REMOTE=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
