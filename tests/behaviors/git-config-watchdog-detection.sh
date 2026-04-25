#!/bin/bash
# Behavioral Enforcement Test: Git Config Watchdog Detection
#
# Verifies that the session-enforcement.ts plugin includes
# config mutation watchdog mechanisms (GitConfigBaseline, baseline capture,
# config hash comparison, security-relevant key detection).
#
# This is a code-structure test, not an agent-behavior test, because
# the watchdog runs in the plugin layer (not in agent output).
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="git-config-watchdog-detection"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

SESSION_FILE=".opencode/plugins/session-enforcement.ts"
FULL_PATH="$WORKTREE_ROOT/$SESSION_FILE"

if [ ! -f "$FULL_PATH" ]; then
    echo "FAIL: $SCENARIO_NAME — $SESSION_FILE not found"
    exit 1
fi

OVERALL_RESULT=0

# Verify 1: GitConfigBaseline interface exists
if ! grep -q "GitConfigBaseline" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — GitConfigBaseline interface missing from session-enforcement.ts"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — GitConfigBaseline interface present"
fi

# Verify 2: Config mutation watchdog function exists
if ! grep -q "captureGitConfigBaseline" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — captureGitConfigBaseline function missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — captureGitConfigBaseline function present"
fi

# Verify 3: Security-relevant key detection exists
if ! grep -q "SECURITY_RELEVANT_KEY_PATTERNS" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — SECURITY_RELEVANT_KEY_PATTERNS missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — SECURITY_RELEVANT_KEY_PATTERNS present"
fi

# Verify 4: GIT_CONFIG_MUTATION block builder exists
if ! grep -q "buildGitConfigMutationBlock" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — buildGitConfigMutationBlock function missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — buildGitConfigMutationBlock function present"
fi

# Verify 5: Exempt key patterns exist
if ! grep -q "EXEMPT_KEY_PATTERNS" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — EXEMPT_KEY_PATTERNS missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — EXEMPT_KEY_PATTERNS present"
fi

# Verify 6: Baseline captured at session start
if ! grep -q "captureGitConfigBaseline(projectDir)" "$FULL_PATH"; then
    echo "FAIL: $SCENARIO_NAME — baseline capture call at session start missing"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — baseline capture call at session start present"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT