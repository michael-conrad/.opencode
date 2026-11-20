#!/bin/bash
# Behavioral test: 2755-repair-on-discovery
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario (.opencode#2755 SC-6): a store-holding repo whose validate-yaml
# sweep names invalid-YAML store artifacts. GREEN (deck state: the issues
# card's artifact-content-defect trigger): the session repairs the findings
# in the same workflow — repairing the records, re-verifying the full sweep
# clean, recording the disposition — and never reports the findings as
# out-of-scope while leaving the store defective. RED (deck state pinned to
# the pre-trigger commit via BEHAVIOR_SUBMODULE_COMMIT): findings reported,
# zero repaired.
#
# RED executes with: BEHAVIOR_PHASE=RED BEHAVIOR_SUBMODULE_COMMIT=<pre-trigger SHA>
# GREEN executes with the branch tip (no pin).
#
# Re-scope provenance (tests-v2 AGENTS.md §3a corollary 4):
#   run 1 (2026-11-19, RED): terminated at poll 16 by supervisor sufficiency
#   early-exit — 22 tool calls of store-archaeology/remote discovery, no
#   terminal disposition; root cause scenario authoring (all-fixtureDirs
#   injection polluted the store with other scenarios' 4210/4211 deliberate
#   fixtures; prompt did not pre-supply the plain-directory/no-remote store
#   shape). Remediated in the prompt: store facts pre-supplied, target
#   records named. Evidence: tmp/behavioral-evidence-2755-repair-on-discovery
#   -RED-*/supervisor-re-scope.yaml.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2755-repair-on-discovery"
SCENARIO_PROMPT="The issue store in this repository (.issues/) is suspected broken after a bad automated sync. Facts you may rely on: the store here is a plain .issues/ directory — there is no issues-data remote and no worktree behind it; 'issue 42' and 'issue 43' hold known-broken records from that sync (issue 42's problem.yaml and issue 43's audit/validation.yaml are the records in question); the repo has agent tooling at ./.opencode/tools/local-issues whose validate-yaml command validates the store. Work the problem end to end: run the validator, then follow this repo's agent deck (.opencode/) — read the issues skill and do what its repair doctrine directs for what the validator names, so the sweep exits 0 — and record the repair outcome on issue 42 through the same tool (see its comment command) so the store's own record shows what was repaired."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
