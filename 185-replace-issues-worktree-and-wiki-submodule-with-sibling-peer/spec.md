# Spec: Replace .issues/ Worktree with Sibling Peer Repos

**Status:** DRAFT
**Date:** 2026-06-11
**Issue:** https://github.com/michael-conrad/opencode-config/issues/185

## Problem

The AI agent is repeatedly confused by git worktrees checked out as `.issues/`. Specific failure patterns:

1. **Worktree path resolution split-brain**: The `worktree.path` context variable fires for ALL worktrees including `.issues/`. An explicit exemption in `060-tool-usage.md` says `.issues/` does NOT need the prefix — but the agent applies or skips the prefix inconsistently, writing to the wrong repo.

2. **Orphan branch in main repo's ref namespace**: The `issues-data` orphan branch lives in the code repo's ref list. During `git-workflow cleanup`, the agent scans branches, sees `issues-data`, and attempts to delete it — losing data.

3. **`.opencode/.issues/` nested worktree**: Same split-brain problem as the parent's `.issues/` but nested inside the submodule, compounding path resolution errors.

## Solution

Replace ALL `.issues/` worktrees with standalone sibling peer repos at the workspace root level. Each sibling is a standalone `git clone` of its parent repo, checked out on the `issues-data` branch — no worktrees, no orphan branches in the code repo's ref list.

### Target Directory Layout

```
~/git/
  opencode-config/                          # code repo (project root)
    .opencode/                              # submodule (mandatory nesting, ONLY nesting)
  opencode-config.issues-data/              # code repo's issue data (standalone clone, issues-data branch)
  .opencode.issues-data/                    # .opencode repo's issue data (standalone clone, issues-data branch)
```

### Characteristics

| Property | Value |
|---|---|
| Branch name in sibling repos | `issues-data` (always, never "issues") |
| Sibling directory naming | `{REPO}.issues-data/` |
| Path resolution | `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/spec-artifacts/` |
| Worktrees | Zero. Not one. Every issue-data repo is a standalone clone. |
| `.issues/` directories | Zero. Eliminated everywhere including `.opencode/.issues/`. |
| Orphan branches in code repo | Zero. All orphan branches live in sibling repos only. |
| Session-init reporting | Does NOT report siblings. Only project root contents. Sibling discovery by `local-issues` tool. |
| Wiki | Out of scope for this spec. Not handled by `local-issues`. |

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

Replace all worktree management in `.opencode/tools/local-issues` with sibling repo operations.

**Functions to rewrite:**

| Current Function | Replacement |
|---|---|
| `_worktree_active()` | `_sibling_valid()` — check `{REPO}.issues-data/.git/HEAD` exists |
| `_ensure_worktree()` | `_ensure_sibling()` — `git clone -b issues-data <remote-url> ../{REPO}.issues-data/` |
| `_ensure_all_worktrees()` | `_ensure_all_siblings()` — iterate repos, clone each |
| `_push_worktree()` | `git -C ../{REPO}.issues-data/ push origin issues-data` |
| `_auto_commit()` | `git -C ../{REPO}.issues-data/ add -A && commit -m "..." && push` |
| `_migrate_existing_data()` | Part of auto-remediation (see below) |
| `_detect_dual_branch()` | Removed — no "issues" branch in sibling |
| `_push_orphan_if_needed()` | Removed — sibling remote always has `issues-data` |
| `init` command | Detect existing `.issues/` → auto-remediate → clone sibling |

**New functions:**

| Function | Purpose |
|---|---|
| `_sibling_repo_path(repo_path)` | Resolve `{PROJECT_ROOT}/../{REPO}.issues-data/` |
| `_sibling_remote_url(repo_path)` | Resolve clone URL from repo's remote |
| `_sibling_valid(repo_path)` | Verify sibling repo exists, has `.git/HEAD`, has correct branch |
| `_validate_sibling_on_call()` | Called at top of every mutation command — verify sibling repo exists or auto-clone |

**Sibling validation on every command call:**

Every `cmd_*` handler (`create`, `update`, `close`, `comment`, `link`, `delete`, `promote`, `search`, `list`, `read`) MUST call `_validate_sibling_on_call()` at entry that verifies:
1. `{PROJECT_ROOT}/../{REPO}.issues-data/` exists
2. `.git/HEAD` exists and is valid
3. If either fails → auto-clone before proceeding, or HALT with clear error

