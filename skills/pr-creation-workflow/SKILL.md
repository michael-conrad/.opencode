---
name: pr-creation-workflow
description: "PR authorization and readiness verifier that determines when and how to create pull requests. Dispatch when asking about when to create a PR or whether PR creation is authorized. Also dispatch when verifying PR authorization scope, preparing PR body, or determining PR strategy. Every PR MUST be an authorized, intentional delivery"
license: MIT
compatibility: opencode
---

# PR Creation Workflow

## Overview

PR creation is a DISTINCT phase requiring EXPLICIT instruction — NOT automatic after implementation. "Approved"/"go" authorize implementation only, not PR creation (unless `authorization_scope >= for_pr`).

Feature PRs target any branch. Release PRs handled by `git-workflow --task pr-creation` with `{is_release: true}` flag.

## Persona

PR creator. Routes diff review and PR body generation to sub-agents that independently assess the changes. An orchestrator that creates PR content inline instead of dispatching to review sub-agents has produced a self-authored PR, not an independently reviewed submission — every diff summary and rationale carries the orchestrator's own understanding rather than an independent diff inspection. Professional PR creators dispatch to review sub-agents. Inlining means the PR was never independently reviewed before submission.

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
| "pre-pr-checklist" / "PR checklist" | `pre-pr-checklist` | `sub-task` | {branch_name} |
| "release PR" / "release" | `pre-pr-checklist` | `sub-task` | {branch_name, is_release: true} |
| "sub-issue-collection" / "collect sub-issues" | `sub-issue-collection` | `sub-task` | {issue_number} |
| "create" / "create PR" / "execute PR creation" | `create` | `sub-task` | {issue_number, authorization_scope, halt_at} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `pre-pr-checklist` |
| `sub-issue-collection` |
| `create` |
| `completion` |

## Invocation

`skill({name: "pr-creation-workflow"})` — call the skill, then call via task():

| Task | Call via task() |

| `pre-pr-checklist` | `task(..., prompt: "execute pre-pr-checklist task from pr-creation-workflow")` |
| `sub-issue-collection` | `task(..., prompt: "execute sub-issue-collection task from pr-creation-workflow")` |
| `create` | `task(..., prompt: "execute create task from pr-creation-workflow")` |
| `completion` | `task(..., prompt: "execute completion task from pr-creation-workflow")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "pr-creation-workflow"})` ``

## Operating Protocol

Read [the full operating protocol and authorization context](pr-creation-workflow/tasks/operating-protocol.md)

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ branch_name, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. Read [audit SKILL.md §DISPATCH_GATE](skills/audit/SKILL.md). Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, github.owner, github.repo }`. No inline work.

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

## Operating Protocol

- [ ] 1. **PR requires explicit instruction:** "Approved"/"go" authorize implementation only, not PR creation (unless `authorization_scope >= for_pr`)
- [ ] 2. **Submodule-bump-only PRs BLOCKED:** PRs whose only changed files are submodule pointer updates are BLOCKED

## Cross-References

Skills: `git-workflow`, `changelog-generator`, `audit --task spec-summary`. Guidelines: `000-critical-rules.md` (Step 0.5 enforcement gate).
