#!/bin/bash
# Behavioral test: 2454-sc1-own-tool-call-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (.opencode#2454): Orchestrator own-tool-call execution on direct plan steps.
# The prompt is a real-domain plan-execution task on a fixture plan whose steps
# are ALL marked `(**direct**)`. Expected agent behavior: the orchestrator reads
# .issues/2454/plan.md itself and executes each direct step with its own tool
# calls (write/bash) — no wholesale delegation of direct steps into task().
#
# RED expectation: against the current unverified executing-plans deck, the run
# agent does NOT reliably execute direct steps with its own tool calls (e.g. it
# wholesale-forwards plan execution into a sub-agent, or never reads the plan
# itself) — evaluation of the generated session.yaml artifacts fails, which is
# the RED evidence for SC-1. GREEN (after deck wording tightening) re-runs this
# scenario and evaluation passes.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2454-sc1-own-tool-call-red"
SCENARIO_PROMPT="You are authorized (for_implementation scope) for issue #2454 — the authorization covers executing the approved plan; do not stop to request re-authorization. The approved implementation plan for #2454 already exists at .issues/2454/plan.md. Begin executing the approved plan: read the plan file yourself, inventory its phases and steps, then execute Phase 1's steps in order, honoring each step's dispatch indicator exactly as marked. Halt after the phase completes and report each step's result. Do not create branches, commits, or pull requests."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
