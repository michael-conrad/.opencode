# Plan: [#1108](https://github.com/michael-conrad/.opencode/issues/1108) — plan tool: skill card + behavioral test coverage + integration

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

**Plan structure decision:** separate (multi-task spec with 5 phases across independent concern boundaries)

**Reason:** Phase 1 (tool source fix — `--contract-path`), Phase 1b (tool source fix — stdout routing), Phase 2 (skill card), Phase 3 (behavioral tests), and Phase 4 (integration) modify different file categories. Phases 1 and 1b modify the same tool but different functions — they are independent and may execute in parallel.

**Implementation checklist:** [`implementation-checklist.md`](implementation-checklist.md) — MUST be followed step-by-step during implementation. Every phase executes the 14-gate implementation pipeline with sub-steps defined in the checklist.

## All-or-Nothing Gate

All SC-1 through SC-13 must PASS for this spec to be complete. Phase gates: Phase N must be complete before Phase N+1 begins. Phase 1 and Phase 1b are independent and may execute in parallel. Phase 2 and Phase 3 both require Phase 1 and Phase 1b complete. Phase 4 requires Phase 2 and Phase 3 complete.

## Circularity Note

Phase 1 fixes the `plan` tool (`plan state update --contract-path`). The plan creation process normally validates phase solvability via `./.opencode/tools/plan plan --problem ...` per plan-structure.md Step 5.5. Since Phase 1 is fixing the tool, this plan uses the **fallback manual acyclic check** for its own phase solvability validation. The `plan` tool circularity is explicitly documented in `.opencode/skills/plan/tasks/fallback.md`.

---

## Phase 1 — Fix `plan state update` (`--contract-path`)

**Concern:** Tool source modification. Files: `.opencode/tools/plan` (function `_action_state_update`).

**Dependencies:** None (independent from all other phases).

### TDD Items

#### Item 1.1: Add `--contract-path` argparse argument

**RED:** `plan state update --help` does not list `--contract-path`. Calling `plan state update --contract-path` produces an unrecognized argument error.

**GREEN:** `--contract-path` (`-c`) argparse argument added with optional string value. Also add `--var-type` (`-t`) argparse argument with choices `bool/string/int/real`.

#### Item 1.2: Implement contract-based domain validation

**RED:** `plan state update` stores raw string values without type/domain validation, regardless of arguments.

**GREEN:** When `--contract-path` is provided, `_action_state_update` loads the contract YAML, resolves variable schema (type + domain), coerces values per type, and validates domain membership — mirroring `solve state update --contract-path` behavior. When `--var-type` is provided without a contract, uses the declared type for coercion.

**Exit criteria:** SC-1: `plan state update --contract-path` with domain-limited contract rejects out-of-domain values. SC-2: accepts in-domain values. SC-3: `plan state update` without `--contract-path` works as before.

### Phase 1 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Phase 1 scope confirmed: only `_action_state_update` modified, contract loading mirrors `solve state update` pattern |
| 2 | pre-red-baseline | Pre-modification state: `plan state update` stores raw strings, no `--contract-path` support |
| 3 | red-phase | Behavioral RED: SC-1 (out-of-domain rejected) fails — current tool accepts any value |
| 4 | red-doublecheck | RED-side evidence captured for all Phase 1 SCs |
| 5 | green-phase | `_action_state_update` modified with `--contract-path` and `--var-type` support, domain validation implemented |
| 6 | checkpoint-commit | Modified `plan` tool committed |
| 7 | structural-checks | `ruff` and `pyright` pass on `.opencode/tools/plan` |
| 8 | green-doublecheck | SC-1 (out-of-domain → rejected), SC-2 (in-domain → accepted), SC-3 (no regression) all PASS |
| 9 | green-vbc | All Phase 1 SCs verified with behavioral evidence |
| 10 | adversarial-audit | Dual-auditor: contract loading mirrors solve, no side effects on other subcommands |
| 11 | cross-validate | Consensus on Phase 1 |
| 12 | regression-check | All existing `plan` behavioral tests pass |
| 13 | review-prep | Review-prep artifacts |
| 14 | exec-summary | Push + issue comment |

