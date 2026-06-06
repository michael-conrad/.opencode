# Plan: #980 tools/plan Implementation

## Overview

Implement `.opencode/tools/plan` — PEP 723 CLI utility wrapping `unified-planning` (v1.3.0). Follows `solve` structural pattern: bash guard, PEP 723 header, argparse dispatch, per-action functions.

## Z3 Phase Dependency

Contract at `.issues/980/spec-artifacts/phase-contract.yaml` — 10 phases with strict dependency ordering proved SAT. Postconditions require all 10 phases complete.

Key dependency chain: SKELETON → PARSER → {PLAN_GEN, CYCLE_DET, GROUND, PDDL} → VALIDATE → INTEGRATION. STATE and DISCOVER are standalone (only need SKELETON).

## 14-Step Implementation Pipeline Reference

Each phase below maps to the serial pipeline from #909: SC coherence gate → pre-red baseline → RED → RED doublecheck → GREEN → checkpoint commit → structural checks → GREEN doublecheck → GREEN VbC → adversarial audit → cross-validate → regression check → review prep → exec summary. The pipeline runs per-phase — each phase is one full cycle through the 14 steps.

## Phases

### Phase 1: Skeleton
**RED**: Write behavioral test: `uv run tools/plan --help` exits 0 with usage text (SC-10)

**GREEN**: Create `.opencode/tools/plan` with bash guard, PEP 723 header, SPDX/provenance headers, module docstring, argparse builder with all subcommands stubbed (print "not implemented" + exit 1), `main()` dispatch.

**Files**: `.opencode/tools/plan`

**Depends**: None

### Phase 2: State
**RED**: Behavioral test: `plan state init` creates file; `plan state update` writes var; `plan state status` reads it; `solve state status` reads same file (SC-5, SC-6)

**GREEN**: Implement `_action_state` with `init`, `update`, `status`. Share format with `solve`: YAML with `variables` + `timestamp` keys. Same project-root resolution.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 1

### Phase 3: Parser
**RED**: Behavioral test: `plan plan --problem gripper.yaml` with valid gripper problem → stderr shows engine dispatch + stdout has `- [ ] N.` action list (SC-1). Also test: `plan plan` with malformed YAML → exit 1 + error message.

**GREEN**: Implement `_build_problem()` — convert YAML schema to `unified-planning` `Problem` object. Handle types, objects, fluents, actions with preconditions/effects, init, goals. Implement `_parse_expression()` for simple logical expressions (`fluent(params)`, `not fluent(params)`).

**Files**: `.opencode/tools/plan`

**Depends**: Phase 1

### Phase 4: Plan Generation
**RED**: Behavioral test: `plan plan --problem gripper.yaml --engine tamer` (or default engine) → ordered action sequence in checklist format (SC-1, SC-10)

**GREEN**: Implement `_action_plan()`: import `OneshotPlanner`, call `planner.solve(problem)`, output ordered action sequence as `- [ ] N. action(params)` checklist. Include YAML block with structured plan data. Handle engine selection via `--engine` flag.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 5: Cycle Detection
**RED**: Behavioral test: YAML problem with cyclic action dependency → `plan plan` exits 1 + "cyclic dependency" error (SC-9). Also test: acyclic problem succeeds.

**GREEN**: Build `networkx.DiGraph` from action preconditions/effects. Call `nx.is_directed_acyclic_graph()` before planning. If cyclic: `nx.find_cycle()`, print cycle path, exit 1.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 6: Validate
**RED**: Behavioral test: `validate --problem p.yaml --plan plan.yaml` with valid plan → exit 0 + "valid" (SC-2). With invalid plan (missing goal) → exit 1 + "invalid" (SC-3).

**GREEN**: Implement `_action_validate()`: parse problem YAML to build problem, parse plan YAML to reconstruct action instances. Use `SequentialPlan` + `simulate()`. Check goal satisfaction. On FAIL: identify unreachable goals, print per-goal status.

**Files**: `.opencode/tools/plan`

**Depends**: Phases 3, 4, 5 (parser + plan gen + cycle detection)

### Phase 7: Ground
**RED**: Behavioral test: `ground --problem p.yaml` → outputs grounded action list with no parameterized actions (SC-7).

**GREEN**: Implement `_action_ground()`: use `Grounder` compilation to ground the problem. Output YAML with grounded actions.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 8: PDDL
**RED**: Behavioral test: `pddl --direction to-pddl --input p.yaml` → output parseable by `unified-planning` PDDL reader (SC-8). `pddl --direction from-pddl --input dir/` → YAML output.

**GREEN**: Implement `_action_pddl()`: wrap `PDDLWriter` and `PDDLReader`. `to-pddl`: write domain.pddl + problem.pddl. `from-pddl`: parse PDDL, output YAML schema.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 9: Discover
**RED**: Behavioral test: `discover` → stderr shows engine enumeration (SC-4). If no engines installed, shows "(none found)" message.

**GREEN**: Implement `_action_discover()`: call `engines.available_engines()`, print sorted list.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 1 (skeleton + UP import)

### Phase 10: Integration Test
**RED**: Full pipeline test: write gripper problem YAML → `plan plan` generates plan → `validate` confirms plan valid → `ground` confirms grounded → `pddl to-pddl` roundtrips → `discover` lists engines. End-to-end pass.

**GREEN**: Verify all phases work together. Fix interface mismatches (YAML schema compat between plan and validate output, etc.).

**Files**: `.opencode/tools/plan`

**Depends**: Phases 6, 7, 8, 9 (all major features complete)

## Item Decomposition

| Item | Phase | Action |
|------|-------|--------|
| 1 | 1 | Skeleton: bash guard, PEP 723, argparse stubs, main dispatch |
| 2 | 2 | State: init, update, status (solve-compatible) |
| 3 | 3 | Parser: YAML → unified-planning Problem (build, expression parse) |
| 4 | 4 | Plan gen: OneshotPlanner solve, checklist output |
| 5 | 5 | Cycle detection: networkx DAG check before planning |
| 6 | 6 | Validate: plan reconstruction, simulation, goal checking |
| 7 | 7 | Ground: Grounder compilation, YAML output |
| 8 | 8 | PDDL: to/from PDDL conversion |
| 9 | 9 | Discover: engine enumeration |
| 10 | 10 | Integration: full pipeline E2E test |

## Files Created

- `.opencode/tools/plan` — PEP 723 inline script

## Success Criteria

See spec body SC-1 through SC-10 for the full criteria. Each RED test above maps to one or more SCs.

## State Tracking

Phase state tracked in `.issues/980/spec-artifacts/phase-state.yaml`. Update via `plan state update` or manually after each phase completes.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)