## Summary

Add a `locate` task to `issue-operations` that wraps `local-issues locate` with a platform fallback. When a `repo#N` reference needs resolution, this task checks local `.issues/` first via `local-issues locate`, and on miss fetches from the remote platform (github-mcp/gitbucket-api) via `import-remote` then returns the local path. This is the procedural gate that makes agent-local routing work.

**depends-on:** #1151

## Background

Spec #1151 adds `local-issues locate` and fixes the session-init labels. But without a procedural gate in `issue-operations`, the agent still has no workflow step that says "call locate first." The `locate` task fills that gap — it becomes the single entry point for all issue resolution.

## Change

### New task: issue-operations --task locate

**New file:** `.opencode/skills/issue-operations/tasks/locate.md`

A task that:
1. Receives a qualified `repo#N` reference (e.g., `.opencode#1107`)
2. Calls `local-issues locate --number <qualified>` to check local
3. If found locally: returns the spec artifact path and tree skeleton
4. If not found and platform has a remote: calls `import-remote` to fetch from GitHub/GitBucket, returns the now-local path
5. If not found and no remote (`github.platform == "local"`): returns "not found" status

**Registration:** Add `locate` to the task table in `issue-operations/SKILL.md` with the same dispatch pattern as the existing 16 tasks.

**Platform routing:** The task lives in `issue-operations` (not in the `local` sub-skill) because it spans both local and remote.

## Success Criteria

| ID | Criterion | Evidence Type |
|---|---|---|
| SC-1 | `issue-operations --task locate` with local issue returns spec artifact path | `behavioral` |
| SC-2 | `issue-operations --task locate` with remote-only issue imports and returns local path | `behavioral` |
| SC-3 | `issue-operations --task locate` with no local and no remote returns "not found" | `behavioral` |
| SC-4 | Agent uses `issue-operations --task locate` before direct `github_issue_read` when resolving `repo#N` (carried forward from #1151 SC-7) | `behavioral` |