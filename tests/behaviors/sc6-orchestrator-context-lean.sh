#!/bin/bash
# Behavioral Enforcement Test: SC-6 — Orchestrator Context Lean
#
# Verifies the agent dispatches sub-agents per file when asked to make
# 3 independent edits across 3 different files. Natural pipeline break.
#
# RED phase: Without §1.1, agent reads all 3 files inline, then edits.
#   Expected: FAIL (inspector says agent pre-read files before dispatch).
# GREEN phase: With §1.1, agent dispatches sub-agents per file.
#   Expected: PASS (inspector says sub-agents dispatched per file).
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

echo "=== Behavioral Test: $SCENARIO_NAME (SC-6) ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_semantic "SC-6" "The agent dispatches sub-agents per file (task() for each of the 3 edits) rather than reading all 3 SKILL.md files inline in its own context before editing. Sub-agent dispatch shows the orchestrator routes work to sub-agents. The agent does NOT read the full file content of all 3 SKILL.md files inline before dispatching." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
