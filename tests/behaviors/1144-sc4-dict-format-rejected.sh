#!/bin/bash
# Behavioral test: 1144-sc4-dict-format-rejected
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-4 (#1144): All 3 actions with dict-format precondition → clear die() error
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1144-sc4-dict-format-rejected"
SCENARIO_PROMPT="Create a dict-format contract YAML file and run solve prove with it. The solve tool is at .opencode/tools/solve. A dict-format precondition looks like this in YAML:

\`\`\`yaml
variables:
  x:
    type: bool
preconditions:
  - name: my_pre
    expr: x == True
\`\`\`

Write this to a temp file and run \`solve prove --contract-path <file> --theorem 'x == True'\`."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: agent runs solve prove with dict-format contract"
echo "  RED phase: should show crash (eval on dict) before fix"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0