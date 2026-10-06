#!/bin/bash
# Behavioral test: 2516-terminal-approval-stage-zero
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2516 SC-3: an agent given `#N approved for pr` on a stage-0 ticket
# (no branch, no plan, no implementation) proceeds through the pipeline —
# it does NOT halt with a clarification request about missing upstream-stage
# approvals, and it enters the pipeline (feature-branch creation) rather than
# stopping.
#
# PROMPT CONSTRUCTION: real-domain task. The developer message carries the
# terminal-stage approval and points at the fixture spec; the agent either
# proceeds (branch creation) or halts — the session.yaml records which.
# The scenario is bounded: no push, no PR, so no remote mutation occurs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2516-terminal-approval-stage-zero"
SCENARIO_PROMPT="The developer just said: '#9001 approved for pr'. Ticket #9001's spec is in the local issue store (spec.md inside its ticket folder) and describes a one-line README fix in this repository. Carry the ticket through the pipeline on a feature branch in this repo. Stop once the fix is committed to the feature branch — do not push and do not open a pull request."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
