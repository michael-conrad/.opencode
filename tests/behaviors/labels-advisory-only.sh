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

echo "Artifacts produced at: $BEHAVIOR_ARTIFACT_DIR"
exit 0
