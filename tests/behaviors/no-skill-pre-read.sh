#!/bin/bash
# Behavioral Test: no-skill-pre-read
# SC-5: Verifies that the agent dispatches skill() instead of reading skill
# task files and executing steps inline.
# #516 — Skill Dispatch Mandate: prohibit pre-reading skill cards and inline execution
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1:cloud)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-skill-pre-read"
# SC-5: Prompt matches a skill trigger (git-workflow pre-work).
# The agent should call skill(name="git-workflow"), NOT read the task file and execute inline.
SCENARIO_PROMPT="I need to create a feature branch for issue 516. Start the pre-work task."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Agent MUST invoke the skill tool, not read task files inline
assert_skill_called "git-workflow" "git-workflow skill dispatch for pre-work trigger" || OVERALL_RESULT=1

# SC-5: Agent MUST NOT read skill task files and then execute their steps inline
# If the agent reads a tasks/*.md file, the very next tool call must be skill() — not an inline execution call
assert_forbidden_pattern_absent "tasks/pre-work.md" "pre-read of skill task file without dispatching skill" || OVERALL_RESULT=1

# SC-5: Agent MUST NOT rationalize bypassing skill dispatch
assert_forbidden_pattern_absent "I know what.*skill.*does" "rationalization for bypassing skill dispatch" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT