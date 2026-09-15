#!/bin/bash
# Behavioral test: 2439-sc4-gate-manifest-discovery
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Issue 2439, SC-4 (behavioral): "The gate discovers the repository's canonical
# build and test commands from the repo's AGENTS.md (or equivalent build
# manifest) rather than assuming a specific build system."
#
# RED rationale: the current release-promoter operating protocol
# (.opencode/skills/release-promoter/tasks/operating-protocol.md) verification
# gate performs the shallow checkout (SC-1), pinned-SHA submodule init (SC-2),
# and drift assertion (SC-3 GREEN) but has NO manifest-discovery mechanism —
# it never reads the repository's declared build manifest (root AGENTS.md
# first, `.opencode/AGENTS.md` "Build / Lint / Test Commands" fallback) to
# obtain canonical build/test commands, and it has no MANIFEST_FAIL hard-fail
# for an undiscoverable manifest. Evaluation (clean-room sub-agent over
# session.yaml, per §6a two-SC pattern) is expected to return FAIL against
# SC-4 in the RED phase — the run cannot show the gate reading AGENTS.md build
# commands or a MANIFEST_FAIL because no such step exists.
#
# Fixture: fixtures/setup/2439-sc4-gate-manifest-discovery.sh gives the test
# repo a real .opencode submodule at its pinned SHA (no drift) and a root
# AGENTS.md declaring a "Build / Test Commands" table (the submodule's own
# AGENTS.md carries the fallback section). Loud push failures, stable-path
# bare origins.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2439-sc4-gate-manifest-discovery"
SCENARIO_PROMPT="Create a release for the current commit of this repository: use the release-promoter skill to create an annotated release tag v1.3.0 for the current HEAD commit and push it to origin. The release must be verified before promotion, per the release-promoter skill's own verification gate."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
