---
title: "[SPEC-FIX] Fix writing-plans skill: task file structure, dispatch markers, contract schemas, and checklist format"
number: 1393
state: open
labels: [spec-fix, skill-card]
created_at: 2026-06-24T20:48:36Z
updated_at: 2026-06-24T20:56:36Z
---

## Parent

https://github.com/michael-conrad/.opencode/issues/1384 — Audit: Skill Card "Use When" Description Compliance

## Problem

The `writing-plans` and `spec-creation` skills' task files have structural defects that cause AI agents to produce non-compliant plans:

1. **Prose pipeline instead of structured dispatch** — The 21-step pipeline in `create.md` is described as prose bullets with template references. The LLM is not a CPU doing machine parsing. Each step must be a structured entry with clear dispatch type, not a long prose string.

2. **Missing nested bullets** — Checkboxed enumerations (`- [ ] N.`) must use nested sub-bullets for additional data (commands, SC references, metadata) instead of shoving everything into a long prose string that is hard to parse.

3. **Dead template references** — Every step in `create.md` references `input:`, `output:`, `template:` paths to YAML contract files that are never loaded by sub-agents. These are dead references that add noise.

4. **Missing contract schemas** — The write sub-agent has no explicit result contract schema. The `create-output-template.yaml` exists but is never referenced in the dispatch flow. Sub-agents need explicit schemas for what they return.

5. **Missing dispatch markers on all steps** — Not every step in `create.md`, `write.md`, and `validate.md` is properly marked as `(**inline**)`, `(**clean-room**)`, or `(**sub-agent**)`. This applies to ALL skill task cards and the skill card itself.

6. **Missing Trigger Dispatch Table in `create.md`** — The `create.md` task file has no Trigger Dispatch Table. The only dispatch table is in `writing-plans/SKILL.md` which maps "create plan" → `create` → `orchestrator`. The sub-steps (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion) have no table entries — they're described only in prose.

7. **Hard-coded truncated RED/GREEN chain in `write.md`** — `write.md` line 91 hard-codes a 4-step chain (`RED → GREEN → GREEN doublecheck → Checkpoint commit`) that the agent copies verbatim into every plan. This causes the agent to skip 8 mandatory gates (pre-RED baseline, RED doublecheck, post-RED enforcement, post-GREEN enforcement, checkpoint tag create, structural checks, GREEN VbC, plus the entire adversarial audit sequence). Additionally, `write.md` line 65 ("No hardcoded gate sequences") contradicts line 72 ("No omitted mandatory gates"), creating ambiguity the agent resolves by following the more specific instruction (don't copy) and ignoring the general one (must include). The fix is to remove the hard-coded chain and instead instruct the agent to read `implementation-pipeline/SKILL.md` §Dispatch Routing Table as the sole source of truth for the implementation workflow step sequence.

## Requirements

### R1: Convert prose pipeline to structured dispatch table

Replace the 21-step prose pipeline in `create.md` with a proper Trigger Dispatch Table following the standard format (User says / Context, Task, Dispatch, Context passed). Each step must be a table row, not a prose bullet.

### R2: Use nested sub-bullets for step data

Every `- [ ] N.` step must use nested sub-bullets for:
- Commands to execute
- SC references
- Dispatch context
- Expected output/verification

No long prose strings in step titles.

### R3: Fix or remove dead template references

Either make the contract template files actionable (loaded by sub-agents) or remove the `input:`, `output:`, `template:` references from the pipeline description.

### R4: Add missing contract schemas

Add explicit result contract schemas for:
- Write sub-agent (plan file path, SC verification table, dispatch marker validation)
- Validate sub-agent (per-check PASS/FAIL, evidence artifacts)
- Revisit sub-agent (resolution_status, resolved markers)

### R5: Add dispatch markers to ALL steps

Every step in `create.md`, `write.md`, `validate.md`, and `writing-plans/SKILL.md` must have exactly one of `(**inline**)`, `(**clean-room**)`, or `(**sub-agent**)` in the title. This applies to ALL skill task cards and the skill card itself.

### R6: Add Trigger Dispatch Table to `create.md`

Add a formal Trigger Dispatch Table to `create.md` covering all 10 sub-steps (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion).

### R7: Standardize checklist format (from original #1393)

- Dispatch indicator examples in `write.md` must use `- [ ] N.` format
- Phase sections format must explicitly say "checkbox steps (`- [ ] N.`)"
- Validation rule 6 must explicitly say "checkbox steps (`- [ ] N.`)"
- Add validation check 13 to `validate.md`: "All implementation steps use `- [ ] N.` checkbox format"

### R8: Remove hard-coded RED/GREEN chain from write.md

- Remove the hard-coded 4-step chain from `write.md` line 91 (`RED → GREEN → GREEN doublecheck → Checkpoint commit`)
- Remove `write.md` line 65 ("No hardcoded gate sequences") — it contradicts the mandatory-gates rule on line 72
- Add instruction: "Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table. Every phase must contain exactly those steps, in that order, with nothing added and nothing removed."
- Add validation check 14 to `validate.md`: "Every phase contains the full implementation workflow step sequence from `implementation-pipeline/SKILL.md` §Dispatch Routing Table"

### R9: Plan structure with global pre/post and grouped RED/GREEN phases

The plan writer MUST structure plans with three tiers:

1. **Global pre-phase** (once, before all RED/GREEN phases): plan-to-pipeline handoff, handoff-consistency check, SC coherence gate, pre-RED baseline
2. **Per-file RED/GREEN phases** (one per file/concern): each phase contains exactly one RED/GREEN chain starting at RED phase (no SC coherence gate, no pre-RED baseline — those are global). Each phase is self-contained with its own RED → RED doublecheck → post-RED enforcement → GREEN → post-GREEN enforcement → checkpoint tag create → checkpoint commit → structural checks → GREEN doublecheck → GREEN VbC sequence.
3. **Global post-phase** (once, after all RED/GREEN phases): adversarial audit (resolve-models → auditor 1 → remediate → auditor 2 → remediate → cross-validate), regression check, review prep, exec summary

This prevents duplication of global pre/post steps across every file phase while keeping each RED/GREEN chain complete within its phase.

### R11: Dynamic sub-step metadata in write.md

`write.md` MUST specify that each step in a plan includes sub-bullets for dispatch context, SC references, failure conditions, and contract paths — but MUST NOT hard-code template values. The sub-agent writing the plan derives these from the spec, the step's purpose, and the issue context at plan-writing time.

The sub-step metadata requirements in `write.md`:
- **Dispatch context** — derived from the step's role and the issue (e.g., RED phase steps include `{ issue_number }`; GREEN phase steps include `{ issue_number, files, scs }`)
- **SC references** — mapped from the spec's SC table to the phase's concern area
- **Failure conditions** — derived from the step's purpose (e.g., RED steps: "enforcement test does not fail → BLOCKED"; GREEN steps: "implementation does not satisfy SCs → BLOCKED")
- **Contract paths** — derived from the step's output contract in `contracts/<task>-output-template.yaml`

No template values, no hard-coded example content. The writer derives dynamically.

### R12: Add z3-check steps to implementation-pipeline dispatch routing table

The `implementation-pipeline/SKILL.md` §Dispatch Routing Table currently has no z3-check entries. The plan writer reads this table to build the gate sequence for each phase. Without z3-check entries in the table, the writer produces RED/GREEN chains without the interleaved z3-check steps.

Add z3-check entries to the dispatch routing table between each RED/GREEN gate pair:
- `red-phase` → `z3-check-red` → `red-doublecheck` → `z3-check-red-doublecheck` → `post-red-enforcement` → `z3-check-post-red` → `green-phase` → `z3-check-green` → `post-green-enforcement` → `z3-check-post-green`

Each z3-check entry dispatches to `solve check` against the previous step's output contract.

### R13: Failure condition requirements in write.md

`write.md` MUST include a requirement that every RED phase step in a plan includes a failure condition. The failure condition is derived from the step's purpose, not hard-coded:

- RED phase steps: "enforcement test does not fail → BLOCKED"
- GREEN phase steps: "implementation does not satisfy SCs → BLOCKED"
- Other steps: derived from what the step produces

Add validation check 17 to `validate.md`: "Every RED phase step has a failure condition derived from the step's purpose"

### R14: Update solve.md to reference output contract validation

`writing-plans/tasks/solve.md` runs `solve check` against the pipeline state machine and `solve model` against dependency contracts. It MUST also instruct the sub-agent to validate against the relevant output contract from `contracts/<task>-output-template.yaml` when running z3-check steps. Add to the procedure: "For z3-check steps, run `solve check` against the previous step's output contract from `contracts/<task>-output-template.yaml` to verify schema conformance."

### R15: Update structure.md to specify three-tier structure

`writing-plans/tasks/structure.md` defines phase structure but doesn't mention the three-tier organization. The structure step feeds into the write step — if structure doesn't define the three tiers, the write step won't produce them. Add to the exit criteria: "Phase structure uses three-tier organization: global pre-phase, per-file RED/GREEN phases, global post-phase."

### R16: Spec writer must produce spec-to-plan handoff manifest

`spec-creation/tasks/write.md` does not produce the `spec-to-plan-handoff.yaml` manifest that `implementation-pipeline/tasks/pre-flight-handoff.md` checks for. Without it, the pre-flight handoff blocks the pipeline. Add a step to `write.md` that produces `./tmp/{issue-N}/artifacts/spec-to-plan-handoff.yaml` with fields: `sc_coverage_total`, `decomposition_classification`, `phase_count`, `status: PASS`.

### R17: Spec writer sc-summary.yaml schema must match plan writer expectations

`spec-creation/tasks/write.md` Step 16 produces `sc-summary.yaml` with a nested `sc_coverage` root key. The plan writer's pre-flight handoff reads `sc_ids_in_summary` from the file. The schema mismatch means the pre-flight handoff can't find the SC IDs. Align the schema: the sc-summary must include a flat `scs` list with `id`, `description`, `evidence_type`, `verification_gate`, `plan_phase` per SC, matching what the plan writer and pre-flight handoff expect.

### R18: Spec writer must save full spec to local .issues/{N}/spec.md

`spec-creation/tasks/write.md` Step 7b saves `remote-exec-summary.md` but not the full spec content to `.issues/{N}/spec.md`. The plan writer expects to read from `.issues/{N}/spec.md` — the workflows mandate the spec be a local file. Add a step to `write.md` that saves the full spec content to `.issues/{N}/spec.md`.

### R19: Spec writer decompose.md must define three-tier phase structure

`spec-creation/tasks/decompose.md` defines discrete units with interfaces, invariants, and failure modes but doesn't mention the three-tier organization (global pre-phase, per-file RED/GREEN phases, global post-phase). The plan writer's `structure.md` now requires three-tier structure (R15), but the spec writer's `decompose.md` doesn't produce the phase structure the plan writer needs. Add a step to `decompose.md` that defines the three-tier phase structure for multi-phase specs.

### R20: Spec writer pipeline-readiness-gate.md must validate three-tier structure

`spec-creation/tasks/pipeline-readiness-gate.md` validates atomicity (PR-1), dependency ordering (PR-2), single concern (PR-3), and phase dependency (PR-4). It doesn't validate that the phase structure follows three-tier organization. Add PR-5 check: "Phase structure follows three-tier organization: global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once)."

### R21: Spec writer traceability.md must verify SC-to-phase mapping

`spec-creation/tasks/traceability.md` maps requirements to spec sections, tests, and implementation steps but doesn't verify that every SC has a phase binding. The plan writer needs this mapping to assign SCs to phases. Add a check to `traceability.md` Step 2: "Verify every SC in the SC table has a phase binding — SCs without phase binding are flagged as MISSING-PHASE-BINDING."

### R22: Spec writer must run local-issues sync after spec folder changes

The spec is written as a full spec locally at `.issues/{N}/spec.md`, then filed as an exec summary remotely. After creating the spec and any associated files in the `.issues/{N}/` directory, and any time a change is made to any files in the spec folder, the tool `local-issues sync` MUST be run so that the `issues-data` branch is up-to-date. This ensures links in the remote spec that refer to the spec folder work as expected, and downstream consumers (plan writer, auditors) can access the local artifacts via the `issues-data` branch.

Add to `spec-creation/tasks/write.md`: "After creating or modifying any files in `.issues/{N}/`, run `.opencode/tools/local-issues sync` to commit and push the local artifacts to the `issues-data` branch."

### R10: Make contracts actionable with Z3 SAT checking between steps

The 22 contract files in `contracts/` define input/output schemas for each sub-task but are never loaded or validated by any sub-agent. The original intent was for `solve` Z3 SAT checking to enforce that no step is skipped or fabricated. Make them actionable:

- Each sub-agent task file MUST include an instruction: "Load your output contract from `contracts/<task>-output-template.yaml` and validate your output against it before returning"
- Each z3-check step in the pipeline MUST run `solve check` against the previous step's output contract to verify the output conforms to the schema — this catches fabricated or incomplete outputs
- The `create-output-template.yaml` already has compliance enforcement fields (`checklist_step_count`, `phase_count`, `sc_coverage`, `gate_sequence_source`, `admonishment_present`, `dispatch_table_free`, `dispatch_modes_used`). The orchestrator MUST run `solve check` against this contract after the write step to verify plan compliance before proceeding to audit.
- The `write-output-template.yaml` and `validate-output-template.yaml` contracts MUST be expanded to include compliance fields matching what `create-output-template.yaml` already has, so every sub-agent validates its own output before returning.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Gate |
|----|-----------|---------------|-------------------|
| SC-1 | `create.md` has a formal Trigger Dispatch Table covering all 10 sub-steps | `structural` | pre-commit |
| SC-2 | Every `- [ ] N.` step in `create.md`, `write.md`, `validate.md` uses nested sub-bullets for data | `semantic` | pre-PR |
| SC-3 | Dead template references removed or made actionable | `semantic` | pre-PR |
| SC-4 | Write, validate, and revisit sub-agents have explicit result contract schemas | `structural` | pre-commit |
| SC-5 | Every step in `create.md`, `write.md`, `validate.md`, and `writing-plans/SKILL.md` has a dispatch marker | `string` | CI |
| SC-6 | `write.md` dispatch indicator examples use `- [ ] N.` format | `string` | CI |
| SC-7 | `write.md` phase sections format explicitly says "checkbox steps (`- [ ] N.`)" | `string` | CI |
| SC-8 | `write.md` validation rule 6 explicitly says "checkbox steps (`- [ ] N.`)" | `string` | CI |
| SC-9 | `validate.md` has check 13: "All implementation steps use `- [ ] N.` checkbox format" | `string` | CI |
| SC-10 | `plan-fidelity.md` PF-CHECKLIST-FORMAT unchanged (already correct) | `structural` | pre-commit |
| SC-11 | `write.md` does not hard-code any RED/GREEN chain — instead instructs agent to read `implementation-pipeline/SKILL.md` §Dispatch Routing Table as the sole source of truth | `string` | CI |
| SC-12 | `write.md` line 65 ("No hardcoded gate sequences") removed | `string` | CI |
| SC-13 | `validate.md` has check 14: "Every phase contains the full implementation workflow step sequence from `implementation-pipeline/SKILL.md` §Dispatch Routing Table" | `string` | CI |
| SC-14 | `write.md` plan format specifies three-tier structure: global pre-phase (once), per-file RED/GREEN phases (one chain each), global post-phase (once) | `string` | CI |
| SC-15 | `validate.md` has check 15: "Global pre/post steps are not duplicated across per-file phases" | `string` | CI |
| SC-16 | Every sub-agent task file instructs agent to load its output contract from `contracts/<task>-output-template.yaml` and validate output against it before returning | `string` | CI |
| SC-17 | Every z3-check step in the pipeline runs `solve check` against the previous step's output contract to verify schema conformance | `string` | CI |
| SC-18 | `write-output-template.yaml` expanded to include compliance fields: `checklist_step_count`, `phase_count`, `gate_sequence_source`, `admonishment_present`, `dispatch_modes_used`, `global_pre_steps`, `per_file_phases`, `global_post_steps` | `structural` |
| SC-19 | `validate-output-template.yaml` expanded with structured `validation_results` schema with per-check PASS/FAIL | `structural` |
| SC-20 | Orchestrator runs `solve check` against `create-output-template.yaml` after write step to verify plan compliance before proceeding to audit | `behavioral` | pre-commit |
| SC-21 | `write.md` specifies dynamic sub-step metadata (dispatch context, SC references, failure conditions, contract paths) derived from spec and step purpose — no hard-coded template values | `string` | CI |
| SC-22 | `implementation-pipeline/SKILL.md` §Dispatch Routing Table includes z3-check entries between each RED/GREEN gate pair | `structural` | pre-commit |
| SC-23 | `write.md` requires failure conditions on RED phase steps, derived from step purpose | `string` | CI |
| SC-24 | `validate.md` has check 17: "Every RED phase step has a failure condition derived from the step's purpose" | `string` | CI |
| SC-25 | `solve.md` instructs sub-agent to validate against output contract from `contracts/<task>-output-template.yaml` for z3-check steps | `string` | CI |
| SC-26 | `structure.md` exit criteria specify three-tier structure: global pre-phase, per-file RED/GREEN phases, global post-phase | `string` | CI |
| SC-27 | `spec-creation/tasks/write.md` produces `spec-to-plan-handoff.yaml` manifest with `sc_coverage_total`, `decomposition_classification`, `phase_count`, `status` | `structural` | pre-commit |
| SC-28 | `spec-creation/tasks/write.md` sc-summary.yaml schema includes flat `scs` list with `id`, `description`, `evidence_type`, `verification_gate`, `plan_phase` per SC | `string` | CI |
| SC-29 | `spec-creation/tasks/write.md` saves full spec content to `.issues/{N}/spec.md` | `structural` | pre-commit |
| SC-30 | `spec-creation/tasks/decompose.md` defines three-tier phase structure for multi-phase specs | `string` | CI |
| SC-31 | `spec-creation/tasks/pipeline-readiness-gate.md` has PR-5 check for three-tier structure validation | `string` | CI |
| SC-32 | `spec-creation/tasks/traceability.md` verifies every SC has a phase binding | `string` | CI |
| SC-33 | `spec-creation/tasks/write.md` instructs agent to run `local-issues sync` after spec folder changes | `string` | CI |

## References

- `writing-plans/tasks/create.md`
- `writing-plans/tasks/write.md`
- `writing-plans/tasks/validate.md`
- `writing-plans/tasks/solve.md`
- `writing-plans/tasks/structure.md`
- `writing-plans/SKILL.md`
- `writing-plans/contracts/` (all 22 template files)
- `implementation-pipeline/SKILL.md` (§Dispatch Routing Table)
- `spec-creation/tasks/write.md` (spec-to-plan handoff, sc-summary schema, local spec.md)
- `spec-creation/tasks/decompose.md` (three-tier phase structure)
- `spec-creation/tasks/pipeline-readiness-gate.md` (PR-5 three-tier validation)
- `spec-creation/tasks/traceability.md` (SC-to-phase mapping)
- `adversarial-audit/tasks/plan-fidelity.md` (line 100 — correct reference)
- `adversarial-audit/tasks/spec-audit.md` (lines 119-120 — canonical checklist format)
