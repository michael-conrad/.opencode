#!/bin/bash
# Behavioral test: spec-creation-cards-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (deepseek-v4-flash-free)
#
# SC-7 (behavioral): Agent produces cards-based format (Exec Summary → Scope of Work
#   → Key Decisions → Risk Callouts) rather than the flat format (Problem/Scope/Approach/Impact).
#
# Behaviors verified by clean-room evaluation:
#   1. Agent uses cards-based format: Exec Summary, Scope of Work, Key Decisions, Risk Callouts
#      rather than flat Problem/Scope/Approach/Impact
#   2. Agent uses "## Goals" and "## Non-Goals" sections in the spec template
#   3. Agent uses "### Scope of Work" (not "### Cards") as the heading name
#   4. The pre-PR gate enforces the AI Agent Instructions constraint at the pipeline level
#
# RED phase: create.md contains contradictory format definitions (Step 7r flat format
#   + Step 7a cards format), so agent may produce the flat format.
# GREEN phase: Step 7r removed, cards format is the single canonical format, so
#   agent MUST produce the cards-based format.
#
# Issue #1902: Align spec-creation create.md with de facto industry standards

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-creation-cards-format"
SCENARIO_PROMPT="Create a [SPEC] issue for adding a health-check endpoint to an API server. The spec must include purpose, endpoint path, response format, success criteria, and affected files. Use spec-creation to produce the full spec body with all required sections."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: create a spec for health-check endpoint"
echo "  Expectation (RED): spec body may use flat format or cards format (pre-fix)"
echo "  Expectation (GREEN): spec body uses cards format (Exec Summary, Scope of Work, Key Decisions, Risk Callouts)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
