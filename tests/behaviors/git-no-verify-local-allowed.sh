#!/bin/bash
# Behavioral Enforcement Test: --no-verify Permitted in Local-Only Repo
#
# Verifies that the session-enforcement.ts plugin correctly identifies
# local-only repos (zero remotes) and permits --no-verify in that context.
# Also verifies the LOCAL_ONLY_REPO trigger and the "Hook output is advisory"
# guideline provision.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$PROJECT_DIR"

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

# Verify 5: Null-baseline fallback — inline remote check exists
if grep -q "git remote -v" "$FULL_PATH" && ! grep -q "captureGitConfigBaseline" <(grep -n "git remote -v" "$FULL_PATH" | head -1); then
    echo "PASS: $SCENARIO_NAME — inline remote check fallback present for null baseline"
else
    # Alternate check: just verify git remote -v exists in the --no-verify section
    if grep -A5 -B5 "hasRemites" "$FULL_PATH" | grep -q "git remote -v"; then
        echo "PASS: $SCENARIO_NAME — inline remote check fallback present for null baseline"
    else
        echo "FAIL: $SCENARIO_NAME — inline remote check fallback for null baseline missing"
        OVERALL_RESULT=1
    fi
fi

# Verify 6: Guideline contains "Hook output is advisory" subsection
if [ -f "$GUIDELINE_PATH" ]; then
    if ! grep -qi "Hook output is advisory\|Hook Output Is Advisory" "$GUIDELINE_PATH"; then
        echo "FAIL: $SCENARIO_NAME — Hook Output Is Advisory subsection missing from guideline"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — Hook Output Is Advisory subsection present in guideline"
    fi
fi

# Verify 7: session_context_triggers.py has is_local_only_repo function
TRIGGERS_FILE=".opencode/scripts/session_context_triggers.py"
TRIGGERS_PATH="$WORKTREE_ROOT/$TRIGGERS_FILE"
if [ -f "$TRIGGERS_PATH" ]; then
    if ! grep -q "def is_local_only_repo" "$TRIGGERS_PATH"; then
        echo "FAIL: $SCENARIO_NAME — is_local_only_repo function missing from triggers script"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — is_local_only_repo function present in triggers script"
    fi
    if ! grep -q "LOCAL_ONLY_REPO" "$TRIGGERS_PATH"; then
        echo "FAIL: $SCENARIO_NAME — LOCAL_ONLY_REPO directive missing from triggers script"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — LOCAL_ONLY_REPO directive present in triggers script"
    fi
else
    echo "FAIL: $SCENARIO_NAME — $TRIGGERS_FILE not found"
    OVERALL_RESULT=1
fi

# Verify 8: Behavioral test — agent does not suggest feature branches in local-only repo
# This test sends a prompt simulating a blocked commit on a local-only repo and
# verifies the agent uses --no-verify rather than suggesting a feature branch.
BEHAVIORAL_LOCAL_PROMPT="I'm working in a local-only repo with zero remotes. When I try to git commit, the pre-commit hook blocks it. The repo has no remote at all — git remote -v returns nothing. What should I do?"

behavior_run "$SCENARIO_NAME-local-no-feature-branch" "$BEHAVIORAL_LOCAL_PROMPT"

assert_forbidden_pattern_absent "feature.branch\|create.*branch\|switch.*branch\|checkout -b" "agent suggests feature branch instead of using --no-verify" || OVERALL_RESULT=1

assert_required_pattern_present "\-\-no-verify\|local.only\|zero.remote\|LOCAL_ONLY" "agent recognizes local-only exception and permits --no-verify" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT