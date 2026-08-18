---
plan_schema_version: "1.0"
issue: 2293
title: "Scope submodule-only PR prohibition to parent repo"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2293 — Scope submodule-only PR prohibition to parent repo

**Goal:** Remove the submodule-only-PR prohibition from the global guideline, reword the surviving task-card references to be parent-repo + action-scoped, and add a release carve-out so dirty/staged submodule pointers do not block a parent-repo release.

**Architecture:** The prohibition transitions from a global guideline resident in every agent's context (SC-1) to a parent-repo + action-scoped rule enforced only by the pre-push hook (unchanged) and the contextual task cards (SC-2/3). The task-card references are reworded to scope the prohibition ONLY to a parent-repo PR whose sole change is bumping submodule pointers, and to explicitly permit a submodule repo filing its own PR for its own changes. A release carve-out is added to `pr-creation.md` release pre-validation so dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release (SC-4). All four SCs are behavioral (opencode run + session.yaml inspection) because the change affects agent routing/dispatch behavior.

**Files:**
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/skills/git-workflow-commit/tasks/implementation.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
- `.opencode/skills/git-workflow-cleanup/SKILL.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

> **Enforcement gate:** All four success criteria MUST pass before the PR is created. Partial implementation is not permitted.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Remove global prohibition | `test-driven-development` | `red` | `guidelines/020-go-prohibitions.md` | SC-1 | — |
| 2 — Reword task-card references | `test-driven-development` | `red` | 5 git-workflow task files | SC-2, SC-3 | 1 |
| 3 — Release carve-out | `test-driven-development` | `red` | `skills/git-workflow-pr/tasks/pr-creation.md` | SC-4 | 2 |

---

## Phase Details

### Phase 1 — Remove Global Prohibition

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `guidelines/020-go-prohibitions.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
- Remove the `critical-rules-049` submodule-only-PR prohibition block from `guidelines/020-go-prohibitions.md`.
- Behavioral test (SC-1) asserts the block is absent and a submodule repo may file its own PR.

**Procedure** (`(**clean-room**)` — dispatch via `test-driven-development` task `red`/`green`; commit via orchestrator `commit-inline`):

- [ ] 1. **Item 1 — SC-1 RED (`(**clean-room**)`).** Dispatch the `red` task to write a behavioral enforcement test (`opencode run` + session.yaml inspection) asserting that the `critical-rules-049` submodule-only-PR prohibition block is absent from `020-go-prohibitions.md` and that a submodule repo may file its own PR. The test FAILs because the global prohibition wording is still present.
- [ ] 2. **Item 1 — SC-1 GREEN (`(**clean-room**)`).** Dispatch the `green` task to remove the `critical-rules-049` block from `guidelines/020-go-prohibitions.md`. What must be true: the global guideline no longer blocks submodule repos' own PRs, and the pre-push hook Gate 2 remains the retained enforcement (unchanged).
- [ ] 3. **Item 1 — SC-1 COMMIT (`(**inline**)`).** Stage the `020-go-prohibitions.md` removal change and the behavioral enforcement test and commit them as one atomic slice.

### Phase 2 — Reword Task-Card References

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | 5 git-workflow task files |
| SCs | SC-2, SC-3 |
| Depends On | 1 |

**Context:**
- Reword the surviving references in `git-workflow-commit/tasks/implementation.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-branch/tasks/pre-work.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` to be parent-repo + action-scoped.
- Add explicit permission for a submodule repo filing its own PR for its own changes.
- The prohibition applies ONLY to a parent-repo PR whose sole change is bumping submodule pointers.

**Procedure** (`(**clean-room**)` — dispatch via `test-driven-development` task `red`/`green`; commit via orchestrator `commit-inline`):

- [ ] 1. **Item 2 — SC-2 RED (`(**clean-room**)`).** Dispatch the `red` task to write a behavioral enforcement test asserting a submodule repo (e.g., SHARED-DAO) filing its own PR for its own change is unambiguously permitted. The test FAILs because the permission language is absent from the surviving task-card references.
- [ ] 2. **Item 2 — SC-2 GREEN (`(**clean-room**)`).** Dispatch the `green` task to add explicit permission language to the surviving task-card references (`git-workflow-commit/tasks/implementation.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-branch/tasks/pre-work.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`) stating a submodule repo filing its own PR for its own changes is normal and NOT covered. What must be true: an agent reading the task cards concludes submodule repos' own PRs are permitted.
- [ ] 3. **Item 2 — SC-2 COMMIT (`(**inline**)`).** Stage the permission-language additions and the SC-2 behavioral enforcement test and commit them as one atomic slice.
- [ ] 4. **Item 3 — SC-3 RED (`(**clean-room**)`).** Dispatch the `red` task to write a behavioral enforcement test in a parent-repo PR-creation context asserting the surviving task-card references are parent-repo + action-scoped, and that no agent reading the task cards concludes submodule repos cannot file their own PRs. The test FAILs because the references are not yet scoped.
- [ ] 5. **Item 3 — SC-3 GREEN (`(**clean-room**)`).** Dispatch the `green` task to reword the surviving task-card references to be parent-repo + action-scoped, stating the prohibition applies ONLY to a parent-repo PR whose sole change is bumping submodule pointers. What must be true: an agent in the parent-repo commit/PR/cleanup paths enforces the prohibition with the parent-repo scope applied.
- [ ] 6. **Item 3 — SC-3 COMMIT (`(**inline**)`).** Stage the reworded task-card references and the SC-3 behavioral enforcement test and commit them as one atomic slice.

### Phase 3 — Release Carve-Out

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `skills/git-workflow-pr/tasks/pr-creation.md` |
| SCs | SC-4 |
| Depends On | 2 |

**Context:**
- Add a release carve-out to `pr-creation.md` release pre-validation: dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release; the "no uncommitted submodule changes" check SHALL NOT block the release path.

**Procedure** (`(**clean-room**)` — dispatch via `test-driven-development` task `red`/`green`; commit via orchestrator `commit-inline`):

- [ ] 1. **Item 4 — SC-4 RED (`(**clean-room**)`).** Dispatch the `red` task to write a behavioral enforcement test dispatching a real-domain release-PR prompt with dirty/staged submodule pointers, asserting the release path is NOT blocked by the "no uncommitted submodule changes" pre-validation. The test FAILs because the release path is currently blocked.
- [ ] 2. **Item 4 — SC-4 GREEN (`(**clean-room**)`).** Dispatch the `green` task to add the release carve-out to `pr-creation.md` release pre-validation: dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release; the "no uncommitted submodule changes" check SHALL NOT block the release path. What must be true: the release path proceeds when dirty/staged submodule pointers are expected.
- [ ] 3. **Item 4 — SC-4 COMMIT (`(**inline**)`).** Stage the `pr-creation.md` release carve-out change and the SC-4 behavioral enforcement test and commit them as one atomic slice.

---

## Exit Criteria

- [ ] C1. SC-1: The submodule-only-PR prohibition is removed from the global guideline `020-go-prohibitions.md`.
- [ ] C2. SC-2: A submodule repo filing its own PR for its own changes is unambiguously permitted.
- [ ] C3. SC-3: The surviving task-card references are parent-repo + action-scoped.
- [ ] C4. SC-4: The release path is NOT blocked by the "no uncommitted submodule changes" pre-validation.

---

## Lifecycle Events

| Timestamp | Event | Notes |
|-----------|-------|-------|
| 2026-08-17T22:57:00Z | `plan_created` | Plan created at `.opencode/.issues/2293/plan.md`; phase_count=3 |
