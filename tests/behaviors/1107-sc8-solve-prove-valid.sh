#!/bin/bash
# Behavioral test: 1107-sc8-solve-prove-valid
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-8 (#1107/Phase3): Valid theorem (preconditions+invariants imply theorem)
#   → solve prove returns VALID
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1107-sc8-solve-prove-valid"

# Create a test contract: a=True implies a=True is trivially valid
TEST_CONTRACT=$(mktemp /tmp/opencode/sc8-contract-XXXXXX.yaml)
cat > "$TEST_CONTRACT" << 'YAML'
name: sc8-valid-theorem
theorem: "a == True"
preconditions:
  - name: a
    expr: a == True
invariants: []
postconditions: []
YAML

SCENARIO_PROMPT="Run solve prove on a contract that has a valid theorem (preconditions imply the theorem). The contract is at $TEST_CONTRACT and the solve tool is at .opencode/tools/solve. Use: ./.opencode/tools/solve prove --contract-path $TEST_CONTRACT"

echo "=== Behavioral Test (GREEN): $SCENARIO_NAME ==="
echo "  Task: verify valid theorem → VALID"
echo "  Contract: $TEST_CONTRACT"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0