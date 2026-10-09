#!/bin/bash
# Behavioral test: 2557-sc17-supervised-polling
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-17: when supervising an `opencode run`, the agent polls at
# intervals of at most 60 seconds; every poll performs a full semantic check
# derived from the run's session DB (message parts, reasoning, tool calls —
# activity/uptime proxies are inadmissible); and every poll's semantic finding
# is reported in the work record as it happens.
#
# DESIGN: the run agent under test launches a NESTED opencode run through the
# harness and supervises it to completion, recording each check-in (time +
# what the nested run was actually doing, read from the nested run's session
# DB) in supervision-log.md. The clean-room evaluator reads the supervisor's
# session.yaml: poll tool calls spaced <=60s apart, each reading the nested
# run's DB, each followed by a reported finding.
#
# PROMPT CONSTRUCTION: real-domain task — launch, supervise, and report on a
# run. Not an interview question.
#
# FIXTURE: none required — the harness checkout inside the test project carries
# tests-v2/with-test-home.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc17-supervised-polling"
SCENARIO_PROMPT="Launch a quick opencode run in the background through the test harness: bash .opencode/tests-v2/with-test-home opencode run \"Answer with exactly one word: coffee or tea?\" --model ollama/qwen3.8:27b-256k-gguf4 --log-level INFO --print-logs — then supervise that run until it finishes. While it runs, check on it at short regular intervals, and every time you check, look at the nested run's session database to see what it is actually doing, then append a line to supervision-log.md with the time and what you found. Keep checking until the run has finished, then tell me the answer it gave and show the log."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_EXPECTED_ARTIFACT="supervision-log.md"
BEHAVIOR_GOAL_ACTIONS="bash,write,edit"
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
