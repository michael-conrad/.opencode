#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc9-read-labels-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: `issue-operations-core/tasks/read-labels.md` SHALL read labels from local
# `{issues_prefix}/{N}/issue.yaml` by default; remote read SHALL be only when
# explicitly requested.
#
# Fixture issue #2241 has `needs-approval` in its local issue.yaml labels array.
# The agent is given a real-domain task that triggers the issue-operations-core
# read-labels path: read the labels for issue #2241. SC-9 requires the agent to
# READ the labels from the LOCAL issue.yaml labels array (via
# `local-issues read-labels`) as the default canonical source. The session.yaml
# (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: read-labels.md Step 2 currently routes to the platform sub-skill and
# reads the REMOTE API label as primary by default. On the gitbucket/github
# platforms, read-labels reads the remote API label. A clean-room sub-agent
# evaluating session.yaml will observe the agent reads the labels from the remote
# API (gitbucket-api get-labels) rather than from the local issue.yaml — so this
# SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the read-labels task
# routes through the gitbucket platform — the path that reads labels from remote
# as primary by default. On the default `local` platform, read-labels routes to
# local read.md which reads issue.yaml, and the test would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: read the labels for the existing fixture issue #2241 on a
# repo whose origin is a GitBucket instance (wired by BEHAVIOR_NEEDS_REMOTE=1).
# The read-labels task (read-labels.md) routes to the platform sub-skill. On the
# gitbucket platform, read-labels reads the labels from the REMOTE API as primary
# by default — the RED path. The prompt states the GitBucket origin as a
# real-domain fact so the agent routes through the gitbucket-api platform
# sub-skill (remote read), NOT the local platform. The prompt does NOT name
# read-labels or issue.yaml. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc9-read-labels-local-first"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Read the labels for issue #2241 and report which authorization labels are present on the issue."

# SC-9 RED: wire a GitBucket origin so read-labels routes through the gitbucket
# platform, the path that reads labels from remote as primary by default (the RED
# state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-9: read-labels reads labels from local issue.yaml by default as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
