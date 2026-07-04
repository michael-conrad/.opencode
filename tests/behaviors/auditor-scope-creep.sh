#!/bin/bash
# Behavioral test: auditor-scope-creep
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Auditor identifies untraced fix element in spec

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-scope-creep"
# Real-domain task: dispatch auditor with a spec where Fix Approach has element with no Root Cause traceability
SCENARIO_PROMPT="Audit this spec for scope creep: The spec's Root Cause is 'database connection pool too small' but the Fix Approach includes 'add Redis caching layer' which has no traceability to any Root Cause element. Evaluate whether this is scope creep and report findings."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
