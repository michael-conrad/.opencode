---
name: github-mcp
description: "Use when GitHub MCP platform operations are needed. Also use when routing issue operations to GitHub via MCP tools, or when GitHub-specific API capabilities are required. Invoke for: GitHub issue creation, GitHub issue comment, GitHub issue closure, GitHub label management, GitHub MCP tool operations. API calls without owner/repo verification target the wrong repository. Every misrouted call is wasted effort. Platform-aware routing is REQUIRED — always use the dispatcher. Trigger phrases: GitHub MCP, GitHub issue, GitHub API, GitHub platform, github_* tool."
license: MIT
compatibility: opencode
---

# GitHub MCP Platform Sub-Skill

## Overview

GitHub platform implementation using GitHub MCP tools. Full API coverage with no fallbacks needed.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

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
| `approved-for-review-prep` | Default authorization (scope: `for_review_prep`) |

`needs-approval` is the default label for unapproved issues. It is applied on creation and replaced by the corresponding `approved-for-*` label at time of authorization. No `approved-for-*` label = awaiting approval.

## Fallbacks

None required. GitHub MCP provides complete API coverage.

## spec.md Mirror (MANDATORY)

See `github-mcp/tasks/spec-mirror.md` for the full spec mirror sync procedure, fallback procedure, staleness detection, and three-file layout.

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

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read tasks/creation.md then execute step 1" | "execute creation task from github-mcp" |
| Preloaded step sequences | "Step 1: call github_issue_write. Step 2: add labels." | "execute creation task from github-mcp" |
| Preloaded expected outcomes | "Return { issue_number, html_url }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The issue was just drafted so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute creation task from github-mcp" without task file path | "execute creation task from github-mcp. Read \`issue-operations/platforms/github-mcp/tasks/creation.md\` first" |

#### Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the task routing table above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)