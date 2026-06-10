# Implementation Plan: init + sync verbs, fully qualified mutations, sync-from-remote

Spec: `.opencode/.issues/1099-init-sync-verbs-for-local-issues-tool/spec.md`
Target file: `.opencode/tools/local-issues`

## Phase 1: `init` verb

**Concern:** Add `init` subcommand that bootstraps worktree and pulls remote.

### Items

1. **Add parser entry** — add `init` subparser to `build_parser()`
2. **Implement `cmd_init`** — call `_ensure_all_worktrees()` for bootstrap, then per repo: `git -C .issues pull --rebase origin issues-data`, capture result, output YAML
3. **Plumbing: `_count_issues(repo_path)`** — helper to count issue directories

## Phase 2: `sync` verb

**Concern:** Add `sync` subcommand for commit-all → pull-rebase → push.

### Items

1. **Add parser entry** — add `sync` subparser to `build_parser()`
2. **Implement `cmd_sync`** — per repo in cascade: add → commit → pull-rebase → push, capture result, output YAML

## Phase 3: Fully qualified mutations and output

**Concern:** All mutation commands require `repo#N` qualifier. All output uses `dirname#N`.

### Items

1. **`create --number`** — change from `type=int` to `type=str`, parse via `_parse_qualified()`, resolve repo, create in correct repo
2. **`comment --number`** — change from `_parse_qualified()` to `_require_qualified()`
3. **`link --number`** — change from `type=int` to `type=str`, parse via `_require_qualified()`
4. **`renumber --from --to`** — change from `type=int` to `type=str`, parse via `_require_qualified()`
5. **`list` output** — use `repo_name#N` for all entries (current repo too)
6. **`search` output** — use `repo_name#N` for all entries
7. **Update `comment` command in parser** — `--number` from `type=str` (already) → enforce `_require_qualified()` in `cmd_comment`

## Phase 4: `sync-from-remote` skill task

**Concern:** New `issue-operations/tasks/sync-from-remote.md` for remote→local issue reconciliation.

### Items

1. **Create task file** — `.opencode/skills/issue-operations/tasks/sync-from-remote.md`
2. **Update issue-operations SKILL.md** — add task to task table and trigger keywords
3. **Update `.issues/AGENTS.md`** — add workflow entry after `sync`