**Parent Plan:** #1324

Fix mismatched command names in `issue-operations/tasks/` dispatcher files — GitBucket code paths only (GitHub MCP paths untouched). Replacements:
- `update-issue` → `gb issue edit`
- `list-issues` → `gb issue list`
- `get-issue` → `gb issue view`
- `get-sub-issues` → replace with "not supported by GitBucket API" note
- Verify `close.md`, `comment.md`, `verify-merge.md`, `creation.md`, `pre-creation.md`, `link-sub-issue.md`, `import-remote.md`, `body-edit.md` use correct `gb` commands