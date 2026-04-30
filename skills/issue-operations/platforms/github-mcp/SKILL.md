---
name: github-mcp
description: GitHub MCP platform sub-skill for issue-operations. Provides capability manifest and thin wrappers around github_* MCP tools.
type: reference
license: MIT
provenance: AI-generated
compatibility: opencode
---

# GitHub MCP Platform Sub-Skill

## Overview

GitHub platform implementation using GitHub MCP tools. Full API coverage with no fallbacks needed.

## Capability Manifest

| Operation | Supported | Notes |
|----------|-----------|-------|
| Create issue | ✅ | `github_issue_write(method="create")` |
| List issues | ✅ | `github_list_issues` |
| Get issue | ✅ | `github_issue_read(method="get")` |
| Update issue | ✅ | `github_issue_write(method="update")` |
| Close issue | ✅ | `github_issue_write(method="update", state="closed")` |
| Get issue comments | ✅ | `github_issue_read(method="get_comments")` |
| Add comment | ✅ | `github_add_issue_comment` |
| Get sub-issues | ✅ | `github_issue_read(method="get_sub_issues")` |
| Add sub-issue | ✅ | `github_sub_issue_write(method="add")` |
| Remove sub-issue | ✅ | `github_sub_issue_write(method="remove")` |
| Search issues | ✅ | `github_search_issues` |
| Search PRs | ✅ | `github_search_pull_requests` |
| Get labels | ✅ | `github_issue_read(method="get_labels")` |
| Labels on creation | ✅ | `github_issue_write(method="create", labels=[...])` |
| Create PR | ✅ | `github_create_pull_request` |
| Merge PR | ✅ | `github_merge_pull_request` |
| PR reviews | ✅ | `github_pull_request_read(method="get_reviews")` |
| PR comments | ✅ | `github_pull_request_read(method="get_review_comments")` |
| PR files | ✅ | `github_pull_request_read(method="get_files")` |
| File contents | ✅ | `github_get_file_contents` |
| Commits | ✅ | `github_list_commits`, `github_get_commit` |

**Dynamic override:** If GitHub MCP tools provide a `capabilities()` endpoint in the future, this static manifest is overridden by dynamic query results.

## Tools

All operations dispatched through the `github_*` MCP tool family. No Python client needed — the MCP server handles authentication and API routing.

## Fallbacks

None required. GitHub MCP provides complete API coverage.

## spec.md Mirror (MANDATORY)

Every `github_issue_read(method="get")` call MUST mirror the spec body to `.issues/<issue_number>/spec.md`:

| Event | Action |
|-------|--------|
| `github_issue_read(method="get")` success | Write `.issues/<issue_number>/spec.md` with header `# Synced from GitHub Issue #<N> at <ISO8601-timestamp>` followed by the issue body |
| `github_issue_read(method="get")` repeated | Overwrite `spec.md` with updated timestamp and body |
| API unreachable (network error, rate limit, auth failure) | Read `.issues/<issue_number>/spec.md` from disk, note staleness in chat: `"spec.md last synced at <timestamp>, may be stale"` |
| API comes back after outage | Re-fetch and overwrite on next spec read |

### Mirror Sync Procedure (MANDATORY)

After every `github_issue_read(method="get")` success:

1. Create directory: `mkdir -p .issues/<issue_number>/`
2. Write `spec.md`:
```
# Synced from GitHub Issue #<N> at <ISO8601-timestamp>

<issue body>
```
3. Report to chat: `"spec.md mirror updated for #<N> at <timestamp>"`

### Fallback Procedure (MANDATORY)

When `github_issue_read(method="get")` fails with a network error, rate limit, or auth failure:

1. Check if `.issues/<issue_number>/spec.md` exists
2. If exists: read from disk, note in chat: `"GitHub API unreachable. Reading spec.md (last synced at <timestamp>, may be stale)."`
3. If NOT exists and API is unreachable: report `"Cannot read spec #<N> — API unreachable and no local spec.md mirror exists."`
4. Proceed with stale/absent data noting the risk

### Staleness Detection

`spec.md` is stale when:
1. The sync timestamp in the header is more than 24 hours old
2. The GitHub Issue was modified (comments added, labels changed) since the last sync

Agent MUST report staleness when detected and should attempt to refresh. If API still unreachable, proceed with stale copy noting the risk.

### No Sync-Back

`spec.md` is read-only from the agent's perspective. The agent NEVER edits `spec.md` — it always writes to the GitHub Issue via the API. This prevents divergence between the local mirror and the authoritative copy.

## Cross-References

- Dispatcher: `../SKILL.md` (issue-operations)
- Related platform: `../gitbucket-api/SKILL.md`

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| Platform operations | When GitHub MCP platform operations are dispatched | Operation type, issue/PR number, github.owner, github.repo | Implementation context, agent memory | NO |