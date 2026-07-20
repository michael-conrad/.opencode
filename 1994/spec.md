> **Full spec and artifacts: [`.issues/{N}/`](https://github.com/michael-conrad/.opencode/tree/issues-data/{N}/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/{N}/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The plan writer (`writing-plans-creation/tasks/write.md` and `writing-plans-creation/tasks/create.md`) produces structurally defective plans. During the implementation of issue #1993, the plan was regenerated 6 times, each time with different categories of defects. The plan writer's output format specification and the actual implementation pipeline requirements are misaligned.

## Root Cause Analysis

The plan writer has two root causes:

**Root Cause 1 — Format specification mismatch.** The `write.md` task card defines a plan format (split files, three-tier structure, dispatch indicators, RED/GREEN chains) that does not match how the implementation pipeline actually consumes plans. The implementation pipeline expects a single flat file with sequentially numbered steps, each step containing its own dispatch instruction. The split-file format and three-tier structure are artifacts that the orchestrator cannot execute.

**Root Cause 2 — No validation against implementation pipeline.** The plan writer has no validation gate that checks whether a generated plan can actually be executed by the implementation pipeline. It validates dispatch markers, approval cascade, and cross-references, but never validates that the plan structure matches what the orchestrator expects.

## Defect Categories Identified

### Category 1: Split-file format (write.md §Split File Convention)

The `write.md` format requires split files: `{N}/plan.md` (index) + `{N}/plan-{NN}-{slug}.md` (one per phase). The implementation pipeline executes a single flat file. Split files require the orchestrator to read multiple files and mentally merge them, which it cannot do — it executes steps sequentially from one file.

**Evidence:** Plan was initially written as split files (plan.md + plan-01.md + plan-02.md + plan-03.md). Rejected because the orchestrator cannot execute across multiple files.

### Category 2: Three-tier structure with nested sub-steps (write.md §Three-Tier Plan Structure)

The `write.md` format requires Tier 3 per-item chains with RED → GREEN → GREEN doublecheck → Checkpoint commit as sub-steps of a parent step. The parent step is marked `(**sub-agent**)`, but the sub-steps contain `(**sub-agent**)` dispatches — a sub-agent cannot dispatch sub-sub-agents.

**Evidence:** Plan-02.md had steps like `10. (**sub-agent**)` with sub-steps `10.1. RED (**sub-agent**)`, `10.2. GREEN (**sub-agent**)` — the sub-agent dispatched for step 10 cannot dispatch sub-agents for 10.1 and 10.2.

### Category 3: VbC steps with preloaded verification instructions (write.md §Phase Completion Block)

The `write.md` format requires a Phase Completion Block with VbC verification assertions. These were marked `(**clean-room**)` but contained inline verification instructions — preloaded context that violates the clean-room contract. A clean-room sub-agent receives only the phase file and independently determines what to verify from the SCs in the phase metadata.

**Evidence:** VbC steps contained text like "Verify: SKILL.md dispatch table has exactly 3 entries (SC-1). revise entry exists (SC-1). Pipeline section exists..." — this is preloaded context.

### Category 4: Missing dispatch instructions in plan steps

Plan steps marked `(**sub-agent**)` contained no `task()` call, no parameters, and no context specification. The orchestrator reading the plan has no instruction on what to dispatch or what context to pass.

**Evidence:** Initial plan steps said "Remove 8 fake dispatch entries from SKILL.md (**sub-agent**)." with no `task()` call, no target file, no SC reference.

### Category 5: Sub-agent context pollution — plan file reference

When dispatch instructions were added, they told the sub-agent to "Read plan.md Phase 1 section first" — forcing the sub-agent to load the entire plan file into its context. The sub-agent should receive only the spec issue number and independently read the spec to determine what to do.

**Evidence:** Steps contained `task(..., prompt: "execute RED for SC-1 from plan. Read \`plan.md\` Phase 1 section first")`.

### Category 6: Global pipeline gates missing or in wrong location

The implementation pipeline requires 10 gates per phase: coherence gate → pre-red-baseline → per-item RED/GREEN → VbC → audit → cross-validate → regression check → finishing checklist → review-prep → cleanup. The plan writer's format specification does not include these gates. When added manually, they were placed in the plan index (split file) instead of the single flat file.

**Evidence:** Initial plan had no global gates. When added, they were in plan.md (index) while phase steps were in plan-01.md (phase file) — the orchestrator cannot execute across split files.

### Category 7: No submodule sync step in plan preamble

The plan format has no requirement to sync submodules to trunk tip before starting implementation. During execution of #1993, the `.opencode` submodule was at a stale SHA, not at `main` tip. The plan must include a submodule sync step as a mandatory preamble step before any implementation work begins.

**Evidence:** `git submodule foreach "git checkout main && git pull"` was required before starting #1993 implementation. The plan had no such step.

### Category 8: Missing dispatch protocol admonishment blocks

The plan format has no mandatory admonishment blocks that define the three dispatch protocols. The orchestrator needs a clear reference at the top of every plan explaining:

- `(**inline**)` — orchestrator executes the step directly. No `task()` call. The step description contains the exact command or action to perform.
- `(**sub-agent**)` — orchestrator dispatches a sub-agent via `task()` with scoped context. The step description contains the exact `task()` call with target file, SC reference, and action. The sub-agent receives only `{issue_number, target_file, sc_reference, action}` — no plan file references, no orchestrator reasoning.
- `(**clean-room**)` — orchestrator dispatches a sub-agent via `task()` with routing metadata only. The step description MUST NOT contain inline verification instructions. The sub-agent receives only `{issue_number, scs}` and independently determines what to verify from the spec.

Without these admonishment blocks, the orchestrator has no binding reference for how to handle each dispatch type. During #1993 execution, the orchestrator dispatched `(**inline**)` steps as sub-agents because the protocol was not explicitly defined in the plan.

**Evidence:** Step 1 of #1993 plan was marked `(**inline**)` but was dispatched as a sub-agent. The orchestrator had no admonishment block telling it that inline means "execute directly, no task() call."

## Goals

- Fix the plan writer to produce a single flat file with sequentially numbered steps
- Every `(**sub-agent**)` step must include the exact `task()` call with target file, SC reference, and action description
- Every `(**clean-room**)` step must contain NO inline verification instructions — the sub-agent independently determines what to verify from SC metadata
- RED/GREEN chains must be flat (not nested) — each RED and GREEN is its own numbered step with its own dispatch indicator
- Global pipeline gates (coherence, pre-red-baseline, VbC, audit, cross-validate, regression, finishing checklist, review-prep, cleanup) must be included as numbered steps in the single flat file
- Sub-agent context must be limited to: target file path, SC reference, and action description — no plan file references
- Plan preamble must include submodule sync step before any implementation work
- Plan preamble must include dispatch protocol admonishment blocks defining inline/sub-agent/clean-room behavior

## Non-Goals

- Not changing the implementation pipeline architecture — only fixing the plan writer's output format
- Not changing how sub-agents execute — only fixing what context they receive

## Scope

### Files to modify

| File | Change |
|------|--------|
| `writing-plans-creation/tasks/write.md` | Replace split-file format with single flat file format. Remove three-tier structure. Remove nested sub-step chains. Add global pipeline gates to format spec. Add dispatch instruction requirements. Add clean-room context restrictions. Add submodule sync step to preamble requirements. Add dispatch protocol admonishment blocks to preamble requirements. |
| `writing-plans-creation/tasks/create.md` | Update pipeline steps reference to match flat file format. Remove split-file references. Update exit criteria to validate flat file structure. Add submodule sync to entry criteria. Add dispatch protocol admonishment validation to exit criteria. |
| `writing-plans-creation/tasks/validate.md` | Add validation rules for: flat file structure, dispatch instructions present on all sub-agent steps, no inline instructions on clean-room steps, no nested sub-agent steps, global pipeline gates present, dispatch protocol admonishment blocks present. |

### Files NOT to modify

- `writing-plans-creation/tasks/completion.md` — not related to format
- `writing-plans-creation/tasks/retroactive.md` — not related to format
- `writing-plans-creation/tasks/update.md` — not related to format
- `writing-plans-holistic/tasks/holistic-self-check.md` — not related to format

## Approach

### Phase 1: Fix `write.md` format specification

1. Replace split-file format with single flat file format
2. Remove three-tier structure (Tier 1/2/3) — replace with flat step list
3. Remove nested sub-step chains — each RED/GREEN/GREEN doublecheck/Checkpoint commit is its own numbered step
4. Add global pipeline gates as required sections in the flat file
5. Add dispatch instruction requirement: every `(**sub-agent**)` step MUST include `task(..., prompt: "...")` with target file, SC reference, and action
6. Add clean-room context restriction: every `(**clean-room**)` step MUST NOT contain inline verification instructions
7. Add sub-agent context restriction: context must be limited to `{issue_number, target_file, sc_reference, action}` — no plan file references
8. Add submodule sync step to preamble requirements: every plan MUST start with `git submodule update --init && git submodule foreach "git checkout $DEFAULT_BRANCH && git pull"` as step 0
9. Add dispatch protocol admonishment blocks to preamble requirements:

```
> **Dispatch Protocol:**
> - `(**inline**)` — Orchestrator executes directly. No `task()` call. The step description contains the exact command or action.
> - `(**sub-agent**)` — Orchestrator dispatches via `task()` with scoped context. The step description contains the exact `task()` call. Sub-agent receives only `{issue_number, target_file, sc_reference, action}`.
> - `(**clean-room**)` — Orchestrator dispatches via `task()` with routing metadata only. Step description MUST NOT contain inline instructions. Sub-agent receives only `{issue_number, scs}`.
```

### Phase 2: Fix `create.md` pipeline references

1. Remove split-file references from pipeline steps
2. Update exit criteria to validate flat file structure
3. Add validation that global pipeline gates are present
4. Add submodule sync to entry criteria
5. Add dispatch protocol admonishment validation to exit criteria

### Phase 3: Fix `validate.md` validation rules

1. Add flat file structure validation
2. Add dispatch instruction presence validation
3. Add clean-room context restriction validation
4. Add no-nested-sub-agent validation
5. Add global pipeline gates presence validation
6. Add dispatch protocol admonishment blocks presence validation

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | `write.md` format specifies single flat file (no split files) | `string` | grep for "split file" in write.md — 0 matches |
| SC-2 | `write.md` format has no three-tier structure (no Tier 1/2/3) | `string` | grep for "Tier 1" or "Tier 2" or "Tier 3" in write.md — 0 matches |
| SC-3 | `write.md` format has no nested sub-step chains | `string` | grep for "sub-steps" or "RED+green" in write.md — 0 matches |
| SC-4 | `write.md` format requires global pipeline gates in every plan | `string` | grep for "coherence gate" and "pre-red-baseline" in write.md — found |
| SC-5 | `write.md` format requires `task()` call on every `(**sub-agent**)` step | `string` | grep for "task(..." in write.md dispatch section — found |
| SC-6 | `write.md` format prohibits inline instructions on `(**clean-room**)` steps | `string` | grep for "clean-room" in write.md — verify no inline verification language follows |
| SC-7 | `write.md` format limits sub-agent context to `{issue_number, target_file, sc_reference, action}` | `semantic` | Sub-agent reads write.md — confirms context restriction section present |
| SC-8 | `create.md` exit criteria validates flat file structure | `string` | grep for "flat file" or "single file" in create.md exit criteria — found |
| SC-9 | `validate.md` validates dispatch instructions present on all sub-agent steps | `string` | grep for "dispatch instruction" or "task()" in validate.md — found |
| SC-10 | `validate.md` validates no nested sub-agent steps | `string` | grep for "nested" or "sub-agent.*sub-agent" in validate.md — found |
| SC-11 | `validate.md` validates global pipeline gates present | `string` | grep for "global pipeline" or "coherence gate" in validate.md — found |
| SC-12 | `write.md` preamble requires submodule sync step | `string` | grep for "submodule" in write.md preamble section — found |
| SC-13 | `create.md` entry criteria includes submodule sync | `string` | grep for "submodule" in create.md entry criteria — found |
| SC-14 | `write.md` preamble requires dispatch protocol admonishment blocks | `string` | grep for "Dispatch Protocol" in write.md preamble section — found |
| SC-15 | `validate.md` validates dispatch protocol admonishment blocks present | `string` | grep for "Dispatch Protocol" in validate.md — found |

## Risk and Edge Cases

- **Risk:** Existing plans in `.issues/` use the old split-file format. They will not be re-validated. Mitigation: This spec only changes the format going forward — existing plans are grandfathered.
- **Risk:** The `write.md` format specification is 190 lines and deeply entangled with the split-file convention. Rewriting it requires careful surgery. Mitigation: Phase 1 handles the rewrite as a single focused pass.
- **Edge case:** Single-phase plans may not need all 10 global pipeline gates (e.g., no cross-phase regression check). Mitigation: All 10 gates are mandatory regardless of phase count — the orchestrator determines which are no-ops.
- **Edge case:** Repos without `.gitmodules` should skip the submodule sync step. Mitigation: The step checks for `.gitmodules` existence before running.

## Dependencies

- Issue #1992 — Sub-agents MUST NOT dispatch sub-agents (architectural invariant)
- Issue #1993 — Refactor spec-creation skill (demonstrated the plan writer defects)

## Call to Action

Review and approve the spec on this issue.