#!/bin/bash
# Behavioral test: 2009-sc4-plan-fidelity-pipeline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Plan-fidelity audit FAILs on missing Pipeline Steps section.
#
# The prompt presents a plan that is missing the mandatory Pipeline Steps section
# and asks the agent to run a plan-fidelity audit on it. The audit should detect
# the missing section and return FAIL.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2009-sc4-plan-fidelity-pipeline"
SCENARIO_PROMPT="You are a plan-fidelity auditor. Execute a plan-fidelity audit on the following plan document and return your verdict as PASS or FAIL.

The plan to audit:

# Plan: Implement Feature X

## Phase 1: Add validation logic

- [ ] 1. Add input validation to the API endpoint
- [ ] 2. Write unit tests for validation
- [ ] 3. Verify all tests pass

## Phase 2: Update documentation

- [ ] 1. Update API docs with new validation rules
- [ ] 2. Add examples to README

This plan is MISSING the mandatory '## Pipeline Steps' section. Every plan must include a Pipeline Steps section that references the implementation pipeline stages (assemble-work, sc-coherence-gate, pre-red-baseline, red-phase, green-phase, audit, etc.) from the implementation-pipeline Trigger Dispatch Table. Without this section, the plan cannot be executed because the orchestrator has no pipeline stage routing information.

Return your verdict as a single word: PASS or FAIL."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
