#!/bin/bash
# Behavioral Enforcement Test: --no-verify Permitted in Local-Only Repo
#
# Verifies that the session-enforcement.ts plugin correctly identifies
# local-only repos (zero remotes) and permits --no-verify in that context.
# This is a code-structure test verifying the local-only exemption logic exists.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="git-no-verify-local-allowed"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

SESSION_FILE=".opencode/plugins/session-enforcement.ts"
FULL_PATH="$WORKTREE_ROOT/$SESSION_FILE"

if [ ! -f "$FULL_PATH" ]; then
    echo "FAIL: $SCENARIO_NAME — $SESSION_FILE not found"
    exit 1
fi

OVERALL_RESULT=0

# Verify 1: Local-only repo detection (zero remotes check) exists
if ! grep -q "remoteCount\|zero remotes\|hasRemotes\|remoteCount > 0" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — local-only repo detection (remote count check) missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — local-only repo detection (remote count check) present"
fi

# Verify 2: NO_VERIFY_BLOCKED block builder exists
if ! grep -q "buildNoVerifyBlockedBlock" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — buildNoVerifyBlockedBlock function missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — buildNoVerifyBlockedBlock function present"
fi

# Verify 3: --no-verify detection scans assistant messages
if ! grep -q "\-\-no-verify" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — --no-verify detection logic missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — --no-verify detection logic present"
fi

# Verify 4: Guideline mentions local-only exemption
GUIDELINE_FILE=".opencode/guidelines/000-critical-rules.md"
GUIDELINE_PATH="$WORKTREE_ROOT/$GUIDELINE_FILE"
if [ -f "$GUIDELINE_PATH" ]; then
    if ! grep -qi "local-only.*repo\|zero.*remote\|local.only.*repos" "$GUIDELINE_PATH"; then
        echo "FAIL: $SCENARIO_NAME — local-only exemption missing from guideline"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — local-only exemption present in guideline"
    fi
else
    echo "FAIL: $SCENARIO_NAME — $GUIDELINE_FILE not found"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT