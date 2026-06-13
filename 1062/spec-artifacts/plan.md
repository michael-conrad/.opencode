# [SPEC] Plan — Handoff Gates: Spec-to-Plan, Plan-to-Pipeline, SC Close-Out, Revision Re-Entry

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

**Issue:** [#1062](https://github.com/michael-conrad/.opencode/issues/1062)
**Decomposition Classification:** single-task (one spec, one concern: handoff integrity verification)
**Plan Structure:** combined (spec body absorbs plan content — single phase, single concern)
**Authorization Scope:** `for_pr` — auto-approves plan, auto-creates PR
**Halt At:** `pr_created`
**PR Strategy:** stacked

---

## Phase 1: Handoff Gate Task Creation

**Concern:** Add four mandatory verification gates to the plan-writing and pipeline-execution workflow that validate handoff integrity between pipeline stages.

**Files:**
- `writing-plans/tasks/handoffs/spec-to-plan.md` (new)
- `implementation-pipeline/tasks/pre-flight-handoff.md` (new)
- `implementation-pipeline/tasks/sc-closeout.md` (new)
- `writing-plans/tasks/create.md` (update entry criteria)
- `implementation-pipeline/SKILL.md` (update pre-flight section)

**SCs covered:** SC-1 through SC-20 (all 20)

### Item A: Create `writing-plans/tasks/handoffs/spec-to-plan.md`

**SC-ID mapping:** SC-3, SC-4, SC-5, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16

**RED condition:** No spec-to-plan handoff task file exists at `writing-plans/tasks/handoffs/spec-to-plan.md`. The plan author has no structured procedure to verify spec artifacts before writing a plan.

**GREEN condition:** A task file at `writing-plans/tasks/handoffs/spec-to-plan.md` must exist and contain artifact enumeration, YAML validation, manifest write, precondition checks, risk cross-reference validation, decision ledger contradiction check, and decomposition consistency validation.

**Per-unit pipeline gate table:**

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Item A's SCs (SC-3,4,5,11,12,13,14,15,16) are internally consistent and complete for this item |
| 2 | pre-red-baseline | Full test suite PASSes before any changes |
| 3 | red-phase | Enforcement test at permanent path → run → FAIL (exit non-zero) — output to `./tmp/1062/artifacts/item-a-test-output.log` |
| 4 | red-doublecheck | RED evidence artifact exists and shows non-zero exit |
| 5 | green-phase | Implement `writing-plans/tasks/handoffs/spec-to-plan.md` → run test → PASS (exit 0) |
| 6 | checkpoint-commit | `git commit -m "phase 1 item A checkpoint"` with test + change |
| 7 | structural-checks | Lint, format, typecheck on changed files |
| 8 | green-doublecheck | GREEN evidence artifact exists and shows exit 0 |
| 9 | green-vbc | VbC against Item A's SCs (SC-3,4,5,11,12,13,14,15,16) — all PASS |
| 10 | adversarial-audit | plan-fidelity + concern-separation audits PASS for Item A |
| 11 | cross-validate | Dual-auditor consensus on all Item A SCs |
| 12 | regression-check | Full test suite PASSes — nothing previously passing is now broken |
| 13 | review-prep | Compare URL verified from session-init, PR body draft for Item A |
| 14 | exec-summary | SC status, artifact paths, byline reported for Item A |

### Item B: Create `implementation-pipeline/tasks/pre-flight-handoff.md`

**SC-ID mapping:** SC-6, SC-7, SC-8, SC-9, SC-17, SC-18

**RED condition:** No plan-to-pipeline handoff task file exists at `implementation-pipeline/tasks/pre-flight-handoff.md`. The pipeline dispatches to sc-coherence-gate with no verification that the plan has RED checkpoints, SC-ID traceability, or approval cascade state.

**GREEN condition:** A task file at `implementation-pipeline/tasks/pre-flight-handoff.md` must exist and contain RED checkpoint validation, SC-ID traceability, manifest write, cross-manifest comparison, approval cascade validation, and verification gate preservation checks.

**Per-unit pipeline gate table:**

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Item B's SCs (SC-6,7,8,9,17,18) are internally consistent and complete for this item |
| 2 | pre-red-baseline | Full test suite PASSes before any changes |
| 3 | red-phase | Enforcement test at permanent path → run → FAIL (exit non-zero) — output to `./tmp/1062/artifacts/item-b-test-output.log` |
| 4 | red-doublecheck | RED evidence artifact exists and shows non-zero exit |
| 5 | green-phase | Implement `implementation-pipeline/tasks/pre-flight-handoff.md` → run test → PASS (exit 0) |
| 6 | checkpoint-commit | `git commit -m "phase 1 item B checkpoint"` with test + change |
| 7 | structural-checks | Lint, format, typecheck on changed files |
| 8 | green-doublecheck | GREEN evidence artifact exists and shows exit 0 |
| 9 | green-vbc | VbC against Item B's SCs (SC-6,7,8,9,17,18) — all PASS |
| 10 | adversarial-audit | plan-fidelity + concern-separation audits PASS for Item B |
| 11 | cross-validate | Dual-auditor consensus on all Item B SCs |
| 12 | regression-check | Full test suite PASSes — nothing previously passing is now broken |
| 13 | review-prep | Compare URL verified from session-init, PR body draft for Item B |
| 14 | exec-summary | SC status, artifact paths, byline reported for Item B |

### Item C: Create `implementation-pipeline/tasks/sc-closeout.md`

**SC-ID mapping:** SC-10

**RED condition:** No SC close-out task file exists at `implementation-pipeline/tasks/sc-closeout.md`. The pipeline's exec-summary step posts completion comments without verifying every SC-ID received a PASS verdict.

**GREEN condition:** A task file at `implementation-pipeline/tasks/sc-closeout.md` must exist and contain exec-summary integration, UNVERIFIED SC blocking, and sc-summary cross-reference patterns.

**Per-unit pipeline gate table:**

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Item C's SC (SC-10) is internally consistent and complete for this item |
| 2 | pre-red-baseline | Full test suite PASSes before any changes |
| 3 | red-phase | Enforcement test at permanent path → run → FAIL (exit non-zero) — output to `./tmp/1062/artifacts/item-c-test-output.log` |
| 4 | red-doublecheck | RED evidence artifact exists and shows non-zero exit |
| 5 | green-phase | Implement `implementation-pipeline/tasks/sc-closeout.md` → run test → PASS (exit 0) |
| 6 | checkpoint-commit | `git commit -m "phase 1 item C checkpoint"` with test + change |
| 7 | structural-checks | Lint, format, typecheck on changed files |
| 8 | green-doublecheck | GREEN evidence artifact exists and shows exit 0 |
| 9 | green-vbc | VbC against Item C's SC (SC-10) — PASS |
| 10 | adversarial-audit | plan-fidelity + concern-separation audits PASS for Item C |
| 11 | cross-validate | Dual-auditor consensus on Item C SC |
| 12 | regression-check | Full test suite PASSes — nothing previously passing is now broken |
| 13 | review-prep | Compare URL verified from session-init, PR body draft for Item C |
| 14 | exec-summary | SC status, artifact paths, byline reported for Item C |

### Item D: Update `writing-plans/tasks/create.md` Entry Criteria

**SC-ID mapping:** SC-1, SC-2, SC-19

**RED condition:** The `writing-plans/tasks/create.md` entry criteria section does not reference spec-to-plan handoff verification as a precondition. The create-and-validate procedure does not reference the handoff-consistency check.

**GREEN condition:** The `writing-plans/tasks/create.md` entry criteria section must include spec-to-plan handoff with PASS condition (SC-1), and the create-and-validate procedure must reference the handoff-consistency check (SC-2, SC-19).

**Per-unit pipeline gate table:**

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Item D's SCs (SC-1,2,19) are internally consistent and complete for this item |
| 2 | pre-red-baseline | Full test suite PASSes before any changes |
| 3 | red-phase | Enforcement test at permanent path → run → FAIL (exit non-zero) — output to `./tmp/1062/artifacts/item-d-test-output.log` |
| 4 | red-doublecheck | RED evidence artifact exists and shows non-zero exit |
| 5 | green-phase | Update `writing-plans/tasks/create.md` entry criteria → run test → PASS (exit 0) |
| 6 | checkpoint-commit | `git commit -m "phase 1 item D checkpoint"` with test + change |
| 7 | structural-checks | Lint, format, typecheck on changed files |
| 8 | green-doublecheck | GREEN evidence artifact exists and shows exit 0 |
| 9 | green-vbc | VbC against Item D's SCs (SC-1,2,19) — all PASS |
| 10 | adversarial-audit | plan-fidelity + concern-separation audits PASS for Item D |
| 11 | cross-validate | Dual-auditor consensus on all Item D SCs |
| 12 | regression-check | Full test suite PASSes — nothing previously passing is now broken |
| 13 | review-prep | Compare URL verified from session-init, PR body draft for Item D |
| 14 | exec-summary | SC status, artifact paths, byline reported for Item D |

### Item E: Update `implementation-pipeline/SKILL.md` Pre-Flight Section

**SC-ID mapping:** SC-20

**RED condition:** The `implementation-pipeline/SKILL.md` pre-flight section does not reference plan-to-pipeline handoff verification before sc-coherence-gate.

**GREEN condition:** The `implementation-pipeline/SKILL.md` pre-flight section must reference plan-to-pipeline handoff AND handoff-consistency check before sc-coherence-gate.

**Per-unit pipeline gate table:**

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Item E's SC (SC-20) is internally consistent and complete for this item |
| 2 | pre-red-baseline | Full test suite PASSes before any changes |
| 3 | red-phase | Enforcement test at permanent path → run → FAIL (exit non-zero) — output to `./tmp/1062/artifacts/item-e-test-output.log` |
| 4 | red-doublecheck | RED evidence artifact exists and shows non-zero exit |
| 5 | green-phase | Update `implementation-pipeline/SKILL.md` pre-flight section → run test → PASS (exit 0) |
| 6 | checkpoint-commit | `git commit -m "phase 1 item E checkpoint"` with test + change |
| 7 | structural-checks | Lint, format, typecheck on changed files |
| 8 | green-doublecheck | GREEN evidence artifact exists and shows exit 0 |
| 9 | green-vbc | VbC against Item E's SC (SC-20) — PASS |
| 10 | adversarial-audit | plan-fidelity + concern-separation audits PASS for Item E |
| 11 | cross-validate | Dual-auditor consensus on Item E SC |
| 12 | regression-check | Full test suite PASSes — nothing previously passing is now broken |
| 13 | review-prep | Compare URL verified from session-init, PR body draft for Item E |
| 14 | exec-summary | SC status, artifact paths, byline reported for Item E |

---

## Phase 1: 14-Item Enumerated Checklist

- [ ] 1. SC-COHERENCE-GATE — **orchestrator routes to pre-analysis**: verify spec SCs are internally consistent and complete for Phase 1
- [ ] 2. PRE-RED-BASELINE — **orchestrator routes to exploration**: run full test suite, confirm all existing tests PASS before any changes
- [ ] 3. RED-PHASE — **orchestrator routes to RED sub-agent**: write enforcement test at permanent path → run → capture output to `./tmp/1062/artifacts/phase1-test-output.log` → expected FAIL (exit non-zero)
- [ ] 4. RED-DOUBLECHECK — **orchestrator inline**: confirm RED evidence artifact exists and shows non-zero exit
- [ ] 5. GREEN-PHASE — **orchestrator routes to GREEN sub-agent (clean-room, receives spec + test path only)**: implement all 5 items (A through E) → run test → capture output → expected PASS (exit 0)
- [ ] 6. CHECKPOINT-COMMIT — **orchestrator inline**: git commit -m "phase 1 checkpoint" with test + change
- [ ] 7. STRUCTURAL-CHECKS — **orchestrator routes to structural sub-agent**: lint, format, typecheck on changed files
- [ ] 8. GREEN-DOUBLECHECK — **orchestrator inline**: confirm GREEN evidence artifact exists and shows exit 0
- [ ] 9. GREEN-VBC — **orchestrator routes to VbC sub-agent**: verification-before-completion against Phase 1's SCs (SC-1 through SC-20)
- [ ] 10. ADVERSARIAL-AUDIT — **orchestrator routes to resolve-models**: dispatches 2 auditors for plan-fidelity + concern-separation
- [ ] 11. CROSS-VALIDATE — **orchestrator inline**: verify dual-auditor consensus on all Phase 1 SCs
- [ ] 12. REGRESSION-CHECK — **orchestrator routes to regression sub-agent**: full test suite, confirm nothing previously passing is now broken
- [ ] 13. REVIEW-PREP — **orchestrator routes to review-prep sub-agent**: compare URL (verified from session-init), PR body draft for Phase 1
- [ ] 14. EXEC-SUMMARY — **orchestrator inline**: read all sub-agent result contracts, produce phase completion report with SC status, artifact paths, byline

---

## Inter-Phase Handoff

Single-phase plan — no inter-phase handoff required. After gate 14:

- Update Z3 state file: `solve state update` with Phase 1 gate states
- Run `solve check`: confirm Phase 1 dependency contract still SAT
- Verify checkpoint tag exists for Phase 1
- Append lifecycle manifest event for Phase 1 completion

---

## Post-All-Phases Sweep

After Phase 1's gate 14:

- [ ] FINISHING CHECKLIST — **orchestrator routes to finishing sub-agent**: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — **orchestrator routes to git-workflow pr-creation**: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — **orchestrator routes to git-workflow cleanup**: delete merged branches, close issues, sync dev

---

## SC-ID Traceability Table

| Plan Item | SC IDs | File |
|-----------|--------|------|
| Item A | SC-3, SC-4, SC-5, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16 | `writing-plans/tasks/handoffs/spec-to-plan.md` |
| Item B | SC-6, SC-7, SC-8, SC-9, SC-17, SC-18 | `implementation-pipeline/tasks/pre-flight-handoff.md` |
| Item C | SC-10 | `implementation-pipeline/tasks/sc-closeout.md` |
| Item D | SC-1, SC-2, SC-19 | `writing-plans/tasks/create.md` |
| Item E | SC-20 | `implementation-pipeline/SKILL.md` |

**Coverage:** 9 + 6 + 1 + 3 + 1 = 20 of 20 SCs. All SCs mapped. No orphan SCs. No SCOPE-CREEP.

---

## Dependency Ordering

**Phase dependency solve contract:** Single phase (Phase 1) — trivially acyclic. Contract exists at `.opencode/.issues/1062/spec-artifacts/dependency-ordering-verification/ordering.yaml`. Z3 prove confirmed VALID (phase_dag_is_acyclic).

**Item dependency ordering within Phase 1:**
- Items A, B, C are independent (new task files, no cross-dependencies)
- Item D depends on Item A (create.md entry criteria references spec-to-plan handoff task)
- Item E depends on Item B (SKILL.md pre-flight references plan-to-pipeline handoff task)
- Items D and E are independent of each other
- Items A, B, C are independent of each other

**Execution order:** A → D, B → E, C (parallelizable: A+B+C in parallel, then D+E in parallel)

---

## Solve and Plan Validation

- `solve check` on dependency contract: SAT confirmed (sc_dag_is_valid, phase_dag_is_acyclic)
- `plan plan` on phase problem: single phase, single concern — SOLVED_SATISFICING

---

**Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)**
