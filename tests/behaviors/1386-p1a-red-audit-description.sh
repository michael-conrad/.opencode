#!/bin/bash
# Behavioral test: 1386-p1a-red-audit-description
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1386-p1a-red-audit-description"
# SC-1 + SC-2: Verify description has mandatory language AND no narrative-only sentences.
# The current description has "they are how trustworthy work is verified" (narrative-only, D5 FAIL).
# The test MUST fail because the description hasn't been updated yet.
SCENARIO_PROMPT="Check the description in .opencode/skills/audit/SKILL.md. Does it contain mandatory language (MUST, REQUIRED, always, not optional, mandatory)? Does it contain any narrative-only sentences (sentences that are metaphors, slogans, or narrative without dispatch-relevant content)? Report PASS only if BOTH conditions are met: mandatory language present AND no narrative-only sentences."

BEHAVIOR_PHASE="RED" behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
