# Plan: Mandate 16-Gate Dispatch Table Format in Plan Writer

**Issue:** .opencode#1214 — Plan writer produces defective plans
**Spec:** BUG with fix spec in issue body
**Authorization Scope:** `for_pr` | `halt_at: pr_created` | `pr_strategy: stacked`
**Type:** Single-item, single-phase (simple work-of-1)

## Summary

Single-file modification: add an Operating Protocol rule to `.opencode/skills/writing-plans/tasks/create.md` mandating that all plan phases use the 16-gate implementation pipeline dispatch table format as the default.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | create.md Operating Protocol mandates 16-gate dispatch table format as default for all plan phases | string |
| SC-2 | create.md specifies correct dispatch type column values | string |

---

## Pre-Work (before pipeline)

1. Create feature branch from dev: `feature/1214-plan-writer-dispatch-mandate`
2. Tag `.opencode` submodule: `.opencode/.opencode/tags/1214-pre`
3. Initialize pipeline state: `solve state init ./tmp/1214/state/`
4. Set initial state: `solve state update ./tmp/1214/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --var-name previous_step --var-value init --var-name current_step --var-value pre-red-baseline --var-name pipeline_state --var-value running`

---

## Phase 1: Add Dispatch Table Mandate to Plan Writer

**Concern:** Single Operating Protocol rule addition to `create.md`

**Files:** `.opencode/skills/writing-plans/tasks/create.md`

**SCs covered:** SC-1, SC-2

| Gate | Dispatch | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|----------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "sc-coherence-gate"}` | SC-1, SC-2 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "pre-red-baseline"}` | SC-1, SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "red-phase"}` | SC-1, SC-2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "red-doublecheck"}` | SC-1, SC-2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "post-red-enforcement"}` | SC-1, SC-2 |
| G6: green-phase | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "green-phase"}` | SC-1, SC-2 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "post-green-enforcement"}` | SC-1, SC-2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2 |
| G9: structural-checks | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "structural-checks"}` | SC-1, SC-2 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "green-doublecheck"}` | SC-1, SC-2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "green-vbc"}` | SC-1, SC-2 |
| G12: adversarial-audit | sub-task | yes (blind) | sub-agent-auditor pair | `{issue: 1214, phase: 1, audit_phase: green_phase}` | SC-1, SC-2 |
| G13: cross-validate | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "cross-validate"}` | SC-1, SC-2 |
| G14: regression-check | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "regression-check"}` | SC-1, SC-2 |
| G15: review-prep | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "review-prep"}` | SC-1, SC-2 |
| G16: exec-summary | sub-task | yes (blind) | general | `{issue: 1214, phase: 1, task: "exec-summary"}` | SC-1, SC-2 |

### RED Assertions

- **SC-1 RED:** `grep -n "16-gate.*dispatch.*table\|dispatch table format.*default" .opencode/skills/writing-plans/tasks/create.md` — expected to FAIL (no mandate text yet)
- **SC-2 RED:** `grep -n "sub-task\|orchestrator routes to general\|orchestrator inline" .opencode/skills/writing-plans/tasks/create.md` — expected to PASS (dispatch types already present)

### Verification Methods

- **SC-1 (string):** `grep -q "16-gate" .opencode/skills/writing-plans/tasks/create.md` — file must contain dispatch table format mandate
- **SC-2 (string):** `grep -q "orchestrator routes to general\|orchestrator inline\|sub-task" .opencode/skills/writing-plans/tasks/create.md` — file must contain correct dispatch types

### Items

#### Item 1: Add Operating Protocol mandate (SC-1)

Insert new rule into `create.md` Operating Protocol (after existing rule 6) mandating that all plan phases use the 16-gate dispatch table format referencing `implementation-pipeline/SKILL.md` §Dispatch Routing Table.

#### Item 2: Verify dispatch column values (SC-2)

Confirm Dispatch Table section rules already specify correct binary dispatch values (`sub-task`/`inline` + `orchestrator routes to general`/`orchestrator inline`). No change needed if correct.

---

## Post-Implementation

1. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
2. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`
3. Create PR: stacked with #1211