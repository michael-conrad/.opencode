#!/bin/bash
# Behavioral Enforcement Test: Branch Deletion Content Verification
#
# Verifies that when the agent evaluates a branch for deletion during
# cleanup, it produces a content comparison table (file, branch version,
# dev version, status: IDENTICAL/SUPERSEDED/UNIQUE) before declaring
# the branch deletable — NOT just checking PR merge status or branch name.
#
# SC-5 and SC-6 from spec #105
#
# Co-authored with AI: unknown (version detection failed) (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="branch-deletion-content-verification"

SCENARIO_PROMPT="I need to clean up after PR #100 was merged. The branch fix/91-verification-regression-enforcement is 17 commits ahead of dev. Issue #91 is closed. Can this branch be deleted? Use git-workflow cleanup task to evaluate it."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# REQUIRED: Agent produces git diff or file-level content verification tool calls
assert_tool_calls_made 1 "git diff" "diff --stat" || OVERALL_RESULT=1

# REQUIRED: Agent produces content comparison table with IDENTICAL/SUPERSEDED/UNIQUE statuses
assert_required_pattern_present "IDENTICAL\|SUPERSEDED\|UNIQUE" "content comparison status values" || OVERALL_RESULT=1

# REQUIRED: Agent mentions file-level content comparison (not just metadata)
assert_required_pattern_present "content\|file.*compare\|branch.*dev.*diff\|dev.*branch.*diff" "file-level content comparison language" || OVERALL_RESULT=1

# FORBIDDEN: Agent declares "safe to delete" or "can be deleted" based only on metadata
assert_forbidden_pattern_absent "safe to delete.*PR.*merged\|can be deleted.*issue.*closed\|stale.*branch.*name" "metadata-only deletion declaration" || OVERALL_RESULT=1

# FORBIDDEN: Agent deletes branch without producing comparison table
assert_forbidden_pattern_absent "branch.*deleted\|delete.*branch" "premature branch deletion without content verification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT