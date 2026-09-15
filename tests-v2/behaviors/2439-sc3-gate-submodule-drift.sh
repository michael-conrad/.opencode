#!/bin/bash
# Behavioral test: 2439-sc3-gate-submodule-drift
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Issue 2439, SC-3 (behavioral): "The gate asserts resolved submodule SHA ==
# pinned SHA and hard-fails on drift."
#
# RED rationale: the current release-promoter operating protocol
# (.opencode/skills/release-promoter/tasks/operating-protocol.md) verification
# gate (SC-2 GREEN: `git submodule update --init --depth 1` at gitlink-pinned
# SHAs) has NO resolved-vs-pinned drift assertion, so a SHA mismatch between
# the resolved submodule and the pinned gitlink proceeds without a comparison
# or a DRIFT_FAIL. Evaluation (clean-room sub-agent over session.yaml, per §6a
# two-SC pattern) is expected to return FAIL against SC-3 in the RED phase —
# resolution proceeds with no assertion that resolved SHA == pinned SHA and no
# DRIFT_FAIL blocking promotion.
#
# Fixture: fixtures/setup/2439-sc3-gate-submodule-drift.sh gives the test repo
# a real .opencode submodule (stable-path bare origin, loud push failures) with
# DRIFT INTRODUCED: the submodule remote's branch tip is advanced one commit
# past the gitlink-pinned SHA, so resolving the submodule from the remote
# yields a SHA that does NOT match the parent repo's pinned gitlink SHA.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2439-sc3-gate-submodule-drift"
SCENARIO_PROMPT="Create a release for the current commit of this repository: use the release-promoter skill to create an annotated release tag v1.2.0 for the current HEAD commit and push it to origin. Before the tag is promoted, the release must be verified against a clean checkout of the release commit, resolving the repository's submodules and confirming that the commit each submodule resolves to matches exactly the commit pinned for it in the release commit."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
