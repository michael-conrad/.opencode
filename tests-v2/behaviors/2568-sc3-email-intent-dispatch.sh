#!/bin/bash
# Behavioral test: 2568-sc3-email-intent-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC under test (.opencode#2568 SC-3): given a developer request that involves
# email, the main agent routes the work by dispatching to the email-ops
# subagent. The prompt is a real-domain email task (gmail intent phrasing) so
# the dispatch decision is the agent's own, not an interview answer.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2568-sc3-email-intent-dispatch"
SCENARIO_PROMPT="Check my gmail inbox for unread messages and tell me what needs my attention."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
