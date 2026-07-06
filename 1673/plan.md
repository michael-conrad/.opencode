# Implementation Plan — [#1673](https://github.com/michael-conrad/.opencode/issues/1673) — Fix spec-creation and writing-plans dispatch and task structure

**Goal:** Fix structural defects in spec-creation and writing-plans skills that prevent correct dispatch routing, task invocation, and plan output format.

**Architecture:** Five independent/dependent phases across two skill directories. Phases 1, 2, 4 are independent. Phases 3 and 5 depend on Phase 2 (same files). Each phase follows RED/GREEN TDD with behavioral enforcement tests.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — Phases 1, 2, 5
- `.opencode/skills/spec-creation/tasks/write.md` — Phases 3, 5
- `.opencode/skills/writing-plans/SKILL.md` — Phases 1, 4, 5
- `.opencode/skills/writing-plans/tasks/create.md` — Phase 4 (consistency check)
- `.opencode/tests/behaviors/` — Behavioral enforcement tests for all phases

> **Compliance requirement:** This plan is a routing document. Every dispatch step MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> from <skill>")` form. Plan steps MUST NOT contain inline procedure text. The full implementation pipeline MUST be enumerated with no skipped or combined steps.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the result before proceeding. Do NOT batch, combine, or skip steps. Each step is a discrete unit of work with its own verification.

> **Step Status instruction:** Each step MUST be tracked with `todowrite` status: `pending` → `in_progress` → `completed`. Clear all items with `todowrite(todos=[])` before halting.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Trigger Phrase Expansion | Add article-variant triggers to skill descriptions | SC-1, SC-2, SC-3, SC-4 | None | 1–10 |
| 2 | Dispatch Table Fixes | Expand Tasks table, Invocation, Trigger Dispatch Table | SC-5, SC-6, SC-7 | None | 11–18 |
| 3 | write.md Structural Renumbering | Fix labels, ordering, content templates, Plan Format Requirements | SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14 | Phase 2 | 19–30 |
| 4 | Execution Model Contradiction | Remove "no task()" language, update sub-agent dispatch model | SC-15, SC-16, SC-17 | None | 31–40 |
| 5 | Missing Pipeline Steps | Add adversarial-audit, change-control, spec-to-plan dispatch paths | SC-18, SC-19, SC-20, SC-21 | Phase 2 | 41–52 |

> **Compliance requirement:** This plan is a routing document. Every dispatch step MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> from <skill>")` form. Plan steps MUST NOT contain inline procedure text. The full implementation pipeline MUST be enumerated with no skipped or combined steps.

> **Self-remediation protocol:** When a step fails, the orchestrator MUST NOT inline-fix. The orchestrator MUST re-task a clean-room sub-agent with the same scoped context. If re-task also fails, report double-failure and HALT.

## Exit Criteria

- [ ] C1: spec-creation SKILL.md description includes all article-variant triggers (SC-1)
- [ ] C2: writing-plans SKILL.md description includes all article-variant triggers (SC-2)
- [ ] C3: Behavioral test passes for spec-creation article-variant dispatch (SC-3)
- [ ] C4: Behavioral test passes for writing-plans article-variant dispatch (SC-4)
- [ ] C5: spec-creation Tasks table lists all 8 task files (SC-5)
- [ ] C6: Invocation section references `execute write task from spec-creation` (SC-6)
- [ ] C7: Trigger Dispatch Table has rows for all 7 sub-tasks (SC-7)
- [ ] C8: No duplicate Step 1a/1b labels in write.md (SC-8)
- [ ] C9: Step 7r appears before Step 7 in write.md (SC-9)
- [ ] C10: No Pre-Step / Step 0.x naming in write.md (SC-10)
- [ ] C11: Content templates are sub-bullets under Assemble Spec (SC-11)
- [ ] C12: Plan Format Requirements mandates skill/task routing form (SC-12)
- [ ] C13: Plan Format Requirements mandates full pipeline enumeration (SC-13)
- [ ] C14: Behavioral test passes for local-issues sync discipline (SC-14)
- [ ] C15: No "no task()" language in writing-plans SKILL.md (SC-15)
- [ ] C16: writing-plans Mandatory Task Discipline states sub-agent dispatch (SC-16)
- [ ] C17: Behavioral test passes for writing-plans sub-agent dispatch (SC-17)
- [ ] C18: spec-creation Operating Protocol includes adversarial-audit step (SC-18)
- [ ] C19: write.md Step 40 references adversarial-audit skill (SC-19)
- [ ] C20: spec-creation Trigger Dispatch Table includes change-control row (SC-20)
- [ ] C21: writing-plans Trigger Dispatch Table includes spec-to-plan row (SC-21)
