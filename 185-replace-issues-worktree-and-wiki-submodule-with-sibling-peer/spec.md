# Spec: Replace .issues/ Worktree and Wiki Submodule with Sibling Peer Repos

**Status:** DRAFT
**Date:** 2026-06-11
**Issue:** https://github.com/michael-conrad/opencode-config/issues/185

## Problem

The AI agent is repeatedly confused by git worktrees checked out as `.issues/` and wiki submodules. Specific failure patterns:

1. **Worktree path resolution split-brain**: The `worktree.path` context variable fires for ALL worktrees including `.issues/`. An explicit exemption in `060-tool-usage.md` says `.issues/` does NOT need the prefix — but the agent applies or skips the prefix inconsistently, writing to the wrong repo.

2. **Orphan branch in main repo's ref namespace**: The `issues-data` orphan branch lives in the code repo's ref list. During `git-workflow cleanup`, the agent scans branches, sees `issues-data`, and attempts to delete it — losing data.

3. **Wiki submodule pointer corruption**: Submodules introduce detached HEAD traps, two-commit push rituals, dirty pointer management during cleanup, and data loss when the agent commits wrong SHAs to the main repo.

4. **`.opencode/.issues/` nested worktree**: Same split-brain problem as the parent's `.issues/` but nested inside the submodule, compounding path resolution errors.

## Solution

Replace ALL `.issues/` worktrees and the wiki submodule with standalone sibling peer repos at the workspace root level. Each sibling repo is a standalone `git clone` — no worktrees, no orphan branches in the code repo, no submodule pointers.

### Target Directory Layout

```
~/git/
  opencode-config/                          # code repo (project root)
    .opencode/                              # submodule (mandatory nesting, ONLY nesting)
  opencode-config.issues-data/              # code repo's issue data (standalone clone)
  opencode-config.wiki/                     # code repo's wiki (standalone clone)
  .opencode.issues-data/                    # .opencode repo's issue data (standalone clone)
```

### Characteristics

| Property | Value |
|---|---|
| Branch name in sibling repos | `issues-data` (always, never "issues") |
| Sibling directory naming | `{REPO}.issues-data/` for issues, `{REPO}.wiki/` for wiki |
| Path resolution | `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/spec-artifacts/` |
| Worktrees | Zero. Not one. Every issue-data repo is a standalone clone. |
| `.issues/` directories | Zero. Eliminated everywhere including `.opencode/.issues/`. |
| Orphan branches in code repo | Zero. All orphan branches live in sibling repos only. |
| Session-init reporting | Does NOT report siblings. Only project root contents. Sibling discovery by `local-issues` tool. |

## Success Criteria

| ID | Criterion | Evidence Type |
|---|---|---|
| SC-1 | `local-issues init` clones sibling repo instead of creating worktree | `behavioral` |
| SC-2 | `local-issues` tool validates sibling repo exists on every command call | `behavioral` |
| SC-3 | Zero `.issues/` directories exist in any repo after migration | `structural` |
| SC-4 | Session-init does NOT report sibling repo paths | `string` |
| SC-5 | `060-tool-usage.md` `.issues/` Worktree Exemption section deleted | `string` |
| SC-6 | All skill task card `.issues/{N}` paths converted to `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/` | `string` |
| SC-7 | Wiki submodule removed from `.gitmodules` | `structural` |
| SC-8 | `git-workflow cleanup` tasks handle "no wiki submodule" branch | `behavioral` |
| SC-9 | `.opencode/.issues/` worktree eliminated — replaced by `.opencode.issues-data/` sibling | `structural` |
| SC-10 | Agent cannot see `issues-data` branch in code repo's ref list | `behavioral` |

## Phases

### Phase 1: `local-issues` Tool Rewrite

Replace all worktree management in `.opencode/tools/local-issues` with sibling repo operations.

**Functions to rewrite:**

