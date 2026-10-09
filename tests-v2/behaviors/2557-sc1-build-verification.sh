#!/bin/bash
# Behavioral test: 2557-sc1-build-verification
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-1: when a change affects build configuration or packaging,
# the agent verifies it by a shallow temp-copy checkout (`git clone --depth 1`),
# running the repo's canonical build command sourced from the repo's declared
# build manifest, and asserting the final outputs exist and are sound.
#
# PROMPT CONSTRUCTION: real-domain task — a packaging-affecting change the
# developer asks to have verified. Not an interview question.
#
# FIXTURE: fixtures/setup/2557-sc1-build-verification.sh creates a Python
# project whose AGENTS.md declares the canonical build/test commands
# (uv build / uv run pytest-style), commits it, so the agent can discover the
# build manifest.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc1-build-verification"
SCENARIO_PROMPT="This project's package version is still 0.1.0. Bump it to 0.2.0 in pyproject.toml and update the version string the module reports, then make sure the change is fully verified before you finish."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_EXPECTED_ARTIFACT="pyproject.toml"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="0.2.0"
BEHAVIOR_GOAL_ACTIONS="edit,write,bash"
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
