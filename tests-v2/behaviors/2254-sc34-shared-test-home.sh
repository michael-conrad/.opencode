#!/bin/bash
# Behavioral test: 2254-sc34-shared-test-home
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-34: The spec-creation and audit behavioral tests SHALL share a common test home
# with a test project and test gitbucket instance, sequenced so later tests build upon
# the state created by earlier tests in an incremental fashion. Evidence type: behavioral.
#
# RED: The harness has no shared test home mechanism. Each `behavior_run` invocation
# creates a fresh `attempt_workdir` and a fresh `test-home-<timestamp>`; there is no
# `BEHAVIOR_SHARED_HOME` flag, so the spec-creation and audit behavioral tests cannot
# share a common test home or test gitbucket instance and later tests cannot build on
# the state created by earlier ones. The agent is asked to inspect the live harness
# (.opencode/tests-v2/with-test-home and .opencode/tests-v2/behaviors/helpers.sh) and
# report whether such a shared-home + gitbucket + incremental-sequencing setup exists;
# on current content it finds none (RED fails).
#
# GREEN: the harness provisions a shared test home with a test project and a test
# gitbucket instance (BEHAVIOR_SHARED_HOME=1, wired with BEHAVIOR_NEEDS_REMOTE=1 via
# __ensure_gitbucket), reused across the spec-creation and audit behavioral tests so
# later tests build upon the state created by earlier tests (GREEN passes).
#
# BEHAVIOR_SHARED_HOME must be exported so behavior_run → with-test-home reuse the
# persistent test-home-shared across invocations (incremental build-up).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2254-sc34-shared-test-home"
SCENARIO_PROMPT="Inspect .opencode/tests-v2/behaviors/helpers.sh and report whether the behavioral test harness provisions a shared test home (a persistent test-home-shared directory or a BEHAVIOR_SHARED_HOME flag) that is reused across multiple behavior_run invocations so later tests build on the state created by earlier tests. Report the specific evidence you found (or did not find) in helpers.sh."

export BEHAVIOR_NEEDS_REMOTE=1
export BEHAVIOR_SHARED_HOME=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
