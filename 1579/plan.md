# Implementation Plan — [#1579](https://github.com/michael-conrad/.opencode/issues/1579) — Add Step Status instruction block to Plan Format Requirements

**Spec:** [#1579](https://github.com/michael-conrad/.opencode/issues/1579)

**Goal:** Insert a new required section 5 (Step Status instruction) into the Plan Format Requirements in `.opencode/skills/writing-plans/tasks/write.md`, renumber existing sections 5-9 to 6-10, update validation rules, and add behavioral enforcement test.

**Architecture:** Edit `.opencode/skills/writing-plans/tasks/write.md` — insert new item 5 between current item 4 and item 5, renumber 5-9 to 6-10, add validation rule. Create behavioral enforcement test at `.opencode/tests/behaviors/plan-step-status-format.sh`.

**Files:**
- `.opencode/skills/writing-plans/tasks/write.md` — Plan Format Requirements section, Validation Rules section
- `.opencode/tests/behaviors/plan-step-status-format.sh` — Behavioral enforcement test (SC-6)

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

## Phase 1 — Insert Step Status instruction block and renumber sections

**Concern:** Insert new required section 5 (Step Status instruction) between current item 4 and item 5 in the Plan Format Requirements, renumber existing sections 5-9 to 6-10, and add validation rule 15.

**Files:** `.opencode/skills/writing-plans/tasks/write.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

**Dependencies:** None

**Entry conditions:** Spec approved, solve SAT

**Exit conditions:** Plan Format Requirements updated with Step Status instruction at position 5, sections 5-9 renumbered to 6-10, validation rules include Step Status presence check, behavioral enforcement test passes.

- [ ] 1. **Pre-RED: Read current Plan Format Requirements (**clean-room**).** Read `.opencode/skills/writing-plans/tasks/write.md` Plan Format Requirements section to confirm current structure. **→ SC-5**
- [ ] 2. **RED: Write behavioral enforcement test (**sub-agent**).** Create `.opencode/tests/behaviors/plan-step-status-format.sh` — a behavioral test that sends a prompt to the agent with a plan containing the Step Status instruction block and verifies the agent formats chat output with ✅, 🔄, ⏳ markers. The test MUST FAIL at this point because the change doesn't exist yet. **→ SC-6**
- [ ] 3. **RED: Write content-verification test (**sub-agent**).** Create a content-verification test that greps for `Step Status instruction` in `write.md` (SC-1), `✅`/`🔄`/`⏳` markers (SC-2), `Omit the ✅ line`/`Omit the ⏳ line` (SC-3), Step Status in validation rules (SC-4), and section numbering (SC-5). The test MUST FAIL at this point. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 4. **Z3 check: RED tests (**inline**).** Run `solve check` — verify both RED test artifacts exist and FAIL. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 5. **RED doublecheck (**inline**).** Re-read both RED test artifacts to confirm they test the correct behavior. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 6. **GREEN: Insert Step Status instruction block (**sub-agent**).** Edit `.opencode/skills/writing-plans/tasks/write.md`:
      - In the Required Sections list, insert new item 5 (Step Status instruction) between current item 4 (one-step-at-a-time protocol admonishment) and current item 5 (Phase sections)
      - Renumber current items 5-9 to 6-10
      - The new item 5 contains the verbatim blockquote with ✅, 🔄, ⏳ markers and edge case rules (omit ✅ when none, omit ⏳ when last)
      - **→ SC-1, SC-2, SC-3, SC-5**
- [ ] 7. **GREEN: Update validation rules (**sub-agent**).** Add validation rule 15 to the Validation Rules section: "Step Status instruction present as required section 5". **→ SC-4**
- [ ] 8. **Z3 check: GREEN (**inline**).** Run `solve check` — verify the edit was applied correctly. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 9. **Post-GREEN enforcement (**inline**).** Re-read `.opencode/skills/writing-plans/tasks/write.md` Plan Format Requirements section and verify:
      - New item 5 exists with Step Status instruction block
      - Old items 5-9 are now items 6-10
      - Validation rule 15 exists
      - **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 10. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/write.md && git commit -m "Add Step Status instruction block to Plan Format Requirements (#1579)"` **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 11. **Structural checks (**inline**).** Run `grep` for `Step Status instruction` in `write.md` (SC-1), `✅`/`🔄`/`⏳` in the instruction block (SC-2), `Omit the ✅ line` and `Omit the ⏳ line` (SC-3), Step Status in validation rules (SC-4), and verify section numbering (SC-5). **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 12. **GREEN doublecheck (**inline**).** Re-read the full Required Sections list to confirm all 10 items are present and correctly numbered. **→ SC-5**
- [ ] 13. **VbC string SCs (**clean-room**).** Verify SC-1 through SC-5 against the edited file. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 14. **VbC behavioral SC (**clean-room**).** Run `.opencode/tests/behaviors/plan-step-status-format.sh` — verify SC-6 passes (agent formats chat output with ✅, 🔄, ⏳ markers). **→ SC-6**
- [ ] 15. **Adversarial audit (**sub-agent**).** Dispatch adversarial-audit --task spec-audit with the spec and the edited file. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 16. **Cross-validate (**sub-agent**).** Dispatch cross-validate to verify auditor findings. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 17. **Regression check (**inline**).** Verify no other sections of `write.md` were affected. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 18. **Review prep (**sub-agent**).** Prepare PR body with Summary, Outcome, Fixes #1579. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 19. **Executive summary (**inline**).** Report completion: plan executed, Step Status instruction block inserted, sections renumbered, validation rules updated, behavioral test passes. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 20. **VbC string SCs (**clean-room**).** Verify SC-1 through SC-5: SC-1 (Step Status instruction present), SC-2 (✅🔄⏳ markers), SC-3 (omit rules), SC-4 (validation rule 15), SC-5 (sections 6-10). **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 21. **VbC behavioral SC (**clean-room**).** Verify SC-6: agent executing a plan with Step Status instruction formats chat output with ✅, 🔄, ⏳ markers. **→ SC-6**

**Concern transition:** Leaving Plan Format Requirements update → entering completion. No further phases.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.

> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

### Exit Criteria

- C1: Plan Format Requirements includes Step Status instruction as required section 5
- C2: Instruction block contains verbatim format with ✅, 🔄, ⏳ markers
- C3: Instruction block includes edge case rules (omit ✅ when none, omit ⏳ when last)
- C4: Validation rules updated to include Step Status instruction presence
- C5: Existing sections renumbered correctly (current 5-9 → 6-10)
- C6: Behavioral enforcement test passes — agent formats chat output with ✅, 🔄, ⏳ markers