**Auto-commit/push unchanged:**

All mutation commands (`create`, `update`, `close`, `comment`, `link`, `delete`, `renumber`, `promote`) still auto-commit and auto-push after mutation. Only the target directory changes from `-C .issues` to `-C ../{REPO}.issues-data/`.

**Removed entirely:**

- `_worktree_active()` — concept eliminated
- `_ensure_worktree()` — concept eliminated
- `git worktree add --detach` — orphan branch creation via `git clone -b issues-data`
- `git worktree prune` — no worktrees to prune
- `.issues/` fallback to plain files — no worktree to fall back from
- `_detect_dual_branch()` — no "issues" branch in sibling

**Auto-remediation (`init` command):**

When `local-issues init` runs, it checks each repo for existing `.issues/` worktrees. If found:

1. Snapshot ALL content from `.issues/` — every file and directory (committed, uncommitted, unpushed)
2. `git worktree remove .issues` (force if dirty: `--force`)
3. `git worktree prune` — remove stale entries
4. Delete `.issues/` directory from repo root
5. Clone sibling from same remote, issues-data branch:
   `git clone -b issues-data <remote-url> ../{REPO}.issues-data/`
6. For each item in snapshot: if it does NOT exist in cloned sibling, copy it in
7. Auto-commit restored content to sibling
8. Remove `issues-data` branch from repo's local ref list:
   `git branch -D issues-data` (local only, not remote)
9. Report: "Migrated from worktree to sibling at ../{REPO}.issues-data/"

### Phase 2: AGENTS.md per Sibling Repo

Each sibling repo has its own AGENTS.md:

**`opencode-config.issues-data/AGENTS.md`:**
```
# AGENTS.md — Issue Data Sibling Repo
- This repo contains issue tracking data only.
- Branch: `issues-data` (always).
- No feature branches. No PRs. No wiki content.
- All operations through `local-issues` tool from the parent repo.
```

**`.opencode.issues-data/AGENTS.md`:**
```
# AGENTS.md — .opencode Issue Data Sibling Repo
- This repo contains issue tracking data for the .opencode repo.
- Branch: `issues-data` (always).
- No feature branches. No PRs.
- All operations through `local-issues` tool.
```

### Phase 3: Skill Task Card Path Updates

~194 references to `.issues/{N}/` across skill task files and guidelines. All must be converted.

**Conversion pattern:**

```
Current:    .issues/{N}/spec-artifacts/plan.md
New:        {PROJECT_ROOT}/../{REPO}.issues-data/{N}/spec-artifacts/plan.md
```

`{REPO}` is resolved by the `local-issues` tool, not hardcoded.

**Files to update (grouped by effort):**

| Group | Files | Ref Count | Effort |
|---|---|---|---|
| issue-operations local platform | `platforms/local/SKILL.md`, `platforms/local/tasks/*.md`, `tasks/creation.md`, `tasks/comment.md`, `tasks/sync-from-remote.md` | ~115 | High |
| writing-plans | `SKILL.md`, `tasks/create.md`, `tasks/create/plan-structure.md`, `tasks/create/create-and-validate.md` | 36 | Medium |
| spec-creation | `tasks/write.md`, `tasks/pipeline-readiness-gate.md` | 27 | Medium |
| guidelines | `060-tool-usage.md`, `000-critical-rules.md` | 8 | Low |
| implementation-pipeline | `SKILL.md`, `enforcement/context-passing.md` | 5 | Low |
| tests | `tests/AGENTS.md` | 3 | Low |
| TOTAL | ~30 files | ~194 | |

### Phase 4: Guideline Updates

**`060-tool-usage.md` — Delete entire `.issues/` Worktree Exemption section:**

```
### `.issues/` Worktree Exemption (CRITICAL)
→ DELETE (lines 126-139)
```

The branching requirement footnote moves to sibling AGENTS.md.

**`060-tool-usage.md` — Update §9 Identity Source Semantics:**

Line 235: `use local .issues/` directory → `use sibling repo at ../{REPO}.issues-data/`

