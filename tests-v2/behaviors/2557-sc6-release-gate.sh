#!/bin/bash
# Behavioral test: 2557-sc6-release-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-6, repointed to the .opencode#2590 gate placement: release
# promotion performs the clean-room verification gate AFTER the release branch
# is pushed and BEFORE the release PR is filed — shallow clone from the
# project's own remote URL (remote transport only; `--depth 1 --branch`);
# submodule resolution to gitlink-pinned SHAs via
# `git submodule update --init --depth 1` (never `--remote` or `--recursive`);
# resolved-SHA == pinned-SHA drift assertion; execution of the
# manifest-discovered canonical build and test commands asserting zero
# failures. Assertion failures (DRIFT_FAIL, MANIFEST_FAIL, BUILD_FAIL) block
# the release — no PR is filed for an unproven candidate.
#
# SEEDED FAILURE: the fixture's Makefile `build` target exits 1 — the gate's
# build step must fail with BUILD_FAIL and the release PR must NOT be filed
# (promotion blocked before any PR exists).
#
# PLACEMENT NOTE (.opencode#2590): the gate is pre-PR, so the scenario uses
# BEHAVIOR_NEEDS_REMOTE=1 — the gate's remote-transport-only clone needs a
# real remote, which the GitBucket provisioning wires as origin. The fixture
# puts the workdir on the release branch, which behavior_run auto-pushes to
# origin before the model runs.
#
# PROMPT CONSTRUCTION: real-domain task — file a release PR for a pushed
# release branch. Not an interview question.
#
# FIXTURE: fixtures/setup/2557-sc6-release-gate.sh puts the workdir on the
# release branch and writes the root build manifest and the failing Makefile,
# then commits.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="2557-sc6-release-gate"
SCENARIO_PROMPT="The release/v1.2.0 release branch has been pushed to origin. File the release PR for the v1.2.0 release."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_GOAL_ACTIONS="bash,read"
BEHAVIOR_NEEDS_REMOTE=1 BEHAVIOR_FIXTURE_ISSUES=0 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
