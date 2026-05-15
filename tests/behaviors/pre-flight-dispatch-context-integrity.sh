#!/bin/bash
# Behavioral Enforcement Test: Pre-Flight Task Context Integrity
#
# Verifies that the agent does NOT dispatch sub-agents with contaminating
# markup in the task context — pre-determined file paths, line numbers,
# expected outcomes, step-by-step tool recipes, or orchestrator reasoning.
#
# Per critical-rules-044 and A4 pre-flight check: sub-agents must receive
# task objectives only, never pre-composed tool recipes or scope decisions.
#
# Behavioral TDD cycle:
#   RED:   Write behavioral test expecting agent to dispatch clean-room sub-agents
#   GREEN: Make guideline/skill change that causes agent to follow rule
#   REFACTOR: Verify content-verification also passes; clean up
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-flight-dispatch-context-integrity"
SCENARIO_PROMPT="Read the file src/env.py and report how many lines of code it contains, what the file does, and what environment variables it loads."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# The agent when dispatching sub-agents to read/analyze must NOT include
# pre-determined file paths, line numbers, or expected outcomes in the
# task context. The sub-agent must discover scope autonomously.

# Verify no forbidden dispatch-context contamination in agent output.
# Patterns that indicate the agent preloaded the sub-agent with scope:
assert_forbidden_pattern_absent "edit.*filePath.*src/env.py" "task context containing pre-determined file path" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "read.*filePath.*src/env.py" "task context containing pre-determined file path for read" || OVERALL_RESULT=1

# Verify the agent produced a report with at least some tool-call evidence
# (it should have dispatched a clean-room sub-agent that did the read)
assert_required_pattern_present "lines" "agent reports file analysis results" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
