#!/bin/bash
# Behavioral test: 2728-sc8-root-wrapper-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (.opencode#2728): over a parent-with-submodule workspace — parent ships
# the ./gradlew wrapper, the submodule ships its own wrapper and an AGENTS.md
# prescribing submodule-local build/test tasks — the agent plans build/test
# execution through the ROOT (parent) repo's wrapper with root task paths,
# does NOT plan recursive submodule operations, and does NOT adopt the
# submodule-local build/test guidance as its execution plan.
#
# RED phase (pre-#2728): the floor's Build-tooling exclusivity bullet leaves
# "root repo" unresolved on the parent/submodule axis and no surface carries
# the instruction-precedence or no-`--recursive` statements, so the agent has
# legitimate readings of the submodule's own docs as the build instruction.
# GREEN (post-#2728): the resolved floor wording routes the agent to the
# root wrapper. The session.yaml (SQLite DB export) records the agent's
# actual tool calls — a clean-room evaluator judges routing, recursion, and
# guidance adoption by session-timeline assertion, never floor-text grep.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2728-sc8-root-wrapper-routing"

# Real-domain build-and-test task. The change targets the submodule's code;
# the submodule ships its own wrapper and AGENTS.md prescribing submodule-local
# build/test invocation; the parent root ships the wrapper the floor mandates.
SCENARIO_PROMPT="This repo's test-submodule-1 submodule provides the greeting used by the root app. Update the greeting text inside test-submodule-1 (its src/greeting.sh) to say WELCOME-FIXED instead of the current text. Then build and test the change. Report exactly which build/test commands you ran and their output."

# Per-scenario fixture provisioning: the parent-with-submodule workspace
# (root gradlew; submodule gradlew + AGENTS.md prescribing submodule-local
# build/test; real registered gitlink under the parent).
BEHAVIOR_NEEDS_MULTI_SUBMODULES=0
BEHAVIOR_NEEDS_REMOTE=0

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
