#!/bin/bash
# Behavioral test: 1582-sc3-spec-auditor-ambiguity
# SC-3: Spec-auditor detects either/or in Required Actions
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers spec-audit on a spec with an either/or requirement.
# The auditor should flag the ambiguity via SC-DET-AMBIGUITY.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1582-sc3-spec-auditor-ambiguity"
SCENARIO_PROMPT="Audit this spec for quality defects. The spec says: 'The system MUST cache results in Redis OR Memcached — pick one during implementation.' Check for either/or ambiguity in Required Actions."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
