---
name: issue-operations
description: "Issue operations dispatcher that routes to GitHub MCP or GitBucket API based on github.platform. Load via skill() when creating, commenting on, or closing GitHub Issues. Comment posting is gated by the substantiveness check — non-substantive progress updates MUST NOT be posted to GitHub Issues. Also load when adding labels, managing sub-issues, or routing to platform-specific implementations. Issue tracking is REQUIRED. User phrases: create issue, comment on issue, close issue, add label, manage sub-issues"
license: MIT
compatibility: opencode
---

# Skill: issue-operations

## Overview

Platform-agnostic Issue Operations router. Detects `github.platform` and routes all issue operations to the appropriate platform sub-skill (github-mcp, gitbucket-api, local).

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "pre-creation" / "prepare issue" | `pre-creation` | `sub-task` | {issue_context} |
| "single-task-check" / "check single task" | `single-task-check` | `sub-task` | {issue_number} |
| "create issue" / "new issue" | `creation` | `sub-task` | {issue_body} |
| "post-creation" / "after create" | `post-creation` | `sub-task` | {issue_number} |
| "comment" / "add comment" / "post comment" | `comment` | `sub-task` | {issue_number, body} |
| "close issue" | `close` | `sub-task` | {issue_number} |
| "link sub-issue" / "add sub-issue" | `link-sub-issue` | `sub-task` | {parent_issue, sub_issue} |
| "verify merge" / "check merged" | `verify-merge` | `sub-task` | {issue_number} |
| "capabilities" / "list capabilities" | `capabilities` | `sub-task` | {platform} |
| "body-edit" / "edit body" | `body-edit` | `sub-task` | {issue_number, new_body} |
| "read-issue" / "get issue" | `read-issue` | `sub-task` | {issue_number} |
| "read-comments" / "get comments" | `read-comments` | `sub-task` | {issue_number} |
| "read-labels" / "get labels" | `read-labels` | `sub-task` | {issue_number} |
| "read-sub-issues" / "get sub-issues" | `read-sub-issues` | `sub-task` | {issue_number} |
| "list-issues" / "list with filters" | `list-issues` | `sub-task` | {filters} |
| "search-issues" / "search" | `search-issues` | `sub-task` | {query} |
| "sync-from-remote" / "reconcile" | `sync-from-remote` | `sub-task` | {platform} |
| "update-issue" / "edit issue" | `update-issue` | `sub-task` | {issue_number, updates} |
| "sync-pull-to-local" / "mirror to local" | `sync-pull-to-local` | `sub-task` | {issue_number} |
| "import-remote" / "retroactive import" | `import-remote` | `sub-task` | {issue_number} |
| "push-artifacts" / "push spec artifacts" | `push-artifacts` | `sub-task` | {issue_number} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Issue Operations Router. Focus: spec-first workflow, validation, labeling, platform-aware routing.

## Tasks

|------|-------|-------------|
| `pre-creation` | |
| `single-task-check` | |
| `creation` | |
| `post-creation` | |
| `comment` | |
| `close` | |
| `link-sub-issue` | |
| `verify-merge` | |
| `capabilities` | |
| `completion` | |
| `body-edit` | Edit remote.md body via 4-agent dispatch (fetch → transform → verify → post) — body edits without structural verification propagate corruption upstream; every remote edit requires verified integrity before propagation |
| `read-issue` | Read single issue via dispatcher — routes to platform sub-skill, no direct `github_*` calls |
| `read-comments` | Read issue comments via dispatcher — context completeness, all comments before action |
| `read-labels` | Read issue labels via dispatcher — authorization scope verification |
| `read-sub-issues` | Read sub-issues via dispatcher — authorization cascade and closure order verification |
| `list-issues` | List issues with filters via dispatcher — dedup checks, label search, overlap detection |
| `search-issues` | Search issues via dispatcher — title dedup, spec/plan overlap detection |
| `sync-from-remote` | Reconcile remote issues against local `.issues/` (root repo) or `{project_root}/{path}/.issues/` (submodule/sub-repo) after `local-issues sync` — detect staleness in both directions, auto-import missing remote issues |
| `update-issue` | Update issue body/labels/state via dispatcher — body-preservation safeguard enforced |
| `sync-pull-to-local` | Mirror remote issue body to `.issues/<N>/spec.md` (root repo) or `{project_root}/{path}/.issues/<N>/spec.md` (submodule/sub-repo) after any `read-issue` — enforces Operating Protocol §3 spec.md mirror mandate |
| `import-remote` | Retroactively import a pre-existing remote issue into local `.issues/` (root repo) or `{project_root}/{path}/.issues/` (submodule/sub-repo) — full mirror with body, comments, frontmatter, and `promotion_type: retroactive_import` |
| `push-artifacts` | Push spec artifacts directory to issues-data — produces artifact directory with URL |

## Invocation

`skill({name: "issue-operations"})` — call the skill, then dispatch to sub-skills via task():

