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

---

## Exit Criteria

- [ ] C1. SC-1: The submodule-only-PR prohibition is removed from the global guideline `020-go-prohibitions.md`.
- [ ] C2. SC-2: A submodule repo filing its own PR for its own changes is unambiguously permitted.
- [ ] C3. SC-3: The surviving task-card references are parent-repo + action-scoped.
- [ ] C4. SC-4: The release path is NOT blocked by the "no uncommitted submodule changes" pre-validation.
