# Task: create

## Purpose

Create an implementation plan from an approved spec. The orchestrator reads this task file and executes the 21-step pipeline, dispatching sub-agents for sub-task steps and running z3-check steps inline.

## Prerequisites

- [ ] 1. Approved spec (verified by approval-gate)
- [ ] 2. Spec stored in `.issues/{N}/spec.md`
- [ ] 3. Spec has explicit approval (`approved` or `go`)
- [ ] 4. (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Operating Protocol — 21-Step Pipeline

Each item is tagged with dispatch scope, chain dependency, and contract paths.

- [ ] 1. [inline] Verify spec is approved (check `approved-for-*` label) — chain: `none`
- [ ] 2. [sub-task: research] `task(..., prompt: "execute research task from writing-plans")` — input: `contracts/research-input-template.yaml`, output: `contracts/research-output-template.yaml`, template: `contracts/research-input-template.yaml`, chain: `step_1`
- [ ] 3. [z3-check] `solve check` — verify research output contains evidence_artifacts — chain: `step_2`
- [ ] 4. [sub-task: readiness] `task(..., prompt: "execute readiness task from writing-plans")` — input: `contracts/readiness-input-template.yaml`, output: `contracts/readiness-output-template.yaml`, template: `contracts/readiness-input-template.yaml`, chain: `step_3`
- [ ] 5. [z3-check] `solve check` — verify readiness output has status PASS — chain: `step_4`
- [ ] 6. [sub-task: structure] `task(..., prompt: "execute structure task from writing-plans")` — input: `contracts/structure-input-template.yaml`, output: `contracts/structure-output-template.yaml`, template: `contracts/structure-input-template.yaml`, chain: `step_5`
- [ ] 7. [z3-check] `solve check` — verify structure output has phase definitions and dependency contract — chain: `step_6`
- [ ] 8. [sub-task: solve] `task(..., prompt: "execute solve task from writing-plans")` — input: `contracts/solve-input-template.yaml`, output: `contracts/solve-output-template.yaml`, template: `contracts/solve-input-template.yaml`, chain: `step_7`
- [ ] 9. [z3-check] `solve check` — verify solve output has SAT and SOLVED status — chain: `step_8`
- [ ] 10. [sub-task: write] `task(..., prompt: "execute write task from writing-plans")` — input: `contracts/write-input-template.yaml`, output: `contracts/write-output-template.yaml`, template: `contracts/write-input-template.yaml`, chain: `step_9`
- [ ] 11. [z3-check] `solve check` — verify write output has plan file path — chain: `step_10`
- [ ] 12. [sub-task: revisit] `task(..., prompt: "execute revisit task from writing-plans")` — input: `contracts/revisit-input-template.yaml`, output: `contracts/revisit-output-template.yaml`, template: `contracts/revisit-input-template.yaml`, chain: `step_11`
- [ ] 13. [z3-check] `solve check` — verify revisit output has resolution_status — chain: `step_12`
- [ ] 14. [sub-task: validate] `task(..., prompt: "execute validate task from writing-plans")` — input: `contracts/validate-input-template.yaml`, output: `contracts/validate-output-template.yaml`, template: `contracts/validate-input-template.yaml`, chain: `step_13`
- [ ] 15. [z3-check] `solve check` — verify validate output has PASS status — chain: `step_14`
- [ ] 16. [sub-task: audit-fidelity] `task(..., prompt: "execute audit-fidelity task from writing-plans")` — input: `contracts/audit-fidelity-input-template.yaml`, output: `contracts/audit-fidelity-output-template.yaml`, template: `contracts/audit-fidelity-input-template.yaml`, chain: `step_15`
- [ ] 17. [z3-check] `solve check` — verify audit-fidelity output has PASS — chain: `step_16`
- [ ] 18. [sub-task: audit-concern] `task(..., prompt: "execute audit-concern task from writing-plans")` — input: `contracts/audit-concern-input-template.yaml`, output: `contracts/audit-concern-output-template.yaml`, template: `contracts/audit-concern-input-template.yaml`, chain: `step_17`
- [ ] 19. [z3-check] `solve check` — verify audit-concern output has PASS — chain: `step_18`
- [ ] 20. [sub-task: completion] `task(..., prompt: "execute completion task from writing-plans")` — input: `contracts/completion-input-template.yaml`, output: `contracts/completion-output-template.yaml`, template: `contracts/completion-input-template.yaml`, chain: `step_19`
- [ ] 21. [z3-check] `solve check` — verify completion output has lifecycle event — chain: `step_20`

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)

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
