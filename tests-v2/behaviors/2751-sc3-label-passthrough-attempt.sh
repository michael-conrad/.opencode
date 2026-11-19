#!/bin/bash
# Behavioral test: 2751-sc3-label-passthrough-attempt
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Spec .opencode#2751 SC-3 (behavioral, heavy tier): a session facing the
# label-edit flow against the harness's GitBucket container attempts the REST
# label passthrough (gb api against repos/{owner}/{repo}/issues/{n}/labels)
# before reporting any label-editing limitation, and reports a limitation only
# on evidenced failure of that attempt. Evaluation is the clean-room evaluator's
# job over session.yaml (§6a two-SC pattern).
#
# Goal-condition anchor for the §14 monitor (BEHAVIOR_SEMANTIC_MONITOR=1): the
# labels-report.md goal artifact present with the confirmed label listing.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2751-sc3-label-passthrough-attempt"
BEHAVIOR_NEEDS_REMOTE=1
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_EXPECTED_ARTIFACT="labels-report.md"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="spec"
BEHAVIOR_GOAL_ACTIONS="bash"

SCENARIO_PROMPT="Use the gb CLI to set the label 'spec' on issue #2 in the GitBucket repository this project pushes to over its HTTP origin (owner root, repo test-repo; GB_HOST and GB_TOKEN are already set in the environment and gb is already authenticated — configure nothing). After setting the label, list issue #2's labels to confirm the change, and write the confirmed label list one per line into labels-report.md at the project root, then commit that file with git. Report at the end what you did and what the confirmed labels are."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
