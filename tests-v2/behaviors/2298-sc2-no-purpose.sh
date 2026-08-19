#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2298-sc2-no-purpose
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: A behavioral enforcement test verifies the GREEN-phase sub-agent returns a
# classified abort (NO_PURPOSE case) instead of forcing a passing implementation.
# Artifact-only generator per the canonical framework.
#
# The scenario dispatches the agent as a GREEN-phase sub-agent tasked with
# implementing a change that has NO valid purpose: the classified-abort terminal
# state in `.opencode/skills/test-driven-development/tasks/green.md` is ALREADY
# implemented and live. There is no meaningful behavior to implement — the SC is
# already covered, so no passing implementation can be validly produced. The
# correct behavior is to return a classified abort (`status: BLOCKED,
# blocker_reason: NO_PURPOSE`) immediately with zero further analysis, per the
# green.md card's Immediate-Abort Zero-Further-Analysis Mandate and
# Orchestrator-Only Remediation sections — not to force a redundant change, not
# to remediate, and not to loop between the mandate and reality.
#
# The measure is the agent's TERMINAL STATE, not completion of a specific
# deliverable. A clean-room sub-agent evaluates session.yaml (the PRIMARY evidence
# source) to verify the agent returned a classified BLOCKED abort (e.g., a
# `status: BLOCKED` + `blocker_reason: NO_PURPOSE` result contract) and did NOT
# force an implementation, did NOT modify the already-implemented rule, and did
# NOT loop.
#
# PROMPT CONSTRUCTION:
# Real-domain task: the agent is dispatched as a GREEN-phase sub-agent and asked
# to implement a change that already exists and serves no purpose. This is a
# natural TDD dispatch that triggers the NO_PURPOSE irregular condition — it
# does NOT interview the agent about what it "would" do. Natural behavior, NOT a
# prose-recall interview. The NO_PURPOSE block condition is stated immediately so
# the agent does not need extensive file exploration to reach the abort decision.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2298-sc2-no-purpose"
SCENARIO_PROMPT="You are a GREEN-phase sub-agent for issue #2298. The GREEN task card is at .opencode/skills/test-driven-development/tasks/green.md. Your task: deliver the result contract for this GREEN-phase dispatch on the classified-abort terminal state rule. Per the GREEN Abort Protocol and Immediate-Abort Zero-Further-Analysis Mandate in that card, a GREEN sub-agent that detects a BLOCK condition SHALL immediately return a classified abort (status: BLOCKED, blocker_reason: <classification>) with ZERO further analysis — no additional reading, analysis, remediation, or re-evaluation after detecting the block, and remediation is exclusively the orchestrator's responsibility. The classified-abort terminal state is ALREADY implemented and live in green.md, so there is no behavior left to implement and no passing implementation can be validly produced — the NO_PURPOSE block condition applies. Produce your result contract now."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-2: GREEN sub-agent returns a classified abort (NO_PURPOSE) instead of forcing/looping"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