| Current Function | Replacement |
|---|---|
| `_worktree_active()` | `_sibling_valid()` — check `{REPO}.issues-data/.git/HEAD` exists |
| `_ensure_worktree()` | `_ensure_sibling()` — `git clone git@github.com:{owner}/{REPO}.git ../{REPO}.issues-data/ -b issues-data` |
| `_ensure_all_worktrees()` | `_ensure_all_siblings()` — iterate repos, clone each |
| `_push_worktree()` | `git -C ../{REPO}.issues-data/ push origin issues-data` |
| `_auto_commit()` | `git -C ../{REPO}.issues-data/ add -A && commit -m "..." && push` |
| `_migrate_existing_data()` | Not needed — sibling repo has own history |
| `_detect_dual_branch()` | Not needed — no "issues" branch exists in sibling |
| `_push_orphan_if_needed()` | Not needed — sibling remote always has `issues-data` |
| `init` command | Clone sibling repo + pull instead of `git worktree add` |

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
- `git worktree add --detach` — orphan branch creation now happens server-side via `git clone -b issues-data`
- `git worktree prune` — no worktrees to prune
- `.issues/` fallback to plain files — no worktree to fall back from
- `_detect_dual_branch()` — no "issues" branch in sibling
- Migration of existing `.issues/` data — not needed

### Phase 2: Create Target Sibling Repos on Remote

| Repo | Remote | Initial Branch | Description |
|---|---|---|---|
| `opencode-config.issues-data` | `github.com/michael-conrad/opencode-config.issues-data` | `issues-data` | Contains issue data for opencode-config repo |
| `opencode-config.wiki` | `github.com/michael-conrad/opencode-config.wiki` | `main` | Contains wiki content for opencode-config repo |
| `.opencode.issues-data` | `github.com/michael-conrad/.opencode.issues-data` | `issues-data` | Contains issue data for .opencode repo |

Each created via:
```bash
gh repo create opencode-config.issues-data --private --description "Issue data for opencode-config"
git clone git@github.com:michael-conrad/opencode-config.issues-data.git ../opencode-config.issues-data/
cd ../opencode-config.issues-data/
git checkout --orphan issues-data
git commit --allow-empty -m "Init issues-data branch"
git push origin issues-data
```

Same pattern for `.opencode.issues-data`.

For wiki: `gh repo create opencode-config.wiki --private --description "Wiki for opencode-config"`

### Phase 3: Session-Init and Repo Information

**No changes to session-init output.** Session-init reports only what's under the project root. Sibling repos are discovered by `local-issues` tool via `{PROJECT_ROOT}/../{sibling-name}/`.

Each sibling repo has its own AGENTS.md:

**`opencode-config.issues-data/AGENTS.md`:**
```
# AGENTS.md — Issue Data Sibling Repo
- This repo contains issue tracking data only.
- Branch: `issues-data` (always).
- No feature branches. No PRs. No wiki content.
- All operations through `local-issues` tool from the parent repo.
```

**`opencode-config.wiki/AGENTS.md`:**
```
# AGENTS.md — Wiki Sibling Repo
- This repo contains wiki content only.
- Branch: `main`.
- Direct git operations only. No issues. No feature branches.
- Not a submodule of opencode-config.
```

**`.opencode.issues-data/AGENTS.md`:**
```
# AGENTS.md — .opencode Issue Data Sibling Repo
- This repo contains issue tracking data for the .opencode repo.
- Branch: `issues-data` (always).
- No feature branches. No PRs.
- All operations through `local-issues` tool.
```

### Phase 4: Skill Task Card Path Updates

~194 references to `.issues/{N}/` across skill task files and guidelines. All must be converted.

**Conversion pattern:**

```
Current:    .issues/{N}/spec-artifacts/plan.md
New:        {PROJECT_ROOT}/../{REPO}.issues-data/{N}/spec-artifacts/plan.md

Where {REPO} is resolved by local-issues tool, not hardcoded.
```

**Preferred approach: Tool abstraction.**

Instead of hardcoding paths in every task file, the `local-issues` tool should resolve paths. Task files reference paths via tool commands:

