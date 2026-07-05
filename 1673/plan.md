# Implementation Plan — [.opencode#1673](https://github.com/michael-conrad/.opencode/issues/1673) — Fix spec-creation and writing-plans dispatch and task structure

**Goal:** Fix spec-creation and writing-plans skills so they are invoked correctly when triggered, produce correct remote body format, have consistent execution models, and produce plans that route to implementation skill task cards rather than inlining procedure text.

**Architecture:** Six phases targeting specific defect categories across two skill files and one task file. Phases 1-2 are independent; Phases 3-6 depend on Phase 2 (same file — `write.md`).

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — trigger phrases, dispatch table, Operating Protocol
- `.opencode/skills/spec-creation/tasks/write.md` — step numbering, content templates, 7r ordering, Plan Format Requirements
- `.opencode/skills/writing-plans/SKILL.md` — execution model contradiction
- `.opencode/skills/writing-plans/tasks/create.md` — sub-agent dispatch pattern (reference only)
- `.opencode/tests/behaviors/` — behavioral enforcement tests

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify its output before proceeding. Do not batch steps, do not skip ahead, do not combine steps. Each step is an atomic unit. If a step fails, remediate before proceeding to the next step. There is no valid reason to skip, compress, reorder, or omit any step.

> **Step Status:** Each step MUST be marked with its status as it is executed. Use `- [x]` for completed steps, `- [-]` for skipped steps (with rationale), and `- [ ]` for pending steps. This checklist is the source of truth for pipeline progress.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Trigger Phrase Expansion | Skill card description fields | SC-1, SC-2, SC-3, SC-4 | None | 1-11 |
| 2 | Dispatch Table Fixes | spec-creation SKILL.md dispatch table | SC-5, SC-6, SC-7 | None | 12-22 |
| 3 | write.md Structural Renumbering + Plan Format | Task file step numbering + plan routing mandate | SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14 | Phase 2 | 23-37 |
| 4 | writing-plans Execution Model | SKILL.md vs create.md contradiction | SC-15, SC-16, SC-17 | None | 38-46 |
| 5 | Missing Pipeline Steps | spec-creation pipeline gaps | SC-18, SC-19, SC-20, SC-21 | Phase 2 | 47-62 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** If a step fails, the agent MUST attempt remediation before escalating. Diagnose the root cause, fix it, and re-verify. Only after 2+ remediation attempts may the agent HALT with a blocker report. Do not skip, reclassify, or soft-pass failures.

## Exit Criteria

- [ ] C1. All 5 phases complete with verified PASS for their SCs
- [ ] C2. Behavioral tests pass for trigger phrase dispatch (SC-3, SC-4)
- [ ] C3. Behavioral test passes for writing-plans sub-agent dispatch (SC-17)
- [ ] C4. Behavioral test passes for local-issues sync discipline (SC-14)
- [ ] C5. All string/structural SCs verified via grep or file check
- [ ] C6. No regressions in existing skill functionality
