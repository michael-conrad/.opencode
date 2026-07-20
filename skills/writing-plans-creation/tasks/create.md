# Task: create

<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->
<!-- Sync locations: see cross-reference table in that file -->

## Purpose

Create an implementation plan from an approved spec. The orchestrator dispatches the pipeline to a sub-agent, which reads this task file and executes the steps. The orchestrator handles all sub-agent dispatch from the SKILL.md Trigger Dispatch Table; this task file contains only the step procedures and artifact expectations.

## Step 0: Holistic Spec Evaluation (Pre-Flight Gate)

**MANDATORY GATE — MUST NOT be skipped.** Before any plan creation steps, the orchestrator dispatches a clean-room sub-agent to evaluate the spec against the 11 holistic dimensions defined in `.opencode/reference/holistic-dimensions.yaml`.

- [ ] 0. (**orchestrator**) Holistic spec evaluation — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `none`
  - Context passed: `{ spec_issue_number, spec_body }`
  - Expected: PASS for all 11 dimensions
  - On FAIL: hard-fail immediately, escalate to user with failing dimension details and resolution guidance
  - On PASS: proceed to Prerequisites

## Plan Template Sections

The write sub-agent MUST include the following sections in every plan produced. These sections feed the 11 holistic dimensions and are mandatory — not optional.

### SC-to-Step Traceability Table

Per phase, map each spec SC to the plan step(s) that implement it. Format:

```markdown
| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1  | ...       | 1     | 1.1, 1.2 |
| SC-2  | ...       | 2     | 2.3 |
```

- Every spec SC MUST trace to at least one plan step
- Steps that don't trace to any SC are scope creep and MUST be removed
- Feeds the **Traceability** dimension

### Safety/Rollback Considerations

Per phase, document rollback plans for destructive operations. Required when any step involves data mutation, file deletion, or irreversible changes. Format:

```markdown
**Phase N — Safety/Rollback:**
- Destructive operations: [list]
- Rollback plan: [steps to undo]
- Data loss risk: [none/low/medium/high]
```

- If no destructive operations exist, state: "No destructive operations in this phase"
- Feeds the **Safety** dimension

### Feasibility Verification

Per step, confirm that referenced files, functions, and libraries exist before including them in the plan. Format:

```markdown
| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1  | `src/foo.py` `bar()` | ✅ | `srclight_get_signature` |
```

- References to non-existent artifacts MUST be flagged before finalization
- Feeds the **Feasibility** dimension

### Evidence/Provenance

Every claim about code state in plan steps must be backed by a tool-call artifact. Claims without evidence MUST be flagged before finalization. Format:

```markdown
| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `bar()` returns `int` | `srclight_get_signature('bar')` | ✅ |
```

- Feeds the **Provenance** dimension

## Guidance

### Escape Hatch Prohibition

Plan step descriptions MUST NOT contain language that lets the agent short-circuit steps. Prohibited patterns:

- "If this step fails, skip it" (without fallback criteria)
- "Attempt X, if not possible do Y" (without clear fallback criteria)
- "Verify manually" (pushes verification to human)
- "May need to be adjusted" (no criteria for adjustment)
- "Left to implementor", "implementor's choice"
- "TBD", "TODO"
- "If time permits"
- "Simplify if needed"

### Step-to-SC Traceability

Every plan step MUST trace to at least one spec SC. Steps that don't trace to any SC are scope creep or unnecessary and MUST be removed.

### Rollback for Destructive Operations

Any step that performs a destructive operation (data mutation, file deletion, irreversible change) MUST have an explicit rollback step or documented rollback plan.

### Plan-Spec Alignment

The plan MUST actually implement the spec it claims to implement. The plan's goal MUST match the spec's goal. The plan MUST NOT add phases the spec didn't ask for or omit phases the spec requires.

## Prerequisites

