#!/bin/bash
# Behavioral test: 1107-sc9-solve-prove-invalid
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-9 (#1107/Phase3): Invalid theorem (preconditions+invariants do not imply
#   theorem) → solve prove returns INVALID
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1107-sc9-solve-prove-invalid"

# Create a test contract: a=True, b=False preconditions, theorem is a==b which is NOT implied
TEST_CONTRACT=$(mktemp /tmp/opencode/sc9-contract-XXXXXX.yaml)
cat > "$TEST_CONTRACT" << 'YAML'
name: sc9-invalid-theorem
theorem: "a == b"
preconditions:
  - name: a
    expr: a == True
  - name: b
    expr: b == False
invariants: []
postconditions: []
YAML

SCENARIO_PROMPT="Run solve prove on a contract that has an invalid theorem (preconditions do not imply the theorem). The contract is at $TEST_CONTRACT and the solve tool is at .opencode/tools/solve. Use: ./.opencode/tools/solve prove --contract-path $TEST_CONTRACT"

echo "=== Behavioral Test (GREEN): $SCENARIO_NAME ==="
echo "  Task: verify invalid theorem → INVALID"
echo "  Contract: $TEST_CONTRACT"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0