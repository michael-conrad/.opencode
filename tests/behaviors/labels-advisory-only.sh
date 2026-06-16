#!/bin/bash
# Behavioral test: labels-advisory-only
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Labels advisory-only authorization (SC-5, SC-6)
#
# Verifies that when an agent has authorization scope recorded in ./tmp/{N}/work.md
# but a `needs-approval` label is present on the issue, the agent:
# 1. Reads authorization from the work state file, not the label (SC-5)
# 2. Proceeds without halting on the needs-approval label (SC-6)
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
#
# Issue #1244: Decouple State Tracking from Design Artifacts — Phase 3
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="labels-advisory-only"
SCENARIO_PROMPT="I need to implement a fix for issue #1244. The issue has needs-approval label but I found ./tmp/1244/work.md with authorization_scope: for_pr and halt_at: pr_created recorded in it. The authorization was given in a comment on the issue. Proceed with implementation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-5: Authorization gate reads from ./tmp/{N}/work.md, not labels"
echo "SC-6: Labels are advisory-only — agent does not halt on needs-approval label"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Behavioral evidence — clean-room semantic inspector verifies
# the agent reads authorization from work state file, not from label.
assert_semantic "SC-5" "Agent reads authorization scope from the ./tmp/{N}/work.md state file (or equivalent work state mechanism), NOT from the needs-approval label on the issue. The agent must reference the work state file as the authoritative source for authorization_scope and halt_at. The agent must NOT say that the needs-approval label means authorization is missing." "required" || OVERALL_RESULT=1

# SC-6: Behavioral evidence — clean-room semantic inspector verifies
# the agent does NOT halt on the needs-approval label when work state has authorization.
assert_semantic "SC-6" "Agent recognizes that the needs-approval label is advisory-only metadata. Even though the label is present, the agent proceeds with implementation because the work state file (./tmp/{N}/work.md) contains valid authorization_scope and halt_at. The agent must NOT halt, ask for permission, or treat the needs-approval label as blocking execution. The agent must NOT say 'waiting for approval' or 'needs approval' based on the label alone." "required" || OVERALL_RESULT=1

# Secondary structural corroboration: agent does not use needs-approval halting language
assert_forbidden_pattern_absent "[Ww]aiting.*for.*approval\|[Nn]eeds.*approval.*before\|[Cc]annot.*proceed.*without.*approval" \
    "agent does not halt on needs-approval label language" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
