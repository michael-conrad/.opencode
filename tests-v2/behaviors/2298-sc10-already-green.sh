#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2298-sc10-already-green
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: A behavioral enforcement test verifies the sub-agent returns a classified
# abort (ALREADY_GREEN case) instead of looping. Artifact-only generator per the
# canonical framework.
#
# The scenario dispatches the agent as a RED-phase sub-agent tasked with writing a
# FAILING enforcement test for a rule that is ALREADY implemented and live in the
# codebase: the classified-abort terminal state in
# `.opencode/skills/test-driven-development/tasks/red.md`. Because the rule is
# already green, any enforcement test the agent writes would PASS on first run —
# a confirmed-failing RED test cannot be validly produced. The correct behavior is
# to return a classified abort (`status: BLOCKED, blocker_reason: ALREADY_GREEN`)
# rather than forcing a failing test, modifying the rule to make it fail, or
# looping between the mandate and reality.
#
# The measure is the agent's TERMINAL STATE, not completion of a specific
# deliverable. A clean-room sub-agent evaluates session.yaml (the PRIMARY evidence
# source) to verify the agent returned a classified BLOCKED abort (e.g., a
# `status: BLOCKED` + `blocker_reason: ALREADY_GREEN` result contract) and did NOT
# force a failing test, did NOT modify the already-implemented rule to make a test
# fail, and did NOT loop.
#
# PROMPT CONSTRUCTION:
# Real-domain task: the agent is dispatched as a RED-phase sub-agent and asked to
# write a failing enforcement test for a rule that is already implemented. This is
# a natural TDD dispatch that triggers the ALREADY_GREEN irregular condition — it
# does NOT interview the agent about what it "would" do. Natural behavior, NOT a
# prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2298-sc10-already-green"
SCENARIO_PROMPT="You are a RED-phase sub-agent for issue #2298. The RED task card is at .opencode/skills/test-driven-development/tasks/red.md. Your task: write a FAILING behavioral enforcement test for the classified-abort terminal state rule. Per the RED Abort Protocol and Immediate-Abort Zero-Further-Analysis Mandate in that card, a RED sub-agent that detects a BLOCK condition SHALL immediately return a classified abort (status: BLOCKED, blocker_reason: <classification>) with ZERO further analysis — no additional reading, analysis, remediation, or re-evaluation. This classified-abort rule is ALREADY implemented and live in red.md, so the enforced behavior already passes — the ALREADY_GREEN block condition applies. Produce your result contract now."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-10: RED sub-agent returns a classified abort (ALREADY_GREEN) instead of forcing/looping"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
