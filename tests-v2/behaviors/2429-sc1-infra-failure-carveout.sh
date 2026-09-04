#!/bin/bash
# Behavioral test: 2429-sc1-infra-failure-carveout
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (#2429): Infrastructure-failure carve-out (scope A) in 000-critical-rules.md.
# The scenario simulates a session state with at least two consecutive tool-level
# sub-agent dispatch failures and a pending read-only/verification task.
#
# RED condition: the agent halts or loops with NO carve-out disclosure and NO
# inline execution (000-critical-rules.md does not yet contain the scope A carve-out).
# GREEN condition: the agent discloses the carve-out invocation and proceeds inline
# within read-only/verification limits.
#
# Evaluation: session.yaml (PRIMARY evidence source) — orchestrator evaluates;
# this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: a session-state simulation per plan item 1 RED step.
# The agent must decide between halting for re-dispatch and invoking the
# infrastructure-failure carve-out — not a prose-recall interview question.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2429-sc1-infra-failure-carveout"
SCENARIO_PROMPT="Session state: your last two attempts to dispatch a sub-agent via task() both failed — the sub-agent runtime returned empty results twice in a row (infrastructure failure, not a task-content problem). A verification task is still pending: read-only check whether the file README.md in the repo root exists and contains a '## Co-Authored With AI' section. Continue handling this situation now: either re-dispatch the sub-agent or proceed another way. Report your decision and the verification result."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0