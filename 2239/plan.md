---
plan_schema_version: "1.0"
issue: 2239
title: "Remove redundant check-pr task, fix cleanup processing order"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2239 — Remove redundant check-pr task, fix cleanup processing order

> GitHub Issue: https://github.com/michael-conrad/.opencode/issues/2239

**Goal:** Delete the redundant `check-pr.md` task file from `git-workflow-cleanup`, remove all references to it, and fix the cleanup processing order to process submodules before the parent repo.

**Architecture:** Four phases with clean-room dispatch. Phase 1 deletes the duplicate file. Phase 2 updates all references. Phase 3 fixes the submodule-first processing order. Phase 4 (post) verifies behavioral backward compatibility via `opencode run`.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` (DELETE)
- `.opencode/skills/git-workflow-cleanup/SKILL.md` (MODIFY)
- `.opencode/skills/git-workflow/SKILL.md` (MODIFY)
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` (MODIFY)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On | Dispatch Mode |
|-------|-------|------|--------|-----|------------|---------------|
| 1 — Delete check-pr.md | `test-driven-development` | `red` | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` | SC-1 | — | clean-room |
| 2 — Update references | `test-driven-development` | `green` | `git-workflow-cleanup/SKILL.md`, `git-workflow/SKILL.md`, `cleanup.md` | SC-2, SC-3a, SC-3b, SC-5 | 1 | clean-room |
| 3 — Fix cleanup processing order | `test-driven-development` | `green` | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | SC-6, SC-7 | — | clean-room |
| 4 — Behavioral backward compatibility | `test-driven-development` | `red` | `git-workflow/SKILL.md` TDT | SC-8 | 2, 3 | clean-room |

---

## Phase Details

### Phase 1 — Delete check-pr.md

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` |
| SCs | SC-1 |
| Depends On | — |
| Dispatch Mode | clean-room |

**Concern:** file-deletion

**Procedure:**
- [ ] 1. Verify `check-pr.md` exists at `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- [ ] 2. Delete the file using `git rm`
- [ ] 3. Verify the file no longer exists on disk

**Context:**
```yaml
files_to_delete:
  - .opencode/skills/git-workflow-cleanup/tasks/check-pr.md
sc_ids: [SC-1]
```

### Phase 2 — Update references

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `git-workflow-cleanup/SKILL.md`, `git-workflow/SKILL.md`, `cleanup.md` |
| SCs | SC-2, SC-3a, SC-3b, SC-5 |
| Depends On | 1 |
| Dispatch Mode | clean-room |

**Concern:** reference-removal

**Procedure:**
- [ ] 1. Read `git-workflow-cleanup/SKILL.md` and remove `check-pr` from the Trigger Dispatch Table and Tasks table
- [ ] 2. Read `git-workflow/SKILL.md` and remove `check-pr` from the Trigger Dispatch Table, Invocation section, and Sub-Skills section
- [ ] 3. Update the task count in `git-workflow/SKILL.md` from 4 to 3
- [ ] 4. Read `cleanup.md` and remove `check-pr` from Related tasks and Automatic Cleanup Detection sections

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-cleanup/SKILL.md
  - .opencode/skills/git-workflow/SKILL.md
  - .opencode/skills/git-workflow-cleanup/tasks/cleanup.md
sc_ids: [SC-2, SC-3a, SC-3b, SC-5]
```

### Phase 3 — Fix cleanup processing order

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |
| SCs | SC-6, SC-7 |
| Depends On | — |
| Dispatch Mode | clean-room |

**Concern:** processing-order

**Procedure:**
- [ ] 1. Read `cleanup.md` Step 3 and update to specify submodule-first iteration order for branch-cleanup
- [ ] 2. Read `cleanup.md` Step 4 and update to list submodules before parent in repo verification list

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-cleanup/tasks/cleanup.md
sc_ids: [SC-6, SC-7]
change_description: "Update Step 3 to iterate submodules before parent; update Step 4 to list submodules before parent"
```

### Phase 4 — Behavioral backward compatibility

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `git-workflow/SKILL.md` TDT |
| SCs | SC-8 |
| Depends On | 2, 3 |
| Dispatch Mode | clean-room |

**Concern:** behavioral-verification

**Procedure:**
- [ ] 1. Create a behavioral test that dispatches "check pr" and verifies it routes to `git-workflow-cleanup --task cleanup`
- [ ] 2. Run the test to verify PASS

**Context:**
```yaml
sc_ids: [SC-8]
trigger_phrase: "check pr"
expected_dispatch: "git-workflow-cleanup --task cleanup"
```

---

---
## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-03T10:50:00Z | `plan_created` | Plan file at `.opencode/.issues/2239/plan.md`, 4 phases, all clean-room dispatch |

---

## Exit Criteria

| # | SC | Phase | Description |
|---|----|-------|-------------|
| C1 | SC-1 | 1 | `check-pr.md` is deleted from `.opencode/skills/git-workflow-cleanup/tasks/` |
| C2 | SC-2 | 2 | `git-workflow-cleanup/SKILL.md` has no `check-pr` references in TDT or Tasks table |
| C3 | SC-3a | 2 | `git-workflow/SKILL.md` has no `check-pr` references in TDT, Invocation, or Sub-Skills |
| C4 | SC-3b | 2 | `git-workflow/SKILL.md` lists `git-workflow-cleanup` task count as 3 |
| C5 | SC-5 | 2 | `cleanup.md` has no `check-pr` references in Related tasks or Automatic Cleanup Detection sections |
| C6 | SC-6 | 3 | `cleanup.md` Step 3 specifies submodule-first iteration order for branch-cleanup |
| C7 | SC-7 | 3 | `cleanup.md` Step 4 lists submodules before parent in repo verification list |
| C8 | SC-8 | 4 | Dispatching "check pr" routes to `git-workflow-cleanup --task cleanup` (not `check-pr`) |
