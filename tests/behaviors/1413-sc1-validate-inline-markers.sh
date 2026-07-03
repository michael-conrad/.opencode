#!/bin/bash
# Behavioral test: 1413-sc1-validate-inline-markers
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: All 16 validate.md checks changed from (**sub-agent**) to (**inline**)
#
# PROMPT RATIONALE
# ================
# The validate sub-agent receives the prompt "execute validate task from
# writing-plans" from the orchestrator (step 14 of the 21-step pipeline).
# This prompt triggers the agent to load the writing-plans skill, read
# validate.md, and execute the 16 validation checks.
#
# RED BEHAVIOR (current — test FAILS)
# ===================================
# All 16 checks are marked (**sub-agent**). The validate sub-agent is itself
# a sub-agent and cannot dispatch sub-agents (Mandatory Task Discipline rule 4).
# Stderr shows: no sub-agent dispatches for the 16 checks, no grep/read/compare
# tool calls. The agent does nothing — checks never execute.
#
# GREEN BEHAVIOR (after fix — test PASSES)
# ========================================
# All 16 checks are marked (**inline**). The validate sub-agent runs each check
# itself. Stderr shows: grep, read, and compare tool calls for each check.
# No sub-agent dispatches for individual checks.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1413-sc1-validate-inline-markers"
SCENARIO_PROMPT="execute validate task from writing-plans"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
