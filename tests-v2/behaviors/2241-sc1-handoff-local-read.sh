#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc1-handoff-local-read
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: `writing-plans/tasks/handoff.md` SHALL read authorization from local
# `{issues_prefix}/{N}/issue.yaml` instead of calling
# `approval-gate --task verify-authorization` (which reads remote labels).
#
# The agent is given a real-domain plan-creation task that triggers the
# writing-plans handoff step (handoff.md). SC-1 requires the agent to READ the
# authorization label (`approved-for-*`) from the LOCAL issue.yaml labels array
# (via `local-issues read-labels`) as the primary canonical source. The session.yaml
# (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: handoff.md Step 2 currently verifies authorization via
# `approval-gate --task verify-authorization`, which routes to the approval-gate
# skill and reads the REMOTE API label as primary. A clean-room sub-agent evaluating
# session.yaml will observe the agent dispatches the approval-gate skill (or reads
# the remote label) rather than reading the authorization label from the local
# issue.yaml — so this SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the handoff Step 2
# authorization check routes through the approval-gate skill on the gitbucket
# platform — the path that reads the label from remote as primary. On the default
# `local` platform, handoff would not have a remote API to read labels from, and
# the test would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the writing-plans handoff step for issue #2241 to verify
# authorization before the plan creation pipeline begins. The prompt provides the
# dispatch context (issue_number, project_root, issues_prefix) and the fixture
# setup script seeds the spec and a local issue.yaml carrying `approved-for-plan`
# at .issues/2241/ so the agent passes Entry Criteria and reaches Step 2 — the
# authorization verification — instead of stalling on missing context. The prompt
# states the GitBucket origin as a real-domain fact (matching the SC-3/SC-4/SC-6/
# SC-7/SC-8 templates) so the agent routes through the approval-gate skill's
# remote label read (RED path), NOT the local platform's local-issues read (which
# would be GREEN). The prompt does NOT name handoff.md, verify-authorization, or
# issue.yaml. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc1-handoff-local-read"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Run the writing-plans handoff step for issue #2241. The spec exists at .issues/2241/spec.md. In this handoff step, verify that issue #2241 is authorized for plan creation before the plan creation pipeline begins, then report the authorization status."

# SC-1 RED: wire a GitBucket origin so the handoff Step 2 authorization check
# routes through the approval-gate skill, the path that reads the label from
# remote as primary (the RED state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-1: handoff reads authorization from local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
