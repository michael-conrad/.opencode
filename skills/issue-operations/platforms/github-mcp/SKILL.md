---
name: github-mcp
description: "Use when GitHub MCP platform operations are needed. GitHub MCP platform sub-skill for issue-operations. Provides capability manifest and thin wrappers around github_* MCP tools. API calls without owner/repo verification target the wrong repository. Every misrouted call is wasted effort."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# GitHub MCP Platform Sub-Skill

## Overview

GitHub platform implementation using GitHub MCP tools. Full API coverage with no fallbacks needed.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

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

All operations routed through the `github_*` MCP tool family. No Python client needed — the MCP server handles authentication and API routing.

## Authorization Labels (Platform-Supported)

GitHub MCP supports the following `approved-for-*` labels for issue labeling:

| Label | Purpose |

| `approved-for-spec` | Authorization through spec creation (scope: `for_spec`) |
| `approved-for-analysis` | Authorization through analysis (scope: `for_analysis`) |
| `approved-for-plan` | Authorization through plan creation (scope: `for_plan`) |
| `approved-for-implementation` | Authorization through implementation (scope: `for_implementation`) |
| `approved-for-pr` | Full pipeline through PR creation (scope: `for_pr`) |
| `approved-for-pr-only` | PR creation only (scope: `for_pr_only`) |
| `approved-for-review` | Code review only (scope: `for_review_only`) |
| `approved-for-review-prep` | Default authorization (scope: `for_review_prep`) |

`needs-approval` is the default label for unapproved issues. It is applied on creation and replaced by the corresponding `approved-for-*` label at time of authorization. No `approved-for-*` label = awaiting approval.

## Fallbacks

None required. GitHub MCP provides complete API coverage.

## spec.md Mirror (MANDATORY)

Every `github_issue_read(method="get")` call MUST mirror the spec body to `.issues/<issue_number>/spec.md` (root repo) or `*/.issues/<issue_number>/spec.md` (submodule/sub-repo):

| Event | Action |

| `github_issue_read(method="get")` success | Write `.issues/<issue_number>/spec.md` (root repo) or `*/.issues/<issue_number>/spec.md` (submodule/sub-repo) with header `# Synced from GitHub Issue #<N> at <ISO8601-timestamp>` followed by the issue body |
| `github_issue_read(method="get")` repeated | Overwrite `spec.md` with updated timestamp and body |
| API unreachable (network error, rate limit, auth failure) | Read `.issues/<issue_number>/spec.md` (root repo) or `*/.issues/<issue_number>/spec.md` (submodule/sub-repo) from disk, note staleness in chat: `"spec.md last synced at <timestamp>, may be stale"` |
| API comes back after outage | Re-fetch and overwrite on next spec read |

### Mirror Sync Procedure (MANDATORY)

After every `github_issue_read(method="get")` success:

1. Create directory: `mkdir -p .issues/<issue_number>/` (root repo) or `mkdir -p */.issues/<issue_number>/` (submodule/sub-repo)
2. Write `spec.md`:
```
# Synced from GitHub Issue #<N> at <ISO8601-timestamp>

<issue body>
```
3. Report to chat: `"spec.md mirror updated for #<N> at <timestamp>"`

### Fallback Procedure (MANDATORY)

When `github_issue_read(method="get")` fails with a network error, rate limit, or auth failure:

1. Check if `.issues/<issue_number>/spec.md` (root repo) or `*/.issues/<issue_number>/spec.md` (submodule/sub-repo) exists
2. If exists: read from disk, note in chat: `"GitHub API unreachable. Reading spec.md (last synced at <timestamp>, may be stale)."`
3. If NOT exists and API is unreachable: report `"Cannot read spec #<N> — API unreachable and no local spec.md mirror exists."`
4. Proceed with stale/absent data noting the risk

### Staleness Detection

`spec.md` is stale when:
1. The sync timestamp in the header is more than 24 hours old
2. The GitHub Issue was modified (comments added, labels changed) since the last sync

Agent MUST report staleness when detected and should attempt to refresh. If API still unreachable, proceed with stale copy noting the risk.

### Three-File Layout

| File | Role | Format | Edited by agent? | Synced to remote? |
|------|------|-------|-------------------|--------------------|
| `spec.md` | Canonical full spec | YAML frontmatter + markdown body | Yes — when spec detail changes | Never |
| `state.md` | Workflow phase tracking and sync timestamps | YAML frontmatter + phase fields | Yes — on phase transitions and sync events | Never |
| `remote.md` | Exact GitHub/GitBucket issue body | **Pure markdown — no YAML frontmatter**. Read verbatim for sync push, zero composition logic. | Yes — via `body-edit` task only | Yes — sync push after verification |

### Mirror Protocol

The agent edits `remote.md` for remote body changes; `spec.md` is the canonical full spec. `remote.md` is the exact GitHub/GitBucket issue body, read verbatim for sync push. Every edit to `remote.md` MUST go through the `body-edit` task (fetch → transform → verify → post).

**Mirror flow:** local edit to `remote.md` → verify structural integrity → sync push to GitHub/GitBucket.

Mirroring through `remote.md` is what professional synchronization looks like. Composing remote bodies from `spec.md` content means unverified text reaches stakeholders. Professional engineers propagate verified remotes — not composed approximations.

## Cross-References

- Router: `../SKILL.md` (issue-operations)
- Related platform: `../gitbucket-api/SKILL.md`

## Sub-Agent Tasks

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| Platform operations | When GitHub MCP platform operations are dispatched | Operation type, issue/PR number, github.owner, github.repo | Implementation context, agent memory | NO |
| `pre-analysis` | Before any sub-agent routing, determine scope independently | Issue number, task description, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `completion` | When workflow halts at any point | Workflow state | Implementation context, agent memory | NO |