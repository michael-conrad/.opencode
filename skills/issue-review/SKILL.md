---
name: issue-review
description: "Use when reviewing a GitHub issue for comments, audits, or Q/A. Also use when gathering context from issue comments, classifying review paths, or delegating to downstream skills. Invoke for: issue review, comment reading, context gathering, path classification, downstream delegation. All comments MUST be read before acting on any issue. Trigger phrases: review issue, read comments, gather context, classify path, audit issue."
license: MIT
compatibility: opencode
---

# Skill: issue-review

## Overview

Unified review orchestrator for GitHub Issues. Gathers issue data, classifies review path via content analysis, delegates to downstream skills, handles Q/A for non-spec issues.

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

**CLI equivalent (for human TUI use):** `` `skill({name: "issue-review"})` ``

## Operating Protocol

- [ ] 1. **Gather first:** read body, ALL comments, labels, sub-issues, auth status before classification.
- [ ] 2. **Triage path:** bug report → analyze-and-spec. Spec → audit. Non-bug, non-spec → qa.
- [ ] 3. **Bug discovery ≠ authorization:** findings reported as bug issues; no code edits during analysis.
- [ ] 4. **Fix spec must target root cause, not symptom** per `000-critical-rules.md`.
- [ ] 5. **Audit findings are internal** — posted to chat, not GitHub comments.
- [ ] 6. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ issue_number, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, cached verification. Auditor tasks use `task(subagent_type="general")` — same as all other tasks. Dispatch contracts carry 2 fields: `spec_local_dir` and `artifact_evidence_dir`. See audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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

## Cross-References

Skills: `audit --task spec-audit`, `brainstorming`, `spec-creation`, `issue-operations`, `approval-gate`. Guidelines: `000-critical-rules.md`, `067-context-completeness.md`.

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
