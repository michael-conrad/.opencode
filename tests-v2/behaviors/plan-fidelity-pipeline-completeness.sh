#!/bin/bash
# Behavioral test: plan-fidelity-pipeline-completeness
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Plan-fidelity audit checks for mandatory pipeline steps and FAILs if missing
#
# RED phase: Must fail because plan-fidelity-evaluator.md has no pipeline
# completeness check yet. The agent receives a plan that is missing mandatory
# pipeline stages and is asked to run a plan-fidelity audit. Without the
# pipeline completeness check in the evaluator, the audit will not detect the
# missing stages — the test FAILs because the evaluator does not enforce
# pipeline completeness.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: agent must run a plan-fidelity audit on a plan that is
# structurally defective (missing pipeline steps). The plan-fidelity evaluator
# has no pipeline completeness check, so the audit will not FAIL for missing
# pipeline steps. This triggers natural agent behavior — not prose recall.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-fidelity-pipeline-completeness"
SCENARIO_PROMPT="Run a plan-fidelity audit on the following plan against the following spec. The plan is missing mandatory implementation pipeline stages (assemble-work, sc-coherence-gate, pre-red-baseline, RED/GREEN per item with Z3 checks, VbC, sc-count-gate, pre-pr-gate, audit, cross-validate, regression-check, review-prep, create-pr, exec-summary). The plan-fidelity audit MUST FAIL because the plan is missing these mandatory pipeline steps.

SPEC:
# Spec: Add Pipeline Completeness Check to Plan-Fidelity Evaluator
## Problem
The plan-fidelity evaluator has no check for whether the plan includes all mandatory implementation pipeline stages.
## Success Criteria
| ID | Criterion | Evidence Type |
| SC-1 | Plan-fidelity evaluator checks for mandatory pipeline stages | behavioral |
| SC-2 | Plan missing pipeline stages produces FAIL verdict | behavioral |
| SC-3 | All mandatory stages from implementation-pipeline SKILL.md are enumerated | string |

PLAN:
# Plan: Add Pipeline Completeness Check
## Phase 1: Add pipeline completeness check to evaluator
### Step 1: Add PF-PIPELINE-COMPLETENESS criterion to evaluation table
- **Dispatch:** (**clean-room**)
- **SC:** SC-1, SC-2, SC-3
- **Action:** Add a new criterion PF-PIPELINE-COMPLETENESS to the evaluation table
- **Verification:** grep for PF-PIPELINE-COMPLETENESS in the evaluator file
### Step 2: Add pipeline completeness check procedure
- **Dispatch:** (**clean-room**)
- **SC:** SC-1, SC-2
- **Action:** Add a new step that checks the plan against mandatory pipeline stages
- **Verification:** grep for the new step in the evaluator file"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
