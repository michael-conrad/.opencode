#!/bin/bash
# Behavioral test: 2657-sc1-stage-request-runs-stage
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2657 SC-6: a developer request that names a stage produces that
# stage's work — the spec file the request names is written, with the spec's
# content — and no edit to an implementation file is made. Clean-room
# evaluation over session.yaml (orchestrator side).
#
# PROMPT CONSTRUCTION: real-domain task — a developer asks for a spec, names
# the file it goes in, and asks for approval before any code. Not an
# interview question.
#
# FIXTURES: per-scenario setup script seeds src/upload.py, docs/, and the
# local issue store (tests-v2 AGENTS.md §3a, §3 Step 0b).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2657-sc1-stage-request-runs-stage"
# Goal condition (tests-v2 AGENTS.md §14): the monitor's classifier judges the run
# against this declared condition, and the SC-8 determination gate lets a run that
# hits the per-turn output cap resume. Without it the classifier returns
# 'undetermined', the gate blocks the resume, and the run cannot finish.
BEHAVIOR_EXPECTED_ARTIFACT="docs/upload-retry-spec.md"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="retry"
BEHAVIOR_GOAL_ACTIONS="write,edit,bash"   # the requested spec file, and its content mentions the retry policy

SCENARIO_PROMPT="Write a spec for how the upload client should retry a failed upload, put it in docs/upload-retry-spec.md, and get my approval of it before you write any code."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
