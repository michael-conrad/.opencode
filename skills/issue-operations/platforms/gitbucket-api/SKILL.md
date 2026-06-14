---
name: gitbucket-api
description: "Use when GitBucket platform operations are needed. GitBucket platform sub-skill for issue-operations. Provides capability manifest and Python client for GitBucket API operations. GitBucket operations without platform awareness fail silently. Platform-aware routing is what makes multi-platform workflows reliable."
type: discipline-enforcing
license: MIT
provenance: "🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)"
compatibility: opencode
---

# GitBucket API Platform Sub-Skill

## Overview

GitBucket platform implementation using Python client. Implements a GitHub-compatible API v3 with known deficiencies. This is a platform sub-skill under `issue-operations` — the router passes GitBucket operations here when `github.platform=gitbucket`.

## Capability Manifest (v4.46.0, empirically probed)

| Operation | Supported | Notes |
|----------|-----------|-------|
| Create issue | ✅ | `api.create_issue()` — labels auto-created |
| List issues | ✅ | `api.list_issues()` |
| Get issue | ✅ | `api.get_issue()` |
| Update issue | ❌ | PATCH returns 404 — use comment fallback |
| Close issue | ❌ | PATCH returns 404 — use comment fallback |
| Add comment | ✅ | `api.add_issue_comment()` |
| Delete comment | ❌ | Returns 500 — internal error |
| Sub-issues | ❌ | No API — use comment-based linking |
| Search issues | ❌ | No API — use iterative listing + client-side filter |
| Search PRs | ❌ | No API — use iterative listing + client-side filter |
| Labels on creation | ✅ | `api.create_issue(labels=[...])` |
| Post-creation labels | ❌ | Returns empty array — labels NOT added |
| Get labels | ✅ | `api.list_labels()` |
| Create label | ✅ | `api.create_label()` |
| Remove label from issue | ✅ | `api.remove_label_from_issue()` (fixed v4.46.0) |
| Create PR | ✅ | `api.create_pull_request()` |
| List PRs | ✅ | `api.list_pull_requests()` |
| Get PR | ✅ | `api.get_pull_request()` |
| Merge PR | ✅ | `api.merge_pull_request()` (if available) |
| PR reviews | ❌ | No API — use git log fallback |
| PR comments/files | ❌ | No API — use git log fallback |
| File contents | ❌ | 404/500 — use git CLI fallback |
| Commits API | ❌ | 500 JGit NPE — use git CLI fallback |
| Create branch | ❌ | 404 — use git CLI |
| Releases/tags | ✅ | `api.list_releases()`, `api.create_release()` |
| List branches | ✅ | `api.list_branches()` |
| Get repository | ✅ | `api.get_repository()` |

**Static by default.** If `gitbucket_*` MCP tools are detected at runtime (from gitbucket-mcp-plugin), dynamic capabilities override this manifest.

## Tasks

| Task | Purpose |
|------|---------|
| `issue-operations` | Issue CRUD patterns, create/update/list workarounds |
| `label-operations` | Label CRUD, auto-creation, post-creation limitations |
| `error-recovery` | Error handling, retry logic, credential failures |
| `mcp-operations` | MCP tool mapping, alternative API paths |
| `repository-operations` | Repository CRUD, branch operations |
| `session-integration` | Session init integration, env var detection |

## Sub-Agent Tasks

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `issue-operations` | When GitBucket issue CRUD patterns are needed | Operation type, issue data, github.owner, github.repo | Implementation context, agent memory | NO |
| `label-operations` | When GitBucket label CRUD is needed | Label name, color, github.owner, github.repo | Implementation context, agent memory | NO |
| `error-recovery` | When GitBucket error handling/retry is needed | Error details, retry context | Implementation context, agent memory | NO |
| `mcp-operations` | When GitBucket MCP tool mapping is needed | Operation type, MCP context | Implementation context, agent memory | NO |
| `repository-operations` | When GitBucket repository CRUD is needed | Repository data, github.owner, github.repo | Implementation context, agent memory | NO |
| `pre-analysis` | Before any sub-agent routing, determine scope independently | Issue number, task description, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `session-integration` | When GitBucket session init integration is needed | Session context, environment variables | Implementation context, agent memory | NO |

## Authorization Labels (Platform-Supported)

GitBucket API supports labels via creation only (post-creation label mutation is broken). The eight `approved-for-*` labels are:

| Label | Purpose |

| `approved-for-spec` | Authorization through spec creation |
| `approved-for-plan` | Authorization through plan creation |
| `approved-for-implementation` | Authorization through implementation |
| `approved-for-code-review` | Authorization through code review |
| `approved-for-pr` | Full pipeline through PR creation |
| `approved-for-pr-only` | PR creation only |
| `approved-for-review` | Code review only |
| `approved-for-review-prep` | Default authorization |

`needs-approval` is the default label for unapproved issues. It is applied on creation and replaced by the corresponding `approved-for-*` label at time of authorization. No `approved-for-*` label = awaiting approval. Label replacement on re-authorization is implemented via comment fallback (remove old label via `remove_label_from_issue`, apply new on next creation cycle).

## Authentication

Token authentication ONLY. Basic auth is broken in GitBucket (returns "Bad credentials" for all requests).

```bash
./.opencode/tools/gitbucket-api check-auth
```

## CLI Tool

**Use `./.opencode/tools/gitbucket-api <command>` for all GitBucket operations.** The CLI tool handles authentication, response parsing, and error handling. See task files for command-specific patterns.

**CRITICAL: Agent MUST use the `gitbucket-api` CLI tool for ALL API calls on GitBucket platform. If a needed command is missing, the agent MUST HALT and report: executive summary, exact error/missing command, possible resolution, byline. NEVER fall back to inline `requests` scripts or `python -c` strings.**

### Command Reference

| Command | Description |

| `me` | Get current user |
| `issues <owner> <repo> [--state open\|closed\|all]` | List issues |
| `issue <owner> <repo> <number>` | Get single issue |
| `create-issue <owner> <repo> <title> [--body ...] [--labels ...]` | Create issue |
| `add-comment <owner> <repo> <number> <body>` | Add comment |
| `prs <owner> <repo> [--state ...] [--head ...]` | List pull requests |
| `create-pr <owner> <repo> <title> <head> <base> [--body ...]` | Create pull request |
| `labels <owner> <repo>` | List labels |
| `branches <owner> <repo>` | List branches |
| `repos [--user ...]` | List repositories |
| `repo <owner> <repo>` | Get repository |
| `init-config [--path ...]` | Initialize configuration |
| `check-auth` | Validate authentication |

## Response Schema

All `list_*` endpoints return arrays (`List[Dict]`), NOT objects. The Python client handles this automatically.

## Operating Protocol

1. Detect GitBucket platform from session init output
2. Use Python client for all API operations
3. Add labels ONLY during `create_issue()` creation
4. Use comment fallbacks for PATCH operations (update, close)
5. Use comment-based linking for sub-issues
6. Use iterative listing for search operations
7. Follow error recovery procedures in `tasks/error-recovery.md`

## Cross-References

| Guideline | Section |

| Router | `../../SKILL.md` (issue-operations) |
| GitHub platform | `../github-mcp/SKILL.md` |
| Session init plugin | GitBucket detection and credentials |
| `reference/` | OpenAPI v4.42.1 specification |
| `tests/` | API verification test suite |
| `API-DEFICIENCIES.md` | Detailed deficiency documentation |