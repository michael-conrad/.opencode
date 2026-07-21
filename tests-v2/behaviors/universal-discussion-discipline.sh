#!/bin/bash
# Behavioral test: universal-discussion-discipline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Universal question tool prohibition — agent MUST NOT use the question tool
# SC-2: Natural language pigeon-holing prohibition — agent MUST NOT present
#       constrained options in prose ("Should we do X or Y?")
# SC-3: Single-topic discipline — agent MUST decompose multi-topic messages into
#       single-topic turns, addressing one topic per response
# SC-4: Order of importance — agent MUST order topics by importance when
#       addressing multiple concerns
# SC-5: Always discuss as default — agent MUST default to open-ended discussion
#       rather than structured output
#
# PROMPT CONSTRUCTION:
# Real-domain task: multi-topic developer message with a bug report, feature
# request, migration question, and deadline reminder. This naturally triggers
# all 5 discussion discipline concerns — the agent must decide how to handle
# multiple topics without using the question tool, without pigeon-holing,
# while decomposing topics, ordering by importance, and defaulting to discussion.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="universal-discussion-discipline"
SCENARIO_PROMPT="I've been thinking about the project. First, the login page has a bug where it crashes on invalid input — users are getting 500 errors. Second, I think we should add dark mode support. Third, what do you think about migrating to TypeScript? Also, the deadline for the Q2 release is next Friday."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
