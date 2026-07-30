## Objective

Decouple the plan-writing pipeline from the implementation-pipeline skill by creating a static reference card containing all canonical dispatch strings, so plans become fully self-contained and the orchestrator no longer depends on loading the implementation-pipeline skill at execution time.

## Background

The current design splits dispatch metadata across two locations: the implementation-pipeline TDT (trigger dispatch table in `skills/implementation-pipeline/SKILL.md`) and the plan writer (`skills/writing-plans/tasks/create.md`). The plan writer loads the implementation-pipeline skill at runtime to discover the canonical per-task cycle and dispatch strings. This creates a two-phase lookup: first load the skill, then match against the TDT. Every implementation-pipeline change cascades into every plan because the plan writer is coupled to the live skill.

The same coupling exists for the research task (`research.md` reads the TDT for skill+task selection), the validation task (`validate.md` verifies plans against the TDT), and the plan artifact format specification (`plan-artifact-format.md` references `implementation-pipeline/SKILL.md` as the validation authority). Five audit tasks also reference the pipeline skill for gate-sequence verification.

The refactoring moves the dispatch strings from the implementation-pipeline TDT and Invocation sections into a static reference card at `skills/writing-plans/reference/implementation-workflow.md`. The plan writer, research task, and validation task read this card instead of loading the live skill. The implementation-pipeline skill retains its state management, remediation routing, enforcement blocks, and DONE_WITH_CONCERNS coercion rule — only the dispatch strings move.

**Two-phase lookup problem eliminated:** Before this change, every plan-write requires: (1) orchestrator loads implementation-pipeline skill, (2) reads TDT for dispatch strings. After this change: plan writer reads a static `.md` file directly — no `skill()` call needed at plan-writing time. The orchestrator reads the plan (which contains baked-in dispatch strings) at execution time, so no skill loading is needed at execution time either.

## Not Included

- Tertiary files that reference implementation-pipeline by name only (pre-work.md, operating-protocol.md, screen-issue-gate2.md, etc.) — these reference the skill as a routing target, not for TDT content
- CHANGELOG.md, README.md — informational only, no structural change
- dispatch-table.yaml — already DEPRECATED
- scripts/session_context_triggers.py — name-only reference
- tmp/rewrite_descriptions.py — throwaway script

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `writing-plans/reference/implementation-workflow.md` exists | structural | `ls` |
| SC-2 | Reference card contains all 17 canonical dispatch strings (pre-regression through exec-summary) from the implementation-pipeline Invocation section | string | grep each step name |
| SC-3 | `create.md` reads the reference card instead of loading the implementation-pipeline TDT | behavioral | `opencode run` with plan-writing scenario, stderr shows reference card read |
| SC-4 | `research.md` reads the reference card for skill+task selection instead of implementation-pipeline TDT | behavioral | `opencode run` with research scenario |
| SC-5 | `validate.md` validates against the reference card instead of implementation-pipeline TDT | behavioral | `opencode run` with validate scenario |
| SC-6 | `plan-artifact-format.md` validation rule (line 91) references the reference card | string | grep |
| SC-7 | `implementation-pipeline/SKILL.md` dispatch strings stripped, retains state management + enforcement + coercion rule | string + structural | grep for absence of `task(..., prompt:` lines; assert coercion rule present |
| SC-8 | Audit cross-references (plan-fidelity-evaluator, 4 verification-audit tasks) updated from `implementation-pipeline/SKILL.md` to reference card | string | grep |
| SC-9 | Deprecated implementation-pipeline dispatch-string references purged across all `.opencode/` files | string | `grep -r` count comparison |
| SC-10 | Behavioral enforcement tests exist for the new plan-writing workflow (create.md reads card, validate.md validates against card) | behavioral | `opencode run` with enforcement test scenario |

## Requirements

The spec SHALL:

1. **REQ-1**: Create a static reference card at `skills/writing-plans/reference/implementation-workflow.md` containing the per-task cycle definition (RED→GREEN→COMMIT), all 17 canonical dispatch strings, dispatch indicator semantics, step labels, and validation rules for plan consumers.

2. **REQ-2**: Update `skills/writing-plans/tasks/create.md` to read the reference card instead of loading the implementation-pipeline TDT at runtime. Replace "Load the implementation-pipeline TDT" with "Read the implementation-workflow reference card".

