# Implementation Plan

Spec: `.opencode/.issues/1102-init-sync-verbs/spec.md`
Target: `.opencode/tools/local-issues`, `.opencode/skills/issue-operations/`

## Phase 1: `init` verb — `.opencode/tools/local-issues`
1. Add `_count_issues()`, `_pull_and_report()`, `_collect_repos()` helpers (before `_push_orphan_if_needed`)
2. Implement `cmd_init()` and `cmd_sync()`
3. Add parser entries + command map registration

## Phase 2: `sync` verb — `.opencode/tools/local-issues`
1. Implement `cmd_sync()`

## Phase 3: Fully qualified mutations — `.opencode/tools/local-issues`
1. `create --number`: `type=int` → `type=str`
2. `comment --number`: `_parse_qualified()` → `_require_qualified()`
3. `link --number`: `type=int` → `type=str`
4. `renumber --from --to`: `type=int` → `type=str`
5. `list`/`search` output: always `dirname#N`
6. Update `.opencode/.issues/AGENTS.md`

## Phase 4: `sync-from-remote` skill task
1. New: `.opencode/skills/issue-operations/tasks/sync-from-remote.md`
2. Update: `.opencode/skills/issue-operations/SKILL.md`
3. Update: `.opencode/.issues/AGENTS.md`