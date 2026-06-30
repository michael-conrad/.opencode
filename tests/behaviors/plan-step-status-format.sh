#!/bin/bash
# Behavioral test: plan-step-status-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (behavioral): Agent executing a plan with Step Status instruction
#   formats chat output with ✅, 🔄, ⏳ markers
#
# Issue #1579: Plan writer injects step status instruction block

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-step-status-format"
SCENARIO_PROMPT="You are executing the following plan. Report your progress in chat.

# Implementation Plan — Test Plan

**Goal:** Demonstrate Step Status format.

> **Step Status:**
> When executing this plan, report progress in chat using:
> 
> ✅ Step N-1 — 
> 🔄 Step N — 
> ⏳ Step N+1 — 
> 
> ✅ = completed. 🔄 = in progress. ⏳ = pending.
> 
> Omit the ✅ line when no step is yet completed.
> Omit the ⏳ line when the current step is the last step.

## Phase 1 — Test

- [ ] 1. Step 1 — Do something
- [ ] 2. Step 2 — Do something else
- [ ] 3. Step 3 — Do a third thing

Report your progress for step 1."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
