#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2450-sc4-analyze-contract
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (.opencode#2450, plan Item 24, phase-2 RED): a gate-running agent at
# the analyze step (spec-creation analyze task) is dispatched against a fixture
# workspace whose unrelated issues (4210, 4211) carry schema violations while
# the issue under analysis (4299) is clean. The seven analytical artifacts are
# pre-seeded by fixtures/setup/2450-sc4-analyze-contract.sh so the agent
# reaches the Step 5.3 R-13 gate directly.
#
# RED condition (passes-as-defect today): the CURRENT analyze.md R-13 gate
# CONTRACT (Step 5.3 body beyond the invocation, exit criteria, result-contract
# wording) does not yet state the scoped-primary/workspace-secondary
# MUST-NOT-gate clause, so the agent is expected to treat the workspace-wide
# state as progress-gating and BLOCK the pipeline on the unrelated 4210/4211
# violations even though the issue under analysis (4299) is clean.
#
# Evaluation contract (clean-room sub-agent inspection of session.yaml — NOT
# this script): RED = pipeline_blocked true with a blocker tied to the
# unrelated issues' violations; GREEN (after the analyze.md contract update,
# plan Item 25) = pipeline proceeds (not BLOCKED on unrelated violations) with
# the scoped gate recorded and BLOCKED semantics preserved only for the target
# issue's own records.
#
# FIXTURES: reuses the SC-3 fixture issues — 4299-sc3-analyze-target (clean
# target), 4210-sc3-unrelated-a (invalid-yaml), 4211-sc3-unrelated-b
# (schema-violation) under fixtures/issues/; artifact pre-seed via
# fixtures/setup/2450-sc4-analyze-contract.sh (name matches SCENARIO_NAME).
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2450-sc4-analyze-contract.sh
# with the bash tool timeout >= 600000ms (2700000ms used for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2450-sc4-analyze-contract"
# Real-domain dispatch shape: the agent is told which issue it is analyzing,
# that the prior run's artifacts already exist, and to follow the CURRENT
# analyze.md R-13 gate contract — the prompt names no dispatch rule, expected
# verdict, or cardinality; analyze.md governs the gate behavior and the
# proceed/blocked decision.
SCENARIO_PROMPT="You are a sub-agent. Execute the analyze task from the spec-creation skill for issue .#4299 in this project (issue record: .issues/4299/; project_root: the current working directory).

The seven analytical artifacts (Steps 1-5.2 outputs) have already been written to tmp/4299/artifacts/ by a prior interrupted run — do not regenerate or re-derive them; verify they exist and continue from there.

Per the current .opencode/skills/spec-creation/tasks/analyze.md, run the analyze-step R-13 gate for this issue, then decide whether the analyze pipeline can proceed for this issue.

Record the outcome in a short YAML file ./tmp/2450-sc4-verdict.yaml with exactly four keys: gate_command (the exact command executed), gate_exit_code (integer), pipeline_blocked (true/false), blocker_reason (a short string; empty if not blocked). Do not write any other report."

# §14 semantic continuous monitoring — mandatory for behavioral runs.
BEHAVIOR_SEMANTIC_MONITOR=1
# 150 polls x 30s = 4500s monitored budget, inside the mandated bash tool
# timeout (>= 600000ms). Sized for the 27B default model.
BEHAVIOR_MONITOR_MAX_POLLS=150
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# §14 GREEN early termination: the run is complete once the verdict file
# is written (both DONE and BLOCKED paths end in that write).
BEHAVIOR_EXPECTED_ARTIFACT="tmp/2450-sc4-verdict.yaml"
BEHAVIOR_GOAL_ACTIONS="write"
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_GOAL_ACTIONS

# Prompt references .issues/4299/ — fixture issues injected by the harness.
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_FIXTURE_ISSUES

# §1: exit 0 unconditionally after artifact generation.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0
