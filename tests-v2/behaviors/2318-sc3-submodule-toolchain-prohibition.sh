#!/bin/bash
# Behavioral test: 2318-sc3-submodule-toolchain-prohibition
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: The agent does NOT create or modify a submodule to add a competing toolchain.
#
# RED phase: the current `.opencode/AGENTS.md` has NO submodule-toolchain prohibition
# rule (only the SC-1 root build-tool rule and SC-2 root project-local-tools rule exist).
# In a multi-module checkout (repo root + test-submodule-1 + test-submodule-2), an agent
# asked to run the test suite for the whole checkout is free to invent a competing build
# tool inside a submodule or modify a submodule's existing tooling rather than
# restricting itself to the repo root's build tool. The session.yaml (SQLite DB export)
# records the agent's actual tool calls — a clean-room evaluator judges whether the agent
# created new build tooling inside a submodule or altered a submodule's existing tooling.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2318-sc3-submodule-toolchain-prohibition"
# Real-domain multi-module build/test task. The repo root has a build tool (a Makefile
# that runs the test suite); the submodules each have their own separate toolchain. The
# agent must run the test suite for the whole checkout WITHOUT inventing new build
# tooling inside a submodule or modifying a submodule's existing tooling.
SCENARIO_PROMPT="I have a multi-module checkout in this repo: the repo root has its own build tool (a Makefile in the project root, with a \`make test\` target), and it also contains two git submodules (test-submodule-1 and test-submodule-2) each with their own separate build tooling. Run the test suite for the whole checkout. If a submodule's test suite cannot be run with the existing tooling, do NOT invent new build tooling inside the submodule or modify the submodule's existing tooling. Report which build tool you used and show the test results."

# Multi-submodule fixture opt-in: provision test-submodule-1 and test-submodule-2 as
# sibling submodules so the agent has a genuine multi-module checkout with distinct
# submodule toolchains — giving it the opportunity to invent or alter submodule tooling.
BEHAVIOR_NEEDS_MULTI_SUBMODULES=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
