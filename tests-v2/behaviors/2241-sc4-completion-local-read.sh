#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc4-completion-local-read
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: `issue-operations-core/tasks/completion.md` SHALL read `needs-approval`
# from local `{issues_prefix}/{N}/issue.yaml` as primary canonical source; remote
# write SHALL be best-effort/secondary only.
#
# Fixture issue #2241 has `needs-approval` in its local issue.yaml labels array.
# The agent is given a real-domain completion task that triggers the
# issue-operations-core completion path (State Check Phase -> Labels applied).
# SC-4 requires the agent to READ the `needs-approval` label from the LOCAL
# issue.yaml labels array as the primary canonical source. The session.yaml
# (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: completion.md currently reads `needs-approval` via
# `issue-operations -> read-labels`, which reads the REMOTE API label as primary.
# A clean-room sub-agent evaluating session.yaml will observe the agent reads
# `needs-approval` from the remote (read-labels) rather than from the local
# issue.yaml — so this SC FAILS.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the completion workflow for issue #2241 and verify its
# authorization state by checking the `needs-approval` label. This triggers the
# completion path (issue-operations-core -> completion.md) which follows the
# State Check Phase -> read-labels flow. The prompt does NOT bias toward a local
# or remote read target — the agent must detect the canonical source. Natural
# behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc4-completion-local-read"
SCENARIO_PROMPT="Run the completion workflow for issue #2241. As part of the state check phase, verify whether the needs-approval label is present to determine the issue's authorization state before completing the workflow."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-4: completion reads needs-approval from local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
