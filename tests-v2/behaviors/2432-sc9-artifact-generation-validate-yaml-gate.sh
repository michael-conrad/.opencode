#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2432-sc9-artifact-generation-validate-yaml-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-09 (.opencode#2432, plan Item 9, phase-5-red): the spec-creation (analyze,
# create) task cards invoke the `local-issues validate-yaml` gate after artifact
# generation and return a BLOCKED result contract when it exits 1.
#
# RED condition (this run executes BEFORE the task-card change): the artifact-
# generation scenario runs through the isolated harness; the SC-09 assertion is
# that the agent invokes the validate-yaml gate after generating analytical
# artifacts. On the pre-change state the gate is absent from the spec-creation
# task cards, so the session evidence is expected to show NO validate-yaml
# invocation — the assertion FAILS, which is the confirmed RED for SC-09.
# (Spec verification method: "artifact-generation scenario asserted to invoke
# the gate after the change (and absent before)").
#
# Evaluation contract (clean-room evaluation of session.yaml per the two-SC
# pattern, tests-v2/AGENTS.md §6a — the evaluator receives ONLY the artifact
# path and this criterion):
#   - The agent ran the spec-creation analyze step for the fixture issue and
#     generated analytical artifacts under tmp/{issue}/artifacts/.
#   - The session shows the agent invoking the `validate-yaml` gate
#     (`local-issues validate-yaml` or equivalent) after artifact generation.
#   - ABSENCE of any validate-yaml invocation in the session = SC-09 FAIL
#     (RED confirmed pre-change; GREEN requires the invocation present).
# session.yaml (SQLite DB export) is the PRIMARY evidence source — §2. stdout.log
# prose is NOT evidence; this script performs ZERO evaluation of model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §11 (Prompt Construction Mandate): a genuine spec-creation
# analyze dispatch for a fixture spec issue (issue_number provided, matching
# analyze.md Entry Criteria). Natural behavior, NOT a prose-recall interview.
# The prompt does NOT name the validate-yaml gate, the task card's internal
# steps, or the expected outcome (no producer context / orchestrator reasoning /
# expected outcomes).
#
# FIXTURE REQUIREMENT (§3 Step 0): the prompt references issue content
# (.issues/2432/spec.md), so the fixture issue directory
# fixtures/issues/2432-sc9-fixture/ (spec.md + issue.yaml — the real #2432 spec,
# whose subject the local-issues tool exists in the test repo's .opencode clone,
# letting pre-spec inspection converge) is injected by setup_fixture_issues()
# as .issues/2432/ (flat) + .issues/open/2432-....
#
# No per-scenario fixtures/setup/ script is required: the analyze task is
# read-only with respect to the repo (artifacts go to tmp/{issue}/artifacts/),
# so no branch/remote/tag state is needed.
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2432-sc9-artifact-generation-validate-yaml-gate.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2432-sc9-artifact-generation-validate-yaml-gate"
SCENARIO_PROMPT="You are a sub-agent. Follow the instructions in [execute the analyze task](.opencode/skills/spec-creation/tasks/analyze.md), performing Step 5 (Analytical artifact generation) only. issue_number: 2432, project_root: the current working directory. The spec to analyze is at .issues/2432/spec.md. Generate the blast-radius analytical artifact (artifact 1 of Step 5.1) for the spec and write it to the Step 5.2 output location."

# §14 semantic continuous monitoring — mandatory for behavioral runs. The monitor
# launches the opencode run in the background and polls the live session DB at
# BEHAVIOR_MONITOR_INTERVAL-second intervals; on a hard-abort signal it kills the
# run, exports session.yaml per §10.5, and records the semantic diagnosis.
BEHAVIOR_SEMANTIC_MONITOR=1
# 150 polls x 30s = 4500s monitored budget, inside the mandated bash tool timeout
# (4200s), leaving headroom for the §10.5 export + §14 diagnosis on abort. A
# single analyze dispatch on the 27B model (task-card read, codebase search,
# 7-artifact generation) measured 26+ min at abort in monitored trials — the
# budget is sized for the slow end of that range. Long sub-agent turns exceed
# short stall windows; BEHAVIOR_STUCK_TASK_POLLS/BEHAVIOR_MONITOR_MAX_REASONING
# are widened by the caller per the §14 monitored-abort diagnostics.
BEHAVIOR_MONITOR_MAX_POLLS=150
BEHAVIOR_STUCK_TASK_POLLS=60
export BEHAVIOR_STUCK_TASK_POLLS
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# The prompt references issue content — keep fixture-issue injection enabled
# (§3 Step 0). This is the harness default; set explicitly for clarity.
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_FIXTURE_ISSUES

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0
