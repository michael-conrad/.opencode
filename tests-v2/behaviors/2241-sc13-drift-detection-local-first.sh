#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc13-drift-detection-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13: `audit/tasks/drift-detection-investigator.md` SHALL read labels from local
# `{issues_prefix}/{N}/issue.yaml` as primary; remote read SHALL be fallback only.
#
# The agent is given a real-domain task that triggers the audit drift-detection
# chain (drift-detection-investigator). SC-13 requires the agent to READ the labels
# for issue #2241 from the LOCAL issue.yaml labels array (via `local-issues
# read-labels`) as the primary canonical source, with remote read only as a
# fallback. The session.yaml (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: drift-detection-investigator.md Metadata Verification Extension
# currently reads labels via `github_issue_read(method=get_labels)` — the REMOTE
# API — as primary. A clean-room sub-agent evaluating session.yaml will observe the
# agent reads the labels from the remote API (gitbucket-api get-labels) rather than
# from the local issue.yaml — so this SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the drift-detection
# investigator's label read routes through the gitbucket platform — the path that
# reads labels from remote as primary by default. On the default `local` platform,
# the label read would route to local read.md which reads issue.yaml, and the test
# would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the audit drift-detection chain for the existing fixture
# issue #2241 on a repo whose origin is a GitBucket instance (wired by
# BEHAVIOR_NEEDS_REMOTE=1). The drift-detection-investigator task reads labels via
# `github_issue_read(method=get_labels)` — the REMOTE API — as primary by default
# (the RED path). The prompt states the GitBucket origin as a real-domain fact so
# the agent routes through the gitbucket-api platform sub-skill (remote read), NOT
# the local platform. The prompt does NOT name drift-detection-investigator.md,
# read-labels, or issue.yaml. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc13-drift-detection-local-first"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Run the audit drift-detection chain for issue #2241. The spec exists at .issues/2241/spec.md. In the drift-detection investigator step, collect the raw evidence about documentation-code drift for issue #2241, including verifying the issue's labels against the actual issue state. Report the gathered evidence including which authorization labels are present on the issue."

# SC-13 RED: wire a GitBucket origin so the drift-detection investigator's label
# read routes through the gitbucket platform, the path that reads labels from
# remote as primary by default (the RED state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-13: drift-detection-investigator reads labels from local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
