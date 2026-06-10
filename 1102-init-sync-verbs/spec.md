# [SPEC] local-issues: init + sync verbs, fully qualified mutations + output, sync-from-remote skill task

**Repo:** `.opencode` (local-issues tool lives at `.opencode/tools/local-issues`)

## Summary

Two new verbs for `local-issues` (`init`, `sync`) and one new skill task in `issue-operations` (`sync-from-remote`). The tool verbs handle git-level worktree initialization and data synchronization. The skill task handles content-level reconciliation between remote and local issue bodies.

## Problem

Currently, worktree initialization is an implicit side effect of the first `list`/`create` call. Pulling remote changes requires manual `git -C .issues pull --rebase origin issues-data`. There's no explicit bootstrap verb, no session-start sync verb, and no content-level reconciliation that ensures local `.issues/` mirrors all open remote issues.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `local-issues init` bootstraps orphan `issues-data` branch + worktree at `.issues/` when none exists, cascading to all discovered child repos | `behavioral` | Run in empty repo, verify `.issues/.git` exists + `issues-data` branch + per-repo worktree files |
| SC-2 | `local-issues init` delegates to `sync` (pull + push) when worktree already exists | `behavioral` | Run on already-initialized repo, verify output shows sync result |
| SC-3 | `local-issues init` reports per-repo YAML with `qualifier`, `status`, and conflict hint when pull fails | `string` | Stale remote causing merge conflict → verify output contains `conflict` + qualifier string |
| SC-4 | `local-issues sync` commits pending changes, pulls remote with rebase, pushes merged result | `behavioral` | Direct `.issues/` write → `sync` → verify commit on issues-data + remote updated |
| SC-5 | `local-issues sync` reports `ok` or `conflict` with qualifier per repo | `string` | grep output for `status: ok\|status: conflict` |
| SC-6 | All `local-issues` output uses fully qualified format (dir#N, never bare #N), and all mutation commands require repo#N qualifier | `string` | Run `list` → grep for `opencode-config#N` format |
| SC-7 | `issue-operations --task sync-from-remote` lists remote open issues, diffs against local, imports missing ones, reports staleness direction | `behavioral` | Set up remote with issues not in local → run task → verify local now has those issues |
| SC-8 | Mutation commands (`create`, `update`, `close`, etc.) still auto-commit + push (unchanged) | `behavioral` | Create issue → verify commit on issues-data occurs |

## Phases

### Phase 1: `init` verb in local-issues

- Add `init` subcommand to `build_parser()`
- Add helpers: `_count_issues()`, `_pull_and_report()`, `_collect_repos()`
- Logic: `_ensure_all_worktrees()` per repo, then pull remote with rebase per repo
- Output per-repo YAML: `{repo, qualifier, path, status, issues_count, pull_result, conflict_hint?}`

### Phase 2: `sync` verb in local-issues

- Add `sync` subcommand to `build_parser()`
- Logic per repo: add → commit → pull-rebase → push
- Reports per-repo YAML with qualifier

### Phase 3: Fully qualified mutations + output

- `create --number`: `type=int` → `type=str`, accept `repo#N` via `_parse_qualified()`
- `comment --number`: `_parse_qualified()` → `_require_qualified()`
- `link --number`: `type=int` → `type=str`, require qualifier
- `renumber --from --to`: `type=int` → `type=str`, require qualifier
- `list`/`search` output: always `dirname#N` format
- Update `.opencode/.issues/AGENTS.md`

### Phase 4: `sync-from-remote` skill task

- New: `.opencode/skills/issue-operations/tasks/sync-from-remote.md`
- Update: `.opencode/skills/issue-operations/SKILL.md` (task table + trigger keywords)
- Update: `.opencode/.issues/AGENTS.md` (workflow table)

## Relationships

- `init` delegates to `sync` when worktree exists
- `sync-from-remote` calls `local-issues sync` as first step
- Mutation auto-commit + push unchanged
- No git jargon in agent-facing interface

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)