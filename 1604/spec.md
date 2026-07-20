## Problem

The `sc-pipeline-readiness.yaml` artifact is missing when `spec-creation` hands off to `writing-plans`. The `writing-plans` readiness task (`writing-plans/tasks/readiness.md` Step 2) reads this file and returns `BLOCKED` with `SPEC_NOT_READY_FOR_PIPELINE` when it does not exist — but the file was never produced because the pipeline-readiness gate was never invoked as a numbered step in the spec-creation Operating Protocol.

### Root Cause Analysis

Three defects combine to produce the missing artifact:

**Defect 1 — Task not dispatchable:** The `pipeline-readiness-gate` task file exists at `spec-creation/tasks/pipeline-readiness-gate.md` but is NOT listed in the spec-creation Tasks table. The table only lists `create` and `completion`. An unlisted task cannot be dispatched by the orchestrator.

**Defect 2 — No numbered step in Operating Protocol:** The Operating Protocol (steps 1-10) has no step for the pipeline-readiness gate. The gate should run between traceability (step 4) and risk (step 5) — before SCs are finalized and written to the spec body. Currently there is no slot for it.

**Defect 3 — Symbolic rule fires too late:** The symbolic rule `spec-creation-pipeline-readiness` fires when `spec_sc_finalized == true`. At this point the SCs are already written into the spec body. The gate is supposed to validate SC structure *before* finalization, not reactively after. The trigger condition is wrong — it should fire at pipeline position (between traceability and risk), not at SC-finalization time.

### Impact

- Every spec-creation run that hands off to writing-plans produces a `SPEC_NOT_READY_FOR_PIPELINE` blocker
- The pipeline-readiness gate is structurally unreachable because it has no numbered step in the protocol
- The symbolic rule's late trigger means the gate validates already-finalized SCs, making any structural fix require a spec revision cycle instead of catching it pre-write

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `pipeline-readiness-gate` is listed in the spec-creation Tasks table | `string` | grep for `pipeline-readiness-gate` in spec-creation/SKILL.md Tasks table |
| SC-2 | Operating Protocol has a numbered step for pipeline-readiness gate between traceability (step 4) and risk (step 5), with correct chain dependency (`step_4`) | `string` | grep for `pipeline-readiness-gate` in Operating Protocol section between step 4 and step 5 |
| SC-3 | The symbolic rule `spec-creation-pipeline-readiness` trigger condition fires at pipeline position (between traceability and risk) instead of at `spec_sc_finalized` | `string` | grep for updated trigger conditions in spec-creation/SKILL.md yaml+symbolic block |
| SC-4 | The Invocation table in spec-creation/SKILL.md includes a `task()` call entry for `pipeline-readiness-gate` | `string` | grep for `pipeline-readiness-gate` in the Call via task() table |
| SC-5 | Existing `pipeline-readiness-gate.md` task file is NOT modified — only the SKILL.md routing is updated | `structural` | `git diff` shows no changes to `tasks/pipeline-readiness-gate.md` |

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `.opencode/skills/spec-creation/SKILL.md` | Modify | Add `pipeline-readiness-gate` to Tasks table, add numbered step in Operating Protocol between step 4 and step 5, add Invocation entry, update symbolic rule trigger conditions |

## Change Control

| Field | Value |
|-------|-------|
| **Author** | AI Agent |
| **Date** | 2026-06-30 |
| **Change Type** | SPEC-FIX — structural defect in spec-creation pipeline routing |
| **Review Required** | Yes — spec-audit before implementation |
| **Dependencies** | None — single-file change to spec-creation/SKILL.md only |
| **Rollback** | `git checkout dev -- .opencode/skills/spec-creation/SKILL.md` |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)