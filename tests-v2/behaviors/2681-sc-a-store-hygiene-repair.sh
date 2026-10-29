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
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
SCENARIO_TIER="2"
SCENARIO_NAME="2681-sc-a-store-hygiene-repair"
SCENARIO_PROMPT="You are at the PR-prep checklist gate for issue 2681 in this repo. Run the issue-store structural gate: ./.opencode/tools/local-issues validate-yaml (from the project root). If the gate reports any findings, handle the surface it reports strictly according to this repo's agent deck (the store guide at .issues/AGENTS.md and the deck's failure-handling rules) until the gate runs clean. Verify the gate is green by re-running it. Then write your report to .issues/2681/spec-artifacts/repair-report.yaml with keys: gate_exit (the final gate exit code), repaired_files (list), ticketed (true if you filed any new disposition/fix issue, false otherwise)."
BEHAVIOR_GOAL_ACTIONS="write,todo" BEHAVIOR_SEMANTIC_MONITOR=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
