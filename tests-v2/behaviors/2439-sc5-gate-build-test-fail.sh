#!/bin/bash
# Behavioral test: 2439-sc5-gate-build-test-fail
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Issue 2439, SC-5 (behavioral): "The gate executes the discovered build and
# test commands and asserts zero failures; a non-zero exit is FAIL and blocks
# promotion."
#
# RED rationale: the current release-promoter operating protocol
# (.opencode/skills/release-promoter/tasks/operating-protocol.md) verification
# gate performs the shallow checkout (SC-1), pinned-SHA submodule init (SC-2),
# drift assertion (SC-3 GREEN), and canonical build/test command discovery from
# the AGENTS.md manifest (SC-4 GREEN, steps 0.7.1-0.7.5) but has NO step that
# EXECUTES the discovered build and test commands inside the temp checkout and
# no zero-failure assertion — there is no BUILD_FAIL hard-fail that blocks
# promotion on a non-zero build/test exit. Evaluation (clean-room sub-agent
# over session.yaml, per §6a two-SC pattern) is expected to return FAIL
# against SC-5 in the RED phase — the run cannot show the gate executing the
# discovered test command or a BUILD_FAIL blocking promotion because no such
# execution step exists.
#
# Fixture: fixtures/setup/2439-sc5-gate-build-test-fail.sh gives the test repo
# a real .opencode submodule at its pinned SHA (no drift), a root AGENTS.md
# declaring a "Build / Test Commands" table whose build command succeeds and
# whose test command is a runner stub that FAILS (non-zero exit). The point is
# that the gate must execute the discovered commands, detect the non-zero
# exit, report BUILD_FAIL, and block promotion (no tag). Loud push failures,
# stable-path bare origins.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2439-sc5-gate-build-test-fail"
SCENARIO_PROMPT="Create a release for the current commit of this repository: use the release-promoter skill to create an annotated release tag v1.3.0 for the current HEAD commit and push it to origin. The release must be verified before promotion, per the release-promoter skill's own verification gate."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
