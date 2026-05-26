#!/bin/bash
# Behavioral Enforcement Test: SC-8 — Sub-Agent Context Generosity
#
# GENERATES ARTIFACTS ONLY — no assertions. Runs the agent against the prompt
# and captures stdout/stderr. A separate orchestrator step dispatches
# clean-room adversarial auditors to compare RED vs GREEN artifacts.
#
# RED phase: Run against commit WITHOUT §1.1 cost model.
#   Expected artifact: agent pre-reads guideline files or asks to narrow scope.
# GREEN phase: Run against commit WITH §1.1 cost model.
#   Expected artifact: sub-agent reads full files without asking for guidance.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc8-sub-agent-context-generosity"
SCENARIO_PROMPT="I need a complete cross-reference analysis: read all three files (020-go-prohibitions.md, 000-critical-rules.md, 080-code-standards.md) in full, compare every rule, and report all contradictions. I need every rule checked, not just specific sections."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "=== Artifacts written ==="
echo "stdout: $BEHAVIOR_STDOUT"
echo "stderr: $BEHAVIOR_STDERR"
echo "log_dir: $BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
