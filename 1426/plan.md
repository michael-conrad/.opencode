# Implementation Plan — [#1426](https://github.com/michael-conrad/.opencode/issues/1426) — Scope carveouts for discard/poisoned-pipeline rules

- **Spec:** #1426
- **Goal:** Add explicit scope boundaries to the "Discard all work on sub-agent failure" and "Orchestrator inline work poisons the pipeline" rules in `020-go-prohibitions.md`, distinguishing pipeline execution artifacts (discard) from published tracking documents (edit in place).
- **Architecture:** Single-file edit to `020-go-prohibitions.md` — two existing bullet points get scope carveouts appended, one new positive-instruction bullet point added adjacent to them.
- **Files:**
  - `.opencode/guidelines/020-go-prohibitions.md` — lines 244-245 (two existing rules) + new positive instruction after line 245

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is exactly one sub-agent dispatch. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel. The RED→GREEN transition is a zero-tolerance gate: the RED test's artifact output MUST be read and confirmed as FAILING before any GREEN implementation begins. If the RED test artifact is not read, or if it shows PASS when FAIL was expected, the phase is poisoned — all work in it MUST be discarded and the phase restarted from RED.

## Phase 1 — Add scope carveouts to discard/poisoned-pipeline rules

- **Concern:** Amend two existing bullet points in `020-go-prohibitions.md` with scope carveouts, add one new positive-instruction bullet point.
- **Files:** `.opencode/guidelines/020-go-prohibitions.md`
- **SCs:** SC-1, SC-2, SC-3
- **Dependencies:** None
- **Entry:** Spec approved, feature branch created
- **Exit:** All three text changes applied, behavioral test passes

- [ ] 1. **Coherence gate (**clean-room**).** Verify the spec's affected-file list matches actual codebase state. Read `020-go-prohibitions.md` lines 240-270 to confirm the two target rules exist at lines 244-245. **→ SC-1, SC-2, SC-3**

- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture the current state of the two target rules and the insertion point. Read lines 244-245 and the blank line after 245. Write baseline to `./tmp/1426/baseline.txt`. **→ SC-1, SC-2, SC-3**

- [ ] 3. **RED — Behavioral test for SC-4 (**sub-agent**).** Write a behavioral enforcement test at `.opencode/tests/behaviors/1426-scope-carveout.sh` that sends a prompt where an issue body has a valid problem statement and valid SCs but contains a defective section. Assert the agent edits the body instead of closing the issue. Run the test — confirm it FAILS (RED). **→ SC-4**

- [ ] 4. **Z3 check — RED (**inline**).** `solve check` — verify RED test artifact exists and shows FAIL status. **→ SC-4**

- [ ] 5. **RED doublecheck (**clean-room**).** Re-read the behavioral test artifact. Confirm the test correctly asserts "agent edits body, does not close issue" and that the failure is genuine (not a harness error). **→ SC-4**

- [ ] 6. **Z3 check — RED doublecheck (**inline**).** `solve check` — verify doublecheck confirms RED is valid. **→ SC-4**

- [ ] 7. **Post-RED enforcement (**inline**).** Confirm no GREEN work has started yet. Verify working tree is clean except for the RED test file. **→ SC-4**

- [ ] 8. **Z3 check — post-RED (**inline**).** `solve check` — verify post-RED enforcement passed. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 9. **GREEN — Add scope carveout to "Discard all work" rule (**sub-agent**).** Edit `020-go-prohibitions.md` line 245. Append to the existing bullet point: "This discard requirement applies to pipeline execution artifacts (sub-agent output, work state files, cached results, temp files). It does NOT apply to published tracking documents (issue bodies, plan files, spec files, comments) — those are edited in place to fix defects." **→ SC-1**

- [ ] 10. **Z3 check — GREEN step 9 (**inline**).** `solve check` — verify the edit was applied (grep for carveout text adjacent to discard rule). **→ SC-1**

- [ ] 11. **GREEN — Add scope carveout to "Orchestrator inline work poisons" rule (**sub-agent**).** Edit `020-go-prohibitions.md` line 244. Append to the existing bullet point: "The pipeline restart applies to pipeline state (work state files, cached results, sub-agent output). It does NOT apply to published artifacts (issues, plans, specs) — those are edited in place." **→ SC-2**

