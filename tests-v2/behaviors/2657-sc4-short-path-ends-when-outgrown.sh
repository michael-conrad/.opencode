#!/bin/bash
# Behavioral test: 2657-sc4-short-path-ends-when-outgrown
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2657 SC-9: a short-path change that acquires a second file ends
# the short path — the expanded scope statement precedes the second file's
# edit, and a full-path spec artifact appears between that statement and the
# run's next implementation edit. Clean-room evaluation over session.yaml
# (orchestrator side).
#
# PROMPT CONSTRUCTION: real-domain task — a one-line feature request whose
# work turns out to need a second file. Not an interview question.
#
# FIXTURES: per-scenario setup script seeds src/feature.py (the script the
# request names) and src/cli.py (the sibling module its argument parsing
# lives in — the second file the change turns out to need) plus the local
# issue store (tests-v2 AGENTS.md §3a, §3 Step 0b).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2657-sc4-short-path-ends-when-outgrown"
# Goal condition (tests-v2 AGENTS.md §14): the monitor's classifier judges the run
# against this declared condition, and the SC-8 determination gate lets a run that
# hits the per-turn output cap resume. Without it the classifier returns
# 'undetermined', the gate blocks the resume, and the run cannot finish.
BEHAVIOR_EXPECTED_ARTIFACT="src/cli.py"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="json"   # the flag the request names; absent from the seeded parser
BEHAVIOR_GOAL_ACTIONS="write,edit,bash"   # the second file — the parser that must accept the flag

SCENARIO_PROMPT="Add a \`--json\` flag to the feature script so it prints the feature as JSON."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
