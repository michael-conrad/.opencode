## Problem

Spec #571 (Platform Routing Enforcement) was closed as completed, but Phase 4 — migration of 17+ consuming skills — was never fully executed. The critical rules (Phase 1-3) exist: `000-critical-rules.md` has `critical-rules-platform-routing-bypass` and `critical-rules-platform-api-deliberation`, and `issue-operations` has the 7 read/query tasks (Phase 2). However, the actual task documentation across the skill deck still contains ~100+ direct `github_*` MCP tool references.

## Evidence

Grep of `.opencode/skills/` for `github_issue_read|github_issue_write|github_add_issue_comment|github_create_pull_request|github_pull_request_read` returns 100+ matches across 20+ files outside `issue-operations/platforms/`.

Most call sites have the `<!-- Routes through issue-operations per SPEC #683 -->` annotation, but the tool names in the task documentation are still `github_*` — meaning an agent reading the task file sees GitHub-specific MCP calls, not platform-agnostic dispatcher calls.

## Root Cause

Spec #571 was superseded by #683 (Content classification gate + local-first architecture), which was also closed as completed. The Phase 4 migration work was never done — the annotations were added but the actual tool names were never replaced.

## Scope

Replace all direct `github_*` MCP tool references in consuming skill task files with platform-agnostic `issue-operations` dispatcher calls. The dispatcher already has all 7 read/query tasks (`read-issue`, `read-comments`, `read-labels`, `read-sub-issues`, `list-issues`, `search-issues`, `update-issue`) plus the existing write tasks (`creation`, `comment`, `close`, `link-sub-issue`).

## Affected Skills (by call volume)

| Priority | Skill | Direct `github_*` References | Pattern |
|----------|-------|------------------------------|---------|
| P0 | `approval-gate` | 80+ | Replace with `issue-operations` task dispatch |
| P1 | `git-workflow` | 15+ | Issue ops → dispatcher; PR ops stay direct |
| P2 | `issue-review` | 20+ | Route through issue-operations |
| P3 | `adversarial-audit` | 12+ | Route through issue-operations |
| P4 | `writing-plans` | 6+ | Route through issue-operations |
| P5 | `spec-creation` | 5+ | Route through issue-operations |
| P6 | `brainstorming` | 3+ | Route through issue-operations |
| P7 | `pre-analysis` | 4+ | Route through issue-operations |
| P8 | `verification-before-completion` | 3+ | Route through issue-operations |
| P9 | `correspondence`, `engineering-approach`, `finishing-a-development-branch`, `pr-creation-workflow`, `conflict-resolution`, `sre-runbook`, `completion-core` | 1-2 each | Route through issue-operations |

## Migration Pattern

```markdown
# BEFORE (direct GitHub MCP call in task doc)
github_issue_read(method="get", issue_number=N)

# AFTER (platform-agnostic dispatcher call)
issue-operations -> read-issue (github_issue_read(method="get", issue_number=N) <!-- Routes through issue-operations per critical-rules-platform-routing-bypass -->
```

The `github_*` tool name stays in parentheses as a hint to the platform sub-skill about which MCP tool to call, but the routing goes through the dispatcher. The `<!-- Routes through issue-operations per ... -->` annotation is already present on most sites.

## Non-Goals

- No changes to `issue-operations/platforms/` — those are the authorized locations for direct `github_*` calls
- No changes to PR operations in `git-workflow` and `pr-creation-workflow` — PRs are excluded per #571 N-04
- No changes to the critical rules or dispatcher infrastructure — only consuming skill task files

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Zero `github_issue_read` references outside `issue-operations/platforms/` in `.opencode/skills/` | `string` — grep returns 0 |
| SC-2 | Zero `github_issue_write` references outside `issue-operations/platforms/` in `.opencode/skills/` | `string` — grep returns 0 |
| SC-3 | Zero `github_add_issue_comment` references outside `issue-operations/platforms/` in `.opencode/skills/` | `string` — grep returns 0 |
| SC-4 | Zero `github_search_issues` / `github_list_issues` references outside `issue-operations/platforms/` | `string` — grep returns 0 |
| SC-5 | All migrated call sites have `<!-- Routes through issue-operations per ... -->` annotation | `string` — grep confirms annotation present |
| SC-6 | PR operations (`github_create_pull_request`, `github_pull_request_read`) remain in `git-workflow` and `pr-creation-workflow` | `string` — grep confirms these are NOT migrated |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)