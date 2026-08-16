# Task: research

## Purpose

Decompose success criteria into implementation phases, build a dependency DAG between phases, select the skill+task from the implementation-workflow reference card for each phase, and run Z3 constraint solving for SAT verification.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The analysis summary must exist at `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`
- The issue number must be provided
- The project root must be set
- The issues prefix must be set

## Procedure

1. Read the analysis summary from `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`.
2. Extract all success criteria from the analysis summary.
3. Group related SCs into phases based on concern boundaries and implementation dependencies.
4. Build a dependency DAG between phases:
   - Identify which phases depend on the output of other phases
   - Record the dependency edges in the structure artifact
5. For each phase, map SCs to items by reading `sc-summary.yaml` and creating one item per SC:
   - Read the implementation-workflow reference card at `skills/writing-plans/reference/implementation-workflow.md`
   - Map each SC to an individual item with its own RED/GREEN/verify/commit cycle
   - Each item references exactly one SC-ID
6. Verify triplet co-location: for each SC, confirm that its RED, GREEN, and COMMIT steps are all assigned to the same phase. If any SC has steps split across phases, return BLOCKED with reason `"TRIPLET_SPLIT: SC-N has RED in phase X and GREEN in phase Y"`.
7. Verify cross-phase dependency: for each phase, check whether any RED test depends on SC output that is not yet committed in the same phase. A RED test in phase X that depends on SC-M output from phase Y (where Y > X) is a cross-phase dependency violation. If found, return BLOCKED with reason `"CROSS_PHASE_DEP: SC-N RED in phase X depends on SC-M output from phase Y"`.
8. Write the structure artifact to `{issues_prefix}/{N}/artifacts/structure.yaml`:
   - Phase list with SC assignments
   - Dependency DAG edges
   - Skill+task selection per phase
9. Generate the dependency contract from the interface-compatibility artifact:
   - Read `{issues_prefix}/{N}/artifacts/interface-compatibility.yaml`.
   - Extract the `dependency_contract` section.
   - Write the extracted contract to `{issues_prefix}/{N}/dependency-contract.yaml`.
   - If `interface-compatibility.yaml` is missing or has no `dependency_contract` section: return BLOCKED with `DEPENDENCY_CONTRACT_NOT_FOUND`.
10. Run `./.opencode/tools/solve model --contract-path {issues_prefix}/{N}/dependency-contract.yaml --query sat`.
    - If UNSAT: return BLOCKED with `UNSAT` and the solver output.
11. Run `./.opencode/tools/solve check --contract-path {issues_prefix}/{N}/dependency-contract.yaml --state-path {issues_prefix}/{N}/artifacts/state-analysis.yaml`.
    - If UNSAT: return BLOCKED with `UNSAT` and the solver output.
12. Run `./.opencode/tools/plan plan --contract-path {issues_prefix}/{N}/dependency-contract.yaml --output {issues_prefix}/{N}/artifacts/plan-output.yaml`.
    - If UNSOLVABLE: return BLOCKED with `UNSOLVABLE` and the planner output.
13. Write the solve output to `{issues_prefix}/{N}/artifacts/solve-output.yaml`.
    - Include: solve_status, plan_status, SAT/UNSAT per check, planner result.
14. Return the result contract.

## Exit Criteria

- The structure artifact has been written to `{issues_prefix}/{N}/artifacts/structure.yaml`
- The artifact contains phase decomposition, dependency DAG, and skill+task selection
- `tools/solve model` returned SAT
- `tools/solve check` returned SAT
- `tools/plan plan` returned SOLVED_SATISFICING or SOLVED_OPTIMALLY
- The solve output has been written to `{issues_prefix}/{N}/artifacts/solve-output.yaml`
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing phase decomposition, SAT status, and planner result>"
artifact_path: "<path to structure.yaml on disk>"
blocker_reason: "<reason if BLOCKED>"
```
