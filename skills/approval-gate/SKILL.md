---
name: approval-gate
description: "Authorization gatekeeper dispatcher that routes to approval-gate-scope sub-skill. Dispatch when the agent needs to verify authorization scope, apply approval labels, handle spec revision revocation, or execute bug discovery protocol. Also dispatch when the agent needs to check approval state, enforce pipeline halt boundaries, or manage spec-to-plan cascade. Triggers when: agent determines authorization verification is needed, agent needs to apply or remove approved-for-* labels, agent detects a spec revision that revokes plan approval, agent discovers a bug during implementation."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: approval-gate (Dispatcher)

## Overview

This is a **dispatcher skill** that routes to the `approval-gate-scope` sub-skill. All original trigger phrases are preserved for backward compatibility. The sub-skill handles all authorization gatekeeping operations.

## Sub-Skill

| Sub-Skill | Purpose | Task Count |
|-----------|---------|------------|
| `approval-gate-scope` | Authorization scope verification, label application, revision revocation, bug discovery protocol | 22 tasks + 6 enforcement files |

## Trigger Dispatch Table

| User says / Context | Task | Dispatches To | Dispatch | Context passed |
|---------------------|------|---------------|----------|----------------|
| "verify authorization" / "check approval" | `verify-authorization` | `approval-gate-scope --task verify-authorization` | `sub-task` | {issue_number, authorization_scope} |
| "screen issue" / "triage" | `screen-issue` | `approval-gate-scope --task screen-issue` | `sub-task` | {issue_number} |
| "pre-implementation analysis" | `pre-implementation-analysis` | `approval-gate-scope --task pre-implementation-analysis` | `sub-task` | {issue_numbers} |
| "verify blockers" | `verify-blockers` | `approval-gate-scope --task verify-blockers` | `sub-task` | {issue_number} |
| "verify closed issue" | `verify-closed-issue` | `approval-gate-scope --task verify-closed-issue` | `sub-task` | {issue_number} |
| "spec-to-plan cascade" | `spec-to-plan-cascade` | `approval-gate-scope --task spec-to-plan-cascade` | `sub-task` | {spec_issue, plan_issue} |
| "item decomposition check" | `item-decomposition-check` | `approval-gate-scope --task item-decomposition-check` | `sub-task` | {plan_issue} |
| "auto-dispatch" | `auto-dispatch` | `approval-gate-scope --task auto-dispatch` | `sub-task` | {authorization_scope} |
| "verify already implemented" | `verify-already-implemented` | `approval-gate-scope --task verify-already-implemented` | `sub-task` | {issue_number} |
| "approval cascade" / "cascade authorization" | `approval-cascade` | `approval-gate-scope --task approval-cascade` | `sub-task` | {parent_issue, sub_issues} |
| "pipeline halt boundary" / "check halt_at" | `check-halt-boundary` | `approval-gate-scope --task check-halt-boundary` | `sub-task` | {authorization_scope, halt_at, pipeline_phase} |
| "apply label" / "set approval label" | `apply-label` | `approval-gate-scope --task apply-label` | `sub-task` | {issue_number, authorization_scope} |
| "revision revocation" / "spec revised" | `revision-revocation` | `approval-gate-scope --task revision-revocation` | `sub-task` | {spec_issue, plan_issue} |
| "bug discovery" / "bug found during implementation" | `bug-discovery-protocol` | `approval-gate-scope --task bug-discovery-protocol` | `sub-task` | {issue_number, bug_description} |
| "verify plan pipeline" / "check pipeline completeness" | `verify-plan-pipeline` | `approval-gate-scope --task verify-plan-pipeline` | `sub-task` | {issue_number} |
| completion / workflow end | `completion` | `approval-gate-scope --task completion` | `sub-task` | {workflow_state} |
| "release PR" / "release authorization" | `verify-authorization` | `approval-gate-scope --task verify-authorization` | `sub-task` | {issue_number, authorization_scope, is_release: true} |