| Task | Sub-Skill | Canonical Dispatch String |
|------|-----------|--------------------------|
| `pre-creation` | `issue-operations-core` | `task(..., prompt: "execute pre-creation from issue-operations-core. Read \`issue-operations-core/tasks/pre-creation.md\` first")` |
| `creation` | `issue-operations-core` | `task(..., prompt: "execute creation from issue-operations-core. Read \`issue-operations-core/tasks/creation.md\` first")` |
| `comment` | `issue-operations-comments` | `task(..., prompt: "execute comment from issue-operations-comments. Read \`issue-operations-comments/tasks/comment.md\` first")` |
| `close` | `issue-operations-core` | `task(..., prompt: "execute close from issue-operations-core. Read \`issue-operations-core/tasks/close.md\` first")` |
| `link-sub-issue` | `issue-operations-sub-issues` | `task(..., prompt: "execute link-sub-issue from issue-operations-sub-issues. Read \`issue-operations-sub-issues/tasks/link-sub-issue.md\` first")` |
| `verify-merge` | `issue-operations-core` | `task(..., prompt: "execute verify-merge from issue-operations-core. Read \`issue-operations-core/tasks/verify-merge.md\` first")` |
| `completion` | `issue-operations-core` | `task(..., prompt: "execute completion from issue-operations-core. Read \`issue-operations-core/tasks/completion.md\` first")` |
| `read-issue` | `issue-operations-core` | `task(..., prompt: "execute read-issue from issue-operations-core. Read \`issue-operations-core/tasks/read-issue.md\` first")` |
| `read-comments` | `issue-operations-core` | `task(..., prompt: "execute read-comments from issue-operations-core. Read \`issue-operations-core/tasks/read-comments.md\` first")` |
| `read-labels` | `issue-operations-core` | `task(..., prompt: "execute read-labels from issue-operations-core. Read \`issue-operations-core/tasks/read-labels.md\` first")` |
| `read-sub-issues` | `issue-operations-sub-issues` | `task(..., prompt: "execute read-sub-issues from issue-operations-sub-issues. Read \`issue-operations-sub-issues/tasks/read-sub-issues.md\` first")` |
| `list-issues` | `issue-operations-core` | `task(..., prompt: "execute list-issues from issue-operations-core. Read \`issue-operations-core/tasks/list-issues.md\` first")` |
| `search-issues` | `issue-operations-core` | `task(..., prompt: "execute search-issues from issue-operations-core. Read \`issue-operations-core/tasks/search-issues.md\` first")` |
| `update-issue` | `issue-operations-core` | `task(..., prompt: "execute update-issue from issue-operations-core. Read \`issue-operations-core/tasks/update-issue.md\` first")` |
| `sync-pull-to-local` | `issue-operations-sync` | `task(..., prompt: "execute sync-pull-to-local from issue-operations-sync. Read \`issue-operations-sync/tasks/sync-pull-to-local.md\` first")` |
| `sync-from-remote` | `issue-operations-sync` | `task(..., prompt: "execute sync-from-remote from issue-operations-sync. Read \`issue-operations-sync/tasks/sync-from-remote.md\` first")` |
| `import-remote` | `issue-operations-sync` | `task(..., prompt: "execute import-remote from issue-operations-sync. Read \`issue-operations-sync/tasks/import-remote.md\` first")` |
| `push-artifacts` | `local (platform)` | `task(..., prompt: "execute push-artifacts from local. Read \`issue-operations/platforms/local/tasks/push-artifacts.md\` first")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "issue-operations"})` ``

## Operating Protocol

- [ ] 1. **Platform routing:** `github.platform` → appropriate sub-skill (github-mcp / gitbucket-api / local).
- [ ] 2. **Substantive comment gate:** only meaningful updates posted as issue comments. No status spam.
- [ ] 3. **spec.md mirror:** every `issue-operations -> read-issue` MUST be followed by `sync-pull-to-local` to mirror the body to `.issues/<N>/spec.md` (root repo) or `{project_root}/{path}/.issues/<N>/spec.md` (submodule/sub-repo). <!-- Enforced by sync-pull-to-local task per issue #764 -->
- [ ] 4. **Byline mandatory:** AI-authored comments must include `🤖 Co-authored with AI: <AgentName> (<ModelId>)`.
- [ ] 5. **Issue creation = no auth needed** Read [010-approval-gate.md](guidelines/010-approval-gate.md).
- [ ] 6. **Adversarial-audit call:** after sub-issue creation, call `audit --task concern-separation --issue <N>` with `audit_phase: sub_issue_creation`.
- [ ] 7. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ issue_number, worktree.path, github.owner, github.repo, github.platform }`, excluding implementation context and agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. Read [audit SKILL.md §DISPATCH_GATE](skills/audit/SKILL.md). `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute creation from issue-operations-core" without task file path | "execute creation from issue-operations-core. Read `issue-operations-core/tasks/creation.md` first" |

## Required: Sub-agent Task File Discovery Directive

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

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

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

## Cross-References

Skills: `github-mcp`, `gitbucket-api`, `local` (platform sub-skills), `audit --task concern-separation`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.


