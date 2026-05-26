#!/bin/bash
# Behavioral Enforcement Test: SC-7 — Sub-Agent Result Contract Frugality
#
# Verifies that when processing large files, results are written to disk
# and only compact findings returned inline. The test repo has 3 unique
# stories. The agent is asked for a multi-file structural analysis —
# it must decide whether to return all detail inline or write to disk.
#
# RED phase: Without §1.1, agent returns verbose analysis inline.
#   Expected: FAIL (semantic inspector finds verbose narrative).
# GREEN phase: With §1.1, agent writes evidence to disk and returns
#   compact summary. Expected: PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc7-sub-agent-result-contract-frugality"
SCENARIO_PROMPT="I have three stories in fixtures/gutenberg/. I need a detailed breakdown: for each story, list every scene heading or chapter title, and the exact line number where it starts. Do this for all three files."

echo "=== Behavioral Test: $SCENARIO_NAME (SC-7) ==="
echo "  Verifying sub-agent returns compact contract + writes evidence to disk"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-7: Sub-agent must write full evidence to disk and return only
# compact contract. The main agent output should not contain the
# full verbose scene/heading analysis.
assert_semantic "SC-7" "The agent writes detailed analysis results (scene headings with line numbers for all three stories) to a file on disk (in ./tmp/ or equivalent) rather than including the full verbose analysis inline in the response. The agent's visible output to the user is a compact summary or reference to the written file, not the complete multi-file breakdown." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
