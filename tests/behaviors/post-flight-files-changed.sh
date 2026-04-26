#!/bin/bash
# Behavioral Enforcement Test: Post-Flight Files Changed Check (SC-15)
#
# Verifies that after sub-agent implementation work, the agent runs
# `git diff --stat` to verify files changed match spec scope, and
# reports file changes per SC in the result contract.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="post-flight-files-changed"
SCENARIO_PROMPT="You just completed implementing Phase 1 of spec #98 as a sub-agent. Verify the files you changed match the spec scope and produce a result contract with files_changed field."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should run git diff --stat to verify files changed
assert_tool_calls_made 1 "git.*diff.*--stat\|diff --stat" || OVERALL_RESULT=1

# Agent should mention files_changed or per-SC file mapping
assert_required_pattern_present "files_changed\|file.*change\|per.SC\|spec.*scope\|changed.*file\|result.*contract" "files changed per SC in result contract" || OVERALL_RESULT=1

# Agent should verify files match spec scope
assert_required_pattern_present "spec.*scope\|match.*spec\|scope.*match\|files.*match\|verify.*file" "spec scope verification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT