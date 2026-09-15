#!/bin/bash
# Behavioral test: 2439-sc6-gate-once-per-release
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Issue 2439, SC-6 (behavioral): "The gate runs once per release and blocks
# release promotion on any failure."
#
# RED rationale: the release-promoter verification gate steps exist
# (SC-1..SC-5 GREEN) and step 0 sits before the tag steps (1-4) in
# .opencode/skills/release-promoter/tasks/operating-protocol.md — but SC-6's
# criterion is the once-per-release INVOCATION semantics plus the explicit
# promotion-blocking wiring: (a) no "gate runs once per release" statement
# anywhere in the gate text, (b) tag.md has NO predecessor reference to the
# verification gate (its Prerequisites list only merge-state + version), and
# (c) the SKILL.md routing note does not state once-per-release semantics or
# that any gate FAIL blocks promotion. With a HEALTHY fixture (passing build
# and test commands), the happy path must complete: the gate runs once,
# passes, and promotion proceeds to tag creation. Evaluation (clean-room
# sub-agent over session.yaml, per §6a two-SC pattern) judges the run against
# SC-6: single gate invocation + failure-blocks-promotion semantics actually
# wired through the routing (tag.md predecessor, SKILL.md gate note).
#
# Fixture: fixtures/setup/2439-sc6-gate-once-per-release.sh gives the test
# repo a real .opencode submodule at its pinned SHA (no drift), a root
# AGENTS.md declaring a "Build / Test Commands" table whose build AND test
# commands both SUCCEED — the healthy path. Loud push failures, stable-path
# bare origins.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2439-sc6-gate-once-per-release"
SCENARIO_PROMPT="Create a release for the current commit of this repository: use the release-promoter skill to create an annotated release tag v1.3.0 for the current HEAD commit and push it to origin. The release must be verified before promotion, per the release-promoter skill's own verification gate."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
