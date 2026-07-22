# Task: solve

## Purpose

Run Z3 constraint solving and plan utility validation as direct CLI invocations.

## Entry Criteria

- Structure step completed with phase definitions and dependency contract
- Dependency contract YAML exists

## Exit Criteria

- `solve model` returns SAT
- `solve check` returns SAT
- `plan plan` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY
- Result contract contains solve_status and plan_status

## Procedure

- [ ] 1. Run `./.opencode/tools/solve model --contract-path <path> --query <query>` — confirm SAT
- [ ] 2. Run `./.opencode/tools/solve check --state-path <path> --contract-path <path>` — confirm SAT
- [ ] 3. For z3-check steps between RED/GREEN dispatches: run `./.opencode/tools/solve check --state-path <path> --contract-path contracts/<task>-output-template.yaml` — validates the previous step's output conforms to its contract schema
- [ ] 4. Run `./.opencode/tools/plan plan --problem <path> --output <path>` — confirm SOLVED
- [ ] 5. If any returns UNSAT or UNSOLVABLE: return BLOCKED with status
- [ ] 6. Return PASS with solve_status and plan_status

## Context Required

- Related skills: `solve`, `plan`
- Related tools: `./.opencode/tools/solve`, `./.opencode/tools/plan`

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/solve.yaml" |
| blocker_reason | "..." |
