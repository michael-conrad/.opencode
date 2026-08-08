#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc6-spec-creation-create-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: `spec-creation/tasks/create.md` SHALL write labels to local
# `{issues_prefix}/{N}/issue.yaml` as primary canonical source; remote write SHALL
# be best-effort/secondary only.
#
# The agent is given a real-domain spec-creation task that triggers the
# spec-creation create pipeline (create.md). SC-6 requires the `needs-approval`
# and `spec-draft` labels to be recorded in the local issue.yaml labels array (via
# `local-issues update --labels`) as the primary canonical source. The session.yaml
# (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: create.md currently routes label writes through Step 3 (remote issue
# stub with `needs-approval`) and Step 3.1 (remote `spec-draft` label) for
# github/gitbucket platforms — it writes the labels to the REMOTE API as primary
# and does NOT record them in the local issue.yaml as canonical. A clean-room
# sub-agent evaluating session.yaml will observe the agent writes labels to the
# remote API (gitbucket-api label calls) rather than to the local issue.yaml as
# primary canonical source — so this SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the spec-creation
# create path routes through create.md's remote-first Step 3/Step 3.1 — the path
# that currently writes labels to remote as primary. On the default `local`
# platform, create.md would not have a remote to write labels to, and the test
# would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: execute the spec-creation create task. This routes through
# spec-creation/tasks/create.md which follows create.md's Step 3 remote-first flow
# for the gitbucket origin — writing the needs-approval and spec-draft labels to
# the REMOTE API as primary. The prompt does NOT bias toward a local or remote write
# target, and does NOT name create.md or issue.yaml — so the agent must detect the
# gitbucket origin and route through create.md's remote-first path where labels are
# written to remote as primary. Natural behavior, NOT a prose-recall interview.
# The prompt targets the create stage directly (not the full explore->analyze->create
# pipeline) so the model reaches the label-write stage within the harness timeout.
# It provides the create task's required dispatch context (issue_number,
# analysis_artifact_path) and the fixture setup script seeds the analysis artifacts at
# tmp/2241/artifacts/ so the agent passes Entry Criteria and reaches Step 3/Step 3.1 —
# the remote-first label write — instead of stalling on missing context. The prompt
# states the GitBucket origin as a real-domain fact (matching the SC-4 template) so
# the agent routes through the gitbucket platform's remote label write (RED path),
# NOT the local platform's local-issues write (which would be GREEN).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc6-spec-creation-create-local-first"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Run the spec-creation create step for issue #2241 to register the spec. In this create step, create the remote spec issue (with the [SPEC] prefix) and apply the needs-approval and spec-draft labels to establish the canonical label state, then report the result."

# SC-6 RED: wire a GitBucket origin so the spec-creation create path routes through
# create.md Step 3/Step 3.1 Remote-First, the path that writes labels to remote as
# primary (the RED state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-6: spec-creation create writes labels to local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
