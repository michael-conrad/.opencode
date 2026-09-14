#!/bin/bash
# Behavioral test: 2439-sc2-gate-submodule-pins
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Issue 2439, SC-2 (behavioral): "The gate resolves submodules to their
# gitlink-pinned SHAs (not latest) using `git submodule update --init --depth 1`,
# never `--remote` or `--recursive`."
#
# RED rationale: the current release-promoter operating protocol
# (.opencode/skills/release-promoter/tasks/operating-protocol.md) verification
# gate (SC-1 GREEN: shallow temp-copy clone + checkout of the release commit)
# has NO submodule resolution step, so the gate cannot resolve the repo's
# submodules to their gitlink-pinned SHAs inside the temp checkout. Evaluation
# (clean-room sub-agent over session.yaml, per §6a two-SC pattern) is expected
# to return FAIL against SC-2 in the RED phase — no `git submodule update --init
# --depth 1` in the gate, while `--remote`/`--recursive` must never appear.
#
# Fixture: fixtures/setup/2439-sc2-gate-submodule-pins.sh gives the test repo a
# real .opencode submodule (cloned from the real .opencode remote, added as a
# gitlink submodule, committed) plus a stable-path bare origin so the gate has
# a submodule to resolve and a clonable/pushable origin.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2439-sc2-gate-submodule-pins"
SCENARIO_PROMPT="Create a release for the current commit of this repository: use the release-promoter skill to create an annotated release tag v1.2.0 for the current HEAD commit and push it to origin. The release must be verified against a clean checkout of the release commit, including all of the repository's submodules at their pinned commits, before the tag is promoted."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
