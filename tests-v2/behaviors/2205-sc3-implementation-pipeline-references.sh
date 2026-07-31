#!/bin/bash
# Content-verification test: 2205-sc3-implementation-pipeline-references
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: No implementation-pipeline references in .md files outside CHANGELOG.md
# grep -r "implementation-pipeline" .opencode/ --include="*.md" | grep -v CHANGELOG.md | wc -l — expect 0
#
# In RED phase, matches exist (>0) and the test fails.
# In GREEN phase, all references are removed (0) and the test passes.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2205-sc3-implementation-pipeline-references"
SCENARIO_PROMPT="Check whether any .md files in the .opencode/ directory (excluding CHANGELOG.md) still contain the string 'implementation-pipeline'. Run a grep command to count matches and report the result."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
