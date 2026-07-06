# [SPEC-FIX] Enforce writing-plans pipeline discipline — prevent plan-by-sub-agent bypass

## Problem

During implementation of #1697, the orchestrator violated the writing-plans pipeline protocol 10 times. Every violation was a known, documented rule that was bypassed. The root cause is that the writing-plans skill's 22-step pipeline is not enforced as a mandatory gate — the orchestrator can dispatch a single sub-agent with a custom prompt and call it a "plan."

### Violations

| # | Violation | Rule | Consequence |
|---|-----------|------|-------------|
| 1 | No local spec file created | writing-plans create.md Prerequisite 2: spec stored at `.issues/{N}/spec.md` | Plan created without verified spec content |
| 2 | Entire 22-step pipeline skipped | writing-plans SKILL.md §Operating Protocol — 22 mandatory steps | No research, readiness, structure, solve, write, clean-room, revisit, validate, audit-fidelity, audit-concern, or completion |
| 3 | No feature branch before plan artifacts | writing-plans create.md §Pipeline execution discipline | Plan artifacts not isolated |
| 4 | No local-issues sync | writing-plans create.md §Pipeline execution discipline | `.issues/` writes unsynced |
| 5 | No plan artifacts committed | writing-plans create.md §Pipeline execution discipline | Plan lost after session |
| 6 | Sub-issues created without proper plan | critical-rules-006: multi-task plan requires verified sub-issue structure | Sub-issues auto-rejected as defective |
| 7 | Preloaded context in task() prompt | approval-gate SKILL.md §DISPATCH_GATE — Forbidden in task() Prompts | Sub-agent received orchestrator bias |
| 8 | No Z3 checks | writing-plans create.md steps 3,5,7,9,12,14,16,18,20,22 | No constraint verification |
| 9 | No adversarial audits | writing-plans create.md steps 17-20 | No fidelity or concern separation audit |
| 10 | No completion step | writing-plans create.md step 21 | No lifecycle event |

### Root Causes

1. **No mandatory gate enforcing the writing-plans pipeline.** The orchestrator can skip the entire 22-step pipeline and dispatch a single sub-agent. There is no gate that says "you must follow the pipeline."

2. **No pre-plan readiness check.** The writing-plans create task requires a local spec file, but there is no gate that verifies it exists before allowing plan creation.

3. **No post-plan validation that the pipeline was followed.** After a plan is created, there is no check that the 22-step pipeline was actually executed.

4. **The `for_pr` gap-fill auto-creates plans without following the pipeline.** The approval-gate's gap-fill for `for_pr` scope auto-creates specs and plans, but the plan creation bypasses the writing-plans pipeline.

5. **Inconsistent entry point naming between spec-creation and writing-plans.** spec-creation uses `write` as its entry point task; writing-plans uses `create`. This inconsistency forces the agent to remember which skill uses which name, increasing cognitive load and creating a vector for dispatch errors.

## Scope

**In scope:**
- Add a mandatory gate to `approval-gate` that verifies the writing-plans pipeline was followed before accepting a plan
- Add a pre-plan readiness check to `writing-plans` that verifies local spec file exists
- Add a post-plan validation step that checks pipeline completeness
- Fix the `for_pr` gap-fill to route through the writing-plans pipeline instead of dispatching a single sub-agent
- Standardize entry point naming: rename spec-creation's `write` task to `create` so both skills use `create` as their entry point
- Update all cross-references across the skill deck and guidelines
- Behavioral enforcement tests for all changes

