#!/bin/bash
# Behavioral test: 982-sc1-local-creation-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Agent dispatches a local-issue creation request through
# issue-operations -> local platform -> creation.md, not inline.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="982-sc1-local-creation-dispatch"
# The standard issue reference format triggers the issue-operations skill.
# github.platform == local means dispatcher routes to local sub-skill.
# Phase 2 prompt: explicit reference to the local platform sub-skill because the
# issue-operations dispatcher doesn't auto-route github.platform==local yet
# (Phase 3 of #983 fixes the dispatcher routing).
SCENARIO_PROMPT="file a bug against platform#1 with the title 'test bug report'. use the local platform sub-skill of issue-operations. the platform is local."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0