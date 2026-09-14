#!/usr/bin/env bash
# SC-3 (issue 2440) structural RED test: trunk-tip-verification.md Procedure Step 8
# (merged-commit check inside `git submodule foreach` eval body).
#
# Asserts:
#   (a) `continue` is absent from the Step 8 foreach eval body — a bare
#       `continue` inside the eval string is invalid control flow in that
#       context (the body executes as a string script per submodule, and
#       `continue` inside it aborts/behaves as a hard error rather than
#       skipping to the next submodule).
#   (b) The network-unreachable WARN-skip path is preserved: the fail-open
#       branch still emits the WARN/skip message and skips the merged-commit
#       check when the remote is unreachable.
#
# Evidence type: structural/string (static inspection, no model run).

set -u
CARD="/home/muksihs/git/opencode-config/.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md"
FAILURES=0

# Extract Step 8 section (from "- [ ] 8." heading to "## Exit Criteria")
STEP8=$(sed -n '/- \[ \] 8\. \*\*Submodule merged-commit check/,/^## Exit Criteria/p' "$CARD")
if [ -z "$STEP8" ]; then
  echo "FATAL: could not extract Step 8 section from $CARD"
  exit 2
fi

# (a) SC-3: no bare `continue` inside the foreach eval body
# Match `continue` as a standalone word within Step 8 bash blocks.
if echo "$STEP8" | grep -nE '^[[:space:]]*continue[[:space:]]*$' >/dev/null; then
  echo "FAIL SC-3a: bare 'continue' found inside Step 8 foreach eval body (invalid control flow in eval-string context)"
  echo "$STEP8" | grep -nE '^[[:space:]]*continue[[:space:]]*$'
  FAILURES=$((FAILURES + 1))
else
  echo "PASS SC-3a: no bare 'continue' in Step 8 foreach eval body"
fi

# (b) SC-3: network-unreachable WARN-skip path preserved
if echo "$STEP8" | grep -Fq 'WARN: Submodule \$path remote unreachable'; then
  echo "PASS SC-3b: WARN/skip message present in fail-open branch"
else
  echo "FAIL SC-3b: network-unreachable WARN/skip message missing from Step 8 fail-open branch"
  FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -gt 0 ]; then
  echo "RESULT: FAIL ($FAILURES assertion failure(s))"
  exit 1
fi
echo "RESULT: PASS"
exit 0
