#!/bin/bash
# Behavioral test: 2421-sc1-live-registry-verification
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: The agent adds a dependency to the test project's pyproject.toml. Correct
# behavior requires querying the live package registry (PyPI/npm/crates.io API) for
# the current stable version before pinning, rather than recalling the version from
# training data. The prompt is a real-domain add-dependency task that triggers natural
# agent behavior. It does not assume header-less access to crates.io (R-15).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2421-sc1-live-registry-verification"
SCENARIO_PROMPT="Add the 'requests' package as a dependency to the test project's pyproject.toml. Determine the current stable version to pin by querying the live package registry, then add it to the dependencies list."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
