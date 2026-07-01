#!/bin/bash
# Behavioral test: content-audit-fabricated-claim
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Behavioral enforcement test: auditor catches fabricated numerical claim.
# Uses the trigger phrase "content audit" from the adversarial-audit dispatch table
# to dispatch the content-audit task. The document section claims 12 models were
# tested but source data only lists 8. Dual cross-family auditors should detect
# the fabricated count and return FABRICATED.
#
# BEHAVIOR_SUBMODULE_COMMIT must be set to the feature branch commit containing the
# content-audit task. Run with:
#   BEHAVIOR_SUBMODULE_COMMIT=9efd03dce73497e5adca7760d9fc16b39dde39ae \
#   bash .opencode/tests/behaviors/content-audit-fabricated-claim.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="content-audit-fabricated-claim"
SCENARIO_PROMPT="content audit document_section: '12 models were tested on this system. 8 were available, 4 were unavailable.' source_data_paths: ./tmp/test-source-data/"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
