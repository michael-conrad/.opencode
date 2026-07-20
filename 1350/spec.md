## Problem

PR operations (`github_create_pull_request`, `github_pull_request_read`, `github_search_pull_requests`) were explicitly excluded from the `issue-operations` dispatcher per #571 N-04, with the rationale that "PRs are git-level operations that don't need platform routing through issue-operations." However, this exclusion leaves ~15+ direct `github_*` PR MCP calls hardcoded across `git-workflow`, `pr-creation-workflow`, `approval-gate`, `verification-before-completion`, and other skills. On GitBucket, these calls silently fail or hit the wrong API.

PR operations need their own dedicated platform-agnostic skill — separate from `issue-operations` — that detects `github.platform` and routes to the appropriate platform sub-skill (github-mcp, gitbucket-api).

## Scope

Create a new `pr-operations` skill with a dispatcher pattern mirroring `issue-operations`:

- **Dispatcher** (`pr-operations/SKILL.md`) — routes to platform sub-skill based on `github.platform`
- **Platform sub-skills** — one per platform, wrapping the platform-specific PR API calls
- **Task cards** — `create-pr`, `read-pr`, `search-prs`, `merge-pr`, `update-pr`, `list-prs`, `get-pr-diff`, `get-pr-files`, `get-pr-commits`, `get-pr-reviews`, `get-pr-review-comments`, `add-pr-comment`, `request-pr-review`, `request-copilot-review`, `update-pr-branch`
- **Critical rule** — all PR operations MUST route through `pr-operations` dispatcher (mirrors `critical-rules-platform-routing-bypass`)

## Affected Consuming Skills

These skills currently have direct `github_*` PR MCP calls that would migrate to `pr-operations`:

| Skill | Direct PR MCP Calls |
|-------|---------------------|
| `git-workflow` | `github_create_pull_request`, `github_pull_request_read`, `github_search_pull_requests` |
| `pr-creation-workflow` | `github_create_pull_request`, `github_pull_request_read` |
| `approval-gate` | `github_pull_request_read`, `github_search_pull_requests` |
| `verification-before-completion` | `github_pull_request_read`, `github_create_pull_request` |
| `adversarial-audit` | `github_pull_request_read` |
| `completion-core` | `github_create_pull_request` (URL extraction) |
| `correspondence` | `github_pull_request_read` |
| `conflict-resolution` | `github_pull_request_read` |
| `git-workflow/cleanup` | `github_pull_request_read`, `github_search_pull_requests` |
| `git-workflow/rebase-pending` | `github_pull_request_read` |

## Platform Sub-Skill Mapping

| Platform | Sub-Skill | Implementation |
|----------|-----------|----------------|
| `github` | `pr-operations/platforms/github-mcp/` | Wraps existing `github_*` MCP tools |
| `gitbucket` | `pr-operations/platforms/gitbucket-api/` | Uses `gb` CLI for PR operations |
| `local` | `pr-operations/platforms/local/` | No PR operations (local-only repos have no PRs) — returns BLOCKED with `reason: LOCAL_ONLY` |

## Task Cards

| Task | GitHub MCP Tool | GitBucket CLI Equivalent |
|------|----------------|--------------------------|
| `create-pr` | `github_create_pull_request` | `gb pr create` |
| `read-pr` | `github_pull_request_read(method=get)` | `gb pr view` |
| `search-prs` | `github_search_pull_requests` | `gb pr list --search` |
| `merge-pr` | `github_merge_pull_request` | `gb pr merge` |
| `update-pr` | `github_update_pull_request` | `gb pr update` |
| `list-prs` | `github_list_pull_requests` | `gb pr list` |
| `get-pr-diff` | `github_pull_request_read(method=get_diff)` | `gb pr diff` |
| `get-pr-files` | `github_pull_request_read(method=get_files)` | `gb pr diff --stat` |
| `get-pr-commits` | `github_pull_request_read(method=get_commits)` | `gb pr commits` |
| `get-pr-reviews` | `github_pull_request_read(method=get_reviews)` | `gb pr review list` |
| `get-pr-review-comments` | `github_pull_request_read(method=get_review_comments)` | `gb pr review comments` |
| `add-pr-comment` | `github_add_comment_to_pending_review` / `github_add_reply_to_pull_request_comment` | `gb pr comment` |
| `request-pr-review` | `github_pull_request_review_write(method=create)` with reviewers | `gb pr review request` |
| `request-copilot-review` | `github_request_copilot_review` | N/A (GitHub-only) |
| `update-pr-branch` | `github_update_pull_request_branch` | `gb pr update-branch` |

