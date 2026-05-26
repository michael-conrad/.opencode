#!/bin/bash
# Behavioral Enforcement Test: SC-7 — Sub-Agent Result Contract Frugality
#
# GENERATES ARTIFACTS ONLY — no assertions. Runs the agent against the prompt
# and captures stdout/stderr. A separate orchestrator step dispatches
# clean-room adversarial auditors to compare RED vs GREEN artifacts.
#
# RED phase: Run against commit WITHOUT §1.1 cost model.
#   Expected artifact: sub-agent returns verbose analysis inline.
# GREEN phase: Run against commit WITH §1.1 cost model.
#   Expected artifact: sub-agent writes evidence to disk, returns compact summary.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc7-sub-agent-result-contract-frugality"
SCENARIO_PROMPT="You have been approved for_implementation for issue #100 which requires a full audit of all personae across all skills. Task a sub-agent to compile every Persona section from every SKILL.md file into a single report, organized by skill name. Write the full report to a file in ./tmp/ and return only a summary."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "=== Artifacts written ==="
echo "stdout: $BEHAVIOR_STDOUT"
echo "stderr: $BEHAVIOR_STDERR"
echo "log_dir: $BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
