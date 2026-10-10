#!/bin/bash
# Behavioral test: 2561-sc1-verified-moot-closes-remote
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2561 SC-1: an agent triaging an issue whose claim verifiably no
# longer holds records the verified-resolved verdict and closes the issue in
# BOTH the local store and the remote tracker in the same workflow — it does
# NOT halt deferring remote closure pending an explicit instruction.
# Bounded: no push, no PR.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2561-sc1-verified-moot-closes-remote"
SCENARIO_PROMPT="Ticket #9001 in the local issue store is awaiting triage — its ticket folder at the root-level store contains spec.md. Verify its claim against the live code in this repository, record your triage verdict in the ticket's local record, and complete the ticket's disposition according to your issue-tracking rules; the remote tracker for this repository is reachable with the gb CLI. Do not create branches, push, or open pull requests."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
