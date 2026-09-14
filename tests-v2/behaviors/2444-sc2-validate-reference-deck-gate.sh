#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2444-sc2-validate-reference-deck-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (.opencode#2444): a validate-task dispatch's reference-deck integrity check
# locates all 4 canonical files at the paths stated in spec-creation/tasks/validate.md
# — the run passes the reference-deck integrity gate WITHOUT
# `reference-deck-integrity: FAIL`.
#
# The 4 canonical targets (post-Phase-1 corrected `../../../` paths from
# .opencode/skills/spec-creation/tasks/validate.md):
#   1. ../../../reference/spec-structure-standards.md   (Step 1.2)
#   2. ../../../reference/holistic-dimensions.yaml      (Steps 2.1/2.2)
#   3. ../../../reference/cost-model-standards.md       (Step 3.5)
#   4. ../../../audit/reference/decomposition-criteria.md (Step 3.7)
#
# RED condition (documented pre-fix evidence, NOT produced by re-breaking the
# corrected files — plan step 19 explicitly forbids re-breaking; precedent: the
# #2434 behavioral end-to-end item): on the pre-fix state, validate.md referenced
# the 4 canonical files with task-relative paths that did not resolve, so EVERY
# validate dispatch BLOCKED at the reference-deck integrity gate. Documented
# observation (spec .opencode/.issues/2444/spec.md, Evidence section): blocked
# validate-task run on spec issue NewSRX-Tech-LLC/Butter#346, 2026-09-12, with
# `reference-deck-integrity: FAIL`. Under that state the SC-2 pass-assertion is
# unmeetable — the scenario's session.yaml would show the reference reads failing
# and a BLOCKED outcome naming the gate. The behavioral run executes at plan
# step 24, AFTER the scenario commit (step 22) and push + fresh-fetch verification
# (step 23), per the 091-incremental-build behavioral variant (COMMIT/PUSH precede
# the behavioral run) — this RED step writes the script and records the RED
# rationale only.
#
# Evaluation contract (clean-room evaluation of session.yaml per the two-SC
# pattern, tests-v2/AGENTS.md §6a — executed at plan step 24 by the
# verification-before-completion verify dispatch; the evaluator receives ONLY the
# artifact path and this criterion):
#   - The agent dispatched the spec-creation validate task for the fixture issue
#     and read the validate task card.
#   - The agent read all 4 canonical reference files at the corrected `../../../`
#     paths listed above (reference-deck integrity gate located every file).
#   - NO `reference-deck-integrity: FAIL` / gate-BLOCKED outcome appears in the
#     session (the aggregate spec verdict itself is NOT the criterion — a FAIL
#     aggregate verdict on the fixture spec does not fail SC-2; only a gate
#     BLOCK does).
# session.yaml (SQLite DB export) is the PRIMARY evidence source — §2. stdout.log
# prose is NOT evidence; this script performs ZERO evaluation of model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §11 (Prompt Construction Mandate): a genuine spec-creation
# validate dispatch for a fixture spec issue (issue_number + spec_path provided,
# matching validate.md Entry Criteria). Natural behavior, NOT a prose-recall
# interview. The prompt does NOT name validate.md's internal steps, reference
# paths, or the expected outcome (no producer context / orchestrator reasoning /
# expected outcomes — validate.md Entry Criteria). The prompt targets the validate
# stage directly (not the full explore->analyze->create->validate pipeline) so the
# model reaches the reference-deck integrity gate within the harness timeout.
#
# FIXTURE REQUIREMENT (§3 Step 0): the prompt references issue content
# (.issues/2444/spec.md), so a fixture issue directory exists at
# fixtures/issues/2444-validate-fixture/ (spec.md + issue.yaml). The harness
# injects it into the test repo as .issues/2444/ (flat) + .issues/open/2444-...
# via setup_fixture_issues(). Fixture spec paths use the root-level .issues/2444/
# form, NOT .opencode/.issues/2444/.
#
# No per-scenario fixtures/setup/ script is required: the validate task is
# read-only (validate.md Exit Criteria — no spec content written, no remote issue
# operations), so no branch/remote/tag state is needed.
#
# §15 targeted-execution mandate: this script is ONE named scenario. Run it once
# for this SC's evidence need via
#   bash .opencode/tests-v2/behaviors/2444-sc2-validate-reference-deck-gate.sh
# with the bash tool timeout parameter >= 600000ms. Never enumerate behaviors/*.sh.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2444-sc2-validate-reference-deck-gate"
SCENARIO_PROMPT="Run the spec-creation validate step for issue #2444 in this repo's local issue tracker. The spec to validate is at .issues/2444/spec.md (spec_path), issue_number 2444. Evaluate the spec and report the aggregate validation verdict."

# §14 semantic continuous monitoring — mandatory for behavioral runs. The monitor
# launches the opencode run in the background and polls the live session DB at
# BEHAVIOR_MONITOR_INTERVAL-second intervals; on a hard-abort signal it kills the
# run, exports session.yaml per §10.5, and records the semantic diagnosis.
BEHAVIOR_SEMANTIC_MONITOR=1
# 60 polls x 30s = 1800s monitored budget, inside the mandated bash tool timeout
# (2400s), leaving headroom for the §10.5 export + §14 diagnosis on abort. A single
# validate dispatch on the 35B model (task-card read, 4 reference loads, spec
# evaluation, verdict) needs ~15-25 min.
BEHAVIOR_MONITOR_MAX_POLLS=60
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# The prompt references issue content — keep fixture-issue injection enabled
# (§3 Step 0). This is the harness default; set explicitly for clarity.
BEHAVIOR_FIXTURE_ISSUES=1
export BEHAVIOR_FIXTURE_ISSUES

# §1: exit 0 unconditionally after artifact generation — never propagate
# behavior_run's internal failure code as the script's exit code.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0
