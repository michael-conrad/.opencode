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
# fixtures/issues/2432-sc9-fixture/ (spec.md + issue.yaml) is injected by
# setup_fixture_issues() as .issues/2432/ (flat) + .issues/open/2432-....
# The fixture spec is a SMALL SELF-CONTAINED FICTIONAL spec (md tool --json read
# flag) consistent with the effective-commit code state — the former fixture
# (copy of the real #2432 spec) described RED-state work the effective commit
# already implemented, sending run agents into spec-vs-code drift rumination
# (issue .opencode#2432 SC-09 R-18 fold-in 5, fixture-state fix). The behavioral
# assertion target (validate-yaml gate invocation after artifact generation) is
# unaffected — artifact content is irrelevant to the assertion.
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
# prompt adds the R-18 incremental-emission directive and the R-21 emission
# protocol for artifact-generation scenarios: write each artifact to disk
# immediately upon deriving it (one artifact per write), check for
# already-written artifacts before re-deriving, write a minimal skeleton
# artifact FIRST (immediately after reading the spec's scope sections, before
# any grounding reads) and then append/refine section-by-section, and make the
# write tool call itself the next assistant action whenever a write is due
# (no intervening restating/summarizing/pre-write prose). Batch-derivation in
# a single 20-30K reasoning turn exhausts budgets before any file write
# (issue .opencode#2432 SC-09 R-18 fold-in; SC-14 R-21 fold-in). The
# directives are behavioral (framework-agnostic), not model-specific.
SCENARIO_PROMPT="You are a sub-agent. Follow the instructions in [execute the analyze task](.opencode/skills/spec-creation/tasks/analyze.md), performing Step 5 (Analytical artifact generation) including the Step 5.3 validate-yaml gate step that follows artifact generation. issue_number: 2432, project_root: the current working directory. The spec to analyze is at .issues/2432/spec.md. Generate the blast-radius analytical artifact (artifact 1 of Step 5.1) for the spec and write it to the exact path ./tmp/2432/artifacts/blast-radius.yaml (relative to project_root — do not use any other artifacts location). Incremental emission: write each artifact to disk immediately upon deriving it — one artifact per write, never batch-derive all artifacts before emitting — and check the artifacts directory for already-written artifacts before deriving, so an interrupted run emits only the remaining artifacts without re-deriving what is already on disk. Skeleton-first write: immediately after reading the spec's scope sections and BEFORE any grounding reads, write a minimal valid skeleton artifact to the target path — the YAML header plus empty placeholder sections, a few lines long; all subsequent work APPENDS to and refines the skeleton section-by-section with one small write per section (grounding still occurs, only AFTER the skeleton write). Action-first transition: when a write is due, your next assistant action MUST be the write tool call itself — no restating what will be written, no summarizing what was derived, no pre-write verification prose between the decision to write and the write call. The same rule applies to the Step 5.3 gate: when you have decided to run the gate, your next tool call MUST be the gate command itself — no intervening read, inspection, or verification call between the decision and the gate execution. Bounded grounding with emit-before-expand ordering: derive the blast radius from the spec's scope sections plus the bounded read set you have already performed, then WRITE the artifact to its path BEFORE making any additional reads; expand grounding with further reads only AFTER the write, and only to fill a required artifact section that could not be derived from what you already have — record the assumption you are filling in the artifact itself rather than exhaustively reading implementations. Completion criterion: the run is complete ONLY when the Step 5.3 validate-yaml gate has actually been executed by you with its exit code recorded — you must include the literal gate command you executed and its exit code in your result contract (tool-call evidence, not prose). A result contract claiming the gate completed without the recorded command + exit code is treated as gate-not-run. Incident recovery: if you make an unintended out-of-scope edit, revert it with ONE immediate corrective tool call, note the incident in one line, and continue the task — no revert-mechanics deliberation."

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
