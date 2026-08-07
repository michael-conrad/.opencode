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
# RED STATE: completion.md's State Check Phase Step 2 reads `needs-approval` via
# `issue-operations -> read-labels`, which routes to the platform sub-skill. On
# the gitbucket/github platforms, read-labels reads the REMOTE API label as
# primary. A clean-room sub-agent evaluating session.yaml will observe the agent
# reads `needs-approval` from the remote API (gitbucket-api get-labels) rather
# than from the local issue.yaml — so this SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the completion
# routes through read-labels on the gitbucket platform — the path that reads
# `needs-approval` from remote as primary. On the default `local` platform,
# read-labels routes to local read.md which reads issue.yaml, and the test
# would not be RED.
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

# SC-4 RED: wire a GitBucket origin so completion's read-labels routes through
# the gitbucket platform, the path that reads needs-approval from remote as
# primary (the RED state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-4: completion reads needs-approval from local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
