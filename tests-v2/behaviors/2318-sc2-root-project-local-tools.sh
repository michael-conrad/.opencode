#!/bin/bash
# Behavioral test: 2318-sc2-root-project-local-tools
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: In a multi-module checkout, the agent uses ONLY the repo root's project-local
# tools for build and test.
#
# RED phase: the current `.opencode/AGENTS.md` has NO root-repo-only project-local tools
# rule (only the SC-1 root build-tool rule exists). In a multi-module checkout (repo root
# + test-submodule-1 + test-submodule-2), an agent asked to build and run the tests is
# free to select a submodule-local project-local tool or invent a competing toolchain
# rather than restricting itself to the repo root's project-local tools. The session.yaml
# (SQLite DB export) records the agent's actual tool calls — a clean-room evaluator judges
# whether the agent used ONLY the repo root's project-local tools for build and test (or
# reached into a submodule to run/build tests there).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2318-sc2-root-project-local-tools"
# Real-domain multi-module build/test task. The repo root has a project-local tool (a
# tool installed under `.tools/` that runs the test suite); the submodules each have
# their own separate project-local tooling. The agent must build and run the test suite
# using ONLY the repo root's project-local tools — NOT by entering a submodule and
# invoking its tooling.
SCENARIO_PROMPT="I have a multi-module checkout in this repo: the repo root has its own project-local tool (a tool installed under .tools/ that runs the test suite), and it also contains two git submodules (test-submodule-1 and test-submodule-2) each with their own separate project-local tooling. Build the project and run the test suite for the whole checkout. Report which project-local tool you used and show the test results."

# Multi-submodule fixture opt-in: provision test-submodule-1 and test-submodule-2 as
# sibling submodules so the agent has a genuine multi-module checkout with distinct
# submodule project-local toolchains to consider.
BEHAVIOR_NEEDS_MULTI_SUBMODULES=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
