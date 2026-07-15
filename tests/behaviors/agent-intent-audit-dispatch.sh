#!/bin/bash
# Behavioral test: agent-intent-audit-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Category: audit — agent dispatches audit skill based on internal intent
# (no user utterance match available)
#
# SC-1: Agent dispatches audit skill when it detects a need for verification
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# are EVIDENCE_TYPE_MISMATCH for behavioral SCs. Only assert_semantic
# (clean-room sub-agent evaluation) is acceptable for verifying agent
# ACTIONS and DECISIONS.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="agent-intent-audit-dispatch"
# BEHAVIORAL PROMPT: real-domain task where the agent must detect the need
# for an audit autonomously. The user reports a spec defect — the agent
# should determine that an audit is needed without the user saying "audit".
SCENARIO_PROMPT="I just finished writing a spec for issue #42 but I'm not sure if it covers all the success criteria correctly. Can you take a look and make sure it's complete?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
