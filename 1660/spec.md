---
issue: 1660
repo: .opencode
title: "[SPEC-FIX] Clean-room plan generation must produce complete plan, not minimal"
status: DRAFT
labels: ["[SPEC-FIX]"]
created: 2026-07-03
updated: 2026-07-09
---

# [SPEC-FIX] Clean-room plan generation must produce complete plan, not minimal

## Summary

The `writing-plans` skill's clean-room plan generation step (Step 11 in `tasks/create.md`) produces a minimal plan that omits mandatory pipeline gates (TDD, adversarial audit, cross-validate, review-prep). This defeats the purpose of clean-room generation — the fidelity comparison cannot detect missing steps if the clean-room plan itself is missing them.

## Root Cause

The clean-room sub-agent in Step 11 receives the generic prompt `"execute write task from writing-plans"` — the same prompt as the standard write step (Step 10) — with no explicit instruction to produce a complete plan. The `write.md` task file has no clean-room-specific instructions. The sub-agent defaults to a minimal "delete-and-verify" approach because the prompt does not signal that completeness expectations differ from the standard write path.

## Required Fix

The clean-room plan generation must produce a plan that is **as complete as the spec requires**. The approach has three components:

### Component A: Prompt Update (create.md Step 11)

Update the Step 11 prompt to reference the `implementation-pipeline/SKILL.md` Trigger Dispatch Table as the completeness standard, rather than hardcoding a gate list. This preserves clean-room independence — the sub-agent independently discovers the mandatory gates from the dispatch table.

**New prompt:** `"execute clean-room task from writing-plans — produce a complete plan that includes ALL mandatory pipeline gates from the implementation-pipeline/SKILL.md Trigger Dispatch Table. The plan must be as complete as the spec requires — do not omit any gate."`