**Out of scope:**
- Changes to the writing-plans 22-step pipeline itself (it's correct — the problem is enforcement)
- Changes to spec-creation's internal pipeline steps (requirements, decompose, traceability, etc.)

## Approach

Four changes:

### Change 1: `approval-gate` — Add `verify-plan-pipeline` task

Add a task that checks whether the writing-plans 22-step pipeline was followed. The task reads the plan artifacts and verifies: local spec file exists, feature branch exists, Z3 check artifacts exist, audit artifacts exist, completion artifact exists. Returns PASS/FAIL.

### Change 2: `writing-plans` — Add `pre-plan-readiness` task

Add a task that verifies: spec is stored at `.issues/{N}/spec.md`, feature branch exists, `local-issues sync` has been run. Returns BLOCKED if any prerequisite is missing.

### Change 3: `approval-gate` — Fix `auto-dispatch` for `for_pr` gap-fill

Fix the `auto-dispatch` task for `for_pr` gap-fill to route plan creation through the writing-plans pipeline (task: `create`) instead of dispatching a single sub-agent with a custom prompt.

### Change 4: Entry point naming standardization — rename spec-creation's `write` to `create`

Rename spec-creation's `write` task to `create` to match writing-plans. `create` is the better choice because it is the more general term (covers the full pipeline, not just the writing step) and is already used by writing-plans.

#### Files to update (spec-creation `write` → `create`):

**spec-creation SKILL.md:**
- Trigger Dispatch Table: change `"write spec"` → `"create spec"`, task `write` → task `create`
- Task list: `write` → `create`
- Invocation table: `"execute write task from spec-creation"` → `"execute create task from spec-creation"`
- Operating Protocol step 10: `[sub-task: write]` → `[sub-task: create]`

**spec-creation/tasks/completion.md:**
- Line 17: `spec-creation --task write` → `spec-creation --task create`

**guidelines/140-planning-spec-creation.md:**
- Line 174: `spec-creation (--task write)` → `spec-creation (--task create)`

**adversarial-audit/tasks/test-quality-audit.md:**
- Lines 217-218: `spec-creation/tasks/write.md` → `spec-creation/tasks/create.md`

**approval-gate/tasks/verify-authorization/sc-traceability-check.md:**
- Lines 7, 30, 74: `spec-creation/tasks/write.md` → `spec-creation/tasks/create.md`

**Rename file:** `spec-creation/tasks/write.md` → `spec-creation/tasks/create.md`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `approval-gate` has a `verify-plan-pipeline` task that checks pipeline completeness | `string` | `grep -q "verify-plan-pipeline" .opencode/skills/approval-gate/SKILL.md` |
| SC-2 | `writing-plans` has a `pre-plan-readiness` task that verifies local spec file and feature branch | `string` | `grep -q "pre-plan-readiness" .opencode/skills/writing-plans/SKILL.md` |
| SC-3 | `approval-gate` auto-dispatch for `for_pr` gap-fill routes through writing-plans create task | `string` | `grep -q "writing-plans.*create" .opencode/skills/approval-gate/tasks/auto-dispatch.md` |
| SC-4 | spec-creation and writing-plans use the same entry point task name: both use `create` | `string` | Compare Trigger Dispatch Table entry point in both SKILL.md files — both must map to task `create` |
| SC-5 | All cross-references to spec-creation's `write` task updated to `create` | `string` | `grep -r "spec-creation.*--task write" .opencode/skills/ .opencode/guidelines/` returns zero matches |
| SC-6 | All cross-references to `spec-creation/tasks/write.md` updated to `spec-creation/tasks/create.md` | `string` | `grep -r "spec-creation/tasks/write" .opencode/skills/ .opencode/guidelines/` returns zero matches |
| SC-7 | Behavioral test: agent follows writing-plans 22-step pipeline when creating a plan under `for_pr` scope | `behavioral` | `opencode-cli run` with behavioral test → stderr shows pipeline steps dispatched |
| SC-8 | Behavioral test: agent does NOT dispatch a single sub-agent with custom prompt for plan creation | `behavioral` | `opencode-cli run` with behavioral test → stderr shows no single sub-agent dispatch for plan |

## Dependencies

- None — all changes are to separate files

## Edge Cases

- **Single-task plans** (one phase) use `{N}/plan.md` as the sole file — the pipeline check should accept this format
- **Retroactive plans** use the same 22-step pipeline but with Step 2 loading existing spec body — the pipeline check should accept this variant
- **Existing plans are not affected** — the gate only applies to new plan creation
- **Entry point rename** must update all cross-references in other skills that dispatch to spec-creation — the SC-5 and SC-6 grep patterns verify completeness
- **The `write` sub-task within writing-plans' `create` workflow is NOT affected** — it is an internal sub-step name, not a top-level entry point
