#!/bin/bash
# Content-verification test: sc-5-cross-references
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: All cross-references to `plan-creation-pipeline` in other skills/guidelines
# are updated to reference `writing-plans` instead.
# grep -r "plan-creation-pipeline" .opencode/ --include="*.md" \
#   --exclude-dir=".opencode/skills/plan-creation-pipeline" | wc -l — expect 0
#
# In RED phase, matches exist (>0) and the test fails.
# In GREEN phase, all references are removed (0) and the test passes.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc-5-cross-references"
SCENARIO_PROMPT="Check whether any .md files in the .opencode/ directory (excluding the .opencode/skills/plan-creation-pipeline/ directory itself) still contain the string 'plan-creation-pipeline'. Run a grep command with --exclude-dir to exclude the plan-creation-pipeline skill directory, count the matches, and report the result."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
