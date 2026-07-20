# Plan: Add Pipeline Completeness Check

## Phase 1: Add pipeline completeness check to evaluator

### Step 1: Add PF-PIPELINE-COMPLETENESS criterion to evaluation table
- **Dispatch:** (**clean-room**)
- **SC:** SC-1, SC-2, SC-3
- **Action:** Add a new criterion PF-PIPELINE-COMPLETENESS to the evaluation table in Step 3 of plan-fidelity-evaluator.md
- **Verification:** grep for PF-PIPELINE-COMPLETENESS in the evaluator file

### Step 2: Add pipeline completeness check procedure
- **Dispatch:** (**clean-room**)
- **SC:** SC-1, SC-2
- **Action:** Add a new step between Step 1 (Pre-Flight Validation Gate) and Step 2 (Read Upstream Artifacts) that checks the plan against the mandatory pipeline stages from implementation-pipeline SKILL.md
- **Verification:** grep for the new step in the evaluator file
