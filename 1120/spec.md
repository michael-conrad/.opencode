# Spec: Replace .issues/ Worktree with Sibling Peer Repos

**Status:** DRAFT
**Date:** 2026-06-11
**Issue:** https://github.com/michael-conrad/.opencode/issues/1120

## Problem

The AI agent is repeatedly confused by git worktrees checked out as `.issues/`. Specific failure patterns:

1. **Worktree path resolution split-brain**: The `worktree.path` context variable fires for ALL worktrees including `.issues/`. An explicit exemption in `060-tool-usage.md` says `.issues/` does NOT need the prefix — but the agent applies or skips the prefix inconsistently, writing to the wrong repo.

2. **Orphan branch in main repo's ref namespace**: The `issues-data` orphan branch lives in the code repo's ref list. During `git-workflow cleanup`, the agent scans branches, sees `issues-data`, and attempts to delete it — losing data.

3. **`.opencode/.issues/` nested worktree**: Same split-brain problem compounded by being nested inside the submodule.

## Solution

Replace ALL `.issues/` worktrees with standalone sibling peer repos at the workspace root level. Each sibling is a standalone `git clone` of its parent repo, checked out on the `issues-data` branch — no worktrees, no orphan branches in the code repo's ref list.

### Target Directory Layout

```
~/git/
  opencode-config/                          # code repo (project root)
    .opencode/                              # submodule (mandatory nesting, ONLY nesting)
  opencode-config.issues-data/              # code repo's issue data (standalone clone)
  .opencode.issues-data/                    # .opencode repo's issue data (standalone clone)
```

### Characteristics

| Property | Value |
|---|---|
| Branch name in sibling repos | `issues-data` (always, never "issues") |
| Sibling directory naming | `{REPO}.issues-data/` |
| Path resolution | `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/spec-artifacts/` |
| Worktrees | Zero. Every issue-data repo is a standalone clone. |
| `.issues/` directories | Zero everywhere including `.opencode/.issues/`. |
| Orphan branches in code repo | Zero. All orphan branches live in sibling repos only. |
| Session-init reporting | Does NOT report siblings. Sibling discovery by `local-issues` tool. |
| Wiki | Out of scope for this spec. |

## Success Criteria

| ID | Criterion | Evidence Type |
|---|---|---|
| SC-1 | `local-issues init` clones sibling repo instead of creating worktree | `behavioral` |
| SC-2 | `local-issues` tool validates sibling repo exists on every command call | `behavioral` |
| SC-3 | Zero `.issues/` directories exist in any repo after migration | `structural` |
| SC-4 | Session-init does NOT report sibling repo paths | `string` |
| SC-5 | `060-tool-usage.md` `.issues/` Worktree Exemption section deleted | `string` |
| SC-6 | All skill task card `.issues/{N}` paths converted to `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/` | `string` |
| SC-7 | `.opencode/.issues/` worktree eliminated — replaced by `.opencode.issues-data/` sibling | `structural` |
| SC-8 | Agent cannot see `issues-data` branch in code repo's ref list | `behavioral` |
| SC-9 | `local-issues init` auto-migrates existing `.issues/` worktree content to sibling | `behavioral` |

## Phases

### Phase 1: `local-issues` Tool Rewrite

Replace all worktree management in `tools/local-issues` with sibling repo operations.

**Functions to rewrite:**

| Current Function | Replacement |
|---|---|
| `_worktree_active()` | `_sibling_valid()` — check `{REPO}.issues-data/.git/HEAD` exists |
| `_ensure_worktree()` | `_ensure_sibling()` — `git clone -b issues-data <remote-url> ../{REPO}.issues-data/` |
| `_ensure_all_worktrees()` | `_ensure_all_siblings()` — iterate repos, clone each |
| `_push_worktree()` | `git -C ../{REPO}.issues-data/ push origin issues-data` |
| `_auto_commit()` | `git -C ../{REPO}.issues-data/ add -A && commit -m "..." && push` |
| `_migrate_existing_data()` | Part of auto-remediation |
| `_detect_dual_branch()` | Removed |
| `_push_orphan_if_needed()` | Removed |
| `init` command | Detect `.issues/` → auto-remediate → clone sibling |

