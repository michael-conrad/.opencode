#!/bin/bash
# Behavioral test: auditor-disk-offload-spec-read
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-disk-offload-spec-read"
SCENARIO_PROMPT="Read .opencode/skills/audit/tasks/spec-audit.md. Show the exact heading and content of Step 6 and Step 7. Also check if Step 6 writes to ./tmp/artifacts/ and Step 7 returns exactly status, artifact_path, summary. Respond with the evidence found."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
