#!/usr/bin/env bash
# Behavioral test: Submodule issue closure routing to correct repo
# SC-10: Agent correctly routes issue closure to michael-conrad/.opencode
# (NOT michael-conrad/opencode-config) when the submodule has related issues
#
# Setup: Creates a scenario where submodule has related issues
# Assertion: Agent uses submodule owner/repo for issue API calls, not parent repo

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
source "$SCRIPT_DIR/helpers.sh"

TEST_NAME="submodule-issue-closure-routing-correct-repo"
PROMPT_FILE=$(mktemp)

cat > "$PROMPT_FILE" <<'PROMPT'
You are closing issue #232 in the .opencode submodule after PR merge.

The submodule-workflow-state command returned:
submodule_workflow:
  has_submodules: true
  parent_branch: feature/232-test
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
        pr_merged: true
        pr_url: https://github.com/michael-conrad/.opencode/pull/50
      branch_state:
        has_matching_branch: true
        branch_name: feature/232-test
      issue_state:
        has_related_issue: true
        issue_number: 232
        issue_open: true
        issue_url: https://github.com/michael-conrad/.opencode/issues/232

Which owner and repo should you use when calling github_issue_write to close issue #232?
PROMPT

# Expected behavior: Agent must route the API call to michael-conrad/.opencode
# (the submodule repo), NOT michael-conrad/opencode-config (the parent repo)

RESULT=$(run_opencode_test "$TEST_NAME" "$PROMPT_FILE")

# Assertions
assert_contains "$RESULT" "michael-conrad/.opencode\|.opencode.*repo\|submodule.*owner.*repo" \
    "FAIL: Agent should route issue closure to the submodule repo (michael-conrad/.opencode)"

assert_not_contains "$RESULT" "michael-conrad/opencode-config.*issue.*close\|opencode-config.*close.*232\|parent.*repo.*close" \
    "FAIL: Agent should NOT route issue closure to the parent repo (michael-conrad/opencode-config)"

assert_contains "$RESULT" "submodule_workflow\|submodule.*owner\|submodule.*repo\|\.opencode" \
    "FAIL: Agent should reference the submodule_workflow output to determine the correct owner/repo"

rm -f "$PROMPT_FILE"
echo "PASS: $TEST_NAME"