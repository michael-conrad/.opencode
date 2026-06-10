# Task: create

## Purpose

Create an implementation plan from an approved spec. Plans are stored at `.issues/{N}/spec-artifacts/plan.md`.

## Prerequisites

1. Approved spec (verified by approval-gate)
2. Spec stored in `.issues/{N}/spec.md`
3. Spec has explicit approval (`approved` or `go`)
4. (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Operating Protocol

1. **Verification first:** Must run verification-enforcement --task verify before reading spec
2. **Combined or separate decision:** Early evaluation whether plan content references spec content inline (combined) or stands alone with separate phase sections (separate)
3. **Item decomposition mandatory:** Plan must enumerate items, order dependencies, specify acceptance criteria
4. **RED checkpoint mandatory:** Every TDD task must include explicit Step 2 checkpoint
5. **Approval cascade auto-approve:** Pipeline scope (`for_plan+`) auto-approves plan

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)

## Exit Criteria

- Plan stored at `.issues/{N}/spec-artifacts/plan.md`
- All validation passed
- Plan reported in chat with `.issues/{N}/spec-artifacts/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)

## Procedure

### Steps 0-5: Plan Structure Definition

**Route to:** `create/plan-structure`

Runs verification gate, makes combined/separate decision, checks for duplicate plans, maps file structure, defines phase structure, and creates TDD tasks with mandatory RED checkpoints.

### Steps 6-13: Plan Creation and Approval Cascade

**Route to:** `create/create-and-validate`

Writes plan header, stores at `.issues/{N}/spec-artifacts/plan.md`, runs self-review and validation, revisits verification, cross-references skills, and applies approval cascade with scope-aware auto-approval.

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `create/plan-structure` | Verification, combined/separate decision, file mapping, TDD definition | ≈750 |
| `create/create-and-validate` | Document writing, local storage, validation, approval cascade | ≈650 |

## Plan Phase Structure Requirements

Each phase MUST include (prose-driven, not rigid headers):
- **Why this phase exists** — concern it addresses and place in overall design
- **What it must accomplish** — tasks, deliverables, behavioral requirements
- **How to verify completion** — success criteria and testable outcomes. Each phase's verification guidance MUST carry cost-frame identity prose that reframes verification cost using the dark-prose-007 formula from `250-dark-prose-reference.md` §Section 3. Verification MUST require real test execution commands that produce saved artifact files in `./tmp/{issue-N}/artifacts/`. Structural checks (file exists, grep match) are NEVER acceptable substitutes for behavioral runtime evidence — a skipped execution is a defect accepted at the point of verification. The death spiral / break dynamics are formalized in `065-verification-honesty.md` §Cost Model — behavioral verification is a break (bounded cost, zero downstream), structural-only verification is a death spiral (compounding exponential cost).
- **What could go wrong** — edge cases, known risks, failure modes
- **What must be done first** — dependencies on prior phases or external prerequisites

## Concern Boundary Annotations

When transitioning between architectural concerns, describe:
- What concern being left (prior scope)
- What concern being entered (new scope)
- What information the new concern needs from prior (handoff point)

## Plan Format

Plan is stored at `.issues/{N}/spec-artifacts/plan.md`. Combined and separate affect which sections the plan document includes but not where it is stored.

**Combined (single-task):**
- Write to `.issues/{N}/spec-artifacts/plan.md`, reference spec content inline
- Retain `[SPEC]` title prefix on spec

**Separate (multi-task):**
- Write to `.issues/{N}/spec-artifacts/plan.md` with separate phase sections
- Phases are sections in the local plan file — no sub-issues

## Approval Cascade Matrix

| Scope | Plan Approval | Implementation |
| -- | -- | -- |
| `for_review_prep` | Separate approval required | Separate approval required |
| `for_spec` | N/A | N/A |
| `for_analysis` | N/A (analysis-only) | N/A |
| `for_plan` | Auto-approved | Separate approval required |
| `for_implementation` | Auto-approved | Auto-approved |
| `for_pr` | Auto-approved | Auto-approved |
| `for_pr_only` | N/A (skip) | N/A |

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task() Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Related skills: `verification-enforcement`, `issue-operations`, `spec-creation`
- Related tasks: `create/plan-structure`, `create/create-and-validate`