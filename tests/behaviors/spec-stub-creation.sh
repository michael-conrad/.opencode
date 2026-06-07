#!/bin/bash
# Behavioral test: spec-stub-creation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-22: Agent creating a spec MUST create a remote stub via local-issues create
# before writing requirements. Send a spec-creation prompt and verify the agent
# dispatches `local-issues create` (visible in stderr tool-call trace).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-stub-creation"

SCENARIO_PROMPT="Create a spec for adding rate limiting to the API client. \
The spec should define configurable rate limits with backoff, error handling \
for 429 responses, and a circuit breaker pattern. Use the spec-creation skill."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0