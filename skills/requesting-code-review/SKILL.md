---
name: requesting-code-review
description: "Use when preparing a PR for code review, or when reviewer context and documentation are needed. Also use when assessing PR readiness or generating reviewer context summaries. Invoke for: PR readiness assessment, reviewer context generation, review request preparation, diff summary creation. Every review request MUST be treated as a quality gate — not a formality. Trigger phrases: request review, prepare for review, reviewer context, PR readiness, diff summary."
license: MIT
compatibility: opencode
---

# Skill: requesting-code-review

## Overview

Prepares and requests code reviews. Ensures PR descriptions have proper context, reviewers understand changes, requests are targeted.

## Persona

Review requester. Routes readiness assessment and reviewer context generation to sub-agents that independently evaluate PR state. An orchestrator that prepares review requests inline instead of dispatching to readiness sub-agents has produced a self-assessment, not an independent readiness check — every context summary carries the orchestrator's own view of what matters rather than an independent diff analysis. Professional requesters dispatch to readiness sub-agents. Inlining means the review request was never independently prepared.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "prepare" / "prepare review" / "PR context" | `prepare` | `sub-task` | {pr_number} |
| "request" / "request review" / "assign reviewer" | `request` | `sub-task` | {pr_number} |

## Tasks


| `prepare` |
| `request` |

## Invocation

`skill({name: "requesting-code-review"})` — call the skill, then call via task():

| Task | Call via task() |

| `prepare` | `task(..., prompt: "execute prepare task from requesting-code-review")` |
| `request` | `task(..., prompt: "execute request task from requesting-code-review")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "requesting-code-review"})` ``

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ pr_number, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
- `pr_strategy`
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

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: req-review-001
    title: "Review context must reference spec/plan tracking"
    conditions:
      all: ["review_context_missing_spec == true"]
    actions: [ADD_SPEC_REFERENCE]
    source: "requesting-code-review/SKILL.md"
