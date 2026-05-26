---
name: requesting-code-review
description: Use when preparing a PR for code review, or when reviewer context and documentation are needed. Triggers on: request review, code review, review request, ready for review, review preparation. Submitting unreviewed code is submitting unverified code. Every review request is a quality gate, not a formality.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: requesting-code-review

## Overview

Prepares and requests code reviews. Ensures PR descriptions have proper context, reviewers understand changes, requests are targeted.

## Tasks

| Task | Words |
|------|-------|
| `prepare` | ≈400 |
| `request` | ≈250 |

## Invocation

`skill({name: "requesting-code-review"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `prepare` | `task(..., prompt: "execute prepare task from requesting-code-review")` |
| `request` | `task(..., prompt: "execute request task from requesting-code-review")` |

**CLI equivalent (for human TUI use):** `/skill requesting-code-review --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ pr_number, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
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