**Note:** The dispatch target changes from `write` to `clean-room` to avoid overwriting the plan being audited (see #1452). The `clean-room.md` task file returns the plan as in-memory markdown, never writing to `.issues/{N}/plan.md`.

### Component B: Completeness Checklist (write.md)

Add a self-verification checklist in `write.md` that the clean-room sub-agent must confirm before returning. The checklist enumerates the gate categories from the dispatch table:

- [ ] RED/GREEN TDD structure for behavioral SCs
- [ ] Adversarial audit step
- [ ] Cross-validation step
- [ ] Regression check step
- [ ] Review-prep step
- [ ] All mandatory admonishments (compliance, one-step-at-a-time, self-remediation)
- [ ] Dispatch mode indicators on every step (`(**sub-agent**)`, `(**inline**)`, `(**clean-room**)`)
- [ ] Proper evidence type handling (behavioral SCs require behavioral testing, not structural)

### Component C: Validation Step (new Step 11a in create.md)

Add a post-generation validation step between Step 11 (clean-room generation) and Step 12 (Z3 check) that validates the clean-room plan against the `implementation-pipeline/SKILL.md` dispatch table. This catches cases where both the main plan and clean-room plan share the same defect (single point of failure).

**New Step 11a:** `(**sub-agent**) Clean-room plan validation — validate clean-room plan against implementation-pipeline/SKILL.md Trigger Dispatch Table. Verify ALL mandatory gates are present. BLOCK if any gate is missing.`

## Affected Files

| File | Change |
|------|--------|
| `skills/writing-plans/tasks/create.md` | Update Step 11 prompt to reference dispatch table and dispatch to `clean-room` task; add new Step 11a (validation); renumber subsequent steps |
| `skills/writing-plans/tasks/write.md` | Add clean-room completeness checklist for self-verification |
| `skills/writing-plans/SKILL.md` | Update Operating Protocol Step 11 description to reflect new prompt; add Step 11a |
| `skills/writing-plans/tasks/operating-protocol.md` | Update Step 11 description to reflect new prompt and dispatch target; add Step 11a |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Clean-room plan includes RED/GREEN TDD structure for behavioral SCs | `string` | Read clean-room plan result contract; check for RED/GREEN structure |
| SC-2 | Clean-room plan includes adversarial audit step | `string` | Read clean-room plan result contract; check for "adversarial audit" |
| SC-3 | Clean-room plan includes cross-validate step | `string` | Read clean-room plan result contract; check for "cross-validate" |
| SC-4 | Clean-room plan includes review-prep step | `string` | Read clean-room plan result contract; check for "review-prep" |
| SC-5 | Clean-room plan includes all mandatory admonishments | `string` | Read clean-room plan result contract; check for compliance/one-step/self-remediation admonishments |
| SC-6 | Clean-room plan has dispatch mode indicators on every step | `string` | Read clean-room plan result contract; check for `(**sub-agent**)`, `(**inline**)`, `(**clean-room**)` |
| SC-7 | Behavioral: plan-fidelity audit can detect missing steps by comparing clean-room vs existing plan | `behavioral` | Create a plan with 3 known omissions (omit RED phase, omit cross-validate, omit review-prep). Run plan-fidelity audit. Verify it flags ALL 3 omissions. PASS criterion: all 3 omissions detected. |
| SC-8 | Clean-room plan is independently generated (not a template copy of the existing plan) | `semantic` | Sub-agent reads both clean-room plan and main plan. Judges whether clean-room plan was independently generated or is a template copy with different wording. |
| SC-9 | Non-clean-room path (Step 10) still produces correct plans after changes | `behavioral` | Run the full writing-plans pipeline. Verify Step 10 produces a valid plan with all required sections per write.md format requirements. |
| SC-10 | Clean-room plan covers ALL mandatory gates from implementation-pipeline/SKILL.md Trigger Dispatch Table | `string` | Extract all gate labels from dispatch table. Read clean-room plan result contract. Check each gate label is present. All must be present. |
| SC-11 | Step 11a (validation step) exists in create.md operating protocol | `structural` | `grep` for "Step 11a" or "Clean-room plan validation" in create.md |
| SC-12 | write.md contains clean-room completeness checklist | `structural` | `grep` for "completeness checklist" or "Clean-room completeness" in write.md |
| SC-13 | operating-protocol.md Step 11 updated to reflect new prompt and dispatch target | `structural` | `grep` for "clean-room task" in operating-protocol.md Step 11 |
| SC-14 | Step 11 dispatches `clean-room` task, not `write` task | `string` | grep for dispatch string in create.md — must reference "clean-room task" not "write task" |
| SC-15 | Clean-room plan does not write to `.issues/{N}/plan.md` | `behavioral` | Run pipeline, verify plan file is not overwritten by clean-room step |

## Design Decisions

### Why reference the dispatch table instead of hardcoding gates

Hardcoding the gate list in the prompt ("include RED/GREEN, audit, cross-validate, review-prep") undermines clean-room independence — the sub-agent is told what to include rather than discovering it independently. Referencing the `implementation-pipeline/SKILL.md` Trigger Dispatch Table preserves clean-room independence: the sub-agent reads the dispatch table, discovers the gates, and includes them. If the dispatch table changes in the future, the clean-room plan automatically reflects the new gates without requiring a prompt update.

### Why add a validation step (Step 11a)

Both the main plan (Step 10) and clean-room plan (Step 11) dispatch the same `write` task. If `write.md` has a defect that causes both to omit a gate, the fidelity audit (Step 17) won't catch it — both plans will be missing the same gate. The validation step validates the clean-room plan against the dispatch table independently, catching this single-point-of-failure scenario.

### Why SC-8 uses semantic evidence

SC-8 ("independently generated") cannot be verified by grep — it requires a sub-agent to read both plans and judge whether the clean-room plan was independently produced or is a template copy. This is a semantic judgment, not a string match.

### Why dispatch target changes from `write` to `clean-room`

Issue #1452 identified that Step 11 dispatches the `write` task, which writes to `.issues/{N}/plan.md`, overwriting the plan that Step 10 just created. The `clean-room.md` task file returns the plan as in-memory markdown, never writing to disk. This fix is incorporated here — #1660 and #1452 are complementary and should be implemented together, with #1452's dispatch target change applied first.

### Why verification methods for SC-1 through SC-6 and SC-10 read the result contract instead of grepping a file

The clean-room plan is returned as a result contract field (in-memory markdown), not written to disk. Verification methods must account for this — read the result contract, not grep a file.

## Cross-References

- #1413 — Introduced Step 11 (clean-room plan generation) into the pipeline
- #1452 — Clean-room plan generator overwrites plan being audited (dispatch target fix — complementary)
- #1374 — writing-plans create.md Plan Format Requirements hardcodes step sequence (cross-cutting — different section of create.md)
- #1673 — Phase 6 enforces Step 11 as mandatory gate
- #1703 — Documents pipeline violations; its own clean-room plan is minimal (27 lines)
- #1372 — Defines canonical plan format (14 sections, 12 validation rules)
- `implementation-pipeline/SKILL.md` — Trigger Dispatch Table (source of truth for mandatory gates)

## Implementation Ordering

#1660 and #1452 are complementary fixes to Step 11. Recommended implementation order:
1. #1452 first — fix dispatch target from `write` to `clean-room`
2. #1660 second — fix completeness of clean-room plan (this spec, rebased on #1452's changes)

#1374 affects `create.md` §Plan Format Requirements (different section from Step 11/11a). No ordering dependency — can be implemented independently.

## Audit History

### 2026-07-09 — Initial Audit (DiMo)

**Findings:**
1. **RELEVANT** — problem still exists in code. Step 11 still uses generic prompt.
2. **NO CONFLICTS** — no direct conflicts with other open specs.
3. **COMPLEMENTARY to #1452** — both fix Step 11 defects. Implementation ordering specified.
4. **MISSING SCs ADDED** — SC-11 (Step 11a existence), SC-12 (write.md checklist), SC-13 (operating-protocol.md update), SC-14 (dispatch target), SC-15 (no overwrite).
5. **VERIFICATION METHODS FIXED** — SC-1 through SC-6 and SC-10 now read result contract instead of grepping file.
6. **AFFECTED FILES EXPANDED** — operating-protocol.md added.
7. **CROSS-CUTTING NOTED** — #1452 (dispatch target) and #1374 (Plan Format Requirements) acknowledged with ordering guidance.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)