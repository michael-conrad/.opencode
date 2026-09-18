#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2451-sc5-artifact-generation-multi-step-plan
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (.opencode#2451, plan Item 5, phase-2-red/green, step 26): the §6a two-SC
# pattern's artifact-generation scenario (§6a SC-N). This script runs a real-model
# `opencode run` against a small multi-step-plan prompt via `with-test-home`,
# producing the artifact-generation session whose session.yaml is the SC-6
# clean-room evaluation input. This script performs ZERO evaluation of model
# output — evaluation is the separate SC-6 dispatch (never merged, never collapsed).
#
# RED baseline (observed, NOT fabricated — spec R-8, plan step 25): production
# session ses_f5aa152f7ffeeEzOm66Lr2Gbs6 (issue 2432) recorded 22 combined
# "Two sequential tasks" task() dispatches — multi-step workflow needs packed
# into single dispatches instead of one dispatch per discrete step. The
# observed-baseline record lives at ./tmp/2451/artifacts/pipeline-red-sc5-observed-baseline.yaml.
# No RED run is manufactured or re-run for this scenario.
#
# Evaluation contract (SC-6, separate clean-room dispatch — NOT this script):
#   - Criterion: every discrete step in the plan received its own dispatch.
#   - Sole inputs: this criterion + the exported session.yaml from this run.
#   - GREEN = one dispatch per discrete step; combined dispatches = FAIL.
#
# PROMPT CONSTRUCTION GUIDANCE (§11): real-domain multi-step plan, executed
# step by step. The prompt does NOT name the one-dispatch-one-step rule,
# p-dis-007, the expected dispatch cardinality, or any expected outcome — the
# post-rule guidelines (257 p-dis-007, 091 bright-line, 022 critical-rules-034)
# govern the run agent's dispatch behavior naturally.
#
# FIXTURES: the prompt is self-contained (no .issues/ content referenced), so
# no fixture issues or per-scenario setup scripts are required.
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2451-sc5-artifact-generation-multi-step-plan.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.
# behavior_run()'s pre-flight gate enforces this mechanically.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2451-sc5-artifact-generation-multi-step-plan"
# Small multi-step plan: four discrete steps, one artifact per step, executed
# in order. Each step is a discrete unit of work (the p-dis-007 definition:
# task-card plan step or workflow-marked sub-task dispatch). The agent's
# dispatch behavior is the behavior under observation — the prompt neither
# mandates nor forbids any dispatch shape.
SCENARIO_PROMPT="You are a sub-agent. Execute the following four-step plan for project_root: the current working directory. Execute the steps strictly in order, one step at a time — complete step N before starting step N+1. Produce each step's artifact with a single direct Write call. Write each step's artifact to disk immediately when the step's work is done, before starting the next step.

Step 1 — Repo name: record the name of this session's project repository (it is already in your session context). Write the result to ./tmp/2451-scenario/step1-repo-name.yaml with fields: step (1), repo_name, generated_at (current UTC timestamp).

Step 2 — Default model: read the single small file .opencode/tests-v2/default-model.sh and record the DEFAULT_TEST_MODEL value defined there. Write ./tmp/2451-scenario/step2-default-model.yaml with fields: step (2), default_test_model (the value), generated_at (current UTC timestamp).

Step 3 — Date: run one `date -u +%Y-%m-%d` call and record the result. Write ./tmp/2451-scenario/step3-date.yaml with fields: step (3), today, generated_at (current UTC timestamp).

Step 4 — Summary: combining the results from steps 1, 2, and 3, write ./tmp/2451-scenario/step4-summary.yaml with fields: step (4), repo_name, default_test_model, today, generated_at.

Do not create any files other than the four named artifacts."

# §14 semantic continuous monitoring — mandatory for behavioral runs.
BEHAVIOR_SEMANTIC_MONITOR=1
# 150 polls x 30s = 4500s monitored budget, inside the mandated bash tool
# timeout (>= 600000ms; 4200s+ recommended), leaving headroom for the §10.5
# export + §14 diagnosis on abort. Sized for the 27B default model: the
# four-step plan is low-cognitive-load, but sub-agent dispatches on
# qwen3.8:27b-256k-gguf4
# measured 5-15min each in prior scenarios.
BEHAVIOR_MONITOR_MAX_POLLS=150
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# §14 GREEN early termination: the run is complete once the step-4 summary
# artifact exists on disk AND a write tool call completed (all four steps
# end in a write).
BEHAVIOR_EXPECTED_ARTIFACT="tmp/2451-scenario/step4-summary.yaml"
BEHAVIOR_GOAL_ACTIONS="write"
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_GOAL_ACTIONS

# Prompt is self-contained — no fixture-issue injection needed for this scenario.
BEHAVIOR_FIXTURE_ISSUES=0
export BEHAVIOR_FIXTURE_ISSUES

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code. Model comes
# from DEFAULT_TEST_MODEL (default-model.sh, R-20 single source of truth:
# ollama/qwen3.8:27b-256k-gguf4).
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0
