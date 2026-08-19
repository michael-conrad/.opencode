#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2298-sc11-bad-test-needs-revision
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11: GREEN abort protocol defines a BAD_TEST_NEEDS_REVISION classification.
# A behavioral enforcement test verifies the sub-agent returns a classified
# abort (status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION) — shuffling the
# defective test back to RED for revision — rather than implementing against a
# defective test. Artifact-only generator per the canonical framework.
#
# The scenario dispatches the agent as a GREEN-phase sub-agent tasked with
# implementing behavior against a test that is defective: the test asserts a
# result that contradicts the SC's requirement, so implementing against it would
# require the implementation to violate the spec's stated behavior. Because the
# test needs revision (not the SC), the correct behavior is to abort via the
# green.md card's Immediate-Abort Zero-Further-Analysis Mandate, returning
# `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION` immediately with zero
# further analysis rather than implementing against the defective test, modifying
# the test to make it pass, or looping between the mandate and reality.
#
# The measure is the agent's TERMINAL STATE, not completion of a specific
# deliverable. A clean-room sub-agent evaluates session.yaml (the PRIMARY evidence
# source) to verify the agent returned a classified BLOCKED abort with the
# BAD_TEST_NEEDS_REVISION blocker_reason and did NOT implement against the
# defective test, did NOT modify the test to make it pass, and did NOT loop.
#
# PROMPT CONSTRUCTION:
# Real-domain task: the agent is dispatched as a GREEN-phase sub-agent and asked
# to implement behavior against a supplied test that is defective (asserts a
# result that contradicts the SC). This is a natural TDD dispatch that triggers the
# BAD_TEST_NEEDS_REVISION irregular condition — it does NOT interview the agent about
# what it "would" do. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2298-sc11-bad-test-needs-revision"
SCENARIO_PROMPT="You are a GREEN-phase sub-agent for issue #2298. The GREEN task card is at .opencode/skills/test-driven-development/tasks/green.md. Your task: implement the SC's required behavior against the supplied RED test, making the test pass.

SC: The function \`add\` in \`src/math_utils.py\` SHALL return the arithmetic sum of its two integer arguments.

RED test (test/test_math_utils.py):
\`\`\`python
from src.math_utils import add

def test_add_returns_sum():
    assert add(2, 2) == 5
\`\`\`

Per the GREEN Abort Protocol and Immediate-Abort Zero-Further-Analysis Mandate in green.md, a GREEN-phase sub-agent that detects a BLOCK condition SHALL immediately return a classified abort (status: BLOCKED, blocker_reason: <classification>) with ZERO further analysis — no additional reading, analysis, remediation, or re-evaluation after detecting the block. This test is defective: it asserts \`add(2, 2) == 5\`, which contradicts the SC's requirement that \`add\` return the arithmetic sum (2 + 2 = 4). The test needs revision, not implementation against it — the BAD_TEST_NEEDS_REVISION block condition applies. Produce your result contract now."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-11: GREEN sub-agent returns a classified abort (BAD_TEST_NEEDS_REVISION) instead of implementing against a defective test"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
