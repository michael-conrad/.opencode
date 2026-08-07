#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc3-creation-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: `issue-operations-core/tasks/creation.md` SHALL write `needs-approval`
# to local `{issues_prefix}/{N}/issue.yaml` as primary canonical source (via
# `local-issues update --labels`); remote write SHALL be best-effort/secondary only.
#
# The agent is given a real-domain creation task: create a new issue. SC-3
# requires the `needs-approval` label to be recorded in the local issue.yaml
# labels array (via `local-issues update --labels`) as the primary canonical
# source. The session.yaml (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: creation.md currently routes the creation through Step 2.1
# Remote-First for github/gitbucket platforms — it creates the remote issue with
# `needs-approval` as the primary label write and does NOT write the label to the
# local issue.yaml as canonical. A clean-room sub-agent evaluating session.yaml
# will observe the agent does NOT write `needs-approval` into the local issue.yaml
# as the primary canonical source — so this SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the creation routes
# through Step 2.1 Remote-First — the path that currently writes `needs-approval`
# to remote as primary. On the default `local` platform, creation already writes
# local-first and the test would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: create a new issue. This triggers the creation path
# (issue-operations-core -> creation) which follows creation.md's platform-aware
# Step 2.1 Remote-First flow. The prompt does NOT bias toward a local or remote
# write target, and the title does NOT reference "local" — so the agent must
# detect the gitbucket origin and route through creation.md's remote-first path
# where needs-approval is written to remote as primary. Natural behavior, NOT a
# prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc3-creation-local-first"
SCENARIO_PROMPT="Create a new issue titled 'SC-3 label write test'. Follow the issue creation workflow and ensure the needs-approval label is applied to the new issue."

# SC-3 RED: wire a GitBucket origin so the creation routes through Step 2.1
# Remote-First, the path that writes needs-approval to remote as primary (the RED
# state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-3: creation writes needs-approval to local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