---

## Phase 1b — Fix `plan discover` stdout output

**Concern:** Tool source modification. Files: `.opencode/tools/plan` (function `_action_discover`).

**Dependencies:** None (independent from Phase 1 — different function within same file).

### TDD Items

#### Item 1b.1: Change `print(name, file=sys.stderr)` to `print(name)` on stdout

**RED:** `plan discover | head -1` produces no stdout output — engine names go to stderr and are invisible to pipes.

**GREEN:** Change `print(name, file=sys.stderr)` to `print(name)` in `_action_discover`. `plan discover | head -1` now outputs engine names on stdout.

**Exit criteria:** SC-4: `plan discover` output can be piped (`plan discover | head -1` returns engine name on stdout).

### Phase 1b Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Scope: single-line change in `_action_discover`, no other functions affected |
| 2 | pre-red-baseline | Verify current behavior: `plan discover | head -1` produces empty stdout |
| 3 | red-phase | Behavioral RED: pipe test fails — no output on stdout |
| 4 | red-doublecheck | RED-side evidence captured for SC-4 |
| 5 | green-phase | `file=sys.stderr` removed, now prints to stdout |
| 6 | checkpoint-commit | Committed (can be same commit as Phase 1 if both modified) |
| 7 | structural-checks | `ruff` on modified file |
| 8 | green-doublecheck | SC-4 (pipe test) PASS |
| 9 | green-vbc | Phase 1b SCs verified |
| 10 | adversarial-audit | Dual-auditor: no other stderr changes, pipe behavior confirmed |
| 11 | cross-validate | Consensus |
| 12 | regression-check | Existing `plan` tests pass |
| 13 | review-prep | Summary |
| 14 | exec-summary | Push |

---

## Phase 2 — Create plan skill card

**Concern:** New skill card directory. Files: `.opencode/skills/plan/SKILL.md`, `.opencode/skills/plan/tasks/{problem,plan,validate,pddl,ground,fallback,state}.md`

**Dependencies:** Phase 1 and Phase 1b complete (skill card must document fixed tool behavior).

### TDD Items

#### Item 2.1: Create `SKILL.md` with trigger keywords and dispatch table

**RED:** No `plan` skill card exists. Skill dispatch gate does not route to `plan`.

**GREEN:** `SKILL.md` at `.opencode/skills/plan/SKILL.md` with trigger keywords (`plan plan`, `plan validate`, `plan ground`, `plan pddl`, `plan discover`, `plan state`, `PDDL`, `phase solvability`), persona (`Planner Router`), and sub-agent dispatch table.

**Exit criteria:** SC-5: behavioral test confirms skill dispatch routes to `plan` skill.

#### Item 2.2: Create task files (problem, plan, validate, pddl, ground, fallback, state)

**RED:** Task files do not exist.

**GREEN:** Seven task files created:
- `problem.md` — Full YAML schema with `domain`, `types`, `objects`, `fluents`, `actions`, `init`, `goals` sections (SC-7: grep for each section keyword)
- `plan.md` — Plan generation procedure, SOLVED_SATISFICING/OPTIMALLY/UNSOLVABLE interpretation
- `validate.md` — Plan validation against domain using SequentialPlanValidator
- `pddl.md` — Bidirectional YAML ↔ PDDL conversion (SC-9: grep for to-pddl and from-pddl)
- `ground.md` — Action schema grounding procedure
- `fallback.md` — Manual acyclic check when planner unavailable (SC-8: grep for acyclic, cycle, dependency)
- `state.md` — State management with contract support (documents `--contract-path` after Phase 1 fix)

**Exit criteria:** SC-6: all 7 files exist. SC-7/8/9: grep patterns confirmed.

