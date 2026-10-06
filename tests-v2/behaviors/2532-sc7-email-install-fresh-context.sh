#!/bin/bash
# Behavioral test: 2532-sc7-email-install-fresh-context
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2532 SC-7: a fresh-context agent given only the deck's
# email-management skill executes the install details card on a clean
# location and reaches a verified-working state without writing to any mail
# profile. Evaluation is clean-room over session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2532-sc7-email-install-fresh-context"
SCENARIO_PROMPT="This repository's agent deck has an email skill at .opencode/skills/email-management/. Install the mail tool its details card describes into ./tmp/tools under the project root (a scratch location, not on PATH), following the card's procedure exactly, then verify the installation the way the card specifies and report the verification output. There is no mail profile on this machine and none must be created or modified — the tool must be installed and verified without touching any existing mail profile."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
