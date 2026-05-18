# [SPEC] Content classification gate + local-first issue architecture — unify #571, #585

**Prerequisite:** #523
**Supersedes:** #571, #585, #60

## Summary

Stop agents from posting internal reasoning, decision logs, and non-stakeholder content to the remote GitHub issue tracker. `.issues/` is the canonical storage for all internal artifacts; GitHub receives only exec summaries via `remote.md` sync.

## What Changes

| Area | Description |
|------|-------------|
| **Content classification gate** | Before every comment: classify as `stakeholder` or `internal`. Internal → `.issues/` only. Stakeholder → exec summary to `remote.md` → sync push. |
| **Routing enforcement** | All `github_*` / `gitbucket-api` issue calls → `issue-operations` dispatcher. Absorbs #571. |
| **Decision Log fix** | `assemble-work.md` Step 7 → `.issues/` storage, not GitHub comments |
| **Skill card bypasses** | ~35-40 files with direct calls → route through dispatcher |
| **Spec body staleness** | Comment revising spec → update `remote.md` + sync push + update `spec.md` |
| **`.issues/` canonical** | Phase tracking, task tracking, detailed plans, reasoning, decision logs all local. GitHub exec summaries only |

## Phases

1. Content classification gate (comment.md Step 1.5)
2. Routing enforcement (platform bypass critical violations + 7 new read/query tasks)
3. Spec body staleness fix (post-comment body update trigger)
4. Decision Log → .issues/ storage (assemble-work.md Step 7)
5. Skill card bypass sweep (migrate 35-40 files)
6. Behavioral enforcement tests

## Files Changed (Primary)

- `skills/issue-operations/tasks/comment.md` — classification gate
- `guidelines/000-critical-rules.md` — platform bypass violations
- `guidelines/060-tool-usage.md` — routing mandate
- `skills/issue-operations/SKILL.md` — 7 new tasks
- `skills/issue-operations/tasks/read-*.md` — 7 new task files
- `skills/divide-and-conquer/tasks/assemble-work.md` — decision log fix
- ~35-40 skill task files — routing migration
- `tests/behaviors/` — 4 new enforcement tests

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
