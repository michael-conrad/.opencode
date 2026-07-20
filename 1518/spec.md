## Defects

- D2 FAIL — description "creating, commenting on, or closing GitHub Issues" doesn't enumerate TDT's 11 tasks (create, edit, list, comment, audit, close, etc.)
- D3 INCOMPLETE — omits platform dispatcher routing detail

## Current → Proposed

**Current:** "Use when creating, commenting on, or closing GitHub Issues. Routes to GitHub MCP or GitBucket API based on github.platform."

**Proposed:** "Use when creating, editing, listing, commenting on, auditing, or closing GitHub/GitBucket issues and pull requests via issue-operations platform dispatcher (github-mcp or gitbucket-api) — always use the dispatcher, never call platform APIs directly."

## Required Action

Update `.opencode/skills/issue-operations/SKILL.md` frontmatter `description` field with proposed text.