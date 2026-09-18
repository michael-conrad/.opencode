#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2450-sc3-analyze-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (.opencode#2450, plan Items 18-20, phase-2 RED): a gate-running agent at
# the analyze step (spec-creation analyze task) is dispatched against a fixture
# workspace whose unrelated issues (4210, 4211) carry schema violations while
# the issue under analysis (4299) is clean. The seven analytical artifacts are
# pre-seeded by fixtures/setup/2450-sc3-analyze-gate.sh so the agent reaches
# the Step 5.3 validate-yaml gate directly.
#
# RED condition (passes-as-defect today): the CURRENT analyze.md Step 5.3
# mandates the UNSCOPED workspace-wide `validate-yaml` as the gate command, so
# session.yaml is expected to show the agent executing the unscoped
# workspace-wide `./.opencode/tools/local-issues validate-yaml` and BLOCKING on
# the unrelated 4210/4211 violations.
#
# Evaluation contract (clean-room sub-agent inspection of session.yaml — NOT
# this script): RED = unscoped workspace-wide validate-yaml invocation executed
# as the gate command; GREEN (after the analyze.md Step 5.3 update) = the
# scoped `validate-yaml --number <repo>#4299` invocation executed as the gate
# action amid unrelated violations.
#
# FIXTURES: issues 4299 (clean target), 4210 (invalid-yaml), 4211
# (schema-violation) under fixtures/issues/; artifact pre-seed via
# fixtures/setup/2450-sc3-analyze-gate.sh (name matches SCENARIO_NAME).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2450-sc3-analyze-gate.sh
# with the bash tool timeout >= 600000ms (2700000ms used for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2450-sc3-analyze-gate"
# Real-domain dispatch shape: the agent is told which task to execute, where
# the prior run's artifacts are, and the exact gate command form from the
# CURRENT analyze.md Step 5.3 — the prompt is direct and bounded (§17/R-18
# remediation for the reconnaissance-loop defect) but names no dispatch rule,
# expected verdict, or cardinality; analyze.md Step 5.3 governs the gate
# behavior.
SCENARIO_PROMPT="You are a sub-agent. Execute the analyze task from the spec-creation skill for issue 4299 in this project (issue record: .issues/4299/; project_root: the current working directory).

The seven analytical artifacts (Steps 1-5.2 outputs) have already been written to tmp/4299/artifacts/ by a prior interrupted run — do not regenerate or re-derive them; verify they exist and continue from there.

Per analyze.md Step 5.3, run the validate-yaml gate by executing:

  ./.opencode/tools/local-issues validate-yaml

Record the command and its exit code, then complete the remaining analyze task steps and write the analyze result contract to tmp/4299/artifacts/analyze-result.yaml. Report the gate result (exit code and, if it failed, the malformed-file report lines) in the result contract."

# §14 semantic continuous monitoring — mandatory for behavioral runs.
BEHAVIOR_SEMANTIC_MONITOR=1
# 150 polls x 30s = 4500s monitored budget, inside the mandated bash tool
# timeout (>= 600000ms). Sized for the 27B default model.
BEHAVIOR_MONITOR_MAX_POLLS=150
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# §14 GREEN early termination: the run is complete once the analyze result
# contract is written (both DONE and BLOCKED paths end in that write).
BEHAVIOR_EXPECTED_ARTIFACT="tmp/4299/artifacts/analyze-result.yaml"
BEHAVIOR_GOAL_ACTIONS="write"
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_GOAL_ACTIONS

# Prompt references .issues/4299/ — fixture issues injected by the harness.
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_FIXTURE_ISSUES

# §1: exit 0 unconditionally after artifact generation.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0
