# Implementation Plan — [#1413](https://github.com/michael-conrad/.opencode/issues/1413) — Fix validate.md dispatch markers, add clean-room plan step, update audit-fidelity.md, update write.md

- **Goal:** Fix two broken chains in the plan creation pipeline: (1) validate.md checks marked `(**sub-agent**)` never execute because sub-agents cannot dispatch sub-agents, and (2) audit-fidelity.md cannot run plan-fidelity without a clean-room plan. Deliverable: all 16 validate.md checks changed to `(**inline**)`, clean-room plan generation step inserted into create.md, audit-fidelity.md passes `clean_room_plan` to plan-fidelity, write.md references mandatory pipeline gates.
- **Architecture:** Three sequential phases (Phase 1 independent, Phase 2 independent, Phase 3 depends on Phase 2) plus a post-phase behavioral regression test. Each phase follows the full implementation-pipeline gate sequence.
- **Files:**
  - `writing-plans/tasks/validate.md` — 16 dispatch marker changes: `(**sub-agent**)` → `(**inline**)`
  - `writing-plans/tasks/create.md` — Insert step 11 (clean-room plan generation), renumber steps 12-21 to 13-22
  - `writing-plans/tasks/audit-fidelity.md` — Add `clean_room_plan` to entry criteria, pass as context to plan-fidelity
  - `writing-plans/tasks/write.md` — Add pipeline gate reference to Plan Format Requirements

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
>
> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Global Pre-Phase

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` with evidence-type uplift and substrate classification. Verify spec #1413 and the existing codebase are coherent. **→ All SCs**
- [ ] 2. **Pre-red-baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` for doc-source currency and SC-ID cross-ref traceability. Write solution state file. **→ All SCs**

## Phase 1 — Fix validate.md dispatch markers

**Concern:** All 16 checks in `writing-plans/tasks/validate.md` are marked `(**sub-agent**)` but the validate sub-agent cannot dispatch sub-agents per Mandatory Task Discipline rule 4. Change all 16 dispatch markers to `(**inline**)` so the validate sub-agent executes them directly.

**Files:** `writing-plans/tasks/validate.md`

**SCs:** SC-1

**Dependencies:** None

**Entry:** Global pre-phase complete

**Exit:** All 16 dispatch markers changed, RED/GREEN chain complete, checkpoint committed

- [ ] 3. **RED phase (**sub-agent**).** Dispatch `test-driven-development --task red` — write a behavioral enforcement test that sends a prompt triggering validate and asserts the agent executes the 16 checks inline (not dispatching sub-agents). Test must FAIL because the markers are still `(**sub-agent**)`. **→ SC-1**
- [ ] 4. **Z3 check RED (**inline**).** `solve check` against red-phase output contract. Verify test code exists and execution result is FAIL. **→ SC-1**
- [ ] 5. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` for RED-side SC evidence. **→ SC-1**
- [ ] 6. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1**
- [ ] 7. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` — `git diff --name-only -- src/ | wc -l` must be 0 (RED phase writes tests only, no implementation code). **→ SC-1**
- [ ] 8. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1**
- [ ] 9. **GREEN phase (**sub-agent**).** Dispatch `test-driven-development --task green` — change all 16 dispatch markers in `writing-plans/tasks/validate.md` from `(**sub-agent**)` to `(**inline**)`. Lines 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, 74, 79, 84. **→ SC-1**
- [ ] 10. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract. Verify implementation code exists. **→ SC-1**
- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` — `git diff --name-only -- test/ | wc -l` must be 0 (GREEN phase writes implementation, not tests). **→ SC-1**
- [ ] 12. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1**
- [ ] 13. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` — create git tag per `000-critical-rules.md` §Checkpoint Rollback Exception. **→ SC-1**
- [ ] 14. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` — commit RED test + GREEN implementation together. **→ SC-1**
- [ ] 15. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` — run lint/typecheck/format. **→ SC-1**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` for GREEN-side SC evidence + semantic intent verification. Verify all 16 markers are `(**inline**)` — no `(**sub-agent**)` remains. **→ SC-1**
- [ ] 17. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` — produce VbC completion artifact. **→ SC-1**

#### Phase 1 VbC

- [ ] 18. **VbC (**clean-room**).** Verify SC-1: all 16 checks changed from `(**sub-agent**)` to `(**inline**)`. Read `writing-plans/tasks/validate.md`, grep for `(**sub-agent**)` — must return 0 matches. **→ SC-1**

**Concern transition:** Leaving Phase 1 (validate.md dispatch markers) → entering Phase 2 (clean-room plan step + write.md update). Phase 2 has no dependency on Phase 1.

## Phase 2 — Add clean-room plan step to create.md + update write.md

