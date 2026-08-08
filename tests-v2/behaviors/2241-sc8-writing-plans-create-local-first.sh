#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc8-writing-plans-create-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: `writing-plans/tasks/create.md` SHALL write `spec-cleared` to local
# `{issues_prefix}/{N}/issue.yaml` as primary canonical source; remote write SHALL
# be best-effort/secondary only.
#
# The agent is given a real-domain plan-creation task that triggers the
# writing-plans create pipeline (create.md). SC-8 requires the `spec-cleared`
# label to be recorded in the local issue.yaml labels array (via
# `local-issues update --labels`) as the primary canonical source. The session.yaml
# (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: create.md Step 9 currently applies the `spec-cleared` label via the
# platform's label API as the primary write for github/gitbucket platforms — it
# writes the label to the REMOTE API as primary and does NOT record it in the
# local issue.yaml as canonical. A clean-room sub-agent evaluating session.yaml
# will observe the agent applies the label via the remote API (gitbucket-api label
# calls) rather than writing it to the local issue.yaml as primary canonical source
# — so this SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the writing-plans
# create Step 9 label write routes through the gitbucket platform's remote label
# API as primary. On the default `local` platform, create.md would not have a remote
# API to write labels to, and the test would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the writing-plans create step for issue #2241 to write the
# plan. The prompt provides the dispatch context (issue_number, project_root,
# issues_prefix) and the fixture setup script seeds the structure artifact and spec
# at .issues/2241/ so the agent passes Entry Criteria and reaches Step 9 — the
# remote-first spec-cleared label write — instead of stalling on missing context.
# The prompt states the GitBucket origin as a real-domain fact (matching the
# SC-3/SC-4/SC-6/SC-7 templates) so the agent routes through the gitbucket
# platform's remote label write (RED path), NOT the local platform's local-issues
# write (which would be GREEN). The prompt does NOT name create.md, spec-cleared,
# or issue.yaml. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc8-writing-plans-create-local-first"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Run the writing-plans create step for issue #2241. The plan has already been generated and written to .issues/2241/plan.md. In this create step, finalize it by applying the spec-cleared label to the spec issue to establish the canonical label state, then report the result."

# SC-8 RED: wire a GitBucket origin so the writing-plans create Step 9 label write
# routes through the gitbucket platform's remote label API as primary (the RED state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-8: writing-plans create writes spec-cleared to local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
