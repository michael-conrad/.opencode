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
| SC-6 | All `local-issues` output uses fully qualified format (dir#N, never bare #N) | `string` | Run `list` → grep output for `opencode-config#N` format |
| SC-7 | `issue-operations --task sync-from-remote` lists remote open issues, diffs against local, imports missing ones, reports staleness direction | `behavioral` | Set up remote with issues not in local → run task → verify local now has those issues |
| SC-8 | Mutation commands (`create`, `update`, `close`, etc.) still auto-commit + push (unchanged) | `behavioral` | Create issue → verify commit on issues-data occurs |

## Phases

### Phase 1: `init` verb in local-issues

- Add `init` subcommand to `build_parser()`
- Logic: `_ensure_all_worktrees()` → `_ensure_worktree()` per repo (idempotent bootstrap)
- After bootstrap: per repo, run `git -C <repo>/.issues pull --rebase origin issues-data`
  - Capture stdout/stderr
  - Exit code 0 → status `ok`
  - Exit code non-zero → status `conflict`, include `qualifier: <dirname>` and `hint: git -C <repo>/.issues pull --rebase origin issues-data`
- Output YAML per repo: `{repo, qualifier, path, status, issues_count, pull_result}`
- All qualifiers come from `_resolve_repo_name()` for consistency

### Phase 2: `sync` verb in local-issues

- Add `sync` subcommand to `build_parser()`
- Logic per repo in cascade:
  1. `git -C .issues add -A && git -C .issues commit --allow-empty -m "auto: sync"`
  2. `git -C .issues pull --rebase origin issues-data`
  3. `git -C .issues push origin issues-data`
- Reports YAML per repo: `{repo, qualifier, status, conflict_hint?}`
- Stderr on conflict: include qualifier so agent knows which repo is affected

### Phase 3: Fully qualified mutation commands

Audit findings: 4 mutation commands missing qualifier support.

- `create --number`: change from `type=int` to `type=str`, accepting `repo#N` qualified form via `_parse_qualified()`. Auto-number (`--number` omitted) creates in current repo with fully qualified output.
- `comment --number`: currently uses `_parse_qualified()` (optional qualifier). Change to `_require_qualified()` — mutations require explicit repo target.
- `link --number`: currently `type=int`, bare number. Add qualifier support, require qualified form for mutations.
- `renumber --from --to`: currently `type=int`, bare numbers. Add qualifier support, require qualified form.

Already enforced: `update`, `close`, `delete`, `promote` (all call `_require_qualified()`). Read-only commands (`read`, `search`, `list`) accept optional qualifier — correct behavior.

Output changes: `list`, `search`, and any other command producing bare `#N` output use `dirname#N` format for all entries.

Update `.opencode/.issues/AGENTS.md` to reflect qualifier pattern throughout.

### Phase 4: `sync-from-remote` skill task in issue-operations

- New task file: `.opencode/skills/issue-operations/tasks/sync-from-remote.md`
- Trigger keywords: `sync-from-remote`, `post-sync reconcile`, `reconcile remote issues`
- Procedure:
  1. Call `local-issues sync` (ensure local git state is current)
  2. List open issues from remote via platform dispatch
  3. Call `local-issues list` and parse issue numbers
  4. Diff: for each remote issue not in local → call `import-remote` task
  5. For issues in both: compare `updated_at` timestamps
     - remote newer → `sync-pull-to-local` (update `remote.md`)
     - local newer → flag for agent action ("local ahead — run save or push")
  6. Report structured YAML: `{imported: [...], stale_remote: [...], stale_local: [...]}`
- Platform dispatch per standard `issue-operations` routing
- `.opencode/.issues/AGENTS.md` workflow table updated: "After `local-issues sync` → call `issue-operations --task sync-from-remote`"

## Relationships

- `init` delegates to `sync`
- `sync-from-remote` calls `local-issues sync` as first step
- Mutation auto-commit + push unchanged from current behavior
- No git jargon in agent-facing interface

## Approval Gate

Create: N/A (spec creation).
Review: standard.
Implementation: `for_implementation` scope.