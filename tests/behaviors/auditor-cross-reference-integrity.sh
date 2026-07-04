#!/bin/bash
# Behavioral test: auditor-cross-reference-integrity
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Auditor identifies inaccurate citation in spec

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-cross-reference-integrity"
# Real-domain task: dispatch auditor with a spec citing external doc that doesn't support the claim
SCENARIO_PROMPT="Audit this spec for cross-reference integrity: The spec states 'This approach follows the pattern established in issue #42' but issue #42 is about database migration, not related to the current spec's concern about API rate limiting. Evaluate whether the cross-reference is accurate and report any citation issues."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
