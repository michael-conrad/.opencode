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

`/skill approval-gate --task <task>`. Key invocations: `verify-authorization` (check auth), `screen-issue` (per-issue screening), `pre-implementation-analysis` (cross-issue merge), `verify-closed-issue` (verify closure), `post-implementation` (push+compare URL), `completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Mandatory invocation** when `approved`/`go`/implementation requested.
2. **Two-gate:** spec approval → plan; plan approval → implementation. Existing plan + approved spec = cascade auto-approve.
3. **Authorization scope** via verb-prefix parsing. Hard HALT at `halt_at`.
4. **Multi-task cascade:** plan authorization → ALL sub-issues. Complete all phases, report once, halt once.
5. **Dispatch order:** `pre-work → pre-analysis → assemble-work → VbC → checklist → review-prep`. Each step produces artifact.
6. **Submodule:** files under submodule → route API calls to submodule repo.
7. **Labels:** `approved-for-*` per scope mapping. No label = awaiting approval.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")`. Standard context: `{ issue_number, github.owner, github.repo, authorization_scope, halt_at, pr_strategy }`. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. `screen-issue` receives issue body + authorization context. `pre-implementation-analysis` receives all issue numbers + authorization context. `pre-analysis` receives only `{ issue_number, task_description }` with zero file paths. No inline work—all tasks dispatch sub-agents. Result contracts return `status` (DONE/BLOCKED/DONE_WITH_CONCERNS/OVERFLOW) + task-specific fields per `enforcement/` result contract schemas.

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
