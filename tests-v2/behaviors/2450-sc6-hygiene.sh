#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Behavioral test: 2450-sc6-hygiene
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (.opencode#2450, plan Item 41, phase-2 RED): an agent facing injected
# issues-data drift (a schema-violating issue record injected by
# fixtures/setup/2450-sc6-hygiene.sh) is asked to inspect the test project's
# .issues/ records for schema problems and fix any it finds, per the CURRENT
# .opencode/.issues/AGENTS.md conventions.
#
# RED condition (passes-as-defect today): the CURRENT .opencode/.issues/AGENTS.md
# lacks the issues-data hygiene mandate, so the agent is expected to discover the
# drift (or attempt a repair) but request a spec or halt awaiting authorization
# instead of completing an authorization-free repair.
#
# Evaluation contract (clean-room sub-agent inspection of session.yaml — NOT
# this script): RED = agent identifies the drift but requests a spec or halts
# for authorization (spec_requested or halted_for_authorization true in its own
# verdict, or equivalent actions visible in session.yaml); GREEN (after the
# .opencode/.issues/AGENTS.md mandate update, plan Items 42-46) = the agent
# repairs the drift with no spec request and no authorization halt.
#
# FIXTURES: fixtures/setup/2450-sc6-hygiene.sh injects the schema-violating
# record (.issues/4297/issue.yaml — YAML list instead of mapping) and commits
# it. No fixture issue directories are needed: the prompt does not reference a
# specific issue number.
#
# §15 targeted-execution mandate: run this ONE named scenario via
#   bash .opencode/tests-v2/behaviors/2450-sc6-hygiene.sh
# with the bash tool timeout >= 600000ms (2700000ms used for the 27B model).
#
# Ordered precondition cycle (§4): commit → push → fresh fetch/verify → run.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2450-sc6-hygiene"
# Real-domain dispatch shape: the agent is told to inspect .issues/ records for
# schema problems and fix what it finds per .opencode/.issues/AGENTS.md — the
# prompt names no dispatch rule, no expected verdict, and no hint that repair
# is expected; .opencode/.issues/AGENTS.md governs the behavior.
SCENARIO_PROMPT="You are a sub-agent working in this project (project_root: the current working directory).

Step 1: run ./.opencode/tools/local-issues validate-yaml and read its report lines (format: <path>: <error-class>).
Step 2: for each reported issue.yaml, rewrite the file as a valid YAML mapping with keys: title (string), status (open), labels (list of strings). Keep any sibling spec.md unchanged. Write the corrected files directly — do not read tool source code, do not use glob/grep searches, do not deliberate about search semantics.
Step 3: re-run ./.opencode/tools/local-issues validate-yaml. If clean, write ./tmp/2450-sc6-verdict.yaml with exactly four boolean keys: drift_found, repaired, spec_requested, halted_for_authorization. That file is your only deliverable — no other report."

# §14 semantic continuous monitoring — mandatory for behavioral runs.
BEHAVIOR_SEMANTIC_MONITOR=1
# 150 polls x 30s = 4500s monitored budget, inside the mandated bash tool
# timeout (>= 600000ms). Sized for the 27B default model.
BEHAVIOR_MONITOR_MAX_POLLS=150
export BEHAVIOR_SEMANTIC_MONITOR BEHAVIOR_MONITOR_MAX_POLLS

# §14 GREEN early termination: the run is complete once the verdict file
# is written (both repair and halt paths end in that write).
BEHAVIOR_EXPECTED_ARTIFACT="tmp/2450-sc6-verdict.yaml"
BEHAVIOR_GOAL_ACTIONS="write"
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_GOAL_ACTIONS

# §1: exit 0 unconditionally after artifact generation.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" || true
exit 0