**Concern:** The 21-step pipeline in `writing-plans/tasks/create.md` has no step between write (step 10) and revisit (step 12) that generates a clean-room plan. Without it, `audit-fidelity` cannot run `plan-fidelity` (which requires `clean_room_plan`). Also, `writing-plans/tasks/write.md` §Plan Format Requirements must reference mandatory pipeline gates.

**Files:** `writing-plans/tasks/create.md`, `writing-plans/tasks/write.md`

**SCs:** SC-2, SC-4

**Dependencies:** None

**Entry:** Phase 1 complete (or parallel start — no dependency)

**Exit:** create.md has step 11 (clean-room plan generation), steps 12-21 renumbered to 13-22. write.md Plan Format Requirements reference mandatory pipeline gates.

- [ ] 19. **RED phase (**sub-agent**).** Dispatch `test-driven-development --task red` — write a behavioral enforcement test that verifies a plan missing mandatory pipeline gates fails validation. Test must FAIL because write.md does not yet reference mandatory pipeline gates. **→ SC-4, SC-5**
- [ ] 20. **Z3 check RED (**inline**).** `solve check` against red-phase output contract. **→ SC-4, SC-5**
- [ ] 21. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` for RED-side SC evidence. **→ SC-4, SC-5**
- [ ] 22. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-4, SC-5**
- [ ] 23. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` — verify no implementation files modified. **→ SC-4, SC-5**
- [ ] 24. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-4, SC-5**
- [ ] 25. **GREEN phase (**sub-agent**).** Dispatch `test-driven-development --task green` — insert step 11 into `writing-plans/tasks/create.md` between step 10 (write) and step 12 (revisit):
  - Step 11: (**sub-agent**) Clean-room plan generation — `task(..., prompt: "execute write task from writing-plans")` with spec body only, no existing plan context
  - Chain: `step_10`
  - Expected: clean_room_plan in output
  - Renumber existing steps 12-21 to 13-22. Update all chain references. **→ SC-2**
- [ ] 26. **GREEN phase (continued) (**sub-agent**).** Dispatch `test-driven-development --task green` — update `writing-plans/tasks/write.md` §Plan Format Requirements to explicitly state that every phase must include the full RED/GREEN chain with all mandatory implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` §Dispatch Routing Table. **→ SC-4**
- [ ] 27. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract. **→ SC-2, SC-4**
- [ ] 28. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` — verify no test files modified. **→ SC-2, SC-4**
- [ ] 29. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-2, SC-4**
- [ ] 30. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-2, SC-4**
- [ ] 31. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep`. **→ SC-2, SC-4**
- [ ] 32. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-2, SC-4**
- [ ] 33. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` — verify create.md has step 11 (clean-room plan generation) and steps are sequentially numbered 1-22. Verify write.md Plan Format Requirements reference mandatory pipeline gates. **→ SC-2, SC-4**
- [ ] 34. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion`. **→ SC-2, SC-4**

#### Phase 2 VbC

- [ ] 35. **VbC (**clean-room**).** Verify SC-2: clean-room plan generation step exists in create.md between write and revisit. Verify SC-4: write.md Plan Format Requirements reference mandatory pipeline gates. **→ SC-2, SC-4**

**Concern transition:** Leaving Phase 2 (create.md + write.md) → entering Phase 3 (audit-fidelity.md). Phase 3 depends on Phase 2's clean-room plan step existing in create.md.

## Phase 3 — Update audit-fidelity.md to pass clean_room_plan

**Concern:** `writing-plans/tasks/audit-fidelity.md` does not accept `clean_room_plan` in its entry criteria and does not pass it as context when dispatching `plan-fidelity`. Without this, the fidelity audit is structurally broken.

**Files:** `writing-plans/tasks/audit-fidelity.md`

**SCs:** SC-3

**Dependencies:** Phase 2 (clean-room plan step must exist in create.md)

**Entry:** Phase 2 VbC PASS

**Exit:** audit-fidelity.md accepts `clean_room_plan` in entry criteria and passes it to plan-fidelity dispatch

- [ ] 36. **RED phase (**sub-agent**).** Dispatch `test-driven-development --task red` — write a behavioral enforcement test that triggers audit-fidelity and verifies it passes `clean_room_plan` to plan-fidelity. Test must FAIL because audit-fidelity.md does not yet accept or pass `clean_room_plan`. **→ SC-3**
- [ ] 37. **Z3 check RED (**inline**).** `solve check` against red-phase output contract. **→ SC-3**
- [ ] 38. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` for RED-side SC evidence. **→ SC-3**
- [ ] 39. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-3**
- [ ] 40. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-3**
- [ ] 41. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-3**
- [ ] 42. **GREEN phase (**sub-agent**).** Dispatch `test-driven-development --task green` — update `writing-plans/tasks/audit-fidelity.md`:
  - Add `clean_room_plan` to entry criteria
  - Pass `clean_room_plan` as context when dispatching `plan-fidelity` **→ SC-3**
