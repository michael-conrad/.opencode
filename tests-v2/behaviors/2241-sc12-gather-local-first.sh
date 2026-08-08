#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc12-gather-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12: `issue-review/tasks/gather.md` SHALL read labels from local
# `{issues_prefix}/{N}/issue.yaml` as primary; remote read SHALL be fallback only.
#
# The agent is given a real-domain task that triggers the issue-review gather
# pipeline. SC-12 requires the agent to READ the labels for issue #2241 from the
# LOCAL issue.yaml labels array (via `local-issues read-labels`) as the primary
# canonical source, with remote read only as a fallback. The session.yaml (SQLite
# DB export) is the PRIMARY evidence source.
#
# RED STATE: gather.md Step 3 currently reads labels via
# `issue-operations -> read-labels`, which routes to the platform sub-skill and
# reads the REMOTE API label as primary by default. On the gitbucket/github
# platforms, read-labels reads the remote API label. A clean-room sub-agent
# evaluating session.yaml will observe the agent reads the labels from the remote
# API (gitbucket-api get-labels) rather than from the local issue.yaml — so this
# SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the gather Step 3 label
# read routes through the gitbucket platform — the path that reads labels from
# remote as primary by default. On the default `local` platform, read-labels
# routes to local read.md which reads issue.yaml, and the test would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the issue-review gather step for the existing fixture
# issue #2241 on a repo whose origin is a GitBucket instance (wired by
# BEHAVIOR_NEEDS_REMOTE=1). The gather task (gather.md) Step 3 reads labels via
# issue-operations -> read-labels, which routes to the platform sub-skill. On the
# gitbucket platform, read-labels reads the labels from the REMOTE API as primary
# by default — the RED path. The prompt states the GitBucket origin as a
# real-domain fact so the agent routes through the gitbucket-api platform
# sub-skill (remote read), NOT the local platform. The prompt does NOT name
# gather.md, read-labels, or issue.yaml. Natural behavior, NOT a prose-recall
# interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc12-gather-local-first"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Run the issue-review gather step for issue #2241 to collect all issue data needed for triage, including the issue body, all comments, the labels, and the authorization status. Report the gathered data including which authorization labels are present on the issue."

# SC-12 RED: wire a GitBucket origin so the gather Step 3 label read routes
# through the gitbucket platform, the path that reads labels from remote as
# primary by default (the RED state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-12: gather reads labels from local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
