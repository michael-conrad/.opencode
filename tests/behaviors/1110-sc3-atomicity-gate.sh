#!/bin/bash
# Behavioral test: 1110-sc3-atomicity-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (behavioral): PR-1 (atomicity) correctly flags bundled SCs that
# contain multiple independently testable assertions, and passes atomic SCs
# that map to exactly one RED→GREEN→COMMIT cycle.
#
# RED phase: pipeline-readiness-gate.md exists but atomicity validation is
# not wired into spec-creation, so the agent does not flag bundled SCs.
#
# GREEN phase: agent inspects SCs for bundled assertions and reports PR-1
# FAIL for non-atomic SCs, PASS for atomic ones.
#
# Issue #1110: Pipeline-readiness gate in spec-creation
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1110-sc3-atomicity-gate"
SCENARIO_PROMPT="Create a [SPEC] issue for adding user authentication. Define the following success criteria:
SC-1: Login endpoint returns 200 on valid credentials
SC-2: Login endpoint returns 401 on invalid credentials AND rate-limits after 5 failed attempts
SC-3: Password reset email is sent AND token expires after 1 hour
SC-4: User profile returns correct display name
Define SC-2 and SC-3 as intentionally bundled (they contain two independently testable assertions each). Then run the pipeline-readiness gate and report which SCs are atomic and which are bundled."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: define atomic + bundled SCs, run readiness gate"
echo "  Expectation (GREEN): PR-1 flags SC-2 and SC-3 as FAIL (bundled)"
echo "  Expectation (GREEN): PR-1 passes SC-1 and SC-4 as PASS (atomic)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0