- [ ] 43. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract. **→ SC-3**
- [ ] 44. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-3**
- [ ] 45. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-3**
- [ ] 46. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-3**
- [ ] 47. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep`. **→ SC-3**
- [ ] 48. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-3**
- [ ] 49. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` — verify audit-fidelity.md entry criteria includes `clean_room_plan` and the plan-fidelity dispatch passes it as context. **→ SC-3**
- [ ] 50. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion`. **→ SC-3**

#### Phase 3 VbC

- [ ] 51. **VbC (**clean-room**).** Verify SC-3: audit-fidelity.md accepts `clean_room_plan` in entry criteria and passes it to plan-fidelity. **→ SC-3**

**Concern transition:** Leaving Phase 3 (audit-fidelity.md) → entering Post-phase (behavioral regression test). Post-phase depends on all 3 phases.

## Post — Behavioral regression test

**Concern:** Verify that a plan missing mandatory pipeline gates fails validation (regression test). This is a behavioral test that exercises the full pipeline.

**Files:** `.opencode/tests/behaviors/` (new test file)

**SCs:** SC-5

**Dependencies:** Phases 1, 2, 3

**Entry:** All 3 phases VbC PASS

**Exit:** Behavioral regression test passes

- [ ] 52. **GREEN phase (**sub-agent**).** Dispatch `test-driven-development --task green` — write behavioral regression test that sends a prompt to create a plan that omits mandatory pipeline gates, and asserts the plan fails validation. **→ SC-5**
- [ ] 53. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract. **→ SC-5**
- [ ] 54. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**
- [ ] 55. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-5**
- [ ] 56. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. **→ SC-5**
- [ ] 57. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep`. **→ SC-5**
- [ ] 58. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**
- [ ] 59. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` — run the behavioral regression test and verify it PASSes. **→ SC-5**
- [ ] 60. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion`. **→ SC-5**
- [ ] 61. **Collect behavioral evidence (**inline**).** Copy behavioral test artifacts from `./tmp/behavioral-evidence-{scenario}-*/` to `./tmp/{issue-N}/artifacts/` so the adversarial audit can discover them at the expected path. **→ SC-5**

#### Post VbC

- [ ] 62. **VbC (**clean-room**).** Verify SC-5: behavioral regression test exists and passes. **→ SC-5**

## Global Post-Phase

- [ ] 63. **Collect behavioral evidence (**inline**).** Copy behavioral test artifacts from `./tmp/behavioral-evidence-*/` to `./tmp/{issue-N}/artifacts/` so the adversarial audit can discover them at the expected path. **→ All SCs**
- [ ] 64. **Adversarial audit — resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ All SCs**
- [ ] 65. **Adversarial audit — auditor 1 (**sub-agent**).** Dispatch `adversarial-audit --task spec-audit` with auditor_1 subagent type. **→ All SCs**
- [ ] 66. **Adversarial audit — auditor 1 remediate (**inline**).** If non-clean-pass, remediate root cause and restart from step 64. **→ All SCs**
- [ ] 67. **Adversarial audit — auditor 2 (**sub-agent**).** Dispatch `adversarial-audit --task spec-audit` with auditor_2 subagent type. **→ All SCs**
- [ ] 68. **Adversarial audit — auditor 2 remediate (**inline**).** If non-clean-pass, remediate root cause and restart from step 64. **→ All SCs**
- [ ] 69. **Cross-validate (**clean-room**).** Dispatch `adversarial-audit --task cross-validate` with `auditor_artifact_paths` from steps 65-68. **→ All SCs**
- [ ] 70. **Regression check (**clean-room**).** Dispatch `test-driven-development --task patterns` for regression tests. **→ All SCs**
- [ ] 71. **Review-prep (**clean-room**).** Dispatch `git-workflow --task review-prep` to prepare branch for PR. **→ All SCs**
- [ ] 72. **Executive summary (**inline**).** Append lifecycle event to `./tmp/{issue-N}/lifecycle.yaml`. Report completion: phases implemented, SCs verified, branch ready for PR. **→ All SCs**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
>
> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- **C1.** All 16 validate.md checks changed from `(**sub-agent**)` to `(**inline**)` — verified by grep
- **C2.** Clean-room plan generation step exists in create.md between write and revisit — verified by read
- **C3.** audit-fidelity.md accepts `clean_room_plan` in entry criteria and passes it to plan-fidelity — verified by read
- **C4.** write.md Plan Format Requirements reference mandatory pipeline gates — verified by read
- **C5.** Behavioral regression test exists and passes — verified by test execution
- **C6.** All adversarial audits pass (spec-audit, cross-validate)
- **C7.** Regression check passes
- **C8.** Review-prep complete, branch ready for PR
