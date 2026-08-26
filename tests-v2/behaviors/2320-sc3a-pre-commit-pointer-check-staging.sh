#!/bin/bash
# Behavioral test: 2320-sc3a-pre-commit-pointer-check-staging
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3a: pre-commit-pointer-check.md uses unambiguous pointer-rides-alongside language: a
# dirty pointer is staged and committed ALONGSIDE a real root change, never dropped and
# never committed standalone.
#
# RED phase: the current pre-commit-pointer-check.md Step 4 only "warns and suggests
# adding" dirty pointers — it does NOT unambiguously state the pointer MUST be staged and
# committed alongside the real change. So an agent reading pre-commit-pointer-check.md and
# committing a real root change alongside a dirty submodule pointer does NOT reliably
# stage and commit the pointer alongside the change (it may drop the pointer or leave it
# uncommitted). The session.yaml records the agent's actual tool calls — a clean-room
# evaluator judges whether the pointer was committed alongside the real change.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2320-sc3a-pre-commit-pointer-check-staging"
SCENARIO_PROMPT="I'm on a feature branch in this repo. I made a real source change (src/real.txt) and the .opencode submodule pointer is dirty (the submodule has new commits not yet recorded by the parent repo). Read .opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md and follow its pre-commit-pointer-check procedure: stage and commit the real source change AND the dirty submodule pointer update in the same commit."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
