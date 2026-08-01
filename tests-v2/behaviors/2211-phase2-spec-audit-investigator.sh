#!/bin/bash
# Behavioral test: 2211-phase2-spec-audit-investigator
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests whether the spec-audit-investigator reads from reference/spec-structure-standards.md
# instead of hard-coding section names (Intent and Executive Summary, Documentation Sources,
# STATUS marker) in Step 3.
#
# PROMPT CONSTRUCTION: Real-domain task — "Run the spec audit investigation on issue #2211"
# triggers the spec-audit-investigator to collect spec structure evidence (Step 3).
# The current code hard-codes section names in Step 3.1 (section inventory), Step 3.5
# (preamble presence), Step 3.6 (Documentation Sources), and Step 3.7 (STATUS marker).
# After the fix, the investigator should read from reference/spec-structure-standards.md
# and derive section names from its Required Sections list.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2211-phase2-spec-audit-investigator"
SCENARIO_PROMPT="Run the spec audit investigation on issue #2211. The spec is at .issues/2211/spec.md. Use the spec-audit-investigator to collect spec structure evidence (Step 3). Read the spec-audit-investigator task file first, then follow its procedure."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