- [ ] 12. **Z3 check — GREEN step 11 (**inline**).** `solve check` — verify the edit was applied (grep for carveout text adjacent to poisoned pipeline rule). **→ SC-2**

- [ ] 13. **GREEN — Add positive instruction (**sub-agent**).** After line 245 (the discard rule with its new carveout), insert a new bullet point: "When an issue body, plan file, or spec file has a content defect, the correct action is to edit the body to fix the defect. Closing the issue and recreating is the last resort, not the first." **→ SC-3**

- [ ] 14. **Z3 check — GREEN step 13 (**inline**).** `solve check` — verify the edit was applied (grep for "edit the body" or "edit in place" in the same section). **→ SC-3**

- [ ] 15. **Post-GREEN enforcement (**inline**).** Verify all three edits are present and correctly positioned. Read lines 244-248 of `020-go-prohibitions.md`. **→ SC-1, SC-2, SC-3**

- [ ] 16. **Z3 check — post-GREEN (**inline**).** `solve check` — verify post-GREEN enforcement passed. **→ SC-1, SC-2, SC-3**

- [ ] 17. **Checkpoint tag create (**inline**).** Create tag: `opencode-config/checkpoint/1426/phase-1-.opencode`. **→ SC-1, SC-2, SC-3**

- [ ] 18. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/020-go-prohibitions.md .opencode/tests/behaviors/1426-scope-carveout.sh && git commit -m "Phase 1: add scope carveouts to discard/poisoned-pipeline rules"`. **→ SC-1, SC-2, SC-3**

- [ ] 19. **Structural checks (**inline**).** `uvx ruff check .opencode/guidelines/020-go-prohibitions.md` (advisory — markdown file, skip if ruff rejects). Verify file is valid markdown. **→ SC-1, SC-2, SC-3**

- [ ] 20. **GREEN doublecheck (**clean-room**).** Re-read the three modified sections. Confirm each carveout is semantically correct: SC-1 carveout is adjacent to the discard rule, SC-2 carveout is adjacent to the poisoned pipeline rule, SC-3 positive instruction is in the same section. **→ SC-1, SC-2, SC-3**

- [ ] 21. **GREEN VbC (**clean-room**).** Verify all three string SCs (SC-1, SC-2, SC-3) by grep for the exact carveout text. Verify SC-4 behavioral test file exists and is correctly structured. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 22. **Adversarial audit — spec-audit (**sub-agent**).** Dispatch adversarial auditor to audit the spec against the implemented changes. Verify all four SCs are addressed. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 23. **Cross-validate (**sub-agent**).** Dispatch second-family auditor to cross-validate the first auditor's verdict. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 24. **Regression check (**clean-room**).** Verify no existing behavioral tests regressed. Run `bash .opencode/tests/test-enforcement.sh --tag go-prohibitions`. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 25. **Review-prep (**sub-agent**).** Prepare PR body with Summary, Outcome, Fixes #1426, and compare URL. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 26. **Exec summary (**inline**).** Report completion: all three text changes applied, behavioral test written, all SCs verified. **→ SC-1, SC-2, SC-3, SC-4**

#### Phase 1 VbC

- [ ] 27. **VbC (**clean-room**).** Verify: SC-1 carveout present adjacent to discard rule (grep). SC-2 carveout present adjacent to poisoned pipeline rule (grep). SC-3 positive instruction present (grep "edit the body"). SC-4 behavioral test exists and passes (run `bash .opencode/tests/behaviors/1426-scope-carveout.sh`). **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving guideline text edits → entering post-implementation cleanup. No further phases — this is a single-phase, self-contained change.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1. SC-1 carveout text present adjacent to the "Discard all work on sub-agent failure" rule in `020-go-prohibitions.md`
- C2. SC-2 carveout text present adjacent to the "Orchestrator inline work poisons the pipeline" rule in `020-go-prohibitions.md`
- C3. SC-3 positive instruction present in the same section ("edit the body" or "edit in place")
- C4. SC-4 behavioral test exists at `.opencode/tests/behaviors/1426-scope-carveout.sh` and passes
- C5. All existing behavioral tests for `go-prohibitions` tag still pass
- C6. Plan written to `.opencode/.issues/1426/plan.md`
