#!/bin/bash
# RED phase test: issue-1212-workstream-d
# Three success criteria for #1212 Workstream D (submodule-sync.md)
#
# SC-D1: submodule-sync.md task file exists
# SC-D2: Dispatch row in SKILL.md routes "sync submodules" to submodule-sync
# SC-D3: Behavioral — opencode-cli run verifies content covers 4 operations
#
# Authority: #1212
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OVERALL_RESULT=0

echo "=== RED Phase: #1212 Workstream D ==="
echo "  Expecting ALL tests to FAIL (feature not implemented yet)"
echo ""

# ─── SC-D1: File existence ────────────────────────────────────────────────
echo "--- SC-D1: submodule-sync.md exists ---"
SUB_SYNC_FILE=".opencode/skills/git-workflow/tasks/submodule-sync.md"
if [ -f "$SUB_SYNC_FILE" ]; then
    echo "  PASS: $SUB_SYNC_FILE exists"
else
    echo "  FAIL: $SUB_SYNC_FILE does not exist (expected RED)"
    OVERALL_RESULT=1
fi
echo ""

# ─── SC-D2: Dispatch row in SKILL.md ───────────────────────────────────────
echo "--- SC-D2: dispatch row routes to submodule-sync ---"
SKILL_MD=".opencode/skills/git-workflow/SKILL.md"
if grep -q 'sync submodules.*submodule-sync' "$SKILL_MD" 2>/dev/null; then
    echo "  PASS: dispatch row found"
else
    echo "  FAIL: no dispatch row routing sync submodules to submodule-sync (expected RED)"
    OVERALL_RESULT=1
fi
echo ""

# ─── SC-D3: Behavioral ────────────────────────────────────────────────────
echo "--- SC-D3: task procedure covers 4 operations ---"
echo "  Using behavioral test harness (opencode-cli run)"
echo "  Prompt: create task file covering 4 operations (fetch dev, commit, push, verify)"
echo ""

source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-1212-sc-d3-submodule-sync"
SCENARIO_PROMPT="Your task is to create a task file at .opencode/skills/git-workflow/tasks/submodule-sync.md that defines a procedure for synchronizing submodule state. The task file must cover exactly these 4 operations in order:

1. git fetch origin dev — fetch the latest dev branch from remote
2. commit submodule pointer — commit the updated submodule pointer to the feature branch with a formatted message
3. git push origin <branch> — push the commit to origin
4. verify SHA liveness — verify the submodule SHA is reachable via tag after push

Write the full task file content including the header and procedure. Do NOT skip any operation."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

STDOUT_CONTENT=$(cat "$BEHAVIOR_STDOUT" 2>/dev/null || echo "")

check_op() {
    local op_num="$1" op_name="$2" pattern="$3"
    if echo "$STDOUT_CONTENT" | grep -qi "$pattern" 2>/dev/null; then
        echo "  SC-D3/${op_name}: PASS"
        return 0
    else
        echo "  SC-D3/${op_name}: FAIL (not found — expected RED)"
        return 1
    fi
}

OP1_FAIL=0; check_op 1 "fetch-dev" "fetch.*origin.*dev\|git fetch.*origin" || OP1_FAIL=1
OP2_FAIL=0; check_op 2 "commit-pointer" "commit.*submodule\|submodule.*pointer\|commit.*pointer\|update.*submodule" || OP2_FAIL=1
OP3_FAIL=0; check_op 3 "push-origin" "push.*origin\|git push" || OP3_FAIL=1
OP4_FAIL=0; check_op 4 "verify-liveness" "liveness\|reachable\|verify.*SHA\|tag.*exist\|check.*SHA" || OP4_FAIL=1

TOTAL_OP_FAILS=$((OP1_FAIL + OP2_FAIL + OP3_FAIL + OP4_FAIL))
if [ "$TOTAL_OP_FAILS" -eq 0 ]; then
    echo "  SC-D3: All 4 operations found (PASS — but unexpected for RED)"
elif [ "$TOTAL_OP_FAILS" -ge 4 ]; then
    echo "  SC-D3: 0/4 operations found (expected RED — none implemented)"
else
    echo "  SC-D3: $((4 - TOTAL_OP_FAILS))/4 found, $TOTAL_OP_FAILS missing (partial RED)"
fi
if [ "$TOTAL_OP_FAILS" -ge 1 ]; then
    OVERALL_RESULT=1
fi
echo ""

# ─── Summary ───────────────────────────────────────────────────────────────
echo "=== Summary ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: All #1212 Workstream D tests pass (unexpected for RED phase)"
else
    echo "FAIL: One or more #1212 Workstream D tests failed (expected RED phase)"
fi

exit $OVERALL_RESULT