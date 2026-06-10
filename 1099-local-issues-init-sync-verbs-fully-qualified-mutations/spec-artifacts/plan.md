# Implementation Plan: init + sync verbs, fully qualified mutations, sync-from-remote

Spec: `.opencode/.issues/1099-local-issues-init-sync-verbs-fully-qualified-mutations/spec.md`
Target file: `.opencode/tools/local-issues`

## Phase 1: `init` verb

**File:** `.opencode/tools/local-issues`
**Items:**
1. Add `_count_issues()` and `_pull_and_report()` helpers
2. Add `_collect_repos()` helper
3. Implement `cmd_init()` — bootstrap worktrees, pull per repo, output YAML
4. Add parser entry + command map registration

## Phase 2: `sync` verb

**File:** `.opencode/tools/local-issues`
**Items:**
1. Implement `cmd_sync()` — commit-all → pull-rebase → push per repo, output YAML
2. Add parser entry + command map registration

## Phase 3: Fully qualified mutations

**File:** `.opencode/tools/local-issues`
**Items:**
1. `create --number`: change to `type=str`, parse via `_parse_qualified()`, fully qualified output
2. `comment --number`: change to `_require_qualified()`
3. `link`: change to `type=str`, parse via `_require_qualified()`
4. `renumber`: change to `type=str`, parse via `_require_qualified()`
5. `list`/`search` output: always `dirname#N` format
6. Update `.opencode/.issues/AGENTS.md`

## Phase 4: `sync-from-remote` skill task

**Files:**
1. `.opencode/skills/issue-operations/tasks/sync-from-remote.md` — new task file
2. `.opencode/skills/issue-operations/SKILL.md` — add task to table and trigger keywords
3. `.opencode/.issues/AGENTS.md` — add workflow entries for init/sync/sync-from-remote