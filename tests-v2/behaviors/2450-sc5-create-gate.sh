#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2450-sc5-create-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (.opencode#2450, plan Item 30, phase-2 RED): a gate-running agent at the
# create step (spec-creation create task) is dispatched against a fixture
# workspace whose unrelated issues (4210, 4211) carry schema violations while
# the issue being created (4299) is clean.
#
# RED condition (passes-as-defect today): the CURRENT create.md Step 6.1
# mandates the UNSCOPED workspace-wide `validate-yaml` over the affected repos
# as the progress gate, so session.yaml is expected to show the agent executing
# the unscoped workspace-wide invocation and BLOCKING the create pipeline on
# the unrelated 4210/4211 violations even though 4299's records are clean.
#
# Evaluation contract (clean-room sub-agent inspection of session.yaml — NOT
# this script): RED = unscoped workspace-wide validate-yaml invocation executed
# as the gate command with pipeline_blocked true and a blocker tied to the
# unrelated issues' violations; GREEN (after the create.md Step 6.1 update,
# plan Item 31) = the scoped `validate-yaml --number <repo>#4299` invocation
# with pipeline proceeding (not BLOCKED on unrelated violations), BLOCKED
# semantics preserved only for the target issue's own records.
#
# FIXTURES: reuses the SC-3/SC-4 fixture issues — 4299 (clean target), 4210
# (invalid-yaml), 4211 (schema-violation) under fixtures/issues/. No setup
# fixture is needed: the prompt directs the agent to run the Step 6.1 gate
# directly (no artifact pre-seed required at the create-step gate).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2450-sc5-create-gate.sh
# with the bash tool timeout >= 600000ms (2700000ms used for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2450-sc5-create-gate"
# Real-domain dispatch shape: the agent is told which issue it is creating the
# spec for and to follow the CURRENT create.md Step 6.1 progress gate — the
# prompt names no dispatch rule, expected verdict, or cardinality; create.md
# Step 6.1 governs the gate behavior and the proceed/blocked decision.
SCENARIO_PROMPT="You are a sub-agent. Execute the create task from the spec-creation skill for issue .#4299 in this project (issue record: .issues/4299/; project_root: the current working directory).

The spec content and local artifacts for this issue have already been written by prior steps — do not regenerate or rewrite them.

Per the CURRENT .opencode/skills/spec-creation/tasks/create.md, run the Step 6.1 validate-yaml progress gate for this issue, then decide whether the create pipeline can proceed for this issue.

Record the outcome in a short YAML file ./tmp/2450-sc5-verdict.yaml with exactly four keys: gate_command (the exact command executed), gate_exit_code (integer), pipeline_blocked (true/false), blocker_reason (a short string; empty if not blocked). Do not write any other report."

# §14 semantic continuous monitoring — mandatory for behavioral runs.
BEHAVIOR_SEMANTIC_MONITOR=1
# 150 polls x 30s = 4500s monitored budget, inside the mandated bash tool
# timeout (>= 600000ms). Sized for the 27B default model.
BEHAVIOR_MONITOR_MAX_POLLS=150
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# §14 GREEN early termination: the run is complete once the verdict file
# is written (both DONE and BLOCKED paths end in that write).
BEHAVIOR_EXPECTED_ARTIFACT="tmp/2450-sc5-verdict.yaml"
BEHAVIOR_GOAL_ACTIONS="write"
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_GOAL_ACTIONS

# Prompt references .issues/4299/ — fixture issues injected by the harness.
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_FIXTURE_ISSUES

# §1: exit 0 unconditionally after artifact generation.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0
