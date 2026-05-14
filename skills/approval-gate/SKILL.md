---
name: approval-gate
description: "Use when user says approved or go, or when authorization needs verification. Triggers on: approval, authorized, implement, start work, go ahead, no approved-for-* label, authorization set, multiple issues approved, interdependency analysis."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: approval-gate

## Overview

Authorization Gatekeeper enforcing spec + plan + authorization workflow. Gate before all implementation begins. Detects authorization phrases, resolves scope, verifies sub-issue structure, cascades plan approval from spec approval.

## Persona

Authorization Gatekeeper. Focus: verify authorization, resolve scope, enforce two-gate model, cascade approval, dispatch to next pipeline stage.

## Tasks

| Task | Words |
|------|-------|
| `verify-qa-mode` | ≈800 |
| `verify-authorization` | ≈400 |
| `verify-authorization/scope-auto-resolve` | ≈200 |
| `verify-authorization/item-decomposition-check` | ≈250 |
| `verify-authorization/sc-traceability-check` | ≈350 |
| `verify-authorization/sub-issue-verification` | ≈600 |
| `verify-authorization/spec-to-plan-cascade` | ≈400 |
| `verify-authorization/gap-fill-cascade` | ≈500 |
| `verify-authorization/auto-dispatch` | ≈500 |
| `verify-authorization/model-selection` | ≈300 |
| `verify-sub-issues` | ≈480 |
| `verify-codebase` | ≈400 |
| `verify-already-implemented` | ≈400 |
| `verify-blockers` | ≈320 |
| `verify-open-questions` | ≈370 |
| `verify-fix-spec` | ≈250 |
| `search-prompt-fail` | ≈300 |
| `verify-closed-issue` | ≈350 |
| `screen-issue` | ≈250 |
| `screen-issue/gate1` | ≈1900 |
| `screen-issue/gate2` | ≈2500 |
| `pre-implementation-analysis` | ≈425 |
| `pre-impl/collect-screening-results` | ≈1200 |
| `pre-impl/reconcile-status` | ≈600 |
| `pre-impl/build-dependency-graph` | ≈1600 |
| `pre-impl/check-cross-spec-overlap` | ≈500 |
| `pre-impl/write-work-state` | ≈720 |
| `pre-impl/yield-to-assemble-work` | ≈920 |
| `reconcile-issue-graph` | ≈600 |
| `verify-schema-api-knowledge` | ≈350 |
| `post-implementation` | ≈480 |
| `completion` | ≈150 |

## Invocation

`skill({name: "approval-gate"})` — load the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `verify-authorization` | `task(..., prompt: "execute verify-authorization task from approval-gate")` |
| `screen-issue` | `task(..., prompt: "execute screen-issue task from approval-gate")` |
| `pre-implementation-analysis` | `task(..., prompt: "execute pre-implementation-analysis task from approval-gate")` |
| `verify-closed-issue` | `task(..., prompt: "execute verify-closed-issue task from approval-gate")` |
| `post-implementation` | `task(..., prompt: "execute post-implementation task from approval-gate")` |
| `completion` | `task(..., prompt: "execute completion task from approval-gate")` |

**CLI equivalent (for human TUI use):** `/skill approval-gate --task <task>`

## Operating Protocol

1. **Mandatory invocation** when `approved`/`go`/implementation requested.
2. **Two-gate:** spec approval → plan; plan approval → implementation. Existing plan + approved spec = cascade auto-approve.
3. **Authorization scope** via verb-prefix parsing. Hard HALT at `halt_at`.
4. **Multi-task cascade:** plan authorization → ALL sub-issues. Complete all phases, report once, halt once.
5. **Dispatch order:** `pre-work → pre-analysis → assemble-work → VbC → checklist → review-prep`. Each step produces artifact.
6. **Submodule:** files under submodule → route API calls to submodule repo.
7. **Labels:** `approved-for-*` per scope mapping. No label = awaiting approval.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")`. Standard context: `{ issue_number, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. `screen-issue` receives issue body + authorization context + pipeline_phase. `pre-implementation-analysis` receives all issue numbers + authorization context + pipeline_phase. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }` with zero file paths. No inline work—all tasks dispatch sub-agents. If a sub-agent returns empty, re-dispatch with original scoped context only (max 2 retries). Result contracts return `status` (DONE/BLOCKED/DONE_WITH_CONCERNS/OVERFLOW) + task-specific fields per `enforcement/` result contract schemas.

### Authorization Context Template
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Dispatch Rules
- Missing `authorization_scope` in dispatch context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`
- The `pipeline_phase` field is NEW — it tracks which phase of a multi-phase plan is currently executing

## Cross-References

Skills: `git-workflow`, `pr-creation-workflow`, `issue-review`, `divide-and-conquer`, `writing-plans`, `executing-plans`, `pre-analysis`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: approval-gate-skill-001
    title: "Pre-implementation authorization verification required"
    conditions:
      all: ["spec_exists == true", "user_authorized == false"]
    actions: [HALT]
    triggers: [git-workflow]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-002
    title: "Multi-task cascade extends authorization from plan to all sub-issues"
    conditions:
      all: ["plan_has_sub_issues == true", "user_authorized == true"]
    actions: [PROCEED]
    triggers: [divide-and-conquer, executing-plans]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-005
    title: "Spec-to-plan approval cascade — spec approves existing plan"
    conditions:
      all: ["spec_approved == true", "spec_has_existing_plan == true"]
    actions: [APPLY_LABEL(approved-for-*, plan), ADD_COMMENT(cascade docs), PROCEED_TO(plan-approved dispatch)]
    triggers: [writing-plans]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-006
    title: "PR merge boundary check — block if required PR not merged"
    conditions:
      all: ["plan_has_pr_boundaries == true", "required_pr_not_merged == true"]
    actions: [HALT, REPORT(CRITICAL: required PR not merged)]
    triggers: [divide-and-conquer, git-workflow]
    source: "approval-gate/SKILL.md"