**New functions:**

| Function | Purpose |
|---|---|
| `_sibling_repo_path(repo_path)` | Resolve `{PROJECT_ROOT}/../{REPO}.issues-data/` |
| `_sibling_remote_url(repo_path)` | Resolve clone URL from repo's remote |
| `_sibling_valid(repo_path)` | Verify sibling repo exists and has correct branch |
| `_validate_sibling_on_call()` | Called on every mutation command — verify or auto-clone |

**Auto-commit/push unchanged** — target changes from `-C .issues` to `-C ../{REPO}.issues-data/`.

**Removed entirely:** `_worktree_active()`, `_ensure_worktree()`, all `git worktree` commands, `.issues/` fallback, `_detect_dual_branch()`.

**Auto-remediation (`init` command):**

When `local-issues init` runs, it checks each repo for existing `.issues/` worktrees:

1. Snapshot ALL content from `.issues/` (committed, uncommitted, unpushed)
2. `git worktree remove .issues` (force if dirty: `--force`)
3. `git worktree prune` — remove stale entries
4. Delete `.issues/` directory from repo root
5. Clone sibling from same remote, issues-data branch
6. For each item in snapshot not present in clone: copy it in
7. Auto-commit restored content to sibling
8. `git branch -D issues-data` (local only, not remote)
9. Report: "Migrated from worktree to sibling at ../{REPO}.issues-data/"

### Phase 2: AGENTS.md per Sibling

Each `{REPO}.issues-data/` clone gets an AGENTS.md restricting operations.

### Phase 3: Path Updates

~194 references to `.issues/{N}/` across skill task files and guidelines. All converted to `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/`.

| Group | Files | Ref Count |
|---|---|---|
| issue-operations local platform | `platforms/local/SKILL.md`, `platforms/local/tasks/*.md`, `tasks/creation.md`, `tasks/comment.md`, `tasks/sync-from-remote.md` | ~115 |
| writing-plans | `SKILL.md`, `tasks/create.md`, `tasks/create/plan-structure.md`, `tasks/create/create-and-validate.md` | 36 |
| spec-creation | `tasks/write.md`, `tasks/pipeline-readiness-gate.md` | 27 |
| guidelines | `060-tool-usage.md`, `000-critical-rules.md` | 8 |
| implementation-pipeline | `SKILL.md`, `enforcement/context-passing.md` | 5 |
| tests | `tests/AGENTS.md` | 3 |

### Phase 4: Guideline Updates

- **`060-tool-usage.md`**: Delete `.issues/` Worktree Exemption section. Update Identity Source Semantics.
- **`000-critical-rules.md`**: Update inline issue content creation rule.

### Phase 5: Test Updates

~30 behavioral test files updated. New behavioral tests:

- `local-issues-init-clones-sibling.sh` — SC-1
- `local-issues-validate-sibling.sh` — SC-2
- `local-issues-auto-clone.sh` — SC-3
- `local-issues-auto-remediate.sh` — SC-9
- `local-issues-agent-no-issues-data-branch.sh` — SC-8

### Phase 6: Final Cleanup

1. Run `local-issues init` — triggers auto-remediation of any lingering `.issues/`
2. Verify zero `.issues/` directories: `find ~/git -name ".issues" -type d`
3. Verify code repo `git branch` shows no `issues-data`
4. Close spec issue

## Items (Dependency Order)

| Item | Phase | Description | Depends On |
|---|---|---|---|
| 1 | 1 | Rewrite `local-issues` tool — replace worktree with sibling clone, add auto-remediation | — |
| 2 | 2 | Create AGENTS.md per sibling | 1 |
| 3 | 3 | Update issue-operations local platform paths | 1 |
| 4 | 3 | Update writing-plans paths | 1 |
| 5 | 3 | Update spec-creation paths | 1 |
| 6 | 3 | Update implementation-pipeline paths | 1 |
| 7 | 4 | Update guidelines | — |
| 8 | 5 | Update test harness, behavioral tests, Python tests | 1 |
| 9 | 6 | Run `local-issues init`; verify zero `.issues/` | 1,8 |