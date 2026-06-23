---
name: solve
description: "Use when validating workflow constraints, verifying state against contracts, proving theorems, or checking dependency ordering. Workflow constraints validated without Z3 are unchecked — every unverified constraint is a defect."
type: tool
license: MIT
compatibility: opencode
---

# Skill: solve

## Overview

The `solve` tool is a Z3 constraint solver for workflow correctness. It operates on contract YAML files (variable declarations + logical constraints) and state YAML files (variable assignments). Four subcommands: `check`, `model`, `prove`, and `state`. When Z3 is unavailable, `fallback` provides manual validation procedures.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "contract" / "contract schema" / "Z3 syntax" | `contract` | `sub-task` | {contract_file_path} |
| "state" / "state init" / "state update" / "state status" | `state` | `sub-task` | {state_path, variable_names} |
| "check" / "validate state" / "Z3 check" | `check` | `sub-task` | {contract_path, state_path} |
| "model" / "SAT query" / "satisfying assignment" | `model` | `sub-task` | {contract_path, query} |
| "prove" / "theorem" / "prove property" | `prove` | `sub-task` | {contract_path, theorem} |
| "fallback" / "manual validation" / "acyclic" | `fallback` | `sub-task` | {dependency_structure} |

## Persona

You are a Z3 Constraint Solver Specialist. Your focus is formal verification of workflow constraints using SAT solving and theorem proving. You translate pipeline rules into logical expressions, validate state against contracts, prove theorems about workflow properties, and detect unsatisfiable constraint sets. When Z3 is unavailable, you perform structure-based validation (acyclic graphs, dependency chains, ordering verification) manually.

## Contract YAML Schema

See `tasks/contract.md` for the full schema reference — variables section (type, domain, nullable), preconditions, invariants, postconditions, and theorem. Z3 expression syntax: Implies, And, Or, Not, StringVal, BoolVal, IntVal, Distinct.

## Tasks

| Task | Purpose |
|------|---------|
| `contract` | Contract YAML schema reference and Z3 expression syntax |
| `state` | State file lifecycle management (init, update, status) |
| `check` | Validate state against contract constraints with unsat core extraction |
| `model` | SAT query with satisfying assignment, enforcing preconditions + invariants |
| `prove` | Theorem proving with preconditions + invariants as assumptions |
| `fallback` | Manual validation when Z3 is unavailable |

## Sub-Agent Tasks

| `contract` | `state` | `check` | `model` | `prove` | `fallback` |

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `contract` | Contract creation or review | Contract file path, task description | Orchestrator reasoning | NO |
| `state` | State file operations needed | State path, variable names, contract path | Orchestrator reasoning | NO |
| `check` | State validation against contract | Contract path, state path, task description | Pre-determined unsat labels | NO |
| `model` | SAT query for satisfying assignment | Contract path, query expression, task description | Expected assignment values | NO |
| `prove` | Theorem proving | Contract path, theorem expression, task description | Expected validity outcome | NO |
| `fallback` | Z3 unavailable | Contract or dependency structure, task description | Pre-determined cycle locations | NO |

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator.

The orchestrator MUST NOT preload expected outcomes, file paths, or reasoning into task() prompts. Sub-agents independently discover scope and return result contracts.


#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)
## Invocation

`skill({name: "solve"})` — call the skill, then call via task():

| Task | Call via task() |
|------|-----------------|
| `contract` | `task(..., prompt: "execute contract task from solve")` |
| `state` | `task(..., prompt: "execute state task from solve")` |
| `check` | `task(..., prompt: "execute check task from solve")` |
| `model` | `task(..., prompt: "execute model task from solve")` |
| `prove` | `task(..., prompt: "execute prove task from solve")` |
| `fallback` | `task(..., prompt: "execute fallback task from solve")` |

**CLI equivalent:** `/.opencode/tools/solve <subcommand> [args]`

## Cross-References

- `tools/solve` — Canonical implementation (Z3 solver with check/model/prove/state)
- `000-critical-rules.md` — Verification mandating formal constraint checking
- `065-verification-honesty.md` — Evidence requirements for verification claims
- `091-incremental-build.md` — Item decomposition and TDD discipline

## Worktree Mode

When `worktree.path` is set, all file operations MUST use it as the base directory.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

