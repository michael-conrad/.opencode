# Implementation Plan — [#1703](https://github.com/michael-conrad/.opencode/issues/1703) — Enforce writing-plans pipeline discipline

**Goal:** Prevent plan-by-sub-agent bypass by adding mandatory gates, readiness checks, and pipeline enforcement.

**Architecture:** Four independent changes: (1) pre-plan-readiness gate in writing-plans, (2) verify-plan-pipeline gate in approval-gate, (3) auto-dispatch fix for for_pr gap-fill, (4) entry point rename spec-creation write→create.

**Files:** writing-plans/tasks/pre-plan-readiness.md, writing-plans/SKILL.md, approval-gate/tasks/verify-plan-pipeline.md, approval-gate/SKILL.md, approval-gate/tasks/auto-dispatch.md, spec-creation/tasks/write.md→create.md, spec-creation/SKILL.md, spec-creation/tasks/completion.md, guidelines/140-planning-spec-creation.md, adversarial-audit/tasks/test-quality-audit.md, approval-gate/tasks/verify-authorization/sc-traceability-check.md

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | pre-plan-readiness | Add pre-plan-readiness task to writing-plans | SC-2 | None | 1-7 |
| 2 | verify-plan-pipeline | Add verify-plan-pipeline task to approval-gate | SC-1 | None | 8-14 |
| 3 | auto-dispatch-fix | Fix auto-dispatch for for_pr gap-fill | SC-3 | Phase 2 | 15-20 |
| 4 | entry-point-rename | Rename spec-creation write → create | SC-4,5,6 | None | 21-32 |

## Exit Criteria

- C1: pre-plan-readiness task exists and verifies spec file + branch
- C2: verify-plan-pipeline task exists and checks pipeline completeness
- C3: for_pr gap-fill routes through writing-plans create
- C4: Both skills use `create` as entry point
- C5: Zero stale `--task write` references
- C6: Zero stale `tasks/write` references
- C7: Behavioral tests pass
- C8: All artifacts committed
