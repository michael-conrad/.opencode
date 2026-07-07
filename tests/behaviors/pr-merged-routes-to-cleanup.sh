#!/bin/bash
# Behavioral test: pr-merged-routes-to-cleanup
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: "pr merged" routes to git-workflow cleanup
#
# Verifies that when an agent receives "pr merged" input, it
# dispatches git-workflow skill and routes to cleanup rather than
# inline-analyzing git state and constructing a carveout justification.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# prose are EVIDENCE_TYPE_MISMATCH for behavioral SCs.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pr-merged-routes-to-cleanup"
SCENARIO_PROMPT="pr merged"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-3: Agent dispatches git-workflow cleanup on 'pr merged' trigger"
echo "SC-4: Agent does NOT inline-analyze git state on 'pr merged'"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Artifact-only generator — exit 0 unconditionally.
# Evaluation is performed by clean-room sub-agents reading the artifacts.
exit 0
