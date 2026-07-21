# Implementation Plan — [#2034](https://github.com/michael-conrad/.opencode/tree/issues-data/2034) — Fix post-merge cleanup workflow

**Goal:** Fix the post-merge cleanup workflow so that "pr merged" dispatches `cleanup` (not `check-pr`), extract cleanup actions from `check-pr.md`, and add a behavioral enforcement test.

**Architecture:** 5 phases — 3 independent trigger-routing fixes (Phases 1-3), then extraction (Phase 4), then behavioral test (Phase 5). Phases 1-3 are independent and may execute in parallel. Phase 4 depends on Phase 3. Phase 5 depends on all prior phases.

**Files:**
- `.opencode/skills/git-workflow/SKILL.md` — Trigger Dispatch Table (Phase 1)
- `.opencode/skills/git-workflow-cleanup/SKILL.md` — Trigger Dispatch Table (Phase 2)
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` — Step 3 route (Phase 3)
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` — Existing branch cleanup logic (Phase 3)
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` — Phases 4-5 extraction (Phase 4)
- `.opencode/tests-v2/behaviors/cleanup-routing.sh` — Behavioral test (Phase 5)

**Dispatch:** All phases are local `.issues/` artifact writes. No GitHub Issue creation for plan phases.

## Blast Radius

| Affected File | Impact Zone |
|---------------|-------------|
| `.opencode/skills/git-workflow/SKILL.md` | Trigger Dispatch Table — "pr merged" routing |
| `.opencode/skills/git-workflow-cleanup/SKILL.md` | Trigger Dispatch Table — "pr merged" routing |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | Step 3 route description |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | Existing file — verification only |
| `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` | Phases 4-5 removal |
| `.opencode/tests-v2/behaviors/cleanup-routing.sh` | New behavioral test file |

## Concern Map Reference

| Concern | Phase |
|---------|-------|
| Fix parent SKILL.md trigger routing | Phase 1 |
| Fix cleanup SKILL.md trigger routing | Phase 2 |
| Verify existing branch-cleanup.md | Phase 3 |
| Extract cleanup actions from check-pr.md | Phase 4 |
| Behavioral enforcement test | Phase 5 |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be followed exactly as written. Every step is mandatory. No step may be skipped, reordered, or combined. Each step's dispatch indicator (`**inline**`, `**sub-agent**`, `**clean-room**`) is binding. If a step cannot be executed as specified, the agent MUST HALT and report the blocker — it MUST NOT improvise an alternative. The plan is the contract. Violating this contract produces defective deliverables that must be discarded, requiring full rework.

> **⚠️ ONE STEP AT A TIME:** Execute exactly one step at a time. After each step, verify the result before proceeding to the next. Do NOT batch steps, do NOT skip ahead, do NOT combine multiple steps into one. Each numbered step is a discrete unit of work with a single dispatch indicator. If a step fails, HALT and report — do not attempt the next step.

> **⚠️ STEP STATUS:** Before executing any step, the agent MUST read the current step's status from the work state file. If the step is marked `completed`, skip it and proceed to the next uncompleted step. If the step is marked `in_progress` but was not started by this agent, treat it as `pending` and re-execute. This ensures idempotent resume after interruption.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|-------------|-------|----------|
| 1 | Fix trigger routing in git-workflow/SKILL.md | Parent SKILL.md trigger routing | SC-1 | None | 1-4 | sub-agent |
| 2 | Fix trigger routing in git-workflow-cleanup/SKILL.md | Cleanup SKILL.md trigger routing | SC-2 | None | 5-8 | sub-agent |
| 3 | Verify existing branch-cleanup.md and update cleanup.md | Verify branch-cleanup.md | SC-3, SC-7 | None | 9-12 | sub-agent |
| 4 | Extract Phases 4-5 from check-pr.md | Workflow boundary violation | SC-4, SC-5 | Phase 3 | 13-17 | sub-agent |
| 5 | Behavioral enforcement test | Behavioral test | SC-6 | Phases 1-4 | 18-22 | sub-agent |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be followed exactly as written. Every step is mandatory. No step may be skipped, reordered, or combined. Each step's dispatch indicator (`**inline**`, `**sub-agent**`, `**clean-room**`) is binding. If a step cannot be executed as specified, the agent MUST HALT and report the blocker — it MUST NOT improvise an alternative. The plan is the contract. Violating this contract produces defective deliverables that must be discarded, requiring full rework.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails, the agent MUST attempt remediation before escalating. Remediation means: diagnose the root cause, fix the issue, and re-execute the step. Only after 2+ remediation attempts may the agent escalate with a full blocker report. The agent MUST NOT skip, reclassify, or soft-pass a failed step.

## Exit Criteria

- [ ] C1. Phase 1 complete: "pr merged" removed from check-pr row and added to cleanup row in git-workflow/SKILL.md Trigger Dispatch Table
- [ ] C2. Phase 2 complete: "pr merged" removed from check-pr row and added to cleanup row in git-workflow-cleanup/SKILL.md Trigger Dispatch Table
- [ ] C3. Phase 3 complete: branch-cleanup.md verified as existing and correct; cleanup.md Step 3 description updated if needed
- [ ] C4. Phase 4 complete: Phases 4-5 removed from check-pr.md; check-pr.md updated to delegate branch cleanup to cleanup workflow
- [ ] C5. Phase 5 complete: behavioral test created at `.opencode/tests-v2/behaviors/cleanup-routing.sh` and passes
- [ ] C6. All SCs (SC-1 through SC-7) verified PASS with correct evidence types
- [ ] C7. All phase files committed to feature branch
