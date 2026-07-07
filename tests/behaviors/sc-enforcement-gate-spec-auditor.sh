#!/bin/bash
# Behavioral Enforcement Test: SC Enforcement Gate — Spec Auditor
#
# Verifies that the spec auditor (audit/tasks/spec-audit.md)
# checks for the all-or-nothing SC enforcement gate (SC-14).
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

SCENARIO_NAME="sc-enforcement-gate-spec-auditor"
echo "=== Behavioral Test: $SCENARIO_NAME ==="

SPEC_AUDIT_FILE="$WORKTREE_ROOT/.opencode/skills/audit/tasks/spec-audit.md"
SC_GATE_TAG="<!-- Fragment ID: sc-enforcement-gate -->"

OVERALL_RESULT=0

# SC-1: Spec auditor has the SC gate fragment reference tag
if grep -q "$SC_GATE_TAG" "$SPEC_AUDIT_FILE"; then
    echo "PASS: $SCENARIO_NAME — spec-audit.md contains fragment reference tag"
else
    echo "FAIL: $SCENARIO_NAME — spec-audit.md missing fragment reference tag"
    OVERALL_RESULT=1
fi

# SC-2: Spec auditor has SC-14 criterion for enforcement gate
if grep -q "SC-14" "$SPEC_AUDIT_FILE"; then
    echo "PASS: $SCENARIO_NAME — spec-audit.md has SC-14 criterion"
else
    echo "FAIL: $SCENARIO_NAME — spec-audit.md missing SC-14 criterion"
    OVERALL_RESULT=1
fi

# SC-3: SC-14 checks for all-or-nothing gate statement
if grep -q "all-or-nothing gate statement" "$SPEC_AUDIT_FILE"; then
    echo "PASS: $SCENARIO_NAME — SC-14 checks for all-or-nothing gate statement"
else
    echo "FAIL: $SCENARIO_NAME — SC-14 missing gate statement requirement"
    OVERALL_RESULT=1
fi

# SC-4: SC-14 checks PASS/FAIL/Remediation requirements
if grep -q "PASS/FAIL/Remediation" "$SPEC_AUDIT_FILE"; then
    echo "PASS: $SCENARIO_NAME — SC-14 checks PASS/FAIL/Remediation requirements"
else
    echo "FAIL: $SCENARIO_NAME — SC-14 missing PASS/FAIL/Remediation requirement"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
