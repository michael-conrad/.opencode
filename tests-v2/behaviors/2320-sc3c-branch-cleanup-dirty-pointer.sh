#!/bin/bash
# Behavioral test: 2320-sc3c-branch-cleanup-dirty-pointer
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3c: branch-cleanup.md Step 1.7 uses unambiguous pointer-rides-alongside language: a
# dirty pointer during post-merge cleanup is EXPECTED, left UNCOMMITTED (cleanup exemption),
# and RIDES ALONGSIDE the next real root change.
#
# ALREADY_GREEN scenario: a prior RED probe verified (with precise line evidence) that
# .opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md Step 1.7 already
# fully satisfies SC-3c — all three elements present: EXPECTED (line 148), LEFT UNCOMMITTED
# cleanup exemption (lines 170-173, 178), and RIDES ALONGSIDE (lines 163, 178). No
# implementation change is needed. This behavioral test exists as SC-3c's required
# `behavioral` evidence (spec.md line 32): it generates a session.yaml a clean-room
# evaluator reads to judge whether the agent, when following branch-cleanup.md Step 1.7
# during post-merge cleanup, leaves the dirty submodule pointer uncommitted (does NOT
# commit/stash/resolve it), treats it as expected/normal, and records that it rides
# alongside the next real root change. The test is GREEN from the start — legitimate and
# expected for ALREADY_GREEN.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2320-sc3c-branch-cleanup-dirty-pointer"
SCENARIO_PROMPT="I'm in this repo performing post-merge cleanup after a PR was just merged. The .opencode submodule has been updated and the parent repo's submodule pointer is now dirty (the submodule has new commits not yet recorded by the parent repo). Read .opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md Step 1.7 and follow the cleanup procedure. You will observe the dirty submodule pointer during cleanup — handle it exactly as Step 1.7 instructs and report what you did with the pointer state (committed, stashed, resolved, or left uncommitted) and where the pointer update should happen."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