### Phase 2 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Skill card scope confirmed: 7 task files, no overlap with solve skill |
| 2 | pre-red-baseline | `.opencode/skills/` surveyed, no duplicate plan-related skill |
| 3 | red-phase | Behavioral RED: agent given "plan plan" prompt does NOT trigger plan skill dispatch |
| 4 | red-doublecheck | RED-side evidence for SC-5 |
| 5 | green-phase | SKILL.md + 7 task files created. State task documents `--contract-path` |
| 6 | checkpoint-commit | Skill card committed |
| 7 | structural-checks | `pymarkdownlnt`, `mdformat` on new `.md` files |
| 8 | green-doublecheck | SC-5 (behavioral: route), SC-6 (structural: files exist), SC-7/8/9 (string: keywords) all PASS |
| 9 | green-vbc | All Phase 2 SCs verified |
| 10 | adversarial-audit | Dual-auditor: task file completeness, schema YAML correctness, fallback procedure documented |
| 11 | cross-validate | Consensus |
| 12 | regression-check | Existing behavioral tests pass |
| 13 | review-prep | Summary |
| 14 | exec-summary | Push + issue comment |

---

## Phase 3 — Behavioral tests

**Concern:** New behavioral test files. Files: `.opencode/tests/behaviors/`

**Dependencies:** Phase 1 and Phase 1b complete (tests exercise fixed tool behavior).

### TDD Items

#### Item 3.1: Behavioral test for `plan discover` (SC-10)

**RED:** No behavioral test for `plan discover` exists.

**GREEN:** Test created at `.opencode/tests/behaviors/` that runs `plan discover`, captures stdout, and asserts at least one engine name is printed on stdout (not stderr).

#### Item 3.2: Behavioral test for `plan state --contract-path` (SC-11)

**RED:** No behavioral test for `plan state init` + `plan state update --contract-path` exists.

**GREEN:** Test created that: runs `plan state init` to create a state file, runs `plan state update --contract-path` with a domain-limited contract, asserts out-of-domain value is rejected.

**Exit criteria:** SC-10: `plan discover` exits 0 and prints to stdout. SC-11: state init succeeds, contract-path enforces domain.

### Phase 3 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Tests exercise Phase 1 and Phase 1b fixes — confirmed tool behavior is stable |
| 2 | pre-red-baseline | Existing test patterns surveyed in `.opencode/tests/behaviors/` |
| 3 | red-phase | Behavioral RED: SC-10 and SC-11 tests fail (fixes not yet implemented) |
| 4 | red-doublecheck | RED-side evidence for both SCs |
| 5 | green-phase | Both test scripts created and passing |
| 6 | checkpoint-commit | Tests committed |
| 7 | structural-checks | Shellcheck on test scripts |
| 8 | green-doublecheck | SC-10 (discover pipe) and SC-11 (state contract) PASS |
| 9 | green-vbc | All Phase 3 SCs verified |
| 10 | adversarial-audit | Dual-auditor: test assertions match spec, no false positives |
| 11 | cross-validate | Consensus |
| 12 | regression-check | Existing behavioral tests pass |
| 13 | review-prep | Summary |
| 14 | exec-summary | Push |

---

## Phase 4 — Integration

**Concern:** Cross-referencing updates. Files: `.opencode/AGENTS.md`, referencing SKILL.md and task files.

**Dependencies:** Phase 2 (skill card exists) and Phase 3 (behavioral tests committed).

### TDD Items

#### Item 4.1: Register `plan` skill in AGENTS.md (SC-12)

**RED:** AGENTS.md Skill Index does not list `plan` skill.

**GREEN:** `plan` skill added to AGENTS.md Skill Index table.

**Exit criteria:** SC-12: grep for `plan` in AGENTS.md returns the skill index entry under the Skill Index table.

#### Item 4.2: Update referencing task files (SC-13)

**RED:** Inline `./.opencode/tools/plan` references exist in task files outside the new plan skill.

**GREEN:** Each referencing task file updated to route through `skill({name: "plan"})` dispatch.

**Exit criteria:** SC-13: inline tool invocations replaced with skill dispatch. Each remaining inline reference confirmed as within the plan skill itself.

