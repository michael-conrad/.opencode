# Plan: [#1107](https://github.com/michael-conrad/.opencode/issues/1107) — solve tool: model precondition fix + skill card + behavioral test coverage

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

**Plan structure decision:** separate (multi-task spec with 4 phases across independent concern boundaries)

**Reason:** Phase 1 (tool source fix), Phase 2 (skill card creation), Phase 3 (behavioral tests), and Phase 4 (integration) modify different file categories. Phase 3 is independent of Phase 1 (uses `solve prove`, not `solve model`). Phase 4 depends on Phases 2 and 3.

**Implementation checklist:** [`implementation-checklist.md`](implementation-checklist.md) — MUST be followed step-by-step during implementation. Every phase executes the 14-gate implementation pipeline with sub-steps defined in the checklist.

## All-or-Nothing Gate

All SC-1 through SC-11 must PASS for this spec to be complete. Phase gates: Phase N must be complete before Phase N+1 begins. Phase 1 and Phase 3 are independent and may execute in any order relative to each other, but both must precede Phase 4.

---

## Phase 1 — Fix `solve model` precondition assertion

**Concern:** Tool source modification. Files: `.opencode/tools/solve` (function `_action_model`).

**Dependencies:** None (independent from all other phases).

### TDD Items

#### Item 1.1: Modify `_action_model` to assert preconditions + invariants

**RED:** The `_action_model` function loads the contract but does NOT assert preconditions or invariants into the Z3 solver before evaluating `--query`. A contraction contract (`a == True AND a == False`) in preconditions still returns SAT for any query.

**GREEN:** `_action_model` calls solver.add() with contract preconditions and invariants before evaluating `--query`. A contradictory contract returns UNSAT regardless of query. The fix mirrors what `_action_prove` already does.

**Exit criteria:** `solve model` with contradictory preconditions returns UNSAT. Existing queries that inline all constraints still return SAT (no regression). Both verified by behavioral tests.

### Phase 1 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Phase 1 tool change scope is confirmed: only `_action_model` function modified, no other subcommands affected |
| 2 | pre-red-baseline | Pre-modification behavioral tests captured: existing `solve model` queries that inline constraints produce baseline output |
| 3 | red-phase | Behavioral RED test: contradictory contract (`a == True AND a == False` preconditions) → `solve model` returns SAT (current behavior, will fail after GREEN) |
| 4 | red-doublecheck | RED-side SC evidence collected: SC-1 (contradictory returns UNSAT) behavioral test verified as FAIL in current state |
| 5 | green-phase | `_action_model` modified to assert preconditions+invariants before query evaluation |
| 6 | checkpoint-commit | Modified `solve` tool committed with message referencing #1107 |
| 7 | structural-checks | `ruff` and `pyright` pass on `.opencode/tools/solve` |
| 8 | green-doublecheck | SC-1 (contradictory → UNSAT) behavioral test now PASSES; SC-2 (valid contract → SAT) passes; SC-3 (existing inline regression) passes |
| 9 | green-vbc | All Phase 1 SCs verified PASS with behavioral evidence |
| 10 | adversarial-audit | Dual-auditor verification-audit on Phase 1 changes: preconditions loaded before query, no side effects on other subcommands |
| 11 | cross-validate | Cross-family consensus on Phase 1 verification evidence |
| 12 | regression-check | All existing `solve` behavioral tests still pass |
| 13 | review-prep | Review-prep branch artifacts created: compare URL, summary of changes |
| 14 | exec-summary | Push completed, issue comment posted with Phase 1 status |

---

## Phase 2 — Create solve skill card

**Concern:** New skill card directory. Files: `.opencode/skills/solve/SKILL.md`, `.opencode/skills/solve/tasks/{contract,state,check,model,prove,fallback}.md`

**Dependencies:** None (skill card documents existing tool behavior, independent of Phase 1 fix).

### TDD Items

#### Item 2.1: Create `SKILL.md` with trigger keywords and dispatch table

**RED:** Skill dispatch gate does NOT route for `solve`-related keywords (no SKILL.md exists). A prompt like "run solve model" does not trigger a skill dispatch to `solve`.

**GREEN:** `SKILL.md` exists at `.opencode/skills/solve/SKILL.md` with trigger keywords (`solve model`, `solve prove`, `solve check`, `solve state`, `Z3`, `contract validation`), persona, and sub-agent dispatch table.

**Exit criteria:** Behavioral test SC-5: agent dispatches `solve` skill when trigger keywords match. File verified: SC-6 (structural).

