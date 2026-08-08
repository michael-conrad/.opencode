#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2241-sc7-analyze-and-spec-local-first
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: `issue-review/tasks/analyze-and-spec.md` SHALL write labels to local
# `{issues_prefix}/{N}/issue.yaml` as primary canonical source; remote write SHALL
# be best-effort/secondary only.
#
# The agent is given a real-domain bug-analysis task that triggers the
# issue-review analyze-and-spec pipeline. SC-7 requires the fix spec's labels
# (e.g., `spec-draft`, `needs-approval`) to be recorded in the local issue.yaml
# labels array (via `local-issues update --labels`) as the primary canonical
# source. The session.yaml (SQLite DB export) is the PRIMARY evidence source.
#
# RED STATE: analyze-and-spec.md Step 6.1 currently applies the `spec-draft` label
# via the platform's label API as the primary write for github/gitbucket platforms
# — it writes the label to the REMOTE API as primary and does NOT record it in the
# local issue.yaml as canonical. A clean-room sub-agent evaluating session.yaml
# will observe the agent applies the label via the remote API (gitbucket-api label
# calls) rather than writing it to the local issue.yaml as primary canonical source
# — so this SC FAILS.
#
# A gitbucket origin is wired (BEHAVIOR_NEEDS_REMOTE=1) so the analyze-and-spec
# Step 6.1 label write routes through the gitbucket platform's remote label API as
# primary. On the default `local` platform, analyze-and-spec would not have a remote
# API to write labels to, and the test would not be RED.
#
# PROMPT CONSTRUCTION:
# Real-domain task: run the issue-review analyze-and-spec step for a bug report.
# The prompt provides the gathered bug-report data inline (issue #2249, bug label,
# body describing a crash) so the agent reaches the analyze-and-spec Step 6.1 label
# write directly — it does NOT need to run the remote `gather` step (which would
# stall on GitBucket auth). The prompt states the GitBucket origin as a real-domain
# fact (matching the SC-3/SC-4/SC-6 templates) so the agent routes through the
# gitbucket platform's remote label write (RED path), NOT the local platform's
# local-issues write (which would be GREEN). The prompt does NOT name
# analyze-and-spec.md, spec-draft, or issue.yaml. Natural behavior, NOT a
# prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2241-sc7-analyze-and-spec-local-first"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Run the issue-review analyze-and-spec step for bug report issue #2249. The gathered data is: issue #2249 titled 'Bug: analyze-and-spec crashes when issue has no reproduction steps', labeled 'bug', body describes a crash with steps to reproduce and expected vs actual behavior. In this step, create the fix spec sub-issue on the GitBucket remote (with the [SPEC] Fix: prefix) and apply the spec-draft label to the fix spec via the remote label API to establish the canonical label state, then report the result."

# SC-7 RED: wire a GitBucket origin so the analyze-and-spec label write routes
# through Step 6.1 Remote-First, the path that writes labels to remote as primary
# (the RED state).
BEHAVIOR_NEEDS_REMOTE=1

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-7: analyze-and-spec writes labels to local issue.yaml as primary canonical source"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