### Phase 4 Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | All referencing files identified: grep for `plan` in `.opencode/skills/*/tasks/*.md` |
| 2 | pre-red-baseline | Baseline inline reference count captured |
| 3 | red-phase | Behavioral RED: inline `plan` references outside skill exist |
| 4 | red-doublecheck | Count confirmed |
| 5 | green-phase | AGENTS.md updated, task files updated to skill dispatch |
| 6 | checkpoint-commit | Integration committed |
| 7 | structural-checks | `pymarkdownlnt` on modified `.md` files |
| 8 | green-doublecheck | SC-12 (grep: AGENTS.md entry) and SC-13 (inline refs reduced) PASS |
| 9 | green-vbc | All Phase 4 SCs verified |
| 10 | adversarial-audit | Dual-auditor: no orphan inline references, AGENTS.md entry matches skill triggers |
| 11 | cross-validate | Consensus |
| 12 | regression-check | All existing behavioral tests pass |
| 13 | review-prep | Full review-prep |
| 14 | exec-summary | Final push + issue close comment |

---

## SC-ID Traceability

| SC-ID | Phase | Item | Evidence Type | Verification |
|-------|-------|------|---------------|-------------|
| SC-1 | 1 | 1.2 | behavioral | Test with domain-limited contract |
| SC-2 | 1 | 1.2 | behavioral | Test with domain-limited contract |
| SC-3 | 1 | 1.2 | behavioral | Re-run existing state tests |
| SC-4 | 1b | 1b.1 | behavioral | Bash pipe test: `plan discover \| head -1` |
| SC-5 | 2 | 2.1 | behavioral | `opencode-cli run` + `assert_semantic` |
| SC-6 | 2 | 2.2 | structural | File existence |
| SC-7 | 2 | 2.2 | string | grep for section keywords in problem.md |
| SC-8 | 2 | 2.2 | string | grep for fallback patterns |
| SC-9 | 2 | 2.2 | string | grep for to-pddl and from-pddl |
| SC-10 | 3 | 3.1 | behavioral | Bash pipe capture + assert non-empty stdout |
| SC-11 | 3 | 3.2 | behavioral | Bash script: state init + contract-path enforcement |
| SC-12 | 4 | 4.1 | string | grep for `plan` in AGENTS.md |
| SC-13 | 4 | 4.2 | string + behavioral | grep + semantic check |

---

## Z3 Contract Reference

Phase ordering contract: [`.issues/1108/spec-artifacts/dependency-ordering-verification/ordering.yaml`](../dependency-ordering-verification/ordering.yaml)

- All-phases SAT: `z3.And(P1_DONE == True, P1b_DONE == True, P2_DONE == True, P3_DONE == True, P4_DONE == True)` → **SAT** (verified)
- Phase ordering invariants: P2 depends on P1 and P1b. P3 depends on P1 and P1b. P4 depends on P2 and P3. P1 and P1b are independent (parallelizable).
- Execution order: Phase 1 + Phase 1b (parallel) → Phase 2 + Phase 3 (parallel, after P1+P1b) → Phase 4

---

## Plan Tool Circularity Handling

This plan's Phase 1 fixes the `plan` tool. During plan creation, phase solvability validation via `./.opencode/tools/plan plan --problem ...` is unavailable because:
1. The `plan` tool's `plan` subcommand may exhibit undocumented behavior
2. The PDDL planner may produce unreliable output before the fix

**Resolution:** Phase dependency solvability was validated manually via acyclic graph check:
- P1 → P2: ✓ (tool fix must precede skill card that documents it)
- P1 → P3: ✓ (tool fix must precede behavioral tests that exercise it)
- P1b → P2: ✓ (stdout fix must precede skill card that documents it)
- P1b → P3: ✓ (stdout fix must precede behavioral test that asserts stdout)
- P2 → P4: ✓ (skill card must exist before AGENTS.md registration)
- P3 → P4: ✓ (behavioral tests must exist before confirming integration complete)
- No cycles detected. All phase ordering is valid.

Fallback procedure per `.opencode/skills/plan/tasks/fallback.md` once created.

---

## Spec Gap: All-or-Nothing Gate

The spec (#1108) does not contain an explicit all-or-nothing gate statement in its SC section. The plan declares it above. The spec should be updated to include: "All-or-nothing gate: All SC-1 through SC-13 must PASS for this spec to be complete."

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)