#!/bin/bash
# Behavioral test: 2257-sc2-issue-level-label-mutation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (behavioral): Issue-level label mutation behavior is empirically determined:
# POST/PUT/DELETE /repos/{owner}/{repo}/issues/{number}/labels via `gb api` with
# `{"labels":[...]}` either confirmed to apply labels (WORKING) or confirmed to
# return empty/no-op (BROKEN), with `get_issue` label readback evidence after each
# write.
#
# RED state: The documented-BROKEN claim (label-operations.md + API-DEFICIENCIES.md)
# asserts POST/PUT return an empty array `[]` and labels are NOT added. The truth is
# UNCONFIRMED. The agent must empirically probe the live provisioned instance with
# `gb api` against the issue-level labels endpoint, then read back actual label state
# via `gb issue view --json` after each write, and classify the behavior as WORKING
# or BROKEN based on the readback evidence — not from the prior docs.
#
# The session.yaml (SQLite DB export) is the PRIMARY evidence source. A clean-room
# sub-agent evaluates whether the agent executed the POST/PUT/DELETE probes against
# the issue-level labels endpoint via `gb api`, read back label state after each write
# via `gb issue view --json`, and empirically classified the behavior as WORKING or
# BROKEN with readback evidence.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2257-sc2-issue-level-label-mutation"
SCENARIO_PROMPT="A self-contained GitBucket instance is provisioned and running. The environment variables GB_HOST, GB_TOKEN, GB_REPO, and GB_PROTOCOL are already set. Empirically determine whether issue-level label mutation works. First create a test issue with 'gb issue create -R \"\$GB_REPO\" -t \"SC2 label probe\" --body \"probe\"'. Then, using the gb api passthrough command 'gb api', probe the issue-level labels endpoint at 'repos/root/test-repo/issues/<NUMBER>/labels' for these operations against the live instance: (1) POST with body '{\"labels\":[\"sc2-probe\"]}' to add a label, (2) PUT with body '{\"labels\":[\"sc2-replace\"]}' to replace labels, and (3) DELETE to remove labels. After each write, read back the actual label state by running 'gb issue view <NUMBER> -R \"\$GB_REPO\" --json' and inspecting the returned labels field. Empirically classify whether issue-level label mutation is WORKING (labels actually apply/change/remove on readback) or BROKEN (readback shows labels unchanged/empty despite 200 responses), and report which of the three operations work and which do not. Do NOT rely on prior documentation — determine the truth empirically from the live instance and report your readback evidence for each operation."

# SC-2: provision a self-contained GitBucket instance so the agent can
# empirically probe issue-level label mutation against it.
# MUST be exported: with-test-home runs as a child process and gates GB_TOKEN
# propagation on this variable — a non-exported value leaves the model's gb
# with no valid token, causing `gb repo view` to 401.
export BEHAVIOR_NEEDS_REMOTE=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
