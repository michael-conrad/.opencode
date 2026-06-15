---
remote_issue: 1212
remote_url: "https://github.com/michael-conrad/.opencode/issues/1212"
last_sync: 2026-06-14T20:50:16Z
source: github.com
---

## Workstream D — New submodule-sync Task

**Parent:** #1208
**Depends on:** #1210 (Workstream B)

### Scope
One new task file in git-workflow skill.

### Changes

Create `.opencode/skills/git-workflow/tasks/submodule-sync.md`:

**Purpose:** Sync a dirty submodule pointer's submodule(s) to the latest dev tip. Used both for mid-feature submodule currency and as a response to user "sync submodules" requests.

**Entry Criteria:** One or more submodules have dirty pointers (modified content in parent repo).

**Procedure:**
- [ ] 1. Detect submodules via `.gitmodules`
- [ ] 2. For each submodule: `git checkout dev && git pull origin dev --ff-only`
- [ ] 3. Return to parent repo
- [ ] 4. Report which submodules were synced and which (if any) failed

**Exit Criteria:** All tracked submodules point to latest dev tip.

**Routing:** This task is referenced by the git-workflow dispatch table row:
```
| "sync submodules" / "update submodules" | submodule-sync | blind sub-task | submodule_paths |
```

### SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-D1 | `submodule-sync.md` exists at the expected path | structural |
| SC-D2 | git-workflow dispatch table has a row referencing submodule-sync for submodule sync triggers | string |
| SC-D3 | The task procedure covers all submodule sync operations | semantic |
