#!/bin/bash
# Behavioral test: skildeck-frontmatter-validation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-1, SC-2, SC-3, SC-4, SC-6: skildeck lint validates SKILL.md YAML frontmatter

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skildeck-frontmatter-validation"
SCENARIO_PROMPT="Run skildeck lint on the skills directory and report any errors found in SKILL.md YAML frontmatter. Specifically check for: unquoted description values, name/directory mismatches, missing required fields, and YAML parse failures."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
