---
name: issue-review
description: "Use when reviewing a GitHub issue for comments, audits, or Q/A. Every unread comment is a defect risk."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: issue-review

## Overview

Unified review orchestrator for GitHub Issues. Gathers issue data, classifies review path via content analysis, delegates to downstream skills, handles Q/A for non-spec issues.



## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "gather" / "gather context" | `gather` | `sub-task` | {issue_number} |
| "triage" / "classify issue" | `triage` | `sub-task` | {issue_number} |
| "audit" / "review spec" | `audit` | `sub-task` | {issue_number} |
| "qa" / "question answer" | `qa` | `sub-task` | {issue_number} |
| "analyze-and-spec" / "bug to spec" | `analyze-and-spec` | `sub-task` | {issue_number} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Issue Review Orchestrator. Focus: gather context, classify path, delegate to correct downstream skill.

## Tasks

| Task |
|------|
| `gather` |
| `triage` |
| `audit` |
| `qa` |
| `analyze-and-spec` |
| `completion` |

## Invocation

`skill({name: "issue-review"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `gather` | `task(..., prompt: "execute gather task from issue-review")` |
| `triage` | `task(..., prompt: "execute triage task from issue-review")` |
| `analyze-and-spec` | `task(..., prompt: "execute analyze-and-spec task from issue-review")` |
| `audit` | `task(..., prompt: "execute audit task from issue-review")` |
| `qa` | `task(..., prompt: "execute qa task from issue-review")` |
| `completion` | `task(..., prompt: "execute completion task from issue-review")` |

**CLI equivalent (for human TUI use):** `/skill issue-review --task <task>`

## Operating Protocol

- [ ] 1. **Gather first:** read body, ALL comments, labels, sub-issues, auth status before classification.
- [ ] 2. **Triage path:** bug report → analyze-and-spec. Spec → audit. Non-bug, non-spec → qa.
- [ ] 3. **Bug discovery ≠ authorization:** findings reported as bug issues; no code edits during analysis.
- [ ] 4. **Fix spec must target root cause, not symptom** per `000-critical-rules.md`.
- [ ] 5. **Audit findings are internal** — posted to chat, not GitHub comments.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ issue_number, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, cached verification. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Skills: `adversarial-audit --task spec-audit`, `brainstorming`, `spec-creation`, `issue-operations`, `approval-gate`. Guidelines: `000-critical-rules.md`, `067-context-completeness.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: issue-review-001
    title: "Bug discovery does NOT authorize fixing"
    conditions:
      all: ["bug_discovered_during_analysis == true", "fix_authorization_received == false"]
    actions: [HALT, CREATE(bug_report), TASK(analyze-and-spec)]
    source: "issue-review/SKILL.md"

  - id: issue-review-002
    title: "Fix spec must target root cause, not symptom"
    conditions:
      all: ["fix_spec_created == true", "fix_approach_targets_root_cause == false"]
    actions: [REJECT, HALT]
    source: "issue-review/SKILL.md"