3. **REQ-3**: Update `skills/writing-plans/tasks/research.md` to read the reference card for skill+task selection instead of the implementation-pipeline TDT.

4. **REQ-4**: Update `skills/writing-plans/tasks/validate.md` to verify plan skill+task references against the reference card instead of the implementation-pipeline TDT.

5. **REQ-5**: Update `skills/writing-plans/reference/plan-artifact-format.md` — replace the validation rule on line 91 referencing `implementation-pipeline/SKILL.md` with a reference to the new reference card.

6. **REQ-6**: Strip dispatch strings from `skills/implementation-pipeline/SKILL.md` TDT rows and Invocation section. Preserve the DONE_WITH_CONCERNS coercion rule, state management, remediation routing, enforcement blocks, pipeline re-priming, and artifact retention.

7. **REQ-7**: Update audit cross-references (plan-fidelity-evaluator.md, 4 verification-audit tasks) from `implementation-pipeline/SKILL.md` to the reference card. Preserve references to the pipeline skill for enforcement rules (coercion, state management).

8. **REQ-8**: Purge all remaining deprecated implementation-pipeline dispatch-string references across `.opencode/` files.

9. **REQ-9**: Add behavioral enforcement tests verifying the plan writer reads the reference card and the validator checks against the card.

## Items

| Item | Phase | SC | Description | Concern | Files |
|------|-------|----|-------------|---------|-------|
| 1 | 1 | SC-1 | Create reference card file | Reference card creation | `skills/writing-plans/reference/implementation-workflow.md` |
| 2 | 1 | SC-2 | Populate card with all 17 dispatch strings + per-task cycle | Reference card creation | `skills/writing-plans/reference/implementation-workflow.md` |
| 3 | 2 | SC-3 | Update create.md to read reference card | Plan writer update | `skills/writing-plans/tasks/create.md` |
| 4 | 2 | SC-4 | Update research.md to read reference card | Plan writer update | `skills/writing-plans/tasks/research.md` |
| 5 | 2 | SC-5 | Update validate.md to validate against reference card | Plan writer update | `skills/writing-plans/tasks/validate.md` |
| 6 | 2 | SC-6 | Update plan-artifact-format.md validation rule | Plan writer update | `skills/writing-plans/reference/plan-artifact-format.md` |
| 7 | 3 | SC-7 | Strip dispatch strings from implementation-pipeline/SKILL.md | Source skill cleanup | `skills/implementation-pipeline/SKILL.md` |
| 8 | 3 | SC-8 | Update audit cross-references | Source skill cleanup | plan-fidelity-evaluator.md, 4 verification-audit tasks, approval-gate-scope/SKILL.md, 065-verification-honesty.md |
| 9 | 4 | SC-9 | Purge deprecated dispatch-string references | Cleanup | All `.opencode/` files identified in pre-spec inspection |
| 10 | 4 | SC-10 | Add behavioral enforcement tests | Cleanup | New test files under `.opencode/tests-v2/behaviors/` |

## Dependencies

- **Prerequisite skills**: `implementation-pipeline` — provides current TDT and Invocation dispatch strings (source data for reference card)
- **Related skills**: `writing-plans` — all plan-writing tasks are being updated; `audit` — cross-references updated; `approval-gate-scope` — coercion rule preserved
- **Guidelines**: `080-code-standards.md` — behavioral test mandate for guideline/skill changes
- **No other spec dependencies** — this is a standalone refactoring

## Traceability

| Requirement | SC(s) | Phase |
|-------------|-------|-------|
| REQ-1 | SC-1, SC-2 | Phase 1 |
| REQ-2 | SC-3 | Phase 2 |
| REQ-3 | SC-4 | Phase 2 |
| REQ-4 | SC-5 | Phase 2 |
| REQ-5 | SC-6 | Phase 2 |
| REQ-6 | SC-7 | Phase 3 |
| REQ-7 | SC-8 | Phase 3 |
| REQ-8 | SC-9 | Phase 4 |
| REQ-9 | SC-10 | Phase 4 |

> **Full spec and artifacts: [`.opencode/.issues/2203/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2203)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2203/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings
