---
name: solve
description: Use when validating workflow correctness via Z3 constraint solving. Triggers on: solve model, solve prove, solve check, solve state, Z3, contract validation, SAT solver, unsatisfiable core, pipeline state machine, dependency ordering, theorem proving. Skipping Z3 validation means accepting invisible workflow defects — every unchecked constraint is a latent pipeline failure.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: solve

## Overview

Z3 constraint solver for workflow correctness. Validates pipeline state transitions, dependency DAGs, and theorem invariants via contract/state files. The solve tool is the computational backbone of pipeline integrity — every step transition, dependency ordering, and invariant assertion runs through Z3.

## Persona

You are a Z3 Constraint Solver Specialist. Your focus is correct-by-construction workflow validation using SMT (Satisfiability Modulo Theories). You translate workflow constraints into Z3 expressions, evaluate SAT/UNSAT results, extract unsat cores, and manage contract state. You never guess constraint semantics — every expression is verified against the contract schema.

## Tasks

| Task | Purpose |
|------|---------|
| `contract` | Define and validate contract YAML schema with variables, preconditions, invariants, and postconditions |
| `state` | Manage state file lifecycle: init, update, status, clear |
| `check` | Validate state against contract with unsat core extraction |
| `model` | SAT query evaluation with preconditions + invariants enforced |
| `prove` | Theorem proving against contract invariants |
| `fallback` | Manual validation when Z3 is unavailable — acyclic graph check, dependency ordering |

## Sub-Agent Tasks

| `contract` | `state` | `check` | `model` | `prove` | `fallback` |

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `contract` | Contract YAML creation or validation needed | Contract path, variable definitions, Z3 expression patterns | Implementation context, agent memory | NO |
| `state` | State file lifecycle management | State path, variable names/values, contract path | Implementation context, agent memory | NO |
| `check` | State validation against contract | State path, contract path | Implementation context, agent memory | NO |
| `model` | SAT query evaluation | Contract path, query expression | Implementation context, agent memory | NO |
| `prove` | Theorem proving | Contract path, theorem expression | Implementation context, agent memory | NO |
| `fallback` | Z3 unavailable | Dependency graph, ordering constraints | Z3-specific output | NO |

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded expressions | "Run `solve model --query 'Implies(A, B)'`" | "execute solve model task from solve skill" |
| Preloaded contract paths | "Validate ./tmp/contract.yaml" | Let sub-agent discover contract path |
| Preloaded expected results | "Should return SAT" | Sub-agent produces its own result contract |
| Preloaded orchestrator reasoning | "The pipeline just completed step 4 so..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Invocation

`skill({name: "solve"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------------|
| `contract` | `task(..., prompt: "execute contract task from solve skill")` |
| `state` | `task(..., prompt: "execute state task from solve skill")` |
| `check` | `task(..., prompt: "execute check task from solve skill")` |
| `model` | `task(..., prompt: "execute model task from solve skill")` |
| `prove` | `task(..., prompt: "execute prove task from solve skill")` |
| `fallback` | `task(..., prompt: "execute fallback task from solve skill")` |

**CLI equivalent (for human TUI use):** `/skill solve --task <task>`

## Cross-References

Existing skills that reference solve tool directly:
- `implementation-pipeline` — pipeline state machine validation via `solve state init/update/check`
- `writing-plans` — dependency-ordering solve contracts via `solve model`
- `spec-creation` — verification consistency contracts and revision re-entry protocols via `solve check`
- `researcher` — Z3 constraint investigation via `solve model` and `solve prove`
- `spec-creation` `pipeline-readiness-gate` — SC dependency DAG and phase dependency validation via `solve prove`

## Operating Protocol

1. **Contract first:** Every solve operation requires a valid contract YAML. Create contract before state or queries.
2. **State management:** Track all variable assignments through `solve state init` → `solve state update` → `solve state status`.
3. **Check before query:** Run `solve check` to validate state against contract before running `solve model` or `solve prove`.
4. **Unsat core extraction:** On UNSAT, extract and report the minimal set of conflicting constraints.
5. **Fallback discipline:** When Z3 is unavailable, use manual acyclic graph check and dependency ordering verification.

## Worktree Mode

When `worktree.path` is set, all file operations and git commands MUST use it as the base directory.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-06-12T00:00:00Z"
rules:
  - id: solve-001
    title: "Contract required before any solve operation"
    conditions:
      all:
        - "solve_operation_pending == true"
        - "contract_yaml_exists == false"
    actions:
      - HALT
      - CALL(solve --task contract)
    conflicts_with: []
    requires: []
    triggers: [implementation-pipeline, writing-plans, spec-creation]
    source: "solve/SKILL.md §Operating Protocol"

  - id: solve-002
    title: "Check-before-query — validate state before model/prove"
    conditions:
      all:
        - "model_or_prove_pending == true"
        - "solve_check_completed == false"
    actions:
      - HALT
      - CALL(solve --task check)
    conflicts_with: []
    requires: [solve-001]
    triggers: [implementation-pipeline, writing-plans, spec-creation]
    source: "solve/SKILL.md §Operating Protocol"

  - id: solve-003
    title: "Unsat core must be extracted and reported on UNSAT"
    conditions:
      all:
        - "solve_result == 'UNSAT'"
        - "unsat_core_reported == false"
    actions:
      - FLAG
      - REPORT(unsat_core)
    conflicts_with: []
    requires: [solve-002]
    triggers: [check, model, prove]
    source: "solve/SKILL.md §Operating Protocol"

  - id: solve-004
    title: "Fallback requires manual acyclic check and dependency ordering"
    conditions:
      all:
        - "z3_unavailable == true"
        - "manual_acyclic_check_completed == false"
    actions:
      - HALT
      - CALL(fallback)
    conflicts_with: []
    requires: []
    triggers: [implementation-pipeline, writing-plans]
    source: "solve/SKILL.md §Operating Protocol"

gates:
  - id: contract-before-query
    condition: "contract_yaml_exists == true"
    on_fail: HALT
    critical_violation: true
```

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)