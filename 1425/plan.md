# Implementation Plan — [#1425](https://github.com/michael-conrad/.opencode/issues/1425) — Fix plan writer protocol admonishment wording, remove RED→GREEN language, add dispatch indicator validation

- **Spec:** [#1425](https://github.com/michael-conrad/.opencode/issues/1425)
- **Goal:** Fix 3 defects in `writing-plans/tasks/write.md` and `writing-plans/tasks/validate.md`: (1) replace "exactly one sub-agent dispatch" with "a single unit of work" in top admonishment, (2) remove RED→GREEN-specific poisoning language from top admonishment, (3) add dispatch indicator validation rules and checks
- **Architecture:** Single-file edits to two task files under `.opencode/skills/writing-plans/tasks/`; behavioral test for SC-5
- **Files:**
  - `.opencode/skills/writing-plans/tasks/write.md` — Fix top admonishment (SC-1, SC-2), add validation rule 14 (SC-4)
  - `.opencode/skills/writing-plans/tasks/validate.md` — Add dispatch indicator validation check 18 (SC-5)
  - `.opencode/tests/behaviors/` — New behavioral test for SC-5

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined.

## Phase 1 — Pre-RED Common

**Concern:** Verify spec readiness, create feature branch, set up test infrastructure
**Files:** (none)
**SCs:** All
**Dependencies:** None
**Entry:** Spec #1425 approved
**Exit:** Feature branch created, behavioral test scaffold ready

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec #1425 is approved (check `approved-for-*` label), verify no superseding issues exist, verify affected files exist at expected paths. **→ All**
- [ ] 2. **Pre-red baseline (**inline**).** Read current verbatim content of top admonishment (write.md lines 64-67) and bottom admonishment (write.md lines 77-82). Save to `./tmp/1425/baseline-top-admonishment.txt` and `./tmp/1425/baseline-bottom-admonishment.txt`. **→ SC-3**
- [ ] 3. **Create feature branch (**inline**).** `git checkout -b feature/1425-plan-writer-fix` from `dev`. **→ All**
- [ ] 4. **Behavioral test scaffold — RED (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/dispatch-indicator-validation.sh` that sends a plan with mismatched dispatch indicators via `opencode-cli run` and asserts stderr shows FAIL from validate task. Test MUST FAIL at this point (no validation rule exists yet). **→ SC-5**

## Phase 2 — Fix top admonishment wording (SC-1, SC-2)

**Concern:** Edit `write.md` top admonishment to fix wording and remove RED→GREEN language
**Files:** `.opencode/skills/writing-plans/tasks/write.md`
**SCs:** SC-1, SC-2
**Dependencies:** Phase 1 (baseline captured)
**Entry:** Baseline captured, feature branch exists
**Exit:** Top admonishment corrected, bottom admonishment verified unchanged

- [ ] 5. **RED — Write failing string test (**inline**).** Write a content-verification test that greps for "single unit of work" in top admonishment position — test MUST FAIL (text doesn't exist yet). **→ SC-1**
- [ ] 6. **GREEN — Fix top admonishment wording (**sub-agent**).** Edit `write.md` lines 64-67: replace "Each numbered step is exactly one sub-agent dispatch." with "Each numbered step is a single unit of work." Remove the RED→GREEN-specific sentence: "The RED→GREEN transition is a zero-tolerance gate: the RED test's artifact output MUST be read and confirmed as FAILING before any GREEN implementation begins. If the RED test artifact is not read, or if it shows PASS when FAIL was expected, the phase is poisoned — all work in it MUST be discarded and the phase restarted from RED." **→ SC-1, SC-2**
- [ ] 7. **GREEN doublecheck (**inline**).** Re-run string test from step 5 — MUST PASS. Grep top admonishment for "sub-agent dispatch" — MUST return zero matches. Grep top admonishment for "RED→GREEN" — MUST return zero matches. **→ SC-1, SC-2**
- [ ] 8. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/write.md && git commit -m "fix top admonishment wording and remove RED→GREEN language"`. **→ SC-1, SC-2**

## Phase 3 — Add validation rule 14 to write.md (SC-4)

**Concern:** Add dispatch indicator validation rule to write.md validation rules section
**Files:** `.opencode/skills/writing-plans/tasks/write.md`
**SCs:** SC-4
**Dependencies:** Phase 2 (write.md edited)
**Entry:** write.md has corrected top admonishment
**Exit:** Validation rule 14 present in write.md

- [ ] 9. **RED — Write failing string test (**inline**).** Grep for "14." under the validation rules section in write.md — MUST return zero matches (rule doesn't exist yet). **→ SC-4**
- [ ] 10. **GREEN — Add validation rule 14 (**sub-agent**).** Append to the validation rules list in write.md (after line 137, rule 13): `14. Dispatch indicators match step content — (**inline**) steps must not contain sub-agent dispatch language; (**sub-agent**) steps must dispatch via task()` **→ SC-4**
- [ ] 11. **GREEN doublecheck (**inline**).** Re-run string test from step 9 — MUST PASS. Verify rule 14 text describes dispatch indicator semantic validation. **→ SC-4**
- [ ] 12. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/write.md && git commit -m "add validation rule 14 for dispatch indicator matching"`. **→ SC-4**

## Phase 4 — Add dispatch indicator validation check to validate.md (SC-5)

**Concern:** Add check 18 to validate.md for dispatch indicator validation
**Files:** `.opencode/skills/writing-plans/tasks/validate.md`
**SCs:** SC-5
**Dependencies:** Phase 3 (rule 14 exists)
**Entry:** Validation rule 14 exists in write.md
**Exit:** Check 18 present in validate.md, behavioral test passes

- [ ] 13. **RED — Write failing behavioral test (**inline**).** Run the behavioral test from step 4 — MUST FAIL (check 18 doesn't exist yet). **→ SC-5**
- [ ] 14. **GREEN — Add check 18 to validate.md (**sub-agent**).** Append new check after check 17 in validate.md: `- [ ] 18. (**inline**) Dispatch indicator validation — Verify each step's dispatch indicator matches its content. (**inline**) steps must not contain sub-agent dispatch language; (**sub-agent**) steps must dispatch via task(). Command: parse plan body, extract dispatch indicators, verify semantic match. SC: SC-5. Expected: all dispatch indicators match step content.` **→ SC-5**
- [ ] 15. **GREEN doublecheck (**inline**).** Re-run behavioral test from step 4 — MUST PASS. **→ SC-5**
- [ ] 16. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans/tasks/validate.md .opencode/tests/behaviors/dispatch-indicator-validation.sh && git commit -m "add dispatch indicator validation check 18 to validate.md"`. **→ SC-5**

## Phase 5 — Verify bottom admonishment unchanged (SC-3)

**Concern:** Confirm bottom self-remediation protocol admonishment was not modified
**Files:** `.opencode/skills/writing-plans/tasks/write.md`
**SCs:** SC-3
**Dependencies:** Phase 2 (write.md edited)
**Entry:** write.md top admonishment fixed
**Exit:** Bottom admonishment confirmed identical to baseline

- [ ] 17. **Verify bottom admonishment unchanged (**inline**).** Diff current bottom admonishment (write.md lines 77-82) against baseline from `./tmp/1425/baseline-bottom-admonishment.txt`. Zero differences = PASS. **→ SC-3**

## Phase 6 — Global post-steps

**Concern:** Collect evidence, run audits, prepare for PR
**Files:** All affected files
**SCs:** All
**Dependencies:** All phases complete
**Entry:** All edits committed
**Exit:** PR-ready

- [ ] 18. **Collect behavioral evidence (**inline**).** Copy `./tmp/behavioral-evidence-*/` artifacts into `./tmp/1425/artifacts/`. **→ SC-5**
- [ ] 19. **Adversarial audit — spec-audit (**sub-agent**).** Dispatch spec-audit against plan and spec #1425. Verify all 5 SCs are addressed. **→ All**
- [ ] 20. **Cross-validate (**sub-agent**).** Cross-validate audit findings. **→ All**
- [ ] 21. **Regression check (**inline**).** Run `uvx ruff check .opencode/skills/writing-plans/tasks/` and `uvx pymarkdownlnt scan .opencode/skills/writing-plans/tasks/write.md .opencode/skills/writing-plans/tasks/validate.md`. **→ All**
- [ ] 22. **Review-prep (**sub-agent**).** Run finishing-a-development-branch checklist. **→ All**
- [ ] 23. **Executive summary (**inline**).** Report completion with file paths, SC status table, and PR URL. **→ All**

#### Phase 6 VbC

- [ ] 24. **VbC (**clean-room**).** Verify all 5 SCs have PASS evidence. Verify bottom admonishment diff is zero. Verify behavioral test (SC-5) passed. **→ All**

**Concern transition:** Leaving implementation → entering PR preparation. Phase 6 depends on Phase 5 bottom-admonishment verification.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

| ID | Criterion |
|----|-----------|
| C1 | Top admonishment says "a single unit of work" — "sub-agent dispatch" absent from top admonishment |
| C2 | Top admonishment has no RED→GREEN language |
| C3 | Bottom admonishment diff against baseline is zero — unchanged |
| C4 | Validation rules in write.md include rule 14 for dispatch indicator matching |
| C5 | validate.md includes check 18 for dispatch indicator validation |
| C6 | Behavioral test for SC-5 passes (stderr shows FAIL on mismatch) |
| C7 | All lint/format checks pass |
| C8 | Adversarial audit PASS for all SCs |