## Invocation

`skill({name: "approval-gate"})` — call the skill, then dispatch to the sub-skill:

| Task | Canonical Dispatch String |
|------|--------------------------|
| `verify-authorization` | `task(..., prompt: "execute verify-authorization from approval-gate-scope. Read \`approval-gate-scope/tasks/verify-authorization.md\` first")` |
| `screen-issue` | `task(..., prompt: "execute screen-issue from approval-gate-scope. Read \`approval-gate-scope/tasks/screen-issue.md\` first")` |
| `pre-implementation-analysis` | `task(..., prompt: "execute pre-implementation-analysis from approval-gate-scope. Read \`approval-gate-scope/tasks/pre-implementation-analysis.md\` first")` |
| `verify-blockers` | `task(..., prompt: "execute verify-blockers from approval-gate-scope. Read \`approval-gate-scope/tasks/verify-blockers.md\` first")` |
| `verify-closed-issue` | `task(..., prompt: "execute verify-closed-issue from approval-gate-scope. Read \`approval-gate-scope/tasks/verify-closed-issue.md\` first")` |
| `spec-to-plan-cascade` | `task(..., prompt: "execute spec-to-plan-cascade from approval-gate-scope. Read \`approval-gate-scope/tasks/spec-to-plan-cascade.md\` first")` |
| `item-decomposition-check` | `task(..., prompt: "execute item-decomposition-check from approval-gate-scope. Read \`approval-gate-scope/tasks/item-decomposition-check.md\` first")` |
| `auto-dispatch` | `task(..., prompt: "execute auto-dispatch from approval-gate-scope. Read \`approval-gate-scope/tasks/auto-dispatch.md\` first")` |
| `verify-already-implemented` | `task(..., prompt: "execute verify-already-implemented from approval-gate-scope. Read \`approval-gate-scope/tasks/verify-already-implemented.md\` first")` |
| `approval-cascade` | `task(..., prompt: "execute approval-cascade from approval-gate-scope. Read \`approval-gate-scope/tasks/approval-cascade.md\` first")` |
| `check-halt-boundary` | `task(..., prompt: "execute check-halt-boundary from approval-gate-scope. Read \`approval-gate-scope/tasks/check-halt-boundary.md\` first")` |
| `apply-label` | `task(..., prompt: "execute apply-label from approval-gate-scope. Read \`approval-gate-scope/tasks/apply-label.md\` first")` |
| `revision-revocation` | `task(..., prompt: "execute revision-revocation from approval-gate-scope. Read \`approval-gate-scope/tasks/revision-revocation.md\` first")` |
| `bug-discovery-protocol` | `task(..., prompt: "execute bug-discovery-protocol from approval-gate-scope. Read \`approval-gate-scope/tasks/bug-discovery-protocol.md\` first")` |
| `verify-plan-pipeline` | `task(..., prompt: "execute verify-plan-pipeline from approval-gate-scope. Read \`approval-gate-scope/tasks/verify-plan-pipeline.md\` first")` |
| `completion` | `task(..., prompt: "execute completion from approval-gate-scope. Read \`approval-gate-scope/tasks/completion.md\` first")` |

## DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read the task file then execute step 1" | "execute verify-authorization from approval-gate-scope" |
| Preloaded step sequences | "Step 1: check scope. Step 2: apply label." | "execute verify-authorization from approval-gate-scope" |
| Preloaded expected outcomes | "Return { authorization_status }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The spec was just revised so we need to..." | Pure objective, no narrative |

### Dispatch Context Contract

Every `task()` call MUST include only:
- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the Trigger Dispatch Table above.

## Cross-References

Sub-skills: `approval-gate-scope`. Skills: `git-workflow`, `pr-creation-workflow`, `issue-review`, `implementation-pipeline`, `writing-plans`, `executing-plans`, `pre-analysis`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`.
