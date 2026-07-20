## Problem

The `writing-plans` skill and its sub-skills have multiple structural defects preventing proper pipeline dispatch:

1. **`writing-plans-creation` missing Trigger Dispatch Table** — 11 pipeline steps in `create.md` have no TDT entries, making them undispatchable
2. **`writing-plans` parent TDT incomplete** — Only 3 high-level entries (`create`, `update`, `holistic-self-check`) but `create.md` defines 11+ pipeline steps needing individual dispatch
3. **Contract paths incorrect** — `create.md` references `.opencode/skills/writing-plans/contracts/` but actual contracts are at `.opencode/skills/writing-plans-creation/contracts/`
4. **Orphaned task** — `pre-plan-readiness.md` exists in task list but not in any TDT
5. **`retroactive.md` not directly dispatchable** — Has its own pipeline but no TDT entry
6. **`clean-room.md` only reachable via audit skill** — No direct dispatch path
7. **Missing canonical dispatch strings** — `writing-plans` Invocation section lacks step-level dispatch strings per DISPATCH_GATE protocol

Additionally, issue #1962 requires `create` to dispatch through `plan-creation-pipeline` with Z3 gates instead of bare inspection — this fix must be incorporated.

## Fix

Comprehensive remediation across three skill files:

### `writing-plans/SKILL.md`
- Add 11 pipeline step entries to Trigger Dispatch Table
- Add canonical dispatch strings for all steps in Invocation
- Update `create` TDT entry to route through `plan-creation-pipeline` per #1962

### `writing-plans-creation/SKILL.md`
- Add complete Trigger Dispatch Table with all 16 task files
- Add Invocation section with canonical dispatch strings

### `writing-plans-creation/tasks/create.md`
- Fix all 11 contract path references to point to `writing-plans-creation/contracts/`
- Replace feasibility verification step with `plan-creation-pipeline` dispatch per #1962
- Add `solve` readiness gate to `pre-plan-readiness.md`

### `writing-plans-creation/tasks/pre-plan-readiness.md`
- Add mandatory `solve` readiness gate per #1962

### Task file dispositions
- `pre-plan-readiness.md` — integrate into pipeline as step 4a (artifact validation) with TDT entry
- `retroactive.md` — add TDT entry for "retroactive plan" / "backfill plan" triggers
- `clean-room.md` — add TDT entry for "clean-room plan" trigger

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `writing-plans` TDT has entries for all 11 pipeline steps from `create.md` | structural |
| SC-2 | `writing-plans-creation` has complete TDT with all 16 tasks | structural |
| SC-3 | All contract paths in `create.md` resolve to existing files | structural |
| SC-4 | `create` task dispatches to `plan-creation-pipeline` with Z3 gates | behavioral |
| SC-5 | `pre-plan-readiness` has `solve` readiness gate | structural |
| SC-6 | `retroactive.md` and `clean-room.md` have TDT entries | structural |
| SC-7 | All canonical dispatch strings follow DISPATCH_GATE format | structural |
| SC-8 | No orphaned tasks in `writing-plans-creation/tasks/` | structural |

## Affected Files

| File | Action |
|------|--------|
| `.opencode/skills/writing-plans/SKILL.md` | Rewrite TDT and Invocation |
| `.opencode/skills/writing-plans-creation/SKILL.md` | Add TDT and Invocation |
| `.opencode/skills/writing-plans-creation/tasks/create.md` | Fix contract paths, add plan-creation-pipeline dispatch, add solve gate |
| `.opencode/skills/writing-plans-creation/tasks/pre-plan-readiness.md` | Add solve readiness gate |
| `.opencode/skills/writing-plans-creation/tasks/retroactive.md` | Add TDT entry (no code change) |
| `.opencode/skills/writing-plans-creation/tasks/clean-room.md` | Add TDT entry (no code change) |