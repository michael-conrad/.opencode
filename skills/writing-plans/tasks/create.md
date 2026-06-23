# Task: create

## Purpose

Create an implementation plan from an approved spec. This is a routing-only task file — it points to the 10 decomposed sub-task files in the 21-step pipeline. The orchestrator dispatches each step via `task()`; sub-agents execute tools directly.

## Prerequisites

- [ ] 1. Approved spec (verified by approval-gate)
- [ ] 2. Spec stored in `.issues/{N}/spec.md`
- [ ] 3. Spec has explicit approval (`approved` or `go`)
- [ ] 4. (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Operating Protocol

- [ ] 1. **Verification first** — **orchestrator routes to**: `research` via sub-agent — Loads `verification-enforcement --task verify` inline, collects evidence artifacts
- [ ] 2. **Readiness gate** — **orchestrator routes to**: `readiness` via sub-agent — Pipeline-readiness gate check + spec-to-plan handoff verification
- [ ] 3. **Structure definition** — **orchestrator routes to**: `structure` via sub-agent — Combined/separate decision, file mapping, phase structure, TDD definition, dependency contract, phase-to-skill mapping
- [ ] 4. **Solve validation** — **orchestrator routes to**: `solve` via sub-agent — Runs `solve model`, `solve check`, `plan plan` as direct CLI
- [ ] 5. **Plan writing** — **orchestrator routes to**: `write` via sub-agent — Writes plan file, validates dispatch markers, applies approval cascade
- [ ] 6. **Verification revisit** — **orchestrator routes to**: `revisit` via sub-agent — Loads `verification-enforcement --task revisit` inline, resolves unverified markers
- [ ] 7. **Validation** — **orchestrator routes to**: `validate` via sub-agent — Plan structure and checklist validation
- [ ] 8. **Audit fidelity** — **orchestrator routes to**: `audit-fidelity` via sub-agent — Plan-fidelity audit with auditor sub-agent type
- [ ] 9. **Audit concern** — **orchestrator routes to**: `audit-concern` via sub-agent — Concern-separation audit with auditor sub-agent type
- [ ] 10. **Completion** — **orchestrator routes to**: `completion` via sub-agent — Lifecycle event, push, report

## Sub-Task Files

| Sub-Task | Purpose |
| -- | -- |
| `research` | Live-source verification gate |
| `readiness` | Pipeline-readiness gate check |
| `structure` | Phase structure and TDD definition |
| `solve` | Z3 constraint solving and plan validation |
| `write` | Plan document writing and dispatch validation |
| `revisit` | Verification revisit and unverified marker resolution |
| `validate` | Plan structure and checklist validation |
| `audit-fidelity` | Plan-fidelity adversarial audit |
| `audit-concern` | Concern-separation adversarial audit |
| `completion` | Lifecycle event, push, report |

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)
- Spec-to-plan handoff PASS

## Exit Criteria

- Plan stored at `.issues/{N}/plan.md`
- All validation passed
- Plan reported in chat with `.issues/{N}/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)

## Plan Format

Plan is stored at `.issues/{N}/plan.md`. Combined and separate affect which sections the plan document includes but not where it is stored.

**Combined (single-task):**
- Write to `.issues/{N}/plan.md`, reference spec content inline
- Retain `[SPEC]` title prefix on spec

**Separate (multi-task):**
- Write to `.issues/{N}/plan.md` with separate phase sections
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

- Related skills: `verification-enforcement`, `issue-operations`, `spec-creation`, `adversarial-audit`, `solve`, `plan`
- Related tasks: `research`, `readiness`, `structure`, `solve`, `write`, `revisit`, `validate`, `audit-fidelity`, `audit-concern`, `completion`
