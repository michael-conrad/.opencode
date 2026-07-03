#!/bin/bash
# Behavioral test: 1244-sc7-checklist-generation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7 (behavioral): Checklist generated at ./tmp/{N}/checklist.md on plan
# creation. The checklist must contain phase sections, step checkboxes with
# dispatch instructions, and status tracking per step.
#
# RED phase: writing-plans does not have checklist generation wired in,
# so plan creation does NOT produce ./tmp/{N}/checklist.md.
#
# GREEN phase: writing-plans generates ./tmp/{N}/checklist.md with phases,
# steps, dispatch instructions, and status tracking after plan content is
# finalized.
#
# Issue #1244: Decouple state tracking from design artifacts — add checklist
# generation (Bug 4 / Phase 4)
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1244-sc7-checklist-generation"
SCENARIO_PROMPT="Create an implementation plan for the following [SPEC]:

## SPEC: Add Rate Limiter Middleware

### Goal
Add configurable rate limiting to the API gateway to prevent abuse.

### Phases

**Phase 1: Core token bucket implementation**
Implement a token bucket algorithm with configurable rate and burst parameters. Store state in an in-memory map keyed by client IP.

**Phase 2: Middleware integration**
Wire the rate limiter into the FastAPI middleware stack. Return 429 responses when rate exceeded, with Retry-After header.

**Phase 3: Configuration and observability**
Add YAML-based rate limit configuration, expose metrics endpoint for rate limit hits, and log warnings near threshold.

Take the plan through to completion — finalize the plan content and any checklist or tracking artifacts it produces."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-GREEN}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: create implementation plan from spec with 3 phases"
echo "  Expectation (GREEN): agent generates ./tmp/{N}/checklist.md with phase sections, step checkboxes, dispatch instructions"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
