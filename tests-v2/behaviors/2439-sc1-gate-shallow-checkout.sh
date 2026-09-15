#!/bin/bash
# Behavioral test: 2439-sc1-gate-shallow-checkout
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Issue 2439, SC-1 (behavioral): "The gate performs a shallow temp-copy checkout
# of the root repo at the release commit."
#
# RED rationale: the current release-promoter operating protocol
# (.opencode/skills/release-promoter/tasks/operating-protocol.md) has NO
# verification-gate checkout step, so the agent cannot perform a shallow
# temp-copy checkout at the release commit before tagging. Evaluation (clean-room
# sub-agent over session.yaml, per §6a two-SC pattern) is expected to return
# FAIL against SC-1 in the RED phase.
#
# Fixture: fixtures/setup/2439-sc1-gate-shallow-checkout.sh wires a local bare
# origin (stable path outside the workdir, loud push failures) so the release
# flow runs as a normal remote-tracking repo with a clonable origin.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2439-sc1-gate-shallow-checkout"
SCENARIO_PROMPT="Create a release for the current commit of this repository: use the release-promoter skill to create an annotated release tag v1.2.0 for the current HEAD commit and push it to origin. The release must be verified against a clean checkout of the release commit before the tag is promoted."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