- [ ] 1. (**inline**) Approved spec (verified by approval-gate)
- [ ] 2. (**inline**) Spec stored in `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
- [ ] 3. (**inline**) Spec has explicit approval (`approved` or `go`)
- [ ] 4. (**inline**) (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Pipeline Steps Reference

The following steps are dispatched by the orchestrator from the SKILL.md Trigger Dispatch Table. This task file receives the results of each step as input context.

| Step | Input Context | Expected Output |
|------|---------------|-----------------|
| research | `{ spec_issue_number, spec_body }` | evidence_artifacts |
| artifact-validation | `{ spec_issue_number, project_root, path }` | PASS or BLOCKED |
| readiness | `{ spec_issue_number, research_output }` | status PASS |
| structure | `{ spec_issue_number, readiness_output }` | phase definitions and dependency contract |
| solve | `{ spec_issue_number, structure_output }` | SAT and SOLVED status |
| plan-creation-pipeline | `{ spec_issue_number, structure_output }` | plan file path (dispatches to plan-creation-pipeline skill) |
| write | `{ spec_issue_number, solve_output }` | plan file path |
| revisit | `{ spec_issue_number, write_output }` | resolution_status |
| validate | `{ spec_issue_number, plan_file_path }` | PASS status |
| audit-fidelity | `{ spec_issue_number, plan_file_path, audit_phase }` | PASS |
| audit-concern | `{ spec_issue_number, plan_file_path, audit_phase }` | PASS |
| completion | `{ workflow_state }` | lifecycle event |

## Operating Protocol

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

- [ ] 2. (**orchestrator**) Research — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_1`
  - Expected: evidence_artifacts in research output

- [ ] 3. (**inline**) Z3 check — `solve check` verify research output contains evidence_artifacts per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:research`
  - Chain: `step_2`

- [ ] 4. (**orchestrator**) Readiness — orchestrator dispatches via SKILL.md Trigger Dispatch Table. The readiness gate MUST read `sc-pipeline-readiness.yaml` created by an independent sub-agent (pipeline-readiness-gate task), NOT by the orchestrator. If the file was created by the orchestrator (same session, no sub-agent dispatch), the gate MUST return BLOCKED.
  - Chain: `step_3`
  - Expected: status PASS in readiness output

- [ ] 4a. (**orchestrator**) Artifact validation — orchestrator dispatches via SKILL.md Trigger Dispatch Table. Validates that all spec-creation analytical artifacts exist, are non-empty, and are well-formed YAML. This step MUST execute before structure step to ensure all required artifacts are available.
  - Chain: `step_4`
  - Expected: PASS in artifact-validation output; if BLOCKED, pipeline halts with `MISSING_SPEC_ARTIFACT`

- [ ] 5. (**inline**) Z3 check — `solve check` verify readiness output has status PASS per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:readiness`
  - Chain: `step_4a`

- [ ] 6. (**orchestrator**) Structure — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_5`
  - Expected: phase definitions and dependency contract in structure output

- [ ] 7. (**inline**) Z3 check — `solve check` verify structure output has phase definitions and dependency contract per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:structure`
  - Chain: `step_6`

- [ ] 8. (**orchestrator**) Solve — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_7`
  - Expected: SAT and SOLVED status in solve output

- [ ] 9. (**inline**) Z3 check — `solve check` verify solve output has SAT and SOLVED status per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:solve`
  - Chain: `step_8`

- [ ] 9a. (**orchestrator**) Plan creation pipeline — orchestrator dispatches to `plan-creation-pipeline` skill via SKILL.md Trigger Dispatch Table. This step replaces the bare inspection with a Z3-verified 6-step pipeline (spec-to-plan-handoff, plan-create, solve-model, solve-check, plan-plan, plan-completion).
  - Chain: `step_9`
  - Context passed: `{ spec_issue_number, structure_output }`
  - Expected: plan file path in pipeline output
  - **Solve gate:** The pipeline includes Z3 verification at each transition (solve-model, solve-check, plan-plan) per `plan-creation-pipeline` SKILL.md