```
Current:  Write plan to .issues/{N}/spec-artifacts/plan.md
New:      Run local-issues write-artifact --number {N} --artifact plan.md --content "<plan>"

Or:       Path resolved via template variable ISSUES_ROOT set by session-init or local-issues tool.
```

**If template variable approach:**

All skill task files that contain `.issues/{N}` get a global search-and-replace:

| Pattern | Replacement |
|---|---|
| `.issues/{N}/` | `{ISSUES_ROOT}/{N}/` |
| `.issues/{issue-N}/` | `{ISSUES_ROOT}/{issue-N}/` |
| `.issues/{N}/spec-artifacts/` | `{ISSUES_ROOT}/{N}/spec-artifacts/` |
| `.issues/open/NNN-slug/` | `{ISSUES_ROOT}/open/NNN-slug/` |

Where `{ISSUES_ROOT}` resolves to `{PROJECT_ROOT}/../{REPO}.issues-data` and is injected by `local-issues tool` context.

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

### Phase 5: Guideline Updates

**`060-tool-usage.md` — Delete entire `.issues/` Worktree Exemption section:**

```
### `.issues/` Worktree Exemption (CRITICAL)
→ DELETE (lines 126-139)
```

The branching requirement footnote ("`.issues/` files MUST NOT be committed directly to `dev` or `main`") moves to the sibling repo's AGENTS.md, not to tool-usage.md.

**`060-tool-usage.md` — Update §9 Identity Source Semantics:**

Line 235: `use local .issues/` directory → `use sibling repo at ../{REPO}.issues-data/`

**`000-critical-rules.md` — Update inline issue content creation rule:**

Line 580: "orchestrator editing .issues/ files or calling github_issue_write directly" → "orchestrator writing to issues-data sibling repo via local-issues tool or calling github_issue_write directly"

### Phase 6: Test Updates

~30 behavioral test files reference `.issues/` paths. Changes:

| Test Type | Change |
|---|---|
| Behavioral tests prompting agent to create `.issues/` worktrees | Rephrase prompts for sibling repo creation |
| Content-verification tests checking `.issues/{N}/spec-artifacts/` paths | Update expected paths to `{PROJECT_ROOT}/../{REPO}.issues-data/{N}/spec-artifacts/` |
| Fixture infrastructure (`setup-fixture-issues.sh`, `helpers.sh`) | Create fixture data in sibling-style layout or use `local-issues` tool to seed |
| Test harness (`behavior_run`) | Pull sibling repo fixture data instead of setting up worktree |
| Python tests (`test_local_issues.py`, `test_local_issues_setup.py`) | Update test directory setup from worktree pattern to sibling clone pattern |

Test files specifically:

| File | Change Description |
|---|---|
| `tests/behaviors/helpers.sh` | Remove worktree setup logic. Replace with sibling clone setup. |
| `tests/behaviors/local-issues-multi-repo.sh` | Change prompt from "create .issues/ worktree" to "clone issues-data sibling repo" |
| `tests/behaviors/local-issues-list-spec-path.sh` | Change `.issues/100/` to sibling-relative path |
| `tests/behaviors/local-issues-list-qualified-format.sh` | Same |
| `tests/behaviors/local-issues-list-sort-order.sh` | Same |
| `tests/behaviors/1102-sc-8-mutation-auto-commit.sh` | Change `-C .issues` to `-C ../{REPO}.issues-data/` in expected output |
| `tests/behaviors/1102-sc-2-init-delegates-to-sync.sh` | Change sync delegation path |
| `tests/behaviors/auditor-*.sh` | Update spec_local_dir paths from `.issues/` to `{PROJECT_ROOT}/../{REPO}.issues-data/` |
| `tests/behaviors/spec1061-sc-*.sh` | Content-verification checks — update artifact paths |
| `tests/behaviors/spec-revision-no-auth.sh` | Update `.issues/1/spec.md` path |
| `tests/behaviors/no-inline-fallback-universal.sh` | Update forbidden pattern if `.issues/` is mentioned |
| `tests/behaviors/issue-operations-submodule-routing.sh` | Update `.issues/` assertion |
| `tests/behaviors/local-issue-routing.sh` | Update expected paths |
| `tests/behaviors/local-first-creation.sh` | Update prompt/expected paths |
| `tests/behaviors/local-issues-create-plain.sh` | Update prompt/expected paths |
| `tests/behaviors/local-issues-autonumber.sh` | Update prompt/expected paths |
| `tests/behaviors/content-classification-gate.sh` | Update `.issues/` local storage path |
| `tests/behaviors/decision-log-local-first.sh` | Update `.issues/` path |
| `tests/behaviors/sync-classification.sh` | Update fixture `.issues/open/`, `.issues/closed/` paths |
| `tests/behaviors/fixtures/setup-fixture-issues.sh` | Update fixture creation paths |
| `tests/test_local_issues.py` | Remove worktree-dependent tests. Add sibling-validation tests. |
| `tests/test_local_issues_setup.py` | Remove worktree creation tests. Add sibling clone tests. |

