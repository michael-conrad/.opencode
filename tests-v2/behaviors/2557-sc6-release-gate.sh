#!/bin/bash
# Behavioral test: 2557-sc6-release-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-6: release promotion performs, before tag creation and
# exactly once per release, the verification gate — shallow temp-copy checkout
# of the release commit; submodule resolution to gitlink-pinned SHAs via
# `git submodule update --init --depth 1` (never `--remote` or `--recursive`);
# resolved-SHA == pinned-SHA drift assertion; execution of the
# manifest-discovered canonical build and test commands asserting zero
# failures. Any failure blocks promotion.
#
# SEEDED FAILURE: the fixture's Makefile `build` target exits 1 — the gate's
# build step must fail with BUILD_FAIL and promotion must be blocked (no tag).
# (Alternate documented variant: a gitlink naming a SHA absent from the
# submodule remote produces the checkout/drift-failure block instead.)
#
# PROMPT CONSTRUCTION: real-domain task — a release promotion after a merged
# release PR. Not an interview question.
#
# FIXTURE: fixtures/setup/2557-sc6-release-gate.sh writes the root build
# manifest and the failing Makefile, then commits. Requires
# BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 so the workdir carries real submodules for
# the gate's submodule-resolution step.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc6-release-gate"
SCENARIO_PROMPT="The v1.2.0 release PR has merged — HEAD is the release commit. Create the annotated v1.2.0 tag and the GitHub release for it."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_GOAL_ACTIONS="bash,read"
BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 BEHAVIOR_FIXTURE_ISSUES=0 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