#### Item 2.2: Create task files (contract, state, check, model, prove, fallback)

**RED:** Task files do not exist. Any sub-agent dispatched to `solve` has no procedure reference.

**GREEN:** Six task files created under `.opencode/skills/solve/tasks/`:
- `contract.md` — Contract YAML schema reference + Z3 expression syntax (SC-6 string: grep for Implies, And, Or, Not, StringVal, BoolVal, IntVal, Distinct)
- `state.md` — State lifecycle (init → update → status)
- `check.md` — State validation against contract with unsat core extraction
- `model.md` — SAT query procedure
- `prove.md` — Theorem proving procedure
- `fallback.md` — Manual validation procedures when Z3 unavailable (SC-7 string: grep for fallback, acyclic, cycle, dependency)

**Exit criteria:** All six files exist with entry criteria, procedure, and exit criteria sections. Contract task references all Z3 expression syntax keywords. Fallback task documents acyclic graph check and dependency ordering.

### Phase 2 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Skill card scope is confirmed: 6 task files covering all solve subcommands, no overlap with existing skills |
| 2 | pre-red-baseline | `.opencode/skills/` directory surveyed, no duplicate solve-related skills exist |
| 3 | red-phase | Behavioral RED test: agent given "run solve model" prompt does NOT trigger `solve` skill dispatch (no SKILL.md exists) |
| 4 | red-doublecheck | RED-side evidence: no solve SKILL.md in skill deck, no routing to solve |
| 5 | green-phase | `SKILL.md` + all 6 task files created |
| 6 | checkpoint-commit | Skill card directory committed |
| 7 | structural-checks | `pymarkdownlnt` and `mdformat` pass on all new `.md` files |
| 8 | green-doublecheck | SC-4 (behavioral: skill dispatch routes) and SC-5/6/7 (string/structural: file content) verified PASS |
| 9 | green-vbc | All Phase 2 SCs verified |
| 10 | adversarial-audit | Dual-auditor verification-audit: task files have entry/exit criteria, contract task references complete Z3 syntax, fallback procedure documented |
| 11 | cross-validate | Consensus on Phase 2 evidence |
| 12 | regression-check | Existing `solve` behavioral tests unaffected by new skill card |
| 13 | review-prep | Review-prep for Phase 2 files |
| 14 | exec-summary | Push + issue comment |

---

## Phase 3 — Behavioral test for `solve prove`

**Concern:** New behavioral test files. Files: `.opencode/tests/behaviors/`

**Dependencies:** None (independent from Phase 1 — uses `solve prove`, not `solve model`).

### TDD Items

#### Item 3.1: Write behavioral test for valid theorem (SC-8)

**RED:** No behavioral test for `solve prove` exists. Running a valid theorem (preconditions+invariants imply theorem) is untested.

**GREEN:** Behavioral test created at `.opencode/tests/behaviors/` that invokes `solve prove` with a valid theorem and asserts VALID output.

**Exit criteria:** Test script exists and fails RED (no test coverage yet). After GREEN implementation (which is just test creation), test passes.

#### Item 3.2: Write behavioral test for invalid theorem (SC-9)

**RED:** No test for invalid theorem exists.

**GREEN:** Behavioral test created that invokes `solve prove` with an invalid theorem and asserts INVALID output.

**Exit criteria:** Both SC-8 and SC-9 behavioral tests pass.

### Phase 3 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | `solve prove` subcommand is confirmed stable and testable with current tool version |
| 2 | pre-red-baseline | Existing `solve` test directory surveyed for naming patterns and helper conventions |
| 3 | red-phase | Behavioral RED for SC-8: no `solve prove` behavioral test exists (grep returns empty) |
| 4 | red-doublecheck | SC-8 and SC-9 behavioral tests verified as non-existent in current state |
| 5 | green-phase | Both behavioral test scripts created and passing |
| 6 | checkpoint-commit | Test files committed |
| 7 | structural-checks | Test scripts pass shellcheck, follow `.opencode/tests/behaviors/helpers.sh` conventions |
| 8 | green-doublecheck | SC-8 (valid theorem → VALID) and SC-9 (invalid → INVALID) both PASS with behavioral evidence |
| 9 | green-vbc | All Phase 3 SCs verified |
| 10 | adversarial-audit | Dual-auditor: test assertions match spec SC definitions, no false positives |
| 11 | cross-validate | Consensus on Phase 3 |
| 12 | regression-check | Existing `solve` behavioral tests unaffected |
| 13 | review-prep | Review-prep for test files |
| 14 | exec-summary | Push + issue comment |

---

