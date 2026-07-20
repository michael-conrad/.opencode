## Summary

The implementation pipeline (`implementation-pipeline`) has no mandatory submodule state verification at its entry point. Submodule sync to dev tip is implemented in `git-workflow/tasks/pre-work.md` but the pipeline does not mandate pre-work as a prerequisite, allowing execution with stale submodules.

## Defects Found

### HIGH — Missing submodule state check in pre-flight conditions
**File:** `implementation-pipeline/tasks/assemble-work.md` lines 38-41

Three pre-flight conditions are checked (branch exists, clean tree, auth scope) but submodule state is not verified. The pipeline entry point can proceed with stale submodules.

### HIGH — No submodule initialization step in dispatch table
**File:** `implementation-pipeline/tasks/pipeline-executor.md` lines 41-59

The 17-step dispatch table starts at `sc-coherence-gate` and runs through RED/GREEN/audit — there is no submodule initialization or sync step. Pipeline resume mid-way or partial pre-work would not catch stale submodules.

### HIGH — Pre-flight handoff has no submodule checks
**File:** `implementation-pipeline/SKILL.md` lines 97-103, `implementation-pipeline/tasks/pre-flight-handoff.md`

The pre-flight section validates plan-to-pipeline handoff and handoff-consistency but has zero submodule state verification. This is the last gate before execution.

### MEDIUM — Conditional pre-work phrasing allows bypass
**File:** `implementation-pipeline/tasks/assemble-work.md` line 39

Pre-flight says "Feature branch exists (or create via `git-workflow --task pre-work`)" — the conditional phrasing allows a path where the branch already exists but pre-work (and its submodule sync) was never run.

### MEDIUM — Pre-red-baseline does not check submodule state
**File:** `implementation-pipeline/tasks/pre-red-baseline.md` lines 35-45

Document source currency check verifies file existence and modification timestamps for plan-referenced files but does not check submodule state. If a submodule has drifted from dev tip, source files could be stale without detection.

## Root Cause

Submodule sync to dev tip is fully implemented in `git-workflow/tasks/pre-work.md` (Steps 2.5/3.5 — glob scan, sub-agent dispatch, init, checkout to dev tip, tag, push). But the implementation pipeline's entry point (`assemble-work.md`) does not mandate that pre-work has been run. The pipeline assumes submodules are current without verification.

## Recommended Fixes

1. **`assemble-work.md` Step 1.3**: Add submodule state verification to pre-flight conditions (e.g., `git submodule status` against expected dev tip)
2. **`pipeline-executor.md`**: Add a step 0 (`submodule-verify`) to the dispatch table, or fold submodule verification into `pre-red-baseline`
3. **`SKILL.md` Pre-Flight**: Add submodule state check alongside the handoff-consistency check
4. **`assemble-work.md`**: Change "or create via" to "MUST have been created via" to make pre-work mandatory, not optional

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created