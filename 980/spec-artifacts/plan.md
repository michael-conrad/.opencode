# Plan: #980 tools/plan Implementation

## Overview

Implement `.opencode/tools/plan` — PEP 723 CLI utility wrapping `unified-planning` (v1.3.0). Follows `solve` structural pattern: bash guard, PEP 723 header, argparse dispatch, per-action functions.

## Z3 Phase Dependency

Contract at `.issues/980/spec-artifacts/phase-contract.yaml` — 10 phases with strict dependency ordering proved SAT. Postconditions require all 10 phases complete.

Key dependency chain: SKELETON → PARSER → {PLAN_GEN, CYCLE_DET, GROUND, PDDL} → VALIDATE → INTEGRATION. STATE and DISCOVER are standalone (only need SKELETON).

## Pure PASS Rule (Hard Gate)

**Anything other than a clean, no-caveat PASS is automatically a FAIL.** This applies at every gate in the pipeline:

| Verdict | Classification | Action |
|---------|---------------|--------|
| PASS | Clean pass, no caveats, no notes, no concerns | Proceed |
| PASS with notes | FAIL — notes mean something was noticed | Remediate |
| PASS with concerns | FAIL — concerns mean something may be wrong | Remediate |
| Functionally equivalent | FAIL — equivalence is not identity | Remediate |
| INCONCLUSIVE | FAIL — inconclusive is not PASS | Remediate |
| PASS with minor issues | FAIL — issues are not clean | Remediate |
| Advisory PASS | FAIL — advisory is not binding | Remediate |

**There is no third option between PASS and FAIL.** INCONCLUSIVE is not a valid gate verdict. "Close enough" is never PASS. The agent MUST NOT proceed past a non-PASS verdict — it MUST remediate and re-run the gate.

This rule is enforced at: RED doublecheck, GREEN doublecheck, GREEN VbC, adversarial audit, cross-validate, and regression check.

## Remediation Loop (Mandatory)

Every gate that returns FAIL triggers a remediation loop. The loop type depends on which gate failed and the scope of the failure:

| Gate | FAIL → Remediation Scope | Target |
|------|-------------------------|--------|
| RED doublecheck | RED was wrong or incomplete | Re-do RED phase |
| GREEN doublecheck | GREEN didn't make RED pass | Re-do GREEN phase |
| Structural checks | Lint/typecheck errors | Re-do GREEN phase (fix code) |
| GREEN VbC | SC not fully met | Re-do GREEN phase |
| Adversarial audit | Quality defects found | Re-do GREEN phase (or plan if spec gap) |
| Cross-validate | VbC and audit disagree | Investigate gap, re-do affected phase |
| Regression check | Something broke | Re-do GREEN phase |

