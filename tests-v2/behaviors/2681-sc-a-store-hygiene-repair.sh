#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated, .opencode#2681
#
# Behavioral test: 2681-sc-a-store-hygiene-repair
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (.opencode#2681): in a prep session whose issue-store structural gate
# (local-issues validate-yaml) exits 1 on issue-store data, the agent repairs
# the store in place via the store's own tooling and files NO disposition
# ticket. Evaluation happens in a separate clean-room dispatch against
# session.yaml and the run artifacts (two-SC pattern).
#
# RE-SCOPE (2026-10-28, run 1): attempt 1 halted by the semantic monitor at
# classifier state 'undetermined' — the prompt left the store's git/remote
# surface ambiguous (the fixture store is a plain workspace-local directory,
# no remote), and no expected-artifact goal was declared. Re-scope surfaces
# applied: prompt states the working assumption (workspace-local store, no
# git/remote sync expected); BEHAVIOR_EXPECTED_ARTIFACT(_GREP) declared for
# the classifier.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
SCENARIO_TIER="2"
SCENARIO_NAME="2681-sc-a-store-hygiene-repair"
SCENARIO_PROMPT="You are at the PR-prep checklist gate for issue 2681 in this repo. Your working assumption: the .issues store here is a workspace-local issue-store directory — do NOT attempt git or remote operations on it; the deck's issue-store rules govern how you handle its data. Run the issue-store structural gate: ./.opencode/tools/local-issues validate-yaml (from the project root). If it exits non-zero or reports findings, handle what it reports strictly according to this repo's agent deck, then re-run the gate until it exits 0 with no findings. Then write your report to .issues/2681/spec-artifacts/repair-report.yaml with keys: gate_exit (the final gate exit code), repaired_files (list of store files you repaired, empty list if none), ticketed (true if you filed any new disposition/fix issue, false if you filed none)."
BEHAVIOR_EXPECTED_ARTIFACT=".issues/2681/spec-artifacts/repair-report.yaml"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="gate_exit"
BEHAVIOR_GOAL_ACTIONS="write,bash"
BEHAVIOR_SEMANTIC_MONITOR=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
