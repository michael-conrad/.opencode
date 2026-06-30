# [SPEC-FIX] Position pipeline-readiness-gate as numbered step in spec-creation Operating Protocol

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `sc-pipeline-readiness.yaml` artifact is missing when spec-creation hands off to writing-plans. The pipeline-readiness gate task file exists at `spec-creation/tasks/pipeline-readiness-gate.md` but is not explicitly positioned in the spec-creation Operating Protocol as a numbered step — it is only enforced reactively via a symbolic rule that fires when SCs are finalized (too late).

### Root Cause

Three defects in `.opencode/skills/spec-creation/SKILL.md`:

1. **Missing from Tasks table** — `pipeline-readiness-gate` is not listed in the Tasks table (only `create` and `completion` are listed)
2. **Missing from Operating Protocol** — The Operating Protocol (steps 1-10) has no numbered step for the gate between traceability (step 4) and risk (step 5)
3. **Wrong trigger position** — The symbolic rule `spec-creation-pipeline-readiness` fires on `spec_sc_finalized == true` (during write step, step 9) instead of at the correct pipeline position between traceability and risk

### Impact

The gate is routinely skipped during spec creation. Specs proceed to the plan writer without validated SC dependency DAGs, atomicity checks, or phase structure validation. The `sc-pipeline-readiness.yaml` artifact is missing from the handoff, causing downstream pipeline failures that could have been caught earlier.

## Scope

**In-scope:**
- Add `pipeline-readiness-gate` to the spec-creation SKILL.md Tasks table
- Insert a numbered step for the pipeline-readiness gate between traceability (step 4) and risk (step 5) in the Operating Protocol
- Add Invocation table entry for `pipeline-readiness-gate`
- Update the symbolic rule `spec-creation-pipeline-readiness` trigger condition to fire at the correct pipeline position
- Existing `tasks/pipeline-readiness-gate.md` file is NOT modified

**Out-of-scope:**
- No changes to the pipeline-readiness-gate task file content
- No changes to other task files or other skills
- No behavioral or structural changes to the gate logic itself
- No changes to the `sc-pipeline-readiness.yaml` artifact schema

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `.opencode/skills/spec-creation/SKILL.md` | Modify | Add to Tasks table, insert Operating Protocol step, add Invocation entry, update symbolic rule trigger |

## Approach

The fix is confined to `.opencode/skills/spec-creation/SKILL.md`:

1. **Tasks table** — Add `pipeline-readiness-gate` row to the Tasks table alongside `create` and `completion`
2. **Operating Protocol** — Insert a new numbered step (step 4.5) between traceability (step 4) and risk (step 5), dispatching to the existing task file via `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")`
3. **Invocation table** — Add `pipeline-readiness-gate` entry with the canonical dispatch string
4. **Symbolic rule** — Update `spec-creation-pipeline-readiness` trigger condition from `spec_sc_finalized == true` to fire at the correct pipeline position (between traceability and risk, i.e., after traceability output is available and before risk analysis begins)

The existing `tasks/pipeline-readiness-gate.md` file is referenced but not modified.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|-------------------|
| SC-1 | `pipeline-readiness-gate` listed in spec-creation Tasks table | string | `grep` for `pipeline-readiness-gate` in SKILL.md Tasks table section |
| SC-2 | Numbered step for pipeline-readiness gate between traceability (step 4) and risk (step 5) in Operating Protocol | string | `grep` for step ordering: traceability step precedes pipeline-readiness-gate step which precedes risk step |
| SC-3 | Symbolic rule trigger condition updated to fire at correct pipeline position | string | `grep` for updated trigger condition in symbolic rules block |
| SC-4 | Invocation table includes task() call entry for pipeline-readiness-gate | string | `grep` for `pipeline-readiness-gate` in Invocation table |
| SC-5 | Existing `pipeline-readiness-gate.md` task file is NOT modified | structural | `git diff --stat` shows only SKILL.md changed |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Numbering shift breaks downstream references | Medium | Medium | All references use task names, not step numbers; verify by diff review |
| Gate blocks spec progression on false positives | Low | Medium | Gate is re-runnable per its own task definition; atomicity/dependency checks are deterministic |
| Existing symbolic rule still fires at wrong position | Low | High | Update trigger condition; verify by reading the symbolic rules block after change |

## Change Control

| Artifact | Cascade Trigger | Action on Revision |
|----------|----------------|-------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `spec-creation/SKILL.md` | Identify current Tasks table, Operating Protocol, Invocation table, and symbolic rules |
| Direct source search | `spec-creation/tasks/pipeline-readiness-gate.md` | Verify task file exists and its context (preceded by traceability, feeds into risk) |
| Direct source search | `spec-creation/tasks/traceability.md` | Verify traceability exit criteria and context |
| Direct source search | `spec-creation/tasks/risk.md` | Verify risk entry criteria and context |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
