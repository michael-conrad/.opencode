#!/bin/bash
# Behavioral test: sc20-local-reads
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-20: create.md self-review reads from local .issues/{N}/spec.md, not from remote API.
#
# RED phase: create.md Step 35 references issue-operations -> read-issue for
# self-review checkpoints (placeholder scan, consistency, scope, ambiguity).
# The agent dispatches issue-operations -> read-issue calls when asked to
# create a spec, because create.md instructs it to read from the remote API.
#
# GREEN phase: After refactor replacing issue-operations -> read-issue with
# local .issues/{N}/spec.md reads, the agent reads from local files instead.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc20-local-reads"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
