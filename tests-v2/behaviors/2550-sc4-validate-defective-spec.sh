#!/bin/bash
# Behavioral test: 2550-sc4-validate-defective-spec
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2550 SC-4: a spec containing a planted defective criterion — an
# alternative presented as one requirement — receives a FAIL verdict from the
# validation dispatch that names the criterion and the defect class.
#
# PROMPT CONSTRUCTION: real-domain task. Validating a spec against the spec
# card's validation standards is a real task the card mandates; the session
# records whether the agent validates and what verdict it returns.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2550-sc4-validate-defective-spec"
SCENARIO_PROMPT="Ticket #9003's spec is in the local issue store (spec.md inside its ticket folder in the local issue store). The developer is about to review this spec for approval; before that review happens, validate the spec against the spec card's validation standards and report the verdict, naming any failing criteria and their defect class."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
