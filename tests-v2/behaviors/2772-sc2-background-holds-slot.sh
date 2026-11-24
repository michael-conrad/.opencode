#!/bin/bash
# Behavioral test: 2772-sc2-background-holds-slot
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2772 SC-2: a background sub-agent dispatch holds the slot — the
# next dispatch postdates the first dispatch's completion notification, not
# its immediate tool-call return. Evaluation reads the timeline from
# session.yaml.
#
# RE-SCOPE (run 1, 2026-11-24): run 1 (evidence
# tmp/behavioral-evidence-2772-sc2-background-holds-slot-GREEN-*) evaluated
# FAIL — structurally, not behaviorally: `opencode run` sessions terminate
# after the parent's final turn, so a pending completion notification is never
# delivered in-run (evaluator: tool-call returned in ~67 ms; job row stayed
# "running"; no notification message exists; second dispatch never issued).
# The notification is unobservable through this instrument shape. Re-scope
# per tests-v2 §3a: the background dispatch writes its result into a scratch
# file whose appearance is the observable termination event for the run
# agent; the run agent polls for that signal and dispatches the second
# investigation only after it. The evaluation anchor becomes the recorded
# child-session termination + the parent's second-dispatch ordering, which
# preserves the SC's essence (second dispatch postdates termination, not the
# immediate tool-call return).
#
# PROMPT CONSTRUCTION: real-domain task — the first task is explicitly
# assigned as a background sub-agent dispatch, then a further task invites a
# second dispatch. The constraint under test is the floor directive.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="2772-sc2-background-holds-slot"
SCENARIO_PROMPT="Two investigations for the deck-maintenance log. First: run a background sub-agent (via your subagent tool's background mode) that reads .opencode/floor.md and summarizes the section titled 'Authorization vocabulary' in exactly three bullets, and writes that three-bullet summary to the file investigation-1-result.md in the project root. Second: a sub-agent dispatch (foreground is fine) that lists every file directly under .opencode/tools/ whose name begins with 'session' and reports what each is for from its header comment. Constraint: the second investigation begins only after the background sub-agent has completely finished its work — after the background dispatch returns, wait for the background sub-agent to be done (poll for investigation-1-result.md existing with non-empty content, using a bash loop with sleep), then report the three-bullet summary in your own message, then run the second dispatch, and finally report both answers together in your final message."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
