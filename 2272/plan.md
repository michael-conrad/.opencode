---
plan_schema_version: "1.0"
issue: 2272
title: "Ticket status-check-and-update reconciliation for audit + git-workflow-pr skills"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: red
---

# Implementation Plan — #2272 — Ticket Status-Check-and-Update Reconciliation

**Goal:** Add a status-check-and-update step to the audit and git-workflow-pr skill workflows so the agent reads the ticket's current status and updates it to reflect the verified-complete or PR-created state when warranted.

**Architecture:** Three phases. Phase 1 adds the status-check-and-update step to the audit skill workflow after a PASS verdict (SC-1). Phase 2 adds the equivalent step to the git-workflow-pr skill workflows on completion (SC-2). Phase 3 adds a behavioral test asserting the agent reads current ticket status before reporting completion in both workflows (SC-3) and documents the behavior in the two skills (SC-4). Phase 3 depends on Phases 1 and 2 because its behavioral test and documentation reference the steps added there.

**Files:**
- `.opencode/skills/audit/` (SKILL.md and/or task files)
- `.opencode/skills/git-workflow-pr/` (SKILL.md and/or task files)
- `.opencode/guidelines/` (only if per-skill mandates are insufficient)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — audit skill status reconciliation | `test-driven-development` | `red` | `.opencode/skills/audit/` | SC-1 | — |
| 2 — git-workflow-pr status reconciliation | `test-driven-development` | `red` | `.opencode/skills/git-workflow-pr/` | SC-2 | — |
| 3 — shared status-check discipline and documentation | `test-driven-development` | `red` | `.opencode/skills/audit/`, `.opencode/skills/git-workflow-pr/` | SC-3, SC-4 | 1, 2 |

---

## Phase Details

### Phase 1 — audit skill status reconciliation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/audit/` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
- files_to_modify: `.opencode/skills/audit/SKILL.md`, `.opencode/skills/audit/tasks/verification-audit-arbiter.md`
- sc_ids: SC-1
- behavior: after an implementation audit returns a PASS verdict, check the ticket's current status and update it to reflect the verified-complete state (review/PR-ready label or status transition) if an update is warranted

### Phase 2 — git-workflow-pr status reconciliation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-pr/` |
| SCs | SC-2 |
| Depends On | — |

**Context:**
- files_to_modify: `.opencode/skills/git-workflow-pr/SKILL.md`, `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`, `.opencode/skills/git-workflow-pr/tasks/completion.md`
- sc_ids: SC-2
- behavior: when an implementation-for-PR workflow completes, check the ticket's current status and update it to reflect the PR-created state if an update is warranted

### Phase 3 — shared status-check discipline and documentation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/audit/`, `.opencode/skills/git-workflow-pr/` |
| SCs | SC-3, SC-4 |
| Depends On | 1, 2 |

**Context:**
- files_to_modify: `.opencode/skills/audit/SKILL.md`, `.opencode/skills/git-workflow-pr/SKILL.md`
- sc_ids: SC-3, SC-4
- behavior: agent reads current ticket status before reporting completion of an implementation audit or implementation-for-PR, skipping the update only when the status is already correct; behavior documented in both skills

---

## Exit Criteria

- [ ] C1. Audit skill workflow gains a status-check-and-update step after a PASS verdict (SC-1)
- [ ] C2. git-workflow-pr skill workflows gain a status-check-and-update step on completion (SC-2)
- [ ] C3. Behavioral test asserts the agent reads current ticket status before reporting completion in both workflows, skipping the update only when already correct (SC-3)
- [ ] C4. Status-check-and-update behavior documented in audit and git-workflow-pr skills (SC-4)
