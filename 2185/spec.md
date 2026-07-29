> **Full spec and artifacts: [`.opencode/.issues/2185/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2185)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2185/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Add automatic SC-by-SC implementation audit to the `verify-already-implemented` gate, triggered on spec approval (not user utterance), with a three-way routing decision: fully implemented (autoclose), partially implemented (remediation loop), or not implemented (normal pipeline). The SC-by-SC audit is a task card under the `audit` skill — `verify-already-implemented` dispatches to it rather than performing inline verification.

## Background

The `verify-already-implemented` gate exists in the approval-gate-scope workflow but has three defects:

1. **Manual trigger**: It fires only when the user says "verify already implemented" — not automatically on spec approval. This means every approved spec routes to plan creation even when the work is already done.
2. **Binary decision**: The gate produces only YES (autoclose) or NO (normal implementation). There is no PARTIALLY_IMPLEMENTED branch for specs where some SCs are already satisfied by existing code.
3. **No SC-by-SC audit**: The gate does not verify each success criterion independently against the codebase. It performs a coarse "is this already implemented?" check without per-SC evidence.

**Architectural correction (v2):** The SC-by-SC implementation audit is a task card under the `audit` skill (`audit/tasks/implementation-audit.md`), not inline logic in `verify-already-implemented.md`. This maintains proper `skill()`/`task()` discipline: the audit skill owns verification, approval-gate-scope owns routing. The `verify-already-implemented` task dispatches to `skill({name: "audit"})` → `task("execute implementation-audit from audit")` and receives a per-SC PASS/FAIL result contract.

The fix adds: (a) auto-dispatch on approval event, (b) SC-by-SC audit via audit skill dispatch, (c) three-way routing with a remediation loop for partial implementation.

## Not Included

- Changes to the SC-by-SC audit methodology itself (how each SC is verified against the codebase) — the existing verification approach is preserved
- Changes to the normal implementation pipeline (plan → implement → PR) — only the routing to it is affected
- Changes to the autoclose behavior — existing autoclose path is preserved unchanged
- Behavioral enforcement tests — these are scoped to a separate implementation phase

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `verify-already-implemented` gate fires automatically on spec approval — triggered by agent intent (approval event), not by user utterance | `behavioral` | `opencode run` with approval prompt → verify agent dispatches verify-already-implemented without user saying "verify already implemented" |
| SC-2 | The gate dispatches SC-by-SC audit to `skill({name: "audit"})` → `task("execute implementation-audit from audit")` and receives per-SC PASS/FAIL evidence | `behavioral` | `opencode run` with partially-implemented spec → verify agent dispatches audit skill for SC-by-SC verification |
| SC-3 | ALL SCs PASS → close issue, update status, halt | `behavioral` | `opencode run` with fully-implemented spec → verify agent closes issue without creating a plan |
| SC-4a | SOME SCs PASS, SOME FAIL → create mini-plan from failing SCs only | `behavioral` | `opencode run` with partially-implemented spec → verify agent creates mini-plan from failing SCs only |
| SC-4b | Mini-plan is implemented on a feature branch | `behavioral` | `opencode run` with partially-implemented spec → verify agent creates feature branch for remediation |
| SC-4c | After implementation, re-audit the failing SCs | `behavioral` | `opencode run` with partially-implemented spec → verify agent re-dispatches implementation-audit after remediation |
| SC-4d | Remediation loop terminates after max 3 iterations and escalates | `behavioral` | `opencode run` with spec that fails remediation 3 times → verify agent escalates instead of infinite loop |
| SC-5 | ALL SCs FAIL → proceed with normal pipeline (plan → implement → PR) | `behavioral` | `opencode run` with not-implemented spec → verify agent routes to normal implementation pipeline |
| SC-6 | Result contract supports PARTIALLY_IMPLEMENTED status | `string` | grep for PARTIALLY_IMPLEMENTED in verify-authorization/verify-already-implemented.md result contract |
| SC-7 | Auto-dispatch routes PARTIALLY_IMPLEMENTED to implementation-pipeline remediate-partial | `behavioral` | `opencode run` with PARTIALLY_IMPLEMENTED result → verify agent routes to implementation-pipeline remediate-partial |
| SC-8 | approval-gate-scope/SKILL.md full-path workflow includes remediation step | `string` | grep for remediation step in full-path workflow |
| SC-9 | implementation-pipeline/SKILL.md TDT has remediate-partial entry | `string` | grep for remediate-partial in implementation-pipeline TDT |
| SC-10 | auto-dispatch-table.md has PARTIALLY_IMPLEMENTED row | `string` | grep for PARTIALLY_IMPLEMENTED in auto-dispatch-table.md |
| SC-11 | approval-gate/SKILL.md TDT auto-dispatches verify-already-implemented on approval | `behavioral` | `opencode run` with approval event → verify agent dispatches verify-already-implemented via approval-gate TDT |
| SC-12 | `audit/tasks/implementation-audit.md` exists and performs SC-by-SC verification against the codebase | `structural` | File exists at `.opencode/skills/audit/tasks/implementation-audit.md` |
| SC-13 | audit/SKILL.md TDT has implementation-audit entry | `string` | grep for implementation-audit in audit/SKILL.md TDT |

## Requirements

1. The `verify-already-implemented` gate SHALL fire automatically when a spec is approved, triggered by the approval event (not by user utterance).
2. The gate SHALL dispatch SC-by-SC implementation audit to `skill({name: "audit"})` → `task("execute implementation-audit from audit")` and receive per-SC PASS/FAIL evidence.
3. If ALL SCs PASS, the gate SHALL close the issue, update status, and halt.
4. If SOME SCs PASS and SOME FAIL (partial implementation), the gate SHALL create a mini-plan from failing SCs only, implement on a feature branch, re-audit, and close on success.
5. The remediation loop SHALL terminate after max 3 iterations and escalate if still failing.
6. If ALL SCs FAIL, the gate SHALL proceed with the normal pipeline (plan → implement → PR).
7. The result contract SHALL support PARTIALLY_IMPLEMENTED as a third status value.
8. The auto-dispatch SHALL route PARTIALLY_IMPLEMENTED results to the implementation-pipeline remediate-partial entry.
9. The approval-gate TDT SHALL auto-dispatch verify-already-implemented on approval events.
10. The audit skill SHALL have an `implementation-audit` task card that performs SC-by-SC verification against the codebase.

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1, SC-11 | Update approval-gate/SKILL.md TDT to auto-dispatch verify-already-implemented on approval |
| 2 | SC-2, SC-12, SC-13 | Create `audit/tasks/implementation-audit.md` task card; add implementation-audit entry to audit/SKILL.md TDT; update verify-already-implemented.md to dispatch to audit skill instead of inline verification |
| 3 | SC-4a, SC-4b, SC-4c, SC-4d, SC-5 | Add remediation loop: mini-plan from failing SCs, feature branch, implement, re-audit, max 3 iterations, escalate |
| 4 | SC-6 | Update verify-authorization/verify-already-implemented.md result contract with PARTIALLY_IMPLEMENTED status |
| 5 | SC-7 | Update auto-dispatch.md Step 0 to route PARTIALLY_IMPLEMENTED to implementation-pipeline remediate-partial |
| 6 | SC-8 | Update approval-gate-scope/SKILL.md full-path workflow with remediation step |
| 7 | SC-9 | Add remediate-partial entry to implementation-pipeline/SKILL.md TDT |
| 8 | SC-10 | Update auto-dispatch-table.md with PARTIALLY_IMPLEMENTED row |

## Dependencies

- `approval-gate` skill — TDT update for auto-dispatch
- `approval-gate-scope` skill — core changes to verify-already-implemented, auto-dispatch, and workflow
- `audit` skill — new `implementation-audit` task card and TDT entry
- `implementation-pipeline` skill — new remediate-partial TDT entry
- `git-workflow` skill — branch creation for remediation (existing, no changes needed)
- `writing-plans` skill — mini-plan creation (existing, no changes needed)

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1 (auto-dispatch on approval) | SC-1, SC-11 | Phase 1 |
| R2 (SC-by-SC audit via audit skill) | SC-2 | Phase 1 |
| R3 (all PASS → autoclose) | SC-3 | Phase 1 |
| R4 (partial → remediation) | SC-4a, SC-4b, SC-4c, SC-4d | Phase 3 |
| R5 (max 3 iterations) | SC-4d | Phase 3 |
| R6 (all FAIL → normal pipeline) | SC-5 | Phase 3 |
| R7 (PARTIALLY_IMPLEMENTED contract) | SC-6 | Phase 4 |
| R8 (auto-dispatch routing) | SC-7 | Phase 5 |
| R9 (TDT auto-dispatch) | SC-11 | Phase 1 |
| R10 (audit task card) | SC-12, SC-13 | Phase 2 |
| — (workflow documentation) | SC-8 | Phase 6 |
| — (pipeline TDT) | SC-9 | Phase 7 |
| — (dispatch table) | SC-10 | Phase 8 |

## Phases

### Phase 1: Decision classification (SC-1, SC-2, SC-3, SC-11)
- Update `approval-gate/SKILL.md` TDT to auto-dispatch verify-already-implemented on approval
- Update `verify-already-implemented.md` Step 4 decision table to three-way routing
- Replace inline SC-by-SC verification in `verify-already-implemented.md` with dispatch to `skill({name: "audit"})` → `task("execute implementation-audit from audit")`
- Files: `.opencode/skills/approval-gate/SKILL.md`, `.opencode/skills/approval-gate-scope/tasks/verify-already-implemented.md`

### Phase 2: Audit task card (SC-12, SC-13)
- Create `audit/tasks/implementation-audit.md` — task card that performs SC-by-SC verification against the codebase, producing per-SC PASS/FAIL evidence
- Add `implementation-audit` entry to `audit/SKILL.md` Trigger Dispatch Table
- Files: `.opencode/skills/audit/tasks/implementation-audit.md`, `.opencode/skills/audit/SKILL.md`

### Phase 3: Remediation loop (SC-4a, SC-4b, SC-4c, SC-4d, SC-5)
- Add Step 5.5 remediation loop: extract failing SCs → create mini-plan → create feature branch → implement → re-audit → close or escalate
- Max 3 iterations, then escalate
- Files: `.opencode/skills/approval-gate-scope/tasks/verify-already-implemented.md`

### Phase 4: Contract update (SC-6)
- Add PARTIALLY_IMPLEMENTED to result contract status enum
- Files: `.opencode/skills/approval-gate-scope/tasks/verify-authorization/verify-already-implemented.md`

### Phase 5: Auto-dispatch routing (SC-7)
- Update auto-dispatch.md Step 0 to route PARTIALLY_IMPLEMENTED to implementation-pipeline remediate-partial
- Files: `.opencode/skills/approval-gate-scope/tasks/verify-authorization/auto-dispatch.md`

### Phase 6: Workflow documentation (SC-8)
- Update approval-gate-scope/SKILL.md full-path workflow with remediation step between Step 13 and Step 14
- Files: `.opencode/skills/approval-gate-scope/SKILL.md`

### Phase 7: Pipeline TDT (SC-9)
- Add remediate-partial entry to implementation-pipeline/SKILL.md Trigger Dispatch Table
- Files: `.opencode/skills/implementation-pipeline/SKILL.md`

### Phase 8: Dispatch table (SC-10)
- Add PARTIALLY_IMPLEMENTED row to auto-dispatch-table.md Context Differentiation table
- Files: `.opencode/skills/approval-gate-scope/enforcement/auto-dispatch-table.md`

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-29 | v2 — Architectural correction: SC-by-SC audit moved to `audit/tasks/implementation-audit.md` task card; verify-already-implemented dispatches to audit skill instead of inline verification. Added Phase 2 (audit task card). Split SC-4 into atomic SCs (SC-4a through SC-4d). Added SC-12, SC-13 for audit task card. Fixed traceability gap (SC-9, SC-10, SC-11 now mapped). Updated affected files, dependencies, and phases. | Architectural correction — audit skill owns verification, approval-gate-scope owns routing. Validation: traceability gap (SC-9/SC-10/SC-11 unmapped), atomicity (SC-4 compound). | Agent (architectural correction) |
