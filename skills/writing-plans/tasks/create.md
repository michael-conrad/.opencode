# Task: create

<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->
<!-- Sync locations: see cross-reference table in that file -->

## Purpose

Create an implementation plan from an approved spec. The orchestrator dispatches the 21-step pipeline to a sub-agent, which reads this task file and executes the steps, dispatching sub-agents for sub-task steps and running z3-check steps inline.

## Step 0: Holistic Spec Evaluation (Pre-Flight Gate)

**MANDATORY GATE — MUST NOT be skipped.** Before any plan creation steps, dispatch a clean-room sub-agent to evaluate the spec against the 11 holistic dimensions defined in `.opencode/reference/holistic-dimensions.yaml`.

- [ ] 0. (**sub-agent**) Holistic spec evaluation — `task(..., prompt: "Evaluate the spec body against all 11 spec_dimensions from .opencode/reference/holistic-dimensions.yaml. For each dimension, produce PASS or FAIL with evidence. If any dimension FAILs, return BLOCKED with the failing dimension IDs, names, and resolution guidance.")`
  - Chain: `none`
  - Context passed: `{ spec_issue_number, spec_body }`
  - Expected: PASS for all 11 dimensions
  - On FAIL: hard-fail immediately, escalate to user with failing dimension details and resolution guidance
  - On PASS: proceed to Prerequisites

## Prerequisites

- [ ] 1. (**inline**) Approved spec (verified by approval-gate)
- [ ] 2. (**inline**) Spec stored in `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
- [ ] 3. (**inline**) Spec has explicit approval (`approved` or `go`)
- [ ] 4. (**inline**) (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Trigger Dispatch Table — Sub-Steps

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| research step in pipeline | `research` | `sub-agent` | `{ spec_issue_number, spec_body }` |
| artifact-validation step in pipeline | `artifact-validation` | `sub-agent` | `{ spec_issue_number, project_root, path }` |
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

**Sequential step ordering:** Every step with a chain dependency MUST execute sequentially. No parallel dispatch of chain-dependent steps. Each step's output is the next step's input. The "sub-agent dispatch implies independence" rationalization is explicitly prohibited.

**Pipeline execution discipline:**
- `todowrite` lifecycle MUST be maintained throughout pipeline execution (CREATE with status, UPDATE on transition, CLEAR before HALT)
- `pipeline_phase` MUST be tracked and updated after each step
- A feature branch MUST be created before any plan artifacts are written
- Plan artifacts MUST be committed to the feature branch after creation
- `local-issues sync` MUST be run before any `.issues/` writes and after each write
- **Plan phases are local `.issues/` artifacts only. Do NOT create GitHub Issues for plan phases or sub-issues.** The plan's phase table is a local file structure (`{N}/plan.md` + `{N}/plan-{NN}.md`), not a GitHub sub-issue hierarchy. Creating GitHub Issues for individual plan phases is a critical violation — it pollutes the issue tracker with tracking noise and breaks the plan's local artifact model.

Each item is tagged with dispatch scope and chain dependency.

- [ ] 1. (**inline**) Verify spec is approved (check `approved-for-*` label)
  - Command: `github_issue_read(method=get_labels, issue_number={N})`
  - Chain: `none`
  - Expected: label `approved-for-*` present

- [ ] 2. (**sub-agent**) Research — `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `step_1`
  - Expected: evidence_artifacts in research output

- [ ] 3. (**inline**) Z3 check — `solve check` verify research output contains evidence_artifacts per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:research`
  - Chain: `step_2`

- [ ] 4. (**sub-agent**) Readiness — `task(..., prompt: "execute readiness task from writing-plans")`. The readiness gate MUST read `sc-pipeline-readiness.yaml` created by an independent sub-agent (pipeline-readiness-gate task), NOT by the orchestrator. If the file was created by the orchestrator (same session, no sub-agent dispatch), the gate MUST return BLOCKED.
  - Chain: `step_3`
  - Expected: status PASS in readiness output

- [ ] 4a. (**sub-agent**) Artifact validation — `task(..., prompt: "execute artifact-validation task from writing-plans")`. Validates that all spec-creation analytical artifacts exist, are non-empty, and are well-formed YAML. This step MUST execute before structure step to ensure all required artifacts are available.
  - Chain: `step_4`
  - Expected: PASS in artifact-validation output; if BLOCKED, pipeline halts with `MISSING_SPEC_ARTIFACT`

- [ ] 5. (**inline**) Z3 check — `solve check` verify readiness output has status PASS per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:readiness`
  - Chain: `step_4a`

- [ ] 6. (**sub-agent**) Structure — `task(..., prompt: "execute structure task from writing-plans")`
  - Chain: `step_5`
  - Expected: phase definitions and dependency contract in structure output

