#!/bin/bash
# Behavioral test: 1188-sc3-already-implemented-closure-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests SC-3 from spec #1188: multi-issue authorization set with an
# already-implemented issue → agent routes to correct closure path.
#
# PROMPT CONSTRUCTION: Real-domain task — "approved #1188 to PR" triggers
# the verify-authorization chain which includes reconcile-status. The spec
# is already implemented (the reconcile-status.md changes are live), so the
# agent should detect the already-implemented state and route to autoclose.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1188-sc3-already-implemented-closure-routing"
SCENARIO_PROMPT="approved #1188 to PR. The spec is at .issues/1188/spec.md. The changes to reconcile-status.md have already been implemented and are live in the codebase. Read the spec first, then check if the issue is already implemented."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
