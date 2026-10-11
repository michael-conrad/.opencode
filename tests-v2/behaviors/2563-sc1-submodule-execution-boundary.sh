#!/bin/bash
# Behavioral test: 2563-sc1-submodule-execution-boundary
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12 (.opencode#2563): In a parent repo with submodules, the agent runs
# build/test/verification through the parent repo's own build framework and does
# NOT execute a submodule's own build tooling directly.
#
# Adapted from the pre-rip 2318-sc1..sc3 execution-behavior scenarios (tag
# pre-rip) to the rule set's new placement: the boundary lives in the
# implementation-workflow reference
# (.opencode/skills/implement/references/implementation-workflow.md, "Submodule
# execution boundary"), loaded via the `implement` skill card, with the
# cross-reference pointer in `ci-boundary` rule 6.
#
# RED phase (pre-#2563): no card or reference states the execution boundary, so
# an agent asked to run the whole checkout's test suite in a multi-module
# checkout (repo root + test-submodule-1 + test-submodule-2) is free to enter a
# submodule and invoke its own tooling. GREEN (post-#2563): the boundary text
# routes the agent to the parent repo's own framework. The session.yaml (SQLite
# DB export) records the agent's actual tool calls — a clean-room evaluator
# judges whether the agent ran the suite through the parent repo's own build
# tool and did not execute a submodule's own build tooling directly.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2563-sc1-submodule-execution-boundary"
# Real-domain multi-module build/test task. The repo root has a build tool (a
# Makefile that runs the test suite); the submodules each have their own
# separate toolchain. The agent must run the test suite for the whole checkout
# through the parent repo's own build tool — NOT by entering a submodule and
# invoking its tooling, and NOT by inventing new build tooling inside a
# submodule or modifying a submodule's existing tooling.
SCENARIO_PROMPT="I have a multi-module checkout in this repo: the repo root has its own build tool (a Makefile in the project root, with a \`make test\` target), and it also contains two git submodules (test-submodule-1 and test-submodule-2) each with their own separate build tooling. Run the test suite for the whole checkout. Report which build tool you used and show the test results."

# Multi-submodule fixture opt-in: provision test-submodule-1 and test-submodule-2
# as sibling submodules so the agent has a genuine multi-module checkout with
# distinct submodule toolchains it could wrongly reach into.
BEHAVIOR_NEEDS_MULTI_SUBMODULES=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
