# Implementation Plan — [#1579](https://github.com/michael-conrad/.opencode/issues/1579) — Add Step Status instruction to Plan Format Requirements

**Goal:** Insert a new required Step Status instruction section into the Plan Format Requirements in `writing-plans/tasks/write.md`, renumber existing sections, and update validation rules.

**Architecture:** Single-file edit to `skills/writing-plans/tasks/write.md`. No other files modified.

**Files:**
- `skills/writing-plans/tasks/write.md` — Plan Format Requirements section (lines 52-167)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

> **Step Status:**
> When executing this plan, report progress in chat using:
> 
> ✅ Step N-1 — 
> 🔄 Step N — 
> ⏳ Step N+1 — 
> 
> ✅ = completed. 🔄 = in progress. ⏳ = pending.
> 
> Omit the ✅ line when no step is yet completed.
> Omit the ⏳ line when the current step is the last step.

## Phase 1 — Insert Step Status section, renumber, update validation rules

**Concern:** Plan Format Requirements structure in `writing-plans/tasks/write.md`

**Files:**
- `skills/writing-plans/tasks/write.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

**Entry:** Spec approved, plan authorized

**Exit:** Plan Format Requirements updated with Step Status instruction, sections renumbered, validation rules updated

- [ ] 1. **Pre-RED coherence gate (**clean-room**).** Verify the current Plan Format Requirements section in `write.md` matches the spec description (items 1-9, no Step Status section yet). Confirm insertion point between current item 4 and item 5. **→ SC-1, SC-5**
- [ ] 2. **Pre-RED baseline (**clean-room**).** Read `skills/writing-plans/tasks/write.md` lines 52-167. Record the current section numbering (1-9) and validation rules (1-14) as baseline. **→ SC-1, SC-5**
- [ ] 3. **RED phase — Write behavioral enforcement test (**sub-agent**).** Create a behavioral test at `.opencode/tests/behaviors/plan-format-step-status.sh` that:
     - Sends a prompt to execute a plan containing the Step Status instruction
     - Asserts the agent's chat output uses the ✅/🔄/⏳ format
     - Asserts the agent omits ✅ when no step completed
     - Asserts the agent omits ⏳ when current step is last
     - Test MUST FAIL (RED) because the Step Status instruction doesn't exist yet
     **→ SC-1, SC-2, SC-3**
- [ ] 4. **Z3 check — RED phase (**inline**).** Verify RED test exists and fails. **→ SC-1, SC-2, SC-3**
- [ ] 5. **RED doublecheck (**clean-room**).** Confirm the behavioral test correctly targets the Step Status instruction format. Verify the test assertions match SC-2 (✅/🔄/⏳ markers) and SC-3 (edge case rules). **→ SC-2, SC-3**
- [ ] 6. **Z3 check — RED doublecheck (**inline**).** Verify RED doublecheck passed. **→ SC-2, SC-3**
- [ ] 7. **Post-RED enforcement (**clean-room**).** Confirm no other plan files or specs reference the old section numbering that would break after renumbering. **→ SC-5**
- [ ] 8. **Z3 check — Post-RED enforcement (**inline**).** Verify post-RED enforcement passed. **→ SC-5**
- [ ] 9. **GREEN phase — Insert Step Status instruction and renumber (**sub-agent**).** Edit `skills/writing-plans/tasks/write.md`:
     - Insert the Step Status instruction block (verbatim from spec) between current item 4 and item 5
     - Renumber existing sections: 5→6, 6→7, 7→8, 8→9, 9→10
     - Update validation rules: add rule 15 for Step Status instruction presence
     **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 10. **Z3 check — GREEN phase (**inline**).** Verify the edit matches spec: verbatim blockquote, correct insertion point, correct renumbering. **→ SC-1, SC-2, SC-3, SC-5**
- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Read the modified `write.md` and verify:
      - Step Status instruction is present verbatim (SC-2)
      - Edge case rules are included (SC-3)
      - Validation rules include Step Status presence check (SC-4)
      - Sections are correctly renumbered 1-10 (SC-5)
      **→ SC-2, SC-3, SC-4, SC-5**
- [ ] 12. **Z3 check — Post-GREEN enforcement (**inline**).** Verify post-GREEN enforcement passed. **→ SC-2, SC-3, SC-4, SC-5**
- [ ] 13. **Checkpoint tag create (**inline**).** Create checkpoint tag for this phase. **→ All**
- [ ] 14. **Checkpoint commit (**inline**).** Commit the edit to `write.md` and the behavioral test. **→ All**
- [ ] 15. **Structural checks (**clean-room**).** Verify:
      - `skills/writing-plans/tasks/write.md` has exactly 10 required sections
      - Validation rules list has 15 entries
      - Behavioral test file exists at `.opencode/tests/behaviors/plan-format-step-status.sh`
      **→ SC-1, SC-4, SC-5**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Re-run the behavioral test from step 3. It MUST now PASS (GREEN) because the Step Status instruction exists. **→ SC-1, SC-2, SC-3**
- [ ] 17. **VbC (**clean-room**).** Verify all SCs:
      - SC-1: Plan Format Requirements includes Step Status instruction as required section 5 — verify by reading `write.md` section list
      - SC-2: Instruction block contains verbatim format with ✅, 🔄, ⏳ markers — verify by reading the inserted block
      - SC-3: Instruction block includes edge case rules (omit ✅ when none, omit ⏳ when last) — verify by reading the inserted block
      - SC-4: Validation rules updated to include Step Status instruction presence — verify rule 15 exists
      - SC-5: Existing sections renumbered correctly (current 5-9 → 6-10) — verify section count and numbering
      **→ All SCs**
- [ ] 18. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor to audit the plan fidelity and the implementation. **→ All**
- [ ] 19. **Cross-validate (**sub-agent**).** Cross-validate VbC and auditor findings. **→ All**
- [ ] 20. **Regression check (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no existing tests break. **→ All**
- [ ] 21. **Review prep (**sub-agent**).** Prepare PR body with Summary, Outcome, Fixes reference. **→ All**
- [ ] 22. **Executive summary (**inline**).** Report completion with file path, SC status, and byline. **→ All**

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify all SCs per step 17 assertions. **→ All SCs**

**Concern transition:** Leaving Plan Format Requirements structure → entering no further phases. This is a single-phase plan.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

### Exit Criteria

- C1: Plan Format Requirements includes Step Status instruction as required section 5
- C2: Instruction block contains verbatim format with ✅, 🔄, ⏳ markers
- C3: Instruction block includes edge case rules (omit ✅ when none, omit ⏳ when last)
- C4: Validation rules updated to include Step Status instruction presence
- C5: Existing sections renumbered correctly (current 5-9 → 6-10)
