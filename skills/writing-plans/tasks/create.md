# Task: create

## Purpose

Create an implementation plan from an approved spec. The orchestrator reads this task file and executes the 21-step pipeline, dispatching sub-agents for sub-task steps and running z3-check steps inline.

## Prerequisites

- [ ] 1. (**inline**) Approved spec (verified by approval-gate)
- [ ] 2. (**inline**) Spec stored in `.issues/{N}/spec.md` or `*/.issues/{N}/spec.md`
- [ ] 3. (**inline**) Spec has explicit approval (`approved` or `go`)
- [ ] 4. (**inline**) (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Trigger Dispatch Table — Sub-Steps

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| research step in pipeline | `research` | `sub-agent` | `{ spec_issue_number, spec_body }` |
| readiness step in pipeline | `readiness` | `sub-agent` | `{ spec_issue_number, research_output }` |
| structure step in pipeline | `structure` | `sub-agent` | `{ spec_issue_number, readiness_output }` |
| solve step in pipeline | `solve` | `sub-agent` | `{ spec_issue_number, structure_output }` |
| write step in pipeline | `write` | `sub-agent` | `{ spec_issue_number, solve_output }` |
| revisit step in pipeline | `revisit` | `sub-agent` | `{ spec_issue_number, write_output }` |
| validate step in pipeline | `validate` | `sub-agent` | `{ spec_issue_number, plan_file_path }` |
| audit-fidelity step in pipeline | `audit-fidelity` | `sub-agent` | `{ spec_issue_number, plan_file_path, audit_phase }` |
| audit-concern step in pipeline | `audit-concern` | `sub-agent` | `{ spec_issue_number, plan_file_path, audit_phase }` |
| completion step in pipeline | `completion` | `sub-agent` | `{ workflow_state }` |

## Operating Protocol — 21-Step Pipeline

Each item is tagged with dispatch scope and chain dependency.

- [ ] 1. (**inline**) Verify spec is approved (check `approved-for-*` label)
  - Command: `github_issue_read(method=get_labels, issue_number={N})`
  - Chain: `none`
  - Expected: label `approved-for-*` present

- [ ] 2. (**sub-agent**) Research — `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `step_1`
  - Expected: evidence_artifacts in research output

- [ ] 3. (**inline**) Z3 check — `solve check` verify research output contains evidence_artifacts per `contracts/create-output-template.yaml:research`
  - Chain: `step_2`

- [ ] 4. (**sub-agent**) Readiness — `task(..., prompt: "execute readiness task from writing-plans")`
  - Chain: `step_3`
  - Expected: status PASS in readiness output

- [ ] 5. (**inline**) Z3 check — `solve check` verify readiness output has status PASS per `contracts/create-output-template.yaml:readiness`
  - Chain: `step_4`

- [ ] 6. (**sub-agent**) Structure — `task(..., prompt: "execute structure task from writing-plans")`
  - Chain: `step_5`
  - Expected: phase definitions and dependency contract in structure output

- [ ] 7. (**inline**) Z3 check — `solve check` verify structure output has phase definitions and dependency contract per `contracts/create-output-template.yaml:structure`
  - Chain: `step_6`

- [ ] 8. (**sub-agent**) Solve — `task(..., prompt: "execute solve task from writing-plans")`
  - Chain: `step_7`
  - Expected: SAT and SOLVED status in solve output

- [ ] 9. (**inline**) Z3 check — `solve check` verify solve output has SAT and SOLVED status per `contracts/create-output-template.yaml:solve`
  - Chain: `step_8`

- [ ] 10. (**sub-agent**) Write — `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_9`
  - Expected: plan file path in write output

- [ ] 11. (**sub-agent**) Clean-room plan generation — `task(..., prompt: "execute write task from writing-plans")` with spec body only, no existing plan context
  - Chain: `step_10`
  - Expected: clean_room_plan in output

- [ ] 12. (**inline**) Z3 check — `solve check` verify clean-room plan output contains clean_room_plan per `contracts/create-output-template.yaml:write`
  - Chain: `step_11`

- [ ] 13. (**sub-agent**) Revisit — `task(..., prompt: "execute revisit task from writing-plans")`
  - Chain: `step_12`
  - Expected: resolution_status in revisit output

- [ ] 14. (**inline**) Z3 check — `solve check` verify revisit output has resolution_status per `contracts/create-output-template.yaml:revisit`
  - Chain: `step_13`

- [ ] 15. (**sub-agent**) Validate — `task(..., prompt: "execute validate task from writing-plans")`
  - Chain: `step_14`
  - Expected: PASS status in validate output

- [ ] 16. (**inline**) Z3 check — `solve check` verify validate output has PASS status per `contracts/create-output-template.yaml:validate`
  - Chain: `step_15`

- [ ] 17. (**sub-agent**) Audit fidelity — `task(..., prompt: "execute audit-fidelity task from writing-plans")`
  - Chain: `step_16`
  - Expected: PASS in audit-fidelity output

- [ ] 18. (**inline**) Z3 check — `solve check` verify audit-fidelity output has PASS per `contracts/create-output-template.yaml:audit-fidelity`
  - Chain: `step_17`

- [ ] 19. (**sub-agent**) Audit concern — `task(..., prompt: "execute audit-concern task from writing-plans")`
  - Chain: `step_18`
  - Expected: PASS in audit-concern output

- [ ] 20. (**inline**) Z3 check — `solve check` verify audit-concern output has PASS per `contracts/create-output-template.yaml:audit-concern`
  - Chain: `step_19`

- [ ] 21. (**sub-agent**) Completion — `task(..., prompt: "execute completion task from writing-plans")`
  - Chain: `step_20`
  - Expected: lifecycle event in completion output

- [ ] 22. (**inline**) Z3 check — `solve check` verify completion output has lifecycle event
  - Chain: `step_21`

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md` or `*/.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)

## Exit Criteria

- Plan stored at `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
- All validation passed
- Plan reported in chat with `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)
- All implementation-pipeline gate steps enumerated in exit criteria or phase structure
- Step numbering is globally sequential across all phases
- Output contract loaded from `contracts/create-output-template.yaml` and validated before returning

## Plan Format

The write sub-agent produces the plan per the format specification in `write.md`.

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
