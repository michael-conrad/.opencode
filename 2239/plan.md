---
plan_schema_version: "1.0"
issue: 2239
title: "Remove redundant check-pr task, fix cleanup processing order"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2239 — Remove redundant check-pr task, fix cleanup processing order

> GitHub Issue: https://github.com/michael-conrad/.opencode/issues/2239

**Goal:** Delete the redundant `check-pr.md` task file from `git-workflow-cleanup`, remove all references to it, and fix the cleanup processing order to process submodules before the parent repo.

**Architecture:** Two independent work phases plus a post-phase behavioral verification. Phase 1 deletes the duplicate file and updates all references. Phase 2 fixes the submodule-first processing order in `cleanup.md`. Phase 3 (post) verifies behavioral backward compatibility via `opencode run`.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` (DELETE)
- `.opencode/skills/git-workflow-cleanup/SKILL.md` (MODIFY)
- `.opencode/skills/git-workflow/SKILL.md` (MODIFY)
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` (MODIFY)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Remove check-pr and update references | `test-driven-development` | `red` | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow/SKILL.md`, `cleanup.md` | SC-1, SC-2, SC-3a, SC-3b, SC-5 | — |
| 2 — Fix cleanup processing order | `test-driven-development` | `green` | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | SC-6, SC-7 | — |
| 3 — Behavioral backward compatibility | `test-driven-development` | `red` | `git-workflow/SKILL.md` TDT | SC-8 | 1, 2 |

---

## Phase Details

### Phase 1 — Remove check-pr and update references

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`, `git-workflow-cleanup/SKILL.md`, `git-workflow/SKILL.md`, `cleanup.md` |
| SCs | SC-1, SC-2, SC-3a, SC-3b, SC-5 |
| Depends On | — |

**Context:**
```yaml
files_to_delete:
  - .opencode/skills/git-workflow-cleanup/tasks/check-pr.md
files_to_modify:
  - .opencode/skills/git-workflow-cleanup/SKILL.md
  - .opencode/skills/git-workflow/SKILL.md
  - .opencode/skills/git-workflow-cleanup/tasks/cleanup.md
sc_ids: [SC-1, SC-2, SC-3a, SC-3b, SC-5]
```

### Phase 2 — Fix cleanup processing order

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |
| SCs | SC-6, SC-7 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/skills/git-workflow-cleanup/tasks/cleanup.md
sc_ids: [SC-6, SC-7]
change_description: "Update Step 3 to iterate submodules before parent; update Step 4 to list submodules before parent"
```

### Phase 3 — Behavioral backward compatibility

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `git-workflow/SKILL.md` TDT |
| SCs | SC-8 |
| Depends On | 1, 2 |

**Context:**
```yaml
sc_ids: [SC-8]
trigger_phrase: "check pr"
expected_dispatch: "git-workflow-cleanup --task cleanup"
```

---

## Exit Criteria

- [ ] C1. `check-pr.md` is deleted from `.opencode/skills/git-workflow-cleanup/tasks/`
- [ ] C2. `git-workflow-cleanup/SKILL.md` has no `check-pr` references in TDT or Tasks table
- [ ] C3. `git-workflow/SKILL.md` has no `check-pr` references in TDT, Invocation, or Sub-Skills
- [ ] C4. `git-workflow/SKILL.md` lists `git-workflow-cleanup` task count as 3
- [ ] C5. `cleanup.md` has no `check-pr` references in Related tasks or Automatic Cleanup Detection sections
- [ ] C6. `cleanup.md` Step 3 specifies submodule-first iteration order for branch-cleanup
- [ ] C7. `cleanup.md` Step 4 lists submodules before parent in repo verification list
- [ ] C8. Dispatching "check pr" routes to `git-workflow-cleanup --task cleanup` (not `check-pr`)
