#!/bin/bash
# Behavioral Enforcement Test: SC Enforcement Gate — Spec Writer
#
# Verifies that the spec writer (spec-creation/tasks/write.md) includes
# the all-or-nothing SC enforcement gate in its Step 3 section.
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

SCENARIO_NAME="sc-enforcement-gate-spec-writer"
echo "=== Behavioral Test: $SCENARIO_NAME ==="

SPEC_WRITE_FILE="$WORKTREE_ROOT/.opencode/skills/spec-creation/tasks/write.md"
SC_GATE_TAG="<!-- Fragment ID: sc-enforcement-gate -->"

OVERALL_RESULT=0

# SC-1: Spec writer has the SC gate fragment reference tag
if grep -q "$SC_GATE_TAG" "$SPEC_WRITE_FILE"; then
    echo "PASS: $SCENARIO_NAME — write.md contains fragment reference tag"
else
    echo "FAIL: $SCENARIO_NAME — write.md missing fragment reference tag"
    OVERALL_RESULT=1
fi

# SC-2: Spec writer has the all-or-nothing gate statement
if grep -q "ALL-OR-NOTHING GATE" "$SPEC_WRITE_FILE"; then
    echo "PASS: $SCENARIO_NAME — write.md contains all-or-nothing gate statement"
else
    echo "FAIL: $SCENARIO_NAME — write.md missing all-or-nothing gate statement"
    OVERALL_RESULT=1
fi

# SC-3: Spec writer has the 4-column SC table format
if grep -q "Verification Method .* Remediation" "$SPEC_WRITE_FILE"; then
    echo "PASS: $SCENARIO_NAME — write.md contains 4-column SC table format (Verification Method + Remediation)"
else
    echo "FAIL: $SCENARIO_NAME — write.md missing 4-column SC table format"
    OVERALL_RESULT=1
fi

# SC-4: Spec writer has gate presence verification in Step 4
if grep -q "Gate presence verification" "$SPEC_WRITE_FILE"; then
    echo "PASS: $SCENARIO_NAME — write.md Gate presence verification in Step 4"
else
    echo "FAIL: $SCENARIO_NAME — write.md missing Gate presence verification in Step 4"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
