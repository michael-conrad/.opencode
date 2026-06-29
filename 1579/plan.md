# Implementation Plan — [#1579](https://github.com/michael-conrad/.opencode/issues/1579) — Plan writer injects step status instruction block

- **Goal:** Add a Step Status instruction block as required section 5 in the Plan Format Requirements of `writing-plans/tasks/write.md`, renumber existing sections 5-9 to 6-10, and add a validation rule for the new section.
- **Architecture:** Single-file documentation change to `skills/writing-plans/tasks/write.md`. No runtime behavior changes, no new files, no dependency changes.
- **Files:** `skills/writing-plans/tasks/write.md`
- **Spec:** [#1579](https://github.com/michael-conrad/.opencode/issues/1579)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Insert Step Status instruction block

**Concern:** Add Step Status instruction block as required section 5 in Plan Format Requirements, renumber sections 5-9 to 6-10, add validation rule.

**Files:** `skills/writing-plans/tasks/write.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

**Entry:** Plan approved, feature branch created

**Exit:** All SCs verified PASS, changes committed

- [ ] 1. **Pre-RED: Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` to verify the plan is coherent with the spec. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 2. **Pre-RED: Baseline check (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to verify doc-source currency and SC-ID cross-reference traceability. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 3. **RED: Write failing enforcement test (**sub-agent**).** Dispatch `test-driven-development --task red` to create a behavioral test that verifies the Step Status instruction block is present in `write.md`. The test MUST FAIL because the change does not exist yet. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 4. **Z3 check RED (**inline**).** Run `solve check` against the red-phase output contract. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 5. **RED doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` to confirm the RED test artifact shows FAIL. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 6. **Z3 check RED doublecheck (**inline**).** Run `solve check` against the red-doublecheck output contract. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 7. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify no source code was modified during RED phase. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 8. **Z3 check post-RED (**inline**).** Run `solve check` against the post-red-enforcement output contract. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 9. **GREEN: Implement Step Status instruction block (**sub-agent**).** Dispatch `test-driven-development --task green` to:
    - [ ] 9.1. Insert the Step Status instruction block as required section 5 between the current one-step-at-a-time protocol admonishment (item 4) and the Phase sections (current item 5)
    - [ ] 9.2. Renumber existing sections 5-9 to 6-10 in the Required Sections list
    - [ ] 9.3. Add validation rule: "Step Status instruction present as required section 5" to the Validation Rules section
    - [ ] 9.4. Update the section count reference in the Required Sections preamble if present
    **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 10. **Z3 check GREEN (**inline**).** Run `solve check` against the green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 11. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify only test files were modified during GREEN phase. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 12. **Z3 check post-GREEN (**inline**).** Run `solve check` against the post-green-enforcement output contract. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 13. **Checkpoint tag create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create a git tag for rollback. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 14. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep` to commit the GREEN changes. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 15. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 16. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify` for semantic-intent verification of the GREEN implementation. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 17. **GREEN VbC (**sub-agent**).** Dispatch `verification-before-completion --task completion` to produce VbC completion artifact. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 18. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 19. **Auditor 1 dispatch (**sub-agent**).** Dispatch audit task with auditor_1. If non-clean-pass: remediate root cause, restart from step 18. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 20. **Auditor 2 dispatch (**sub-agent**).** Dispatch same audit task with auditor_2. If non-clean-pass: remediate root cause, restart from step 18. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 21. **Cross-validate (**sub-agent**).** Dispatch `adversarial-audit --task cross-validate` with `auditor_artifact_paths` from steps 19-20. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 22. **Regression check (**sub-agent**).** Dispatch `test-driven-development --task patterns` for regression tests. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 23. **Review prep (**sub-agent**).** Dispatch `git-workflow --task review-prep` to prepare the branch for PR. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 24. **Exec summary (**sub-agent**).** Dispatch `completion-core --task completion` to append lifecycle event and produce chat exec summary. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

#### Phase 1 VbC

- [ ] 25. **VbC (**clean-room**).** Verify all SCs: SC-1 (grep for `Step Status instruction` in `write.md`), SC-2 (grep for `✅`, `🔄`, `⏳` in instruction block), SC-3 (grep for `Omit the ✅ line` and `Omit the ⏳ line`), SC-4 (grep for Step Status in validation rules), SC-5 (verify section numbering 6-10). **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving Step Status instruction block insertion → entering no further phases. Single-phase plan complete.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Self-Review Evidence

- Plan validated against Plan Format Requirements in `write.md` — all 18 validation checks applied
- Spec reference: [#1579](https://github.com/michael-conrad/.opencode/issues/1579) — single-phase, single-file documentation change
- All dispatch indicators use only valid values: `(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`
- Step numbering is globally sequential (1-25) across the single phase
- RED→GREEN→doublecheck→commit chains present for all items
- Adversarial audit decomposed into individual steps (18-20) per multi-dispatch prohibition

## Exit Criteria

- C1. Step Status instruction block present as required section 5 in Plan Format Requirements
- C2. Instruction block contains verbatim format with ✅, 🔄, ⏳ markers
- C3. Instruction block includes edge case rules (omit ✅ when none, omit ⏳ when last)
- C4. Validation rules include Step Status instruction presence check
- C5. Existing sections renumbered correctly (5-9 → 6-10)
- C6. All SCs verified PASS
- C7. Changes committed to feature branch
- C8. Review prep complete
