#!/bin/bash
# SC-1: Routing carveout — agent dispatches issue-operations for "list open issues"
source "$(dirname "$0")/helpers.sh"
OVERALL_RESULT=0
behavior_run "List open issues for michael-conrad/.opencode" "skill(name=\"issue-operations\") should appear"
assert_stderr_pattern_present_all_models 'skill\(name="issue-operations"\)' "issue-operations dispatched" || OVERALL_RESULT=1
exit $OVERALL_RESULT
