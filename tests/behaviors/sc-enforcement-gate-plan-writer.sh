#!/bin/bash
# Behavioral Enforcement Test: SC Enforcement Gate — Plan Writer
#
# Verifies that the plan writer (writing-plans/tasks/create/plan-structure.md)
# extracts and preserves the all-or-nothing SC enforcement gate from the spec.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$WORKTREE_ROOT")" != ".opencode" ]; do
    WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"
done
WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"

SCENARIO_NAME="sc-enforcement-gate-plan-writer"
echo "=== Behavioral Test: $SCENARIO_NAME ==="

PLAN_STRUCTURE_FILE="$WORKTREE_ROOT/.opencode/skills/writing-plans/tasks/create/plan-structure.md"
SC_GATE_TAG="<!-- Fragment ID: sc-enforcement-gate -->"

OVERALL_RESULT=0

# SC-1: Plan writer has the SC gate fragment reference tag
if grep -q "$SC_GATE_TAG" "$PLAN_STRUCTURE_FILE"; then
    echo "PASS: $SCENARIO_NAME — plan-structure.md contains fragment reference tag"
else
    echo "FAIL: $SCENARIO_NAME — plan-structure.md missing fragment reference tag"
    OVERALL_RESULT=1
fi

# SC-2: Plan writer extracts all-or-nothing gate from spec
if grep -q "all-or-nothing gate" "$PLAN_STRUCTURE_FILE"; then
    echo "PASS: $SCENARIO_NAME — plan-structure.md references all-or-nothing gate"
else
    echo "FAIL: $SCENARIO_NAME — plan-structure.md missing all-or-nothing gate reference"
    OVERALL_RESULT=1
fi

# SC-3: Plan writer flags SPEC_GAP if spec lacks the gate
if grep -q "SPEC_GAP" "$PLAN_STRUCTURE_FILE"; then
    echo "PASS: $SCENARIO_NAME — plan-structure.md flags SPEC_GAP when gate missing"
else
    echo "FAIL: $SCENARIO_NAME — plan-structure.md missing SPEC_GAP flag"
    OVERALL_RESULT=1
fi

# SC-4: Plan writer preserves gate language in TDD task structure
if grep -q "RED checkpoint is a sub-gate" "$PLAN_STRUCTURE_FILE"; then
    echo "PASS: $SCENARIO_NAME — plan-structure.md links RED checkpoints to gate chain"
else
    echo "FAIL: $SCENARIO_NAME — plan-structure.md missing RED checkpoint gate chain language"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
