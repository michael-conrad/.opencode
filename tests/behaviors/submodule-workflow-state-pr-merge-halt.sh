#!/usr/bin/env bash
# Behavioral test: Submodule PR merge HALT when submodule PR is NOT merged
# SC-9: Agent with submodule-workflow-state command output that shows
# combination_class == main_and_sub HALTs cleanup when submodule PR is NOT merged
#
# Setup: Creates a mock submodule-workflow-state output showing
# main_and_sub combination with unmerged submodule PR
# Assertion: Agent HALTs with blocker message instead of proceeding to issue closure

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
source "$SCRIPT_DIR/helpers.sh"

TEST_NAME="submodule-workflow-state-main-and-sub-pr-not-merged-halt"
PROMPT_FILE=$(mktemp)

cat > "$PROMPT_FILE" <<'PROMPT'
You are performing cleanup after PR #100 was merged in the parent repo michael-conrad/opencode-config.
The submodule .opencode is at michael-conrad/.opencode.

The submodule-workflow-state command returned:
submodule_workflow:
  has_submodules: true
  parent_branch: feature/100-test
  parent_has_pr: true
  parent_pr_number: 100
  parent_pr_url: https://github.com/michael-conrad/opencode-config/pull/100
  submodules:
    - path: .opencode
      owner: michael-conrad
      repo: .opencode
      combination_class: main_and_sub
      pr_state:
        has_pr: true
        pr_number: 50
        pr_merged: false
        pr_url: https://github.com/michael-conrad/.opencode/pull/50
      branch_state:
        has_matching_branch: true
        branch_name: feature/100-test
      issue_state:
        has_related_issue: true
        issue_number: 232
        issue_open: true
        issue_url: https://github.com/michael-conrad/.opencode/issues/232

Should you proceed with issue closure and branch cleanup?
PROMPT

# Expected behavior: Agent must HALT because submodule PR #50 is not merged
# even though parent PR #100 is merged.
# The correct response mentions:
# 1. HALT/blocked
# 2. Submodule PR not merged (PR #50)
# 3. Cannot proceed with cleanup

RESULT=$(run_opencode_test "$TEST_NAME" "$PROMPT_FILE")

# Assertions
assert_contains "$RESULT" "HALT\|blocked\|Blocked\|cannot proceed\|not merged" \
    "FAIL: Agent should HALT when submodule PR is not merged in main_and_sub combination"

assert_contains "$RESULT" "#50\|PR.*50\|submodule.*PR" \
    "FAIL: Agent should reference the submodule PR number (#50)"

assert_not_contains "$RESULT" "close.*issue\|delete.*branch\|proceed.*cleanup\|Cleanup complete" \
    "FAIL: Agent should NOT proceed with closure or cleanup when submodule PR is unmerged"

rm -f "$PROMPT_FILE"
echo "PASS: $TEST_NAME"