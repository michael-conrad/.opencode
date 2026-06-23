# Task: solve

## Purpose

Run Z3 constraint solving and plan utility validation as direct CLI invocations. Sub-agents are leaf nodes — execute tools directly, never dispatch further sub-agents.

## Entry Criteria

- Structure step completed with phase definitions and dependency contract
- Dependency contract YAML exists

## Exit Criteria

- `solve model` returns SAT
- `solve check` returns SAT
- `plan plan` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY
- Result contract contains solve_status and plan_status

## Procedure

1. Run `./.opencode/tools/solve model --contract-path <path> --query <query>` — confirm SAT
2. Run `./.opencode/tools/solve check --state-path <path> --contract-path <path>` — confirm SAT
3. Run `./.opencode/tools/plan plan --problem <path> --output <path>` — confirm SOLVED
4. If any returns UNSAT or UNSOLVABLE: return BLOCKED with status
5. Return PASS with solve_status and plan_status

## Context Required

- Related skills: `solve`, `plan`
- Related tools: `./.opencode/tools/solve`, `./.opencode/tools/plan`
