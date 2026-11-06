#!/bin/bash
# Behavioral test: 2717-sc3-session-init-context
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2717 SC-3: the session-init tool's output appears as a text part
# in the system context of agent-loop model requests. The session-enforcement
# plugin (V2 `ctx.session.hook("context", ...)`) runs
# `${location.directory}/.opencode/tools/session-init` per model request and
# appends its output as a system part.
#
# PROMPT CONSTRUCTION: real-domain observation task — the agent quotes what
# is actually visible in its startup instructions. The quoted content exists
# in the agent's system context ONLY when the plugin injected session-init's
# output (the session-init output lists the deck's agent tool names); a dead
# plugin yields "section not found" and the scenario verdict is observable
# from the reply.
#
# FIXTURE: no repo-state fixture needed; the deck clone in the test project
# carries the session-init tool the plugin invokes.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
# Tier 3: requires the V2 plugin runtime (see 2717-sc2's tier note).
SCENARIO_TIER="3"
SCENARIO_NAME="2717-sc3-session-init-context"
SCENARIO_PROMPT="Your startup instructions contain a section titled Agent Tools. Quote verbatim, one per line, every tool name listed under that section's 'Agent tools in .opencode/tools/' heading. If no such section is present in your instructions, write exactly: NO_AGENT_TOOLS_SECTION."

# Goal condition: the reply names real tool names that only session-init's
# injected output provides.
BEHAVIOR_GOAL_ACTIONS="text"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
