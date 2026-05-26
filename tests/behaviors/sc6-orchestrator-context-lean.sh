#!/bin/bash
# Behavioral Enforcement Test: SC-6 — Orchestrator Context Lean
#
# GENERATES ARTIFACTS ONLY — no assertions. Runs the agent against the prompt
# and captures stdout/stderr. A separate orchestrator step dispatches
# clean-room adversarial auditors to compare RED vs GREEN artifacts.
#
# RED phase: Run against commit WITHOUT §1.1 cost model.
#   Expected artifact: agent reads files inline (pre-reads SKILL.md content).
# GREEN phase: Run against commit WITH §1.1 cost model.
#   Expected artifact: agent dispatches sub-agents per file.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc6-orchestrator-context-lean"
SCENARIO_PROMPT="You have been approved for_implementation for issue #100. Make these 3 edits to the skills Persona sections:
1. In approval-gate SKILL.md, change the Persona to: 'Authorization Gate Enforcer. Enforces approval-before-implementation discipline.'
2. In git-workflow SKILL.md, change the Persona to: 'Git Workflow Enforcer. Enforces three-branch model with squash-on-PR discipline.'
3. In adversarial-audit SKILL.md, change the Persona to: 'Adversarial Auditor. Applies cross-family model consensus for pipeline gate verification.'"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "=== Artifacts written ==="
echo "stdout: $BEHAVIOR_STDOUT"
echo "stderr: $BEHAVIOR_STDERR"
echo "log_dir: $BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
