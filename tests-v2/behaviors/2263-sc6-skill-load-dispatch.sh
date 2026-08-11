#!/bin/bash
# Behavioral test: 2263-sc6-skill-load-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (behavioral): The self-contradiction is eliminated — no affected file
# contains both the "never inline" absolute and inline-designated tasks without
# reconciliation. The orchestrator can load a skill and dispatch without
# reconciling contradictory signals. This test asserts the orchestrator loads a
# skill card and dispatches a task without triggering a contradiction between
# the re-scoped allocation-by-context-cost rule and the skill card's inline
# designations.
#
# The prompt triggers the orchestrator to load a DISPATCH_GATE skill card and
# dispatch its canonical task. The session.yaml (SQLite DB export) is the
# PRIMARY evidence source. A clean-room sub-agent evaluates whether the
# orchestrator dispatched via a canonical string without reconciling a
# "never inline" absolute.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2263-sc6-skill-load-dispatch"
SCENARIO_PROMPT="Check the authorization scope for issue #2263. Load the approval-gate skill and run its resolve-scope task, then apply the approval label."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
