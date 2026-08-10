#!/bin/bash
# Behavioral test: 2254-sc32-functional-spec-creation-pipeline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-32: Dispatching the full spec-creation pipeline (analyze → create → validate)
# against a fixture problem in the shared test home SHALL produce a valid spec with
# no mis-routing, no missing task cards, no broken cross-references, and no
# deprecated dispatch strings. Evidence type: behavioral.
#
# The test dispatches the remediated spec-creation pipeline end-to-end against a
# bound fixture issue (#2270) in the shared test home, wired to the test gitbucket
# instance (BEHAVIOR_NEEDS_REMOTE=1, BEHAVIOR_SHARED_HOME=1). The session.yaml
# (SQLite DB export) is the PRIMARY evidence source — a clean-room sub-agent reads
# it and judges whether the agent routed analyze → create → validate through the
# canonical task cards (no mis-routing, no missing task cards, no broken
# cross-references, no deprecated `execute X from Y` dispatch strings) and produced
# a valid spec.
#
# BEHAVIOR_SHARED_HOME must be exported so behavior_run → with-test-home reuse the
# persistent test-home-shared across invocations (SC-34 incremental sequencing).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2254-sc32-functional-spec-creation-pipeline"
SCENARIO_PROMPT="This repository's origin is a GitBucket instance (GB_HOST and GB_TOKEN are set). Create a spec for issue #2270 through the spec-creation pipeline. Issue #2270 is titled '[SPEC] Add a --validate-only flag to the opencode run command' and its record is at .issues/2270/issue.yaml. Run the full pipeline end-to-end: analyze (pre-spec inspection, requirements extraction, decomposition, analytical artifacts), create (assemble the spec, create the remote [SPEC] issue stub on the GitBucket origin, write the full spec to the remote issue body, write the local spec to .issues/2270/spec.md), then validate (run the holistic self-check and structural validation). Report the result contract of each step and the final spec_path and issue_url."

# SC-32: wire a GitBucket origin (test repo as origin) and reuse the shared test
# home so the pipeline's remote issue stub creation and post-push reconciliation
# run against a real remote API.
export BEHAVIOR_NEEDS_REMOTE=1
export BEHAVIOR_SHARED_HOME=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