- [ ] 10. (**orchestrator**) Write — orchestrator dispatches via SKILL.md Trigger Dispatch Table. **Post-dispatch file verification:** After the sub-agent returns DONE with a file path, run `ls` or `file-exists` to confirm the file exists on disk. If the file does not exist, re-task clean-room (do not accept the empty result).
  - Chain: `step_9a`
  - Expected: plan file path in write output
  - **Behavioral SC requirement:** The write sub-agent MUST generate phase exit criteria for behavioral SCs that include both `behavior_run` artifact generation AND `behavioral-test-evaluation` clean-room dispatch steps. Each SC in the exit criteria MUST carry an `evidence_type` metadata annotation (e.g., `evidence_type: behavioral`). The VbC section for behavioral SCs MUST include a mandatory gate: after artifact generation, dispatch `behavioral-test-evaluation` before allowing PASS verdict.

- [ ] 11. (**orchestrator**) Clean-room plan generation — **MANDATORY GATE — MUST NOT be skipped.** orchestrator dispatches via SKILL.md Trigger Dispatch Table with spec body only, no existing plan context. The orchestrator MUST NOT proceed past Step 10 without dispatching Step 11. If Step 11 is skipped, the pipeline MUST halt.
  - Chain: `step_10`
  - Expected: clean_room_plan in output

- [ ] 12. (**inline**) Z3 check — `solve check` verify clean-room plan output contains clean_room_plan per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:write`
  - Chain: `step_11`

- [ ] 13. (**orchestrator**) Revisit — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_12`
  - Expected: resolution_status in revisit output

- [ ] 14. (**inline**) Z3 check — `solve check` verify revisit output has resolution_status per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:revisit`
  - Chain: `step_13`

- [ ] 15. (**orchestrator**) Validate — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_14`
  - Expected: PASS status in validate output

- [ ] 16. (**inline**) Z3 check — `solve check` verify validate output has PASS status per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:validate`
  - Chain: `step_15`

- [ ] 17. (**orchestrator**) Audit fidelity — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_16`
  - Expected: PASS in audit-fidelity output

- [ ] 18. (**inline**) Z3 check — `solve check` verify audit-fidelity output has PASS AND `all_criteria_pass == true` per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:audit-fidelity`. If `all_criteria_pass` is `false` or missing, treat as FAIL — orchestrator MUST halt and require remediation before proceeding.
  - Chain: `step_17`

- [ ] 19. (**orchestrator**) Audit concern — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_18`
  - Expected: PASS in audit-concern output

- [ ] 20. (**inline**) Z3 check — `solve check` verify audit-concern output has PASS AND `all_criteria_pass == true` per `.opencode/skills/writing-plans-creation/contracts/create-output-template.yaml:audit-concern`. If `all_criteria_pass` is `false` or missing, treat as FAIL — orchestrator MUST halt and require remediation before proceeding.
  - Chain: `step_19`

- [ ] 21. (**orchestrator**) Completion — orchestrator dispatches via SKILL.md Trigger Dispatch Table
  - Chain: `step_20`
  - Expected: lifecycle event in completion output

- [ ] 22. (**inline**) Z3 check — `solve check` verify completion output has lifecycle event
  - Chain: `step_21`

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)
- **Mandatory step completeness enforced:** All steps in the implementation-pipeline SKILL.md Trigger Dispatch Table MUST be included in the generated plan with correct skill/task references. Plans that omit mandatory steps or use incorrect skill/task names are defective and MUST be rejected at validation. This is non-waivable — no exception for any reason.
- **Analytical artifacts MUST exist:** All 7 analytical artifacts must be present and non-empty at `{project_root}/{path}/.issues/{N}/artifacts/` before plan creation begins:
  - `blast-radius.yaml`
  - `concern-map.yaml`
  - `code-path-inventory.yaml`
  - `cross-cutting-matrix.yaml`
  - `interface-compatibility.yaml`
  - `state-analysis.yaml`
  - `testability-assessment.yaml`
  
  **On missing artifacts:** Before BLOCKING, attempt auto-generation by dispatching `spec-creation/tasks/analytical-artifacts.md` in retroactive mode. If auto-generation succeeds, proceed with plan creation. If auto-generation also fails, return BLOCKED with `MISSING_SPEC_ARTIFACT` and list which artifacts are missing.

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
