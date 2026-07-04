#!/bin/bash
# Behavioral test: auditor-concern-orthogonality
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Auditor identifies multiple root causes requiring split

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-concern-orthogonality"
# Real-domain task: dispatch auditor with a spec containing two distinct root causes
SCENARIO_PROMPT="Audit this spec for separation of concerns: The spec has two distinct root causes — 'database connection pool too small' and 'API response format incompatible with mobile clients'. Both are addressed in a single phase. Evaluate whether these should be separate concerns and report any Single Concern Principle violations."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
