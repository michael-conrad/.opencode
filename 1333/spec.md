**Parent Plan:** #1324

Rewrite all `issue-operations/platforms/gitbucket-api/` task files to call `gb` CLI instead of the bespoke Python tool. Files to rewrite:
- `tasks/mcp-operations.md` — canonical command reference with `gb` command mappings
- `tasks/issue-operations.md`
- `tasks/repository-operations.md`
- `tasks/label-operations.md`
- `tasks/session-integration.md`
- `tasks/error-recovery.md`
- `SKILL.md` — update capability manifest

Add `TOOL_MISSING` detection that returns BLOCKED when `gb` not found.