- [ ] 7. (**inline**) Z3 check — `solve check` verify structure output has phase definitions and dependency contract per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:structure`
  - Chain: `step_6`

- [ ] 8. (**sub-agent**) Solve — `task(..., prompt: "execute solve task from writing-plans")`
  - Chain: `step_7`
  - Expected: SAT and SOLVED status in solve output

- [ ] 9. (**inline**) Z3 check — `solve check` verify solve output has SAT and SOLVED status per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:solve`
  - Chain: `step_8`

- [ ] 10. (**sub-agent**) Write — `task(..., prompt: "execute write task from writing-plans")`. **Post-dispatch file verification:** After the sub-agent returns DONE with a file path, run `ls` or `file-exists` to confirm the file exists on disk. If the file does not exist, re-task clean-room (do not accept the empty result).
  - Chain: `step_9`
  - Expected: plan file path in write output
  - **Behavioral SC requirement:** The write sub-agent MUST generate phase exit criteria for behavioral SCs that include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps. Each SC in the exit criteria MUST carry an `evidence_type` metadata annotation (e.g., `evidence_type: behavioral`). The VbC section for behavioral SCs MUST include a mandatory gate: after artifact generation, dispatch `behavioral-test-evaluation` before allowing PASS verdict.

- [ ] 11. (**sub-agent**) Clean-room plan generation — **MANDATORY GATE — MUST NOT be skipped.** `task(..., prompt: "execute write task from writing-plans")` with spec body only, no existing plan context. The orchestrator MUST NOT proceed past Step 10 without dispatching Step 11. If Step 11 is skipped, the pipeline MUST halt.
  - Chain: `step_10`
  - Expected: clean_room_plan in output

- [ ] 12. (**inline**) Z3 check — `solve check` verify clean-room plan output contains clean_room_plan per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:write`
  - Chain: `step_11`

- [ ] 13. (**sub-agent**) Revisit — `task(..., prompt: "execute revisit task from writing-plans")`
  - Chain: `step_12`
  - Expected: resolution_status in revisit output

- [ ] 14. (**inline**) Z3 check — `solve check` verify revisit output has resolution_status per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:revisit`
  - Chain: `step_13`

- [ ] 15. (**sub-agent**) Validate — `task(..., prompt: "execute validate task from writing-plans")`
  - Chain: `step_14`
  - Expected: PASS status in validate output

- [ ] 16. (**inline**) Z3 check — `solve check` verify validate output has PASS status per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:validate`
  - Chain: `step_15`

- [ ] 17. (**sub-agent**) Audit fidelity — `task(..., prompt: "execute audit-fidelity task from writing-plans")`
  - Chain: `step_16`
  - Expected: PASS in audit-fidelity output

- [ ] 18. (**inline**) Z3 check — `solve check` verify audit-fidelity output has PASS AND `all_criteria_pass == true` per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:audit-fidelity`. If `all_criteria_pass` is `false` or missing, treat as FAIL — orchestrator MUST halt and require remediation before proceeding.
  - Chain: `step_17`

- [ ] 19. (**sub-agent**) Audit concern — `task(..., prompt: "execute audit-concern task from writing-plans")`
  - Chain: `step_18`
  - Expected: PASS in audit-concern output

- [ ] 20. (**inline**) Z3 check — `solve check` verify audit-concern output has PASS AND `all_criteria_pass == true` per `.opencode/skills/writing-plans/contracts/create-output-template.yaml:audit-concern`. If `all_criteria_pass` is `false` or missing, treat as FAIL — orchestrator MUST halt and require remediation before proceeding.
  - Chain: `step_19`

- [ ] 21. (**sub-agent**) Completion — `task(..., prompt: "execute completion task from writing-plans")`
  - Chain: `step_20`
  - Expected: lifecycle event in completion output

- [ ] 22. (**inline**) Z3 check — `solve check` verify completion output has lifecycle event
  - Chain: `step_21`

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)
- **Mandatory step completeness enforced:** All steps in the implementation-pipeline SKILL.md Trigger Dispatch Table MUST be included in the generated plan with correct skill/task references. Plans that omit mandatory steps or use incorrect skill/task names are defective and MUST be rejected at validation. This is non-waivable — no exception for any reason.

## Exit Criteria

- Plan index stored at `{N}/plan.md` with phase table
- Phase files stored at `{N}/plan-{NN}.md` (one per phase)
- All validation passed
- Plan reported in chat with `{N}/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)
- All implementation-pipeline gate steps enumerated in exit criteria or phase structure
- Step numbering is globally sequential across all phases
- Phase exit criteria for behavioral SCs include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps
- Each SC in the exit criteria carries an `evidence_type` metadata annotation (e.g., `evidence_type: behavioral`)
- The VbC section for behavioral SCs includes a mandatory gate: after artifact generation, dispatch `behavioral-test-evaluation` before allowing PASS verdict
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

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task() Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Related skills: `verification-enforcement`, `issue-operations`, `spec-creation`, `audit`, `solve`, `plan`
- Related tasks: `research`, `readiness`, `structure`, `solve`, `write`, `revisit`, `validate`, `audit-fidelity`, `audit-concern`, `completion`
