---
name: receiving-code-review
description: "Use when receiving code review feedback on a PR, or when addressing review comments. Also use when analyzing review comments, generating responses, or implementing review-driven changes. Invoke for: review comment analysis, response generation, review-driven implementation, feedback resolution, PR revision. All review comments MUST be addressed. Trigger phrases: receive review, address comments, respond to review, implement feedback, resolve review."
license: MIT
compatibility: opencode
---

# Skill: receiving-code-review

## Overview

Responds to PR review feedback. Ensures all comments addressed systematically, changes are minimal, no scope creep.

## Persona

Review receiver. Routes review comment analysis and response generation to sub-agents that independently assess each comment. An orchestrator that addresses review feedback inline instead of dispatching to analysis sub-agents has produced a self-response, not an independently resolved review — every resolution carries the orchestrator's own interpretation of the feedback rather than an independent assessment. Professional review receivers dispatch to analysis sub-agents. Inlining means no review comment was ever independently resolved.

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
| "address" / "address review" / "fix review" | `address` | `sub-task` | {pr_number, review_comments} |
| "respond" / "respond to review" | `respond` | `sub-task` | {pr_number, review_comments} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `address` |
| `respond` |
| `completion` |

## Invocation

`skill({name: "receiving-code-review"})` — call the skill, then call via task():

| Task | Call via task() |

| `address` | `task(..., prompt: "execute address task from receiving-code-review")` |
| `respond` | `task(..., prompt: "execute respond task from receiving-code-review")` |
| `completion` | `task(..., prompt: "execute completion task from receiving-code-review")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "receiving-code-review"})` ``

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ pr_number, review_comments, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, github.owner, github.repo }`. No inline work.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

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


