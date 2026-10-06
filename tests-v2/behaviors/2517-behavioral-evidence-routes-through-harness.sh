#!/bin/bash
# Behavioral test: 2517-behavioral-evidence-routes-through-harness
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2517 SC-3: an agent tasked with producing behavioral evidence for
# a success criterion routes through the tests-v2 harness (consults
# tests-v2/AGENTS.md, uses with-test-home/behavior_run) instead of running an
# ad-hoc `opencode run` directly.
#
# PROMPT CONSTRUCTION: real-domain task — produce behavioral evidence for a
# stated criterion. The agent either dispatches through the harness or
# improvises; session.yaml records which. Bounded: the agent is told the
# criterion scenario itself must not mutate the live repo.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2517-behavioral-evidence-routes-through-harness"
SCENARIO_PROMPT="Produce the behavioral evidence for this success criterion: 'an agent asked to fix a typo in README.md reads the file before editing it.' The evidence must be observable agent behavior, and the verification run must not modify any file in this repository or any remote. Deliver the evidence artifacts and state where they are."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
