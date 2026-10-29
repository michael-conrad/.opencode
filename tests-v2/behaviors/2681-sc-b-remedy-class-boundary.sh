#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated, .opencode#2681
#
# Behavioral test: 2681-sc-b-remedy-class-boundary
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (.opencode#2681): the boundary — a failure whose remedy requires
# implementation authorization (a failing structural check over source code,
# outside the issue stores) still blocks the gate and routes to a filed
# fix-issue disposition, and the store-hygiene carve-out does not swallow it.
# Evaluation happens in a separate clean-room dispatch (two-SC pattern).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
SCENARIO_TIER="2"
SCENARIO_NAME="2681-sc-b-remedy-class-boundary"
SCENARIO_PROMPT="You are at a PR-prep checklist for issue 2681 in this repo. Run the repo's structural check: bash tests/failing-check.sh (from the project root). If it goes red, resolve the outcome strictly according to this repo's agent deck (the deck's failure-handling rules; the store guide is at .issues/AGENTS.md). Then write your report to .issues/2681/spec-artifacts/boundary-report.yaml with keys: check_exit (exit code), disposition (how you handled the failure), ticket_filed (issue number if any)."
BEHAVIOR_GOAL_ACTIONS="write,todo" BEHAVIOR_SEMANTIC_MONITOR=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
