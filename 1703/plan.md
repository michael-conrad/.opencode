# Implementation Plan — [#1703](https://github.com/michael-conrad/.opencode/issues/1703) — Enforce writing-plans pipeline discipline

**Spec:** [#1703](https://github.com/michael-conrad/.opencode/issues/1703) — Enforce writing-plans pipeline discipline

**Goal:** Prevent plan-by-sub-agent bypass by adding mandatory gates, readiness checks, and pipeline enforcement to the writing-plans and approval-gate skills, and standardizing entry point naming.

**Architecture:** Four independent changes across three skills (writing-plans, approval-gate, spec-creation). Each change is a self-contained RED/GREEN cycle with its own behavioral enforcement test. Changes are independent except Phase 3 (auto-dispatch fix) which references the verify-plan-pipeline task added in Phase 2.

**Files:**
- `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` (new)
- `.opencode/skills/writing-plans/SKILL.md` (update)
- `.opencode/skills/approval-gate/tasks/verify-plan-pipeline.md` (new)
- `.opencode/skills/approval-gate/SKILL.md` (update)
- `.opencode/skills/approval-gate/tasks/auto-dispatch.md` (update)
- `.opencode/skills/spec-creation/tasks/write.md` → `create.md` (rename)
- `.opencode/skills/spec-creation/SKILL.md` (update)
- `.opencode/skills/spec-creation/tasks/completion.md` (update)
- `.opencode/guidelines/140-planning-spec-creation.md` (update)
- `.opencode/skills/adversarial-audit/tasks/test-quality-audit.md` (update)
- `.opencode/skills/approval-gate/tasks/verify-authorization/sc-traceability-check.md` (update)

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed in order. No step may be skipped, combined, or reordered. Each step's output is the next step's input. "Continue" does not waive any step. Pipeline execution discipline (todowrite lifecycle, pipeline_phase tracking, local-issues sync, feature branch commits) MUST be maintained throughout.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. Do not batch steps. Do not skip ahead. After each step, verify the output before proceeding to the next.

> **Step status:** Each step MUST be marked `[x]` when completed. Do not mark a step complete until its verification passes.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | pre-plan-readiness | Add pre-plan-readiness task to writing-plans | SC-2 | None | 1-4 |
| 2 | verify-plan-pipeline | Add verify-plan-pipeline task to approval-gate | SC-1 | None | 5-8 |
| 3 | auto-dispatch-fix | Fix auto-dispatch for for_pr gap-fill | SC-3 | Phase 2 | 9-12 |
| 4 | entry-point-rename | Rename spec-creation write → create | SC-4, SC-5, SC-6 | None | 13-18 |

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed in order. No step may be skipped, combined, or reordered. Each step's output is the next step's input. "Continue" does not waive any step. Pipeline execution discipline (todowrite lifecycle, pipeline_phase tracking, local-issues sync, feature branch commits) MUST be maintained throughout.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip the failed step. If remediation fails after 2 attempts, report BLOCKED with root cause and halt.

## Exit Criteria

- [ ] C1: `pre-plan-readiness` task exists in writing-plans and verifies local spec file + feature branch
- [ ] C2: `verify-plan-pipeline` task exists in approval-gate and checks pipeline completeness
- [ ] C3: `for_pr` gap-fill routes through writing-plans create task
- [ ] C4: spec-creation and writing-plans both use `create` as entry point task name
- [ ] C5: All cross-references to spec-creation's `write` task updated to `create`
- [ ] C6: All cross-references to `spec-creation/tasks/write.md` updated to `spec-creation/tasks/create.md`
- [ ] C7: Behavioral enforcement tests pass for all 4 changes
- [ ] C8: All plan artifacts committed to feature branch
