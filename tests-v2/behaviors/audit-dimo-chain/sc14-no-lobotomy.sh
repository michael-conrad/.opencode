#!/bin/bash
# Behavioral test: sc14-no-lobotomy
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14 (behavioral): No SC may be weakened, deferred, or reclassified to a
# lower evidence type to evade implementation. All SCs maintain their declared
# evidence type through implementation.
#
# Real-domain task: user asks to verify that all SCs in spec #1987 maintain
# their declared evidence types — no behavioral SC downgraded to structural.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc14-no-lobotomy"
SCENARIO_PROMPT="Verify that all success criteria in spec #1987 maintain their declared evidence types. Check that SC-8, SC-9, SC-10, and SC-14 are still declared as 'behavioral' evidence type and have not been weakened, deferred, or reclassified to a lower evidence type. Read the spec at .opencode/.issues/1987/spec.md and report any SC that has been lobotomized."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