**`000-critical-rules.md` — Update inline issue content creation rule:**

Line 580: "orchestrator editing .issues/ files" → "orchestrator writing to issues-data sibling repo via local-issues tool"

### Phase 5: Test Updates

~30 behavioral test files reference `.issues/` paths. Changes:

| File | Change Description |
|---|---|
| `tests/behaviors/helpers.sh` | Remove worktree setup. Replace with sibling clone setup. |
| `tests/behaviors/local-issues-multi-repo.sh` | Change prompt from "create .issues/ worktree" to "clone issues-data sibling" |
| `tests/behaviors/local-issues-list-spec-path.sh` | Change `.issues/100/` to sibling-relative path |
| `tests/behaviors/local-issues-list-qualified-format.sh` | Same |
| `tests/behaviors/local-issues-list-sort-order.sh` | Same |
| `tests/behaviors/1102-sc-8-mutation-auto-commit.sh` | Change `-C .issues` to `-C ../{REPO}.issues-data/` |
| `tests/behaviors/1102-sc-2-init-delegates-to-sync.sh` | Change sync delegation path |
| `tests/behaviors/auditor-*.sh` | Update spec_local_dir paths |
| `tests/behaviors/spec1061-sc-*.sh` | Content-verification artifact paths |
| `tests/behaviors/spec-revision-no-auth.sh` | Update `.issues/1/spec.md` path |
| `tests/behaviors/no-inline-fallback-universal.sh` | Update forbidden pattern |
| `tests/behaviors/issue-operations-submodule-routing.sh` | Update `.issues/` assertion |
| `tests/behaviors/local-issue-routing.sh` | Update expected paths |
| `tests/behaviors/local-first-creation.sh` | Update prompt/expected paths |
| `tests/behaviors/local-issues-create-plain.sh` | Update prompt/expected paths |
| `tests/behaviors/local-issues-autonumber.sh` | Update prompt/expected paths |
| `tests/behaviors/content-classification-gate.sh` | Update `.issues/` storage paths |
| `tests/behaviors/decision-log-local-first.sh` | Update `.issues/` path |
| `tests/behaviors/sync-classification.sh` | Update fixture paths |
| `tests/behaviors/fixtures/setup-fixture-issues.sh` | Update fixture creation paths |
| `tests/test_local_issues.py` | Remove worktree tests. Add sibling-validation tests. |
| `tests/test_local_issues_setup.py` | Remove worktree tests. Add sibling clone tests. |

New behavioral tests:

- `local-issues-init-clones-sibling.sh` — SC-1: `local-issues init` clones sibling (behavioral)
- `local-issues-validate-sibling.sh` — SC-2: validates sibling exists on every call (behavioral)
- `local-issues-auto-clone.sh` — SC-3: auto-clones if sibling missing (behavioral)
- `local-issues-auto-remediate.sh` — SC-9: auto-migrates existing `.issues/` (behavioral)
- `local-issues-agent-no-issues-data-branch.sh` — SC-8: agent cannot see issues-data in code repo (behavioral)

### Phase 6: Final Cleanup — Verify

1. Run `local-issues init` — triggers auto-remediation of any lingering `.issues/` worktrees
2. Verify zero `.issues/` directories: `find ~/git -name ".issues" -type d`
3. Verify code repo `git branch` shows no `issues-data` branch
4. Verify `status: completed` for this spec's issue

## Items (Dependency Order)

| Item | Phase | Description | Depends On |
|---|---|---|---|
| 1 | 1 | Rewrite `local-issues` tool — replace worktree functions with sibling clone functions, add auto-remediation for existing `.issues/` | — |
| 2 | 2 | Create AGENTS.md for each sibling repo | 1 |
| 3 | 3 | Update issue-operations local platform paths | 1 |
| 4 | 3 | Update writing-plans paths | 1 |
| 5 | 3 | Update spec-creation paths | 1 |
| 6 | 3 | Update implementation-pipeline paths | 1 |
| 7 | 4 | Update guidelines (060-tool-usage.md, 000-critical-rules.md) | — |
| 8 | 5 | Update test harness, behavioral tests, Python tests | 1 |
| 9 | 6 | Run `local-issues init` to trigger auto-remediation; verify zero `.issues/` | 1,8 |