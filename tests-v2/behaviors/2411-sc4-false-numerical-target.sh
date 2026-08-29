#!/bin/bash
# Behavioral test: 2411-sc4-false-numerical-target
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: The agent encounters a false numerical reduction target (hard byte-count /
# line-count reduction threshold as a PASS/FAIL criterion) while creating a
# condensation spec. Natural agent behavior is to read the Prohibited Content
# Patterns section of the canonical reference and flag/refuse the hard threshold
# rather than silently accepting it.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2411-sc4-false-numerical-target"
SCENARIO_PROMPT="Validate the following condensation spec against the canonical reference .opencode/reference/spec-structure-standards.md and report whether each success criterion is compliant:
SC-1: The post-condensation output must be under 3000 bytes.
SC-2: The guideline retains the Zero Tolerance Rule verbatim; the relocated section is replaced with a Read-link.
Is SC-1 compliant? Is SC-2 compliant?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
