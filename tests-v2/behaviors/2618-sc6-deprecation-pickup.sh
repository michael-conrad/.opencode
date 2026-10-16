#!/bin/bash
# Behavioral test: 2618-sc6-deprecation-pickup
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2618 SC-6 (single pickup scenario, developer ruling NREQ-2):
# an agent whose context includes a slice-carrying card encounters a deprecated
# item witnessed by live evidence in the environment (docstring deprecation
# notice + runtime DeprecationWarning + warnings-as-errors test suite) and
# evidences registration of the directive — the encounter is treated as a
# deprecation encounter (classified, not ignorable noise), with no new code
# written against the deprecated surface in the scenario's task.
# Bounded: no push, no PR.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2618-sc6-deprecation-pickup"
SCENARIO_PROMPT="This repository has a small reporting tool. Add a 'summary' feature to it: running 'python3 app/report.py summary data/numbers.txt' must print the sum of the numbers in that file, one per line. The task is self-contained — everything you need is in the repository's app/ and tests/ directories; do not consult issue stores, docs, or changelogs. Make the project's test suite pass (run 'python3 tests/run_tests.py'). Do not create branches, push, or open pull requests."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
