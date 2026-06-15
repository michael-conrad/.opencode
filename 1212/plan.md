# Plan: Workstream D — New submodule-sync Task for git-workflow

**Spec:** #1212
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Separate (2-phase, new file + dispatch table update)

## Summary

Create a new `submodule-sync.md` task file under git-workflow skill and add a dispatch table row to the SKILL.md. The task syncs dirty submodule pointers to latest dev tip — used for mid-feature submodule currency and user "sync submodules" requests.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-D1 | `submodule-sync.md` exists at `.opencode/skills/git-workflow/tasks/submodule-sync.md` | structural |
| SC-D2 | git-workflow SKILL.md dispatch table has a row referencing `submodule-sync` for `"sync submodules" / "update submodules"` triggers | string |
| SC-D3 | The task procedure covers all submodule sync operations (detect via `.gitmodules`, checkout dev, pull --ff-only, return to parent, report results) | semantic |

---

## Pre-Work

1. Create feature branch from dev: `feature/1212-submodule-sync-task`
2. Tag `.opencode` submodule: `opencode-config/checkpoint/1212/pre-opencode`

---

## Phase 1: Create submodule-sync Task File

**Concern:** New task file implementing the submodule sync procedure (SC-D1, SC-D3).

**Files to modify:**
- `NEW: .opencode/skills/git-workflow/tasks/submodule-sync.md`

**Entry Criteria:** Spec approved, feature branch exists, submodule tagged.

**Exit Criteria:** `submodule-sync.md` exists with procedure covering: `.gitmodules` detection, per-submodule checkout dev and pull --ff-only, return to parent repo, result reporting.

### TDD Cycle

| Step | Action |
|------|--------|
| **RED** | `test -f .opencode/skills/git-workflow/tasks/submodule-sync.md` → expected FAIL (file doesn't exist yet) |
| **GREEN** | Create `submodule-sync.md` with full procedure |
| **REFACTOR** | `wc -w` check (< 3000 words), verify cross-references to git-workflow tag convention and submodule sub-agents table |

### Task File Content Description

The file follows the pattern from `provenance.md`:

```
# Task: submodule-sync

## Purpose
Sync dirty submodule pointers to latest dev tip. Used for mid-feature submodule currency and user "sync submodules" requests.

## Entry Criteria
- One or more submodules have dirty pointers in parent repo
- `.gitmodules` exists in worktree

## Procedure
- [ ] 1. Detect submodules: read `.gitmodules` for `[submodule "..."]` paths
- [ ] 2. For each submodule path:
      - `git checkout dev && git pull origin dev --ff-only`
      - On failure: log the submodule path and error; continue to next submodule
- [ ] 3. Return to parent repo: `git -C <parent> checkout <original-branch>`
- [ ] 4. Report: which submodules were synced successfully, which (if any) failed

## Exit Criteria
All accessible submodules point to latest dev tip. Failed submodules reported but do not block.

## Cross-References
- `git-workflow/SKILL.md` §Tag Convention — hash permanence tags preserve SHAs before sync
- `pre-work` task — submodule tagging at feature start
- Sub-Agent Tasks for Submodule Operations table — submodule ops NEVER done inline
```

## Phase 2: Update git-workflow SKILL.md Dispatch Table

**Concern:** Add dispatch table row referencing submodule-sync for "sync submodules" / "update submodules" triggers (SC-D2).

**Files to modify:**
- `.opencode/skills/git-workflow/SKILL.md` — Trigger Dispatch Table (line ~30, between "provenance" row and "completion" row)

**Entry Criteria:** Phase 1 complete, task file exists.

**Exit Criteria:** Dispatch table has exactly one new row for "sync submodules" / "update submodules" → `submodule-sync`.

### TDD Cycle

| Step | Action |
|------|--------|
| **RED** | `grep 'sync submodules' .opencode/skills/git-workflow/SKILL.md` → expected no match (row doesn't exist yet) |
| **GREEN** | Insert new row before the `completion` row: `\| "sync submodules" / "update submodules" \| submodule-sync \| sub-task \| {submodule_paths} \|` |
| **REFACTOR** | Verify table alignment; add task name to Tasks section list; add invocation row to Invocation table |

### Dispatch Table Row

```
| "sync submodules" / "update submodules" | submodule-sync | sub-task | {submodule_paths} |
```

### Invocation Row (add to Invocation section)

```
| submodule-sync | `task(..., prompt: "execute submodule-sync task from git-workflow")` |
```

---

## Verification Methods

- **SC-D1 (structural):** `test -f .opencode/skills/git-workflow/tasks/submodule-sync.md` → exits 0
- **SC-D2 (string):** `grep -q 'sync submodules.*submodule-sync' .opencode/skills/git-workflow/SKILL.md` → exits 0
- **SC-D3 (semantic):** Read `submodule-sync.md` and verify all four operation types present: `.gitmodules` detection, checkout dev + pull --ff-only, return to parent, result reporting

---

## Post-Implementation

1. Tag submodule: `opencode-config/checkpoint/1212/post-opencode`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`