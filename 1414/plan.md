# Implementation Plan — [#1414](https://github.com/michael-conrad/.opencode/issues/1414) — Add one-step-at-a-time protocol admonishment to plan files

**Spec: #1414**

- **Goal:** Add one-step-at-a-time protocol admonishment to plan format requirements and plan-fidelity auditor, with behavioral tests
- **Architecture:** Three-phase additive change: (1) plan template, (2) auditor criteria, (3) behavioral tests
- **Files:**
  - `.opencode/skills/writing-plans/tasks/write.md`
  - `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`
  - `.opencode/tests/behaviors/plan-fidelity-one-step.sh`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Cost frame:** Skipping or combining steps in this phase costs exponentially more than following them. A skipped RED test means the GREEN implementation has no verified failure state — the defect ships to Phase 2 where it costs 10× more to find. Following every step costs minutes. Skipping costs days of rework.

## Phase 1 — Add to plan format

**Concern:** Add one-step-at-a-time protocol admonishment to `write.md` Plan Format Requirements

**Files:** `.opencode/skills/writing-plans/tasks/write.md`

**SCs:** SC-1

**Dependencies:** None

**Entry:** Phase 1 start

**Exit:** `write.md` contains the new admonishment block after item 3

- [ ] 1. **Pre-RED coherence gate (**clean-room**).** Verify the spec's affected file list matches the actual codebase. **→ SC-1, SC-2**
  - Read `write.md` Plan Format Requirements section to confirm insertion point (after existing compliance admonishment at item 3)
  - Read `plan-fidelity.md` evaluation criteria table to confirm insertion point
  - Confirm no existing one-step-at-a-time block exists
- [ ] 2. **RED phase — write behavioral test for SC-3 (**sub-agent**).** Write behavioral test that sends a plan missing the protocol block to the plan-fidelity auditor and asserts FAIL for PF-ONE-STEP. **→ SC-3**
  - Create `.opencode/tests/behaviors/plan-fidelity-one-step.sh`
  - Test sends a plan without the one-step-at-a-time block → auditor verdict contains FAIL for PF-ONE-STEP
  - Assert: `assert_semantic "SC-3" "auditor reports FAIL for PF-ONE-STEP when plan is missing the one-step-at-a-time protocol admonishment"`
  - Run test, confirm it FAILS (RED)
- [ ] 3. **RED phase — write behavioral test for SC-4 (**sub-agent**).** Write behavioral test that sends a plan with the protocol block and asserts PASS for PF-ONE-STEP. **→ SC-4**
  - Add to same test file or create companion test
  - Test sends a plan with the one-step-at-a-time block → auditor verdict contains PASS for PF-ONE-STEP
  - Assert: `assert_semantic "SC-4" "auditor reports PASS for PF-ONE-STEP when plan contains the one-step-at-a-time protocol admonishment"`
  - Run test, confirm it FAILS (RED)
- [ ] 4. **GREEN phase — add admonishment to write.md (**sub-agent**).** Edit `write.md` Plan Format Requirements to add the one-step-at-a-time protocol admonishment after item 3 (existing compliance admonishment). **→ SC-1**
  - Insert new blockquote after the compliance admonishment at item 3
  - Text:
    ```
    > **One-step-at-a-time protocol:** Each numbered step is exactly one sub-agent dispatch. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel. The RED→GREEN transition is a zero-tolerance gate: the RED test's artifact output MUST be read and confirmed as FAILING before any GREEN implementation begins. If the RED test artifact is not read, or if it shows PASS when FAIL was expected, the phase is poisoned — all work in it MUST be discarded and the phase restarted from RED.
    ```
  - Update validation rules to add item 13 requiring the new admonishment
- [ ] 5. **GREEN doublecheck (**sub-agent**).** Verify `write.md` contains the new admonishment verbatim. **→ SC-1**
  - grep for exact text in `write.md`
- [ ] 6. **Checkpoint commit (**inline**).** Commit Phase 1 changes. **→ SC-1, SC-3, SC-4**
  - Stage: `git add .opencode/skills/writing-plans/tasks/write.md .opencode/tests/behaviors/plan-fidelity-one-step.sh`
  - Commit: `git commit -m "Phase 1: add one-step-at-a-time protocol admonishment to write.md + RED behavioral tests"`

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify SC-1: `write.md` contains the one-step-at-a-time protocol admonishment verbatim. Verify SC-3 and SC-4 behavioral tests exist and are RED (fail before GREEN). **→ SC-1, SC-3, SC-4**

**Concern transition:** Leaving plan format template → entering plan-fidelity auditor criteria. Phase 2 depends on Phase 1's new admonishment text being defined.

> **Cost frame:** Skipping or combining steps in this phase costs exponentially more than following them. A skipped RED test means the GREEN implementation has no verified failure state — the defect ships to Phase 2 where it costs 10× more to find. Following every step costs minutes. Skipping costs days of rework.