**The orchestrator MUST NOT proceed past a FAIL gate.** The only valid actions on FAIL are:
1. Diagnose root cause (read failure evidence)
2. Remediate (re-task the failed phase's sub-agent with failure context)
3. Re-verify (re-run the gate that failed)
4. If re-verification also FAILs: report double-failure with both evidence artifacts

## 14-Step Implementation Pipeline Reference

Each phase below runs as one full cycle through the 14-step serial pipeline. The gate loop is:

```
SC coherence gate → pre-red baseline → RED → RED doublecheck
  → (FAIL → remediate RED) → (PASS → continue)
  → GREEN → checkpoint commit → structural checks → GREEN doublecheck
  → (FAIL → remediate GREEN) → (PASS → continue)
  → GREEN VbC → adversarial audit → cross-validate → regression check
  → (any FAIL → remediate) → (all PASS → continue)
  → review prep → exec summary → HALT
```

At EVERY gate (RED doublecheck, GREEN doublecheck, structural, VbC, audit, cross-validate, regression), the only PASS that counts is a clean, no-caveat PASS. Everything else is FAIL → remediate.

## Phases

### Phase 1: Skeleton
**RED**: Write behavioral test: `uv run tools/plan --help` exits 0 with usage text (SC-10)

**RED doublecheck**: Verify test actually FAILs (tool doesn't exist yet). If test passes for wrong reason (e.g., wrong command), remediate RED.

**GREEN**: Create `.opencode/tools/plan` with bash guard, PEP 723 header, SPDX/provenance headers, module docstring, argparse builder with all subcommands stubbed (print "not implemented" + exit 1), `main()` dispatch.

**GREEN doublecheck**: Verify RED test now passes. If RED test still fails, remediate GREEN (fix the implementation, not the test).

**Files**: `.opencode/tools/plan`

**Depends**: None

### Phase 2: State
**RED**: Behavioral test: `plan state init` creates file; `plan state update` writes var; `plan state status` reads it; `solve state status` reads same file (SC-5, SC-6)

**RED doublecheck**: Verify test FAILs (state not implemented yet). Legitimate FAIL or broken test harness? If broken harness, remediate RED.

**GREEN**: Implement `_action_state` with `init`, `update`, `status`. Share format with `solve`: YAML with `variables` + `timestamp` keys. Same project-root resolution.

**GREEN doublecheck**: Verify RED test passes clean (no caveats, no edge cases flagged). If any SC not met, remediate GREEN.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 1

### Phase 3: Parser
**RED**: Behavioral test: `plan plan --problem gripper.yaml` with valid gripper problem → stderr shows engine dispatch + stdout has `- [ ] N.` action list (SC-1). Also test: `plan plan` with malformed YAML → exit 1 + error message.

**RED doublecheck**: Verify test FAILs. If plan parser partially works from skeleton imports, test may need adjustment — but do NOT weaken the assertion.

**GREEN**: Implement `_build_problem()` — convert YAML schema to `unified-planning` `Problem` object. Handle types, objects, fluents, actions with preconditions/effects, init, goals. Implement `_parse_expression()` for simple logical expressions (`fluent(params)`, `not fluent(params)`).

**GREEN doublecheck**: Verify RED test passes clean. Pure PASS only.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 1

### Phase 4: Plan Generation
**RED**: Behavioral test: `plan plan --problem gripper.yaml --engine tamer` (or default engine) → ordered action sequence in checklist format (SC-1, SC-10)

**RED doublecheck**: Verify test FAILs. If engine not installed, test infrastructure issue — remediate (install engine or use default).

**GREEN**: Implement `_action_plan()`: import `OneshotPlanner`, call `planner.solve(problem)`, output ordered action sequence as `- [ ] N. action(params)` checklist. Include YAML block with structured plan data. Handle engine selection via `--engine` flag.

**GREEN doublecheck**: Verify RED test passes clean. If plan output is wrong format or missing steps, remediate GREEN.

**VbC**: Verify SC-1 and SC-10 fully met. If checkpoint format, engine dispatch, or error handling is incomplete, remediate.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 5: Cycle Detection
**RED**: Behavioral test: YAML problem with cyclic action dependency → `plan plan` exits 1 + "cyclic dependency" error (SC-9). Also test: acyclic problem succeeds.

**RED doublecheck**: Verify cyclic test FAILs (no cycle detection), acyclic test may PASS (but that's ok — it should work). If both fail, remediate RED (test is wrong).

**GREEN**: Build `networkx.DiGraph` from action preconditions/effects. Call `nx.is_directed_acyclic_graph()` before planning. If cyclic: `nx.find_cycle()`, print cycle path, exit 1.

**GREEN doublecheck**: Verify cyclic test now passes clean. Verify acyclic test still passes (didn't regress).

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 6: Validate
**RED**: Behavioral test: `validate --problem p.yaml --plan plan.yaml` with valid plan → exit 0 + "valid" (SC-2). With invalid plan (missing goal) → exit 1 + "invalid" (SC-3).

**RED doublecheck**: Verify both tests FAIL (validate not implemented). If one passes for wrong reason (e.g., CLI framework returns 0 by default), remediate RED (fix test isolation).

**GREEN**: Implement `_action_validate()`: parse problem YAML to build problem, parse plan YAML to reconstruct action instances. Use `SequentialPlan` + `simulate()`. Check goal satisfaction. On FAIL: identify unreachable goals, print per-goal status.

**GREEN doublecheck**: Verify valid-plan test passes clean. Verify invalid-plan test passes clean (exit 1, "invalid" message). Pure PASS for both.

**VbC**: Verify SC-2 and SC-3 fully met. If validation is too lenient (false PASS) or too strict (false FAIL), remediate GREEN — fix the goal-checking logic.

**Files**: `.opencode/tools/plan`

**Depends**: Phases 3, 4, 5 (parser + plan gen + cycle detection)

### Phase 7: Ground
**RED**: Behavioral test: `ground --problem p.yaml` → outputs grounded action list with no parameterized actions (SC-7).

**RED doublecheck**: Verify test FAILs.

**GREEN**: Implement `_action_ground()`: use `Grounder` compilation to ground the problem. Output YAML with grounded actions.

**GREEN doublecheck**: Verify RED test passes clean. Verify grounded output has no parameterized actions.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 8: PDDL
**RED**: Behavioral test: `pddl --direction to-pddl --input p.yaml` → output parseable by `unified-planning` PDDL reader (SC-8). `pddl --direction from-pddl --input dir/` → YAML output.

**RED doublecheck**: Verify both directions FAIL.

**GREEN**: Implement `_action_pddl()`: wrap `PDDLWriter` and `PDDLReader`. `to-pddl`: write domain.pddl + problem.pddl. `from-pddl`: parse PDDL, output YAML schema.

**GREEN doublecheck**: Verify to-pddl roundtrip works (write then read back). Verify from-pddl produces valid YAML. Pure PASS only.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 3 (parser)

### Phase 9: Discover
**RED**: Behavioral test: `discover` → stderr shows engine enumeration (SC-4). If no engines installed, shows "(none found)" message.

**RED doublecheck**: Verify test FAILs (discover not implemented). If engines happen to be installed and discover accidentally works via some default output, remediate RED (test needs to be more specific).

**GREEN**: Implement `_action_discover()`: call `engines.available_engines()`, print sorted list.

**GREEN doublecheck**: Verify RED test passes clean. Verify output lists at least the expected message format.

**Files**: `.opencode/tools/plan`

**Depends**: Phase 1 (skeleton + UP import)

### Phase 10: Integration Test
**RED**: Full pipeline test: write gripper problem YAML → `plan plan` generates plan → `validate` confirms plan valid → `ground` confirms grounded → `pddl to-pddl` roundtrips → `discover` lists engines. End-to-end pass.

**RED doublecheck**: Verify test FAILs or produces wrong results for at least some steps.

**GREEN**: Verify all phases work together. Fix interface mismatches (YAML schema compat between plan and validate output, etc.).

**GREEN doublecheck**: Full pipeline produces clean PASS on E2E test.

**VbC**: Verify ALL SC-1 through SC-12 passing. Any SC with caveats, notes, or concerns = FAIL.

**Adversarial audit**: Independent auditor reviews implementation. Finds any defect → FAIL → remediate GREEN.

**Cross-validate**: VbC evidence vs audit findings. If they disagree → investigate and remediate.

**Regression check**: Verify nothing previously working is now broken. If regression → remediate GREEN.

**Files**: `.opencode/tools/plan`

**Depends**: Phases 6, 7, 8, 9 (all major features complete)

## Remediation Scope Decision

When any gate produces FAIL, the orchestrator tasks a remediation-scope sub-agent that receives the failure evidence and determines:

| Scope | When | Action |
|-------|------|--------|
| **implementation only** | Failure is in GREEN output (wrong code, missing feature) | Re-task the phase's GREEN step with failure evidence |
| **plan + implementation** | Failure reveals plan gap (SCs incomplete, wrong phases) | Revise plan, re-task from RED |
| **spec + plan + implementation** | Failure reveals spec gap (requirement missed) | Revise spec + plan, re-task from RED |

The orchestrator NEVER makes this determination inline — it tasks a clean-room sub-agent that receives only the failure evidence and returns a scope recommendation.

## Fail-Closed on UNKNOWN (Hard Gate)

Any gate that returns UNKNOWN, times out, or cannot execute (infrastructure failure, model unavailable, test harness broken) is treated as FAIL. Exceptions:
- If the gate is a behavioral test and the model is genuinely unavailable after 2+ remediation attempts (alternative model, timeout increase, infrastructure check): report FAIL with escalation — do NOT skip the gate.

**There is no valid path from "gate cannot execute" to PASS.**

## Pure PASS Verification Checklist (Mandatory per Gate)

Before any gate can report PASS, the verifier MUST check:
- [ ] No caveats, notes, concerns, or advisory language in the result
- [ ] No "functionally equivalent" or "close enough" rationalization
- [ ] No INCONCLUSIVE substitute for PASS
- [ ] All evidence artifacts are tool-call results (not memory, not training data)
- [ ] The PASS is for the correct SC — not a different SC that happens to pass

If any check fails → the verdict is FAIL, not PASS.

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

See spec body SC-1 through SC-12 for the full criteria. Each RED test above maps to one or more SCs. Each SC requires pure PASS — no caveats.

## State Tracking

Phase state tracked in `.issues/980/spec-artifacts/phase-state.yaml`. Update via `plan state update` or manually after each phase completes.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)