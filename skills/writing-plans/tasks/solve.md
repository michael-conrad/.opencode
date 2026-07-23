# Task: solve

## Purpose

Runs Z3 constraint solving via `tools/solve` for SAT verification and `tools/plan` for ordering validation against the dependency contract.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The dependency contract must exist at `{issues_prefix}/{N}/dependency-contract.yaml`

## Procedure

1. Read the dependency contract from `{issues_prefix}/{N}/dependency-contract.yaml`.
   - If missing: return BLOCKED with `DEPENDENCY_CONTRACT_NOT_FOUND`.
2. Run `./.opencode/tools/solve model --contract-path {issues_prefix}/{N}/dependency-contract.yaml --query sat`.
   - If UNSAT: return BLOCKED with `UNSAT` and the solver output.
3. Run `./.opencode/tools/solve check --contract-path {issues_prefix}/{N}/dependency-contract.yaml --state-path {issues_prefix}/{N}/artifacts/state-analysis.yaml`.
   - If UNSAT: return BLOCKED with `UNSAT` and the solver output.
4. Run `./.opencode/tools/plan plan --contract-path {issues_prefix}/{N}/dependency-contract.yaml --output {issues_prefix}/{N}/artifacts/plan-output.yaml`.
   - If UNSOLVABLE: return BLOCKED with `UNSOLVABLE` and the planner output.
5. Write the solve output to `{issues_prefix}/{N}/artifacts/solve-output.yaml`.
   - Include: solve_status, plan_status, SAT/UNSAT per check, planner result.
6. Return the result contract.

## Exit Criteria

- `tools/solve model` returned SAT
- `tools/solve check` returned SAT
- `tools/plan plan` returned SOLVED_SATISFICING or SOLVED_OPTIMALLY
- The solve output has been written to `{issues_prefix}/{N}/artifacts/solve-output.yaml`
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing SAT status and planner result>"
artifact_path: "<{issues_prefix}/{N}/artifacts/solve-output.yaml>"
blocker_reason: "<reason if BLOCKED>"
```