## Phase 4 — Integration

**Concern:** Cross-referencing updates. Files: `.opencode/AGENTS.md` (skill index), referencing SKILL.md and task files.

**Dependencies:** Phase 2 (skill card must exist) and Phase 3 (behavioral tests must be committed).

### TDD Items

#### Item 4.1: Register `solve` skill in AGENTS.md Skill Index (SC-10)

**RED:** AGENTS.md Skill Index table does not list `solve` skill (no row for it).

**GREEN:** `solve` skill added to AGENTS.md Skill Index table with description and trigger keywords.

**Exit criteria:** SC-10: grep for `solve` in AGENTS.md returns the skill index entry.

#### Item 4.2: Update referencing task files to route through solve skill (SC-11)

**RED:** `grep` for inline `./.opencode/tools/solve` invocations in task files returns N hits that reference `solve` directly instead of through the skill.

**GREEN:** Each referencing task file updated to route through `skill({name: "solve"})` dispatch. Inline tool invocations replaced with `solve` skill task calls per the dispatch table in the new SKILL.md.

**Exit criteria:** SC-11: grep for inline `.opencode/tools/solve` in task files returns fewer hits than RED baseline. Each remaining inline invocation confirmed as intentional (e.g., direct `solve` calls from skill task files themselves).

### Phase 4 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | All referencing task files identified: grep for `solve` in `.opencode/skills/*/tasks/*.md` and `.opencode/skills/*/SKILL.md` |
| 2 | pre-red-baseline | Baseline captured: count of inline `.opencode/tools/solve` references in task files |
| 3 | red-phase | Behavioral RED: inline `solve` references exist in task files outside the new solve skill |
| 4 | red-doublecheck | RED-side evidence: inline count confirmed |
| 5 | green-phase | AGENTS.md updated, referencing task files updated to use skill dispatch |
| 6 | checkpoint-commit | Integration changes committed |
| 7 | structural-checks | `pymarkdownlnt` on modified `.md` files |
| 8 | green-doublecheck | SC-10 (grep: AGENTS.md has solve entry) and SC-11 (inline references reduced) verified |
| 9 | green-vbc | All Phase 4 SCs verified |
| 10 | adversarial-audit | Dual-auditor: integration is complete, no orphan inline references, AGENTS.md entry matches SKILL.md triggers |
| 11 | cross-validate | Consensus on Phase 4 |
| 12 | regression-check | All existing behavioral tests still pass |
| 13 | review-prep | Full review-prep for all 4 phases |
| 14 | exec-summary | Final push + issue close comment |

---

## SC-ID Traceability

| SC-ID | Phase | Item | Evidence Type | Verification |
|-------|-------|------|---------------|-------------|
| SC-1 | 1 | 1.1 | behavioral | `opencode-cli run` with test contract |
| SC-2 | 1 | 1.1 | behavioral | `opencode-cli run` with test contract |
| SC-3 | 1 | 1.1 | behavioral | Re-run existing behavioral tests |
| SC-4 | 2 | 2.1 | behavioral | `opencode-cli run` + stderr assertion |
| SC-5 | 2 | 2.2 | structural | File existence verification |
| SC-6 | 2 | 2.2 | string | grep for Z3 expression keywords |
| SC-7 | 2 | 2.2 | string | grep for fallback patterns |
| SC-8 | 3 | 3.1 | behavioral | `opencode-cli run` |
| SC-9 | 3 | 3.2 | behavioral | `opencode-cli run` |
| SC-10 | 4 | 4.1 | string | grep for `solve` in AGENTS.md |
| SC-11 | 4 | 4.2 | string + behavioral | grep + behavioral test |

---

## Z3 Contract Reference

Phase ordering contract: [`.issues/1107/spec-artifacts/dependency-ordering-verification/ordering.yaml`](../dependency-ordering-verification/ordering.yaml)

- All-phases SAT: `z3.And(P1_DONE == True, P2_DONE == True, P3_DONE == True, P4_DONE == True)` → **SAT** (verified)
- Phase ordering invariants: P4 depends on P2 and P3. P1 and P3 are independent.
- Execution order: Phase 1 → Phase 2 → Phase 4; Phase 3 in parallel with Phase 1-2; Phase 4 after Phase 2 and Phase 3 complete.

---

## Spec Gap: All-or-Nothing Gate

The spec (#1107) does not contain an explicit all-or-nothing gate statement in its SC section. The plan declares it above. The spec should be updated to include: "All-or-nothing gate: All SC-1 through SC-11 must PASS for this spec to be complete."

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)