## Phases

### Phase 1: Skill Infrastructure

Create `pr-operations/SKILL.md` dispatcher with:
- Platform detection (`github.platform`)
- Task dispatch table for all 15+ PR operations
- Critical rule: all PR operations MUST route through `pr-operations`
- Exclusivity constraint: platform sub-skill files are the ONLY authorized location for direct `github_*` PR MCP calls

### Phase 2: Platform Sub-Skills

Create platform sub-skill directories and task cards:
- `pr-operations/platforms/github-mcp/` — wraps `github_*` MCP tools
- `pr-operations/platforms/gitbucket-api/` — wraps `gb` CLI PR commands
- `pr-operations/platforms/local/` — returns BLOCKED with LOCAL_ONLY

### Phase 3: Critical Rule

Add to `000-critical-rules.md`:
- `critical-rules-pr-routing-bypass` — calling `github_create_pull_request`, `github_pull_request_read`, `github_search_pull_requests`, `github_merge_pull_request`, `github_update_pull_request`, `github_list_pull_requests`, `github_request_copilot_review`, `github_update_pull_request_branch` directly (outside `pr-operations/platforms/`) is a Tier 1 violation

### Phase 4: Migration

Migrate all consuming skills to route through `pr-operations` dispatcher. Each migrated call site gets a `` annotation.

### Phase 5: Enforcement Tests

- Behavioral test: agent routes PR creation through `pr-operations` instead of calling `github_create_pull_request` directly
- Behavioral test: agent routes PR read through `pr-operations` instead of calling `github_pull_request_read` directly
- Content-verification: zero `github_create_pull_request` / `github_pull_request_read` / `github_search_pull_requests` calls outside `pr-operations/` directory

## Non-Goals

- No changes to `issue-operations` — PR operations get their own skill, separate from issue operations
- No changes to existing platform sub-skills — `github-mcp`, `gitbucket-api`, `local` remain as-is
- No changes to session-init — `github.platform` detection unchanged

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `pr-operations/SKILL.md` exists with dispatch table for all 15+ PR operations | `string` — file exists |
| SC-2 | `pr-operations/platforms/github-mcp/` exists with task cards wrapping all `github_*` PR MCP tools | `string` — directory exists |
| SC-3 | `pr-operations/platforms/gitbucket-api/` exists with task cards wrapping `gb` CLI PR commands | `string` — directory exists |
| SC-4 | `pr-operations/platforms/local/` exists returning BLOCKED with LOCAL_ONLY | `string` — file exists |
| SC-5 | `000-critical-rules.md` has `critical-rules-pr-routing-bypass` critical violation | `string` — grep confirms |
| SC-6 | Zero `github_create_pull_request` calls outside `pr-operations/` in `.opencode/skills/` | `string` — grep returns 0 |
| SC-7 | Zero `github_pull_request_read` calls outside `pr-operations/` in `.opencode/skills/` | `string` — grep returns 0 |
| SC-8 | Zero `github_search_pull_requests` calls outside `pr-operations/` in `.opencode/skills/` | `string` — grep returns 0 |
| SC-9 | All migrated call sites have `` annotation | `string` — grep confirms |
| SC-10 | Behavioral test: agent routes PR creation through `pr-operations` | `behavioral` — `opencode-cli run` |
| SC-11 | Behavioral test: agent routes PR read through `pr-operations` | `behavioral` — `opencode-cli run` |

## Interdependencies

| Issue | Relationship | Action |
|-------|-------------|--------|
| **#580** (PR staleness verification) | MEDIUM | #580 adds a staleness check to the PR-creation enforcement gate. If this spec's platform-agnostic PR operations skill routes PR creation through a new dispatcher, #580's enforcement gate should hook into that dispatcher rather than the current `pr-creation` task files. |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)