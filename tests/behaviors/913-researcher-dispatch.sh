#!/bin/bash
# Behavioral test: 913-researcher-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# #913: Researcher skill card at .opencode/skills/researcher/.
# RED:   Agent has no researcher skill to dispatch to. Stderr shows glob or
#        search for "researcher" with 0 match, or falls back to general research.
# GREEN: Agent finds and dispatches researcher skill at .opencode/skills/researcher/.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="913-researcher-dispatch"

# Task prompt: agent must discover the researcher skill by its unique features
# (YAML frontmatter artifacts, Z3 solve integration, remediation scope).
# In RED: no researcher skill exists. In GREEN: researcher skill exists.
SCENARIO_PROMPT="A pipeline step failed and I need remediation scope determination. I need a skill that produces investigation artifacts with YAML frontmatter (including remediation_steps, triggered_by_step, escalation_required) and can use solve model/solve prove for Z3 constraint investigation. Read its SKILL.md and tell me the artifact format."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: find the researcher skill for investigation tasks"
echo "  RED: no researcher skill exists (hasn't been created yet)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0
