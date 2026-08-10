#!/bin/bash
# Behavioral test: 2254-sc33-audit-dimo-chain
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-33: Dispatching the audit DiMo 4-role chain (investigator → validator →
# evaluator → arbiter) against a fixture spec in the shared test home SHALL produce
# a valid verdict, with each role dispatching to the correct split task card with a
# complete dispatch contract. Evidence type: behavioral.
#
# RED: The audit DiMo chain (as of the pre-remediation content) mis-routes roles,
# dispatches to missing task cards, or carries incomplete dispatch contracts when
# dispatched end-to-end against a fixture spec. The agent is asked to run a spec
# audit on a fixture spec in the shared test home and report whether the audit
# produced a valid verdict (evidence.yaml → reasoning.yaml → verdict.yaml →
# judgment.yaml) with each role dispatching to the correct split spec-audit task
# card carrying a complete dispatch contract. On current content the chain fails to
# run end-to-end (RED fails).
#
# GREEN: the remediated audit chain dispatches the 4-role DiMo chain end-to-end
# against the fixture spec, each role dispatching to the correct split task card
# (spec-audit-investigator/validator/evaluator/arbiter) with a complete dispatch
# contract, producing a valid verdict (GREEN passes).
#
# Uses the shared test home (BEHAVIOR_SHARED_HOME=1) so the audit chain builds
# incrementally on the shared test project + gitbucket instance per SC-34.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2254-sc33-audit-dimo-chain"
SCENARIO_PROMPT="Run a spec audit on the fixture spec at .issues/2211/spec.md in the shared test home. Dispatch the audit DiMo 4-role chain end-to-end (investigator -> validator -> evaluator -> arbiter), each role dispatching to its split spec-audit task card with a complete dispatch contract, and report the final verdict."

export BEHAVIOR_NEEDS_REMOTE=1
export BEHAVIOR_SHARED_HOME=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