## Phase 2 — Add to plan-fidelity auditor

**Concern:** Add PF-ONE-STEP criterion to `plan-fidelity.md` evaluation criteria table

**Files:** `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md`

**SCs:** SC-2

**Dependencies:** Phase 1 (admonishment text defined)

**Entry:** Phase 1 VbC PASS

**Exit:** `plan-fidelity.md` evaluation criteria table includes PF-ONE-STEP

- [ ] 8. **GREEN phase — add PF-ONE-STEP criterion (**sub-agent**).** Edit `plan-fidelity.md` evaluation criteria table to add PF-ONE-STEP criterion. **→ SC-2**
  - Add row to the evaluation criteria table in Step 3
  - Criterion: `PF-ONE-STEP | One-step-at-a-time protocol admonishment present at top of plan | FAIL if missing`
- [ ] 9. **GREEN doublecheck (**sub-agent**).** Verify `plan-fidelity.md` contains `PF-ONE-STEP` in the evaluation criteria table. **→ SC-2**
  - grep for `PF-ONE-STEP` in `plan-fidelity.md`
- [ ] 10. **Checkpoint commit (**inline**).** Commit Phase 2 changes. **→ SC-2**
  - Stage: `git add .opencode/skills/adversarial-audit/tasks/plan-fidelity.md`
  - Commit: `git commit -m "Phase 2: add PF-ONE-STEP criterion to plan-fidelity auditor"`

#### Phase 2 VbC

- [ ] 11. **VbC (**clean-room**).** Verify SC-2: `plan-fidelity.md` evaluation criteria table includes PF-ONE-STEP. **→ SC-2**

**Concern transition:** Leaving auditor criteria → entering behavioral test verification. Phase 3 depends on Phase 1 and Phase 2 being complete.

> **Cost frame:** Skipping or combining steps in this phase costs exponentially more than following them. A skipped RED test means the GREEN implementation has no verified failure state — the defect ships to Phase 2 where it costs 10× more to find. Following every step costs minutes. Skipping costs days of rework.

## Phase 3 — Behavioral tests

**Concern:** Verify behavioral tests pass (GREEN) after implementation

**Files:** `.opencode/tests/behaviors/plan-fidelity-one-step.sh`

**SCs:** SC-3, SC-4

**Dependencies:** Phase 1 (write.md change), Phase 2 (plan-fidelity.md change)

**Entry:** Phase 2 VbC PASS

**Exit:** Both behavioral tests PASS

- [ ] 12. **GREEN phase — run behavioral tests (**sub-agent**).** Run the behavioral test script and confirm both SC-3 and SC-4 pass. **→ SC-3, SC-4**
  - `bash .opencode/tests/behaviors/plan-fidelity-one-step.sh`
  - Confirm SC-3: plan missing protocol block → auditor FAIL for PF-ONE-STEP
  - Confirm SC-4: plan with protocol block → auditor PASS for PF-ONE-STEP
- [ ] 13. **Checkpoint commit (**inline**).** Commit Phase 3 changes. **→ SC-3, SC-4**
  - Stage: `git add .opencode/tests/behaviors/plan-fidelity-one-step.sh`
  - Commit: `git commit -m "Phase 3: behavioral tests pass for PF-ONE-STEP"`

#### Phase 3 VbC

- [ ] 14. **VbC (**clean-room**).** Verify SC-3 and SC-4: behavioral tests pass with correct PASS/FAIL verdicts. **→ SC-3, SC-4**

**Concern transition:** Leaving implementation → entering global post-steps.

## Global Post-Steps

- [ ] 15. **Collect behavioral evidence (**sub-agent**).** Collect behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1414/artifacts/`. **→ SC-3, SC-4**
- [ ] 16. **Adversarial audit (**sub-agent**).** Dispatch adversarial audit of all changed files. **→ All SCs**
- [ ] 17. **Cross-validate (**sub-agent**).** Cross-validate auditor verdicts. **→ All SCs**
- [ ] 18. **Regression check (**sub-agent**).** Run existing enforcement tests to confirm no regressions. **→ All SCs**
  - `bash .opencode/tests/test-enforcement.sh --changed`
- [ ] 19. **Review prep (**sub-agent**).** Prepare PR with summary of changes. **→ All SCs**
- [ ] 20. **Executive summary (**inline**).** Report completion with file paths, SC status, and PR URL. **→ All SCs**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1. `write.md` Plan Format Requirements includes the one-step-at-a-time protocol admonishment verbatim after item 3
- C2. `plan-fidelity.md` evaluation criteria table includes PF-ONE-STEP criterion
- C3. Behavioral test exists that verifies plan-fidelity auditor reports FAIL when plan is missing the protocol block
- C4. Behavioral test exists that verifies plan-fidelity auditor reports PASS when plan contains the protocol block
- C5. All behavioral tests pass
- C6. No regressions in existing enforcement tests
