#!/bin/bash
# Behavioral test: bug-1100-zero-padded-issue-dir
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Bug #1100: get_issue_path() creates zero-padded dir ("001-init") but
# _find_issue_dir() searches with str(number) ("1"), so
# entry.name.startswith("1-") on "001-init" -> False.
#
# This test creates a zero-padded issue dir and proves that
# local-issues delete --number repo#1 cannot find it (RED phase).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="bug-1100-zero-padded-issue-dir"
SCENARIO_PROMPT=$(cat <<'PROMPT'
You are testing the local-issues tool in .opencode/tools/local-issues.

First, create an issue with number 1:
./.opencode/tools/local-issues create --number 1 --title "zero-pad-test"

Then try to delete it:
./.opencode/tools/local-issues delete --number opencode-config#1

What happened? Did the delete succeed, or did it fail to find the issue?
Report the full output of both commands.
PROMPT
)

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0