**New test SCs to add:**

- SC-1: `local-issues init` clones sibling repo (behavioral)
- SC-2: `local-issues` tool validates sibling repo exists on every command call (behavioral)
- SC-3: Tool auto-clones if sibling repo missing (behavioral)
- SC-4: Tool HALT with clear error if sibling cannot be cloned (behavioral)
- SC-5: Mutation commands auto-commit to sibling repo (behavioral)

### Phase 7: Wiki Submodule Removal

1. Remove wiki submodule from `.gitmodules`
2. Remove wiki section from `.git/config`
3. Delete wiki checkout directory
4. `git-workflow cleanup` task: add branch for "no wiki submodule" — skip submodule-related cleanup steps
5. Verify no remaining wiki submodule references in guidelines or skill tasks

### Phase 8: Final Cleanup — Remove `.issues/` Worktree

1. `git worktree prune` — remove stale `.issues/` worktree entries
2. Delete `.issues/` directory from opencode-config
3. Delete `.opencode/.issues/` worktree and directory
4. Remove `issues-data` branch from opencode-config remote: `git push origin --delete issues-data`
5. Remove `issues-data` branch from `.opencode` remote: `git push origin --delete issues-data`
6. Verify zero `.issues/` directories exist anywhere: `find ~/git -name ".issues" -type d`
7. Verify code repo `git branch` shows no `issues-data` branch
8. Verify `status: completed` for this spec's issue

## Items (Dependency Order)

| Item | Phase | Description | Depends On |
|---|---|---|---|
| 1 | 1 | Rewrite `local-issues` tool — replace worktree functions with sibling functions | — |
| 2 | 2 | Create `opencode-config.issues-data` repo on remote | — |
| 3 | 2 | Create `.opencode.issues-data` repo on remote | — |
| 4 | 2 | Create `opencode-config.wiki` repo on remote | — |
| 5 | 3 | Create AGENTS.md for each sibling repo | 2,3,4 |
| 6 | 4 | Update issue-operations platform paths | 1 |
| 7 | 4 | Update writing-plans paths | 1 |
| 8 | 4 | Update spec-creation paths | 1 |
| 9 | 4 | Update implementation-pipeline paths | 1 |
| 10 | 5 | Update guidelines (060-tool-usage.md, 000-critical-rules.md) | — |
| 11 | 6 | Update behavioral test scripts | 1 |
| 12 | 6 | Update Python tests | 1 |
| 13 | 6 | Update test harness/fixtures | 1 |
| 14 | 7 | Remove wiki submodule | 4,5 |
| 15 | 7 | Update cleanup tasks for no-wiki-submodule | 14 |
| 16 | 8 | Remove `.issues/` worktree from opencode-config | 1-6 |
| 17 | 8 | Remove `.opencode/.issues/` worktree | 1-6 |
| 18 | 8 | Delete `issues-data` branch from both remotes | 16,17 |
| 19 | 8 | Zero-`.issues/` verification pass | 16,17,18 |