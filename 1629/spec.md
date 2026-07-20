## Summary

Bug #1440 identified that the implementation pipeline has no mandatory submodule state verification at its entry point. Submodule sync to dev tip is implemented in `git-workflow/tasks/pre-work.md` but the pipeline does not mandate pre-work as a prerequisite, allowing execution with stale submodules.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `assemble-work.md` Step 1.3 pre-flight conditions include submodule state verification (`git submodule status` against expected dev tip) | `string` | grep for submodule status check in pre-flight conditions |
| SC-2 | `pipeline-executor.md` dispatch table includes a `submodule-verify` step (step 0) or submodule verification is folded into `pre-red-baseline` | `string` | grep for submodule-verify in dispatch table or pre-red-baseline |
| SC-3 | `SKILL.md` Pre-Flight section includes submodule state check alongside handoff-consistency check | `string` | grep for submodule state check in pre-flight section |
| SC-4 | `assemble-work.md` Step 1.3 changes "or create via" to "MUST have been created via" to make pre-work mandatory | `string` | grep for "MUST have been created via" in assemble-work.md |
| SC-5 | `pre-red-baseline.md` document source currency check includes submodule state verification | `string` | grep for submodule state check in pre-red-baseline.md |

## Affected Files

- `implementation-pipeline/tasks/assemble-work.md`
- `implementation-pipeline/tasks/pipeline-executor.md`
- `implementation-pipeline/SKILL.md`
- `implementation-pipeline/tasks/pre-red-baseline.md`

## Root Cause

Submodule sync to dev tip is fully implemented in `git-workflow/tasks/pre-work.md` (Steps 2.5/3.5 — glob scan, sub-agent dispatch, init, checkout to dev tip, tag, push). But the implementation pipeline's entry point (`assemble-work.md`) does not mandate that pre-work has been run. The pipeline assumes submodules are current without verification.

## Change Control

- **Spec created:** 2026-07-01
- **Spec author:** OpenCode (ollama-cloud/deepseek-v4-flash)
- **Status:** DRAFT

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
