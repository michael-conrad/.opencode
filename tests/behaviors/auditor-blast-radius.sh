#!/bin/bash
# Behavioral test: auditor-blast-radius
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Auditor discovers missing files in spec's Files Affected table

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-blast-radius"
# Real-domain task: dispatch auditor with a spec claiming "all files" but listing incomplete set
SCENARIO_PROMPT="Audit this spec for blast radius completeness: The spec's Files Affected table lists only 'src/main.py' and 'src/utils.py' as affected files. However, the spec modifies a function called by 5 other modules. Use srclight_get_dependents to trace the full impact and report any missing files."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
