# Implementation Plan — [#1585](https://github.com/michael-conrad/.opencode/issues/1585) — Fix YAML frontmatter in playwright-cli/SKILL.md

- **Goal:** Fix YAML parse error in `.opencode/skills/playwright-cli/SKILL.md` by wrapping the `description` field value in double quotes
- **Architecture:** Single-file YAML frontmatter edit — no structural or behavioral changes
- **Files:**
  - `.opencode/skills/playwright-cli/SKILL.md` — line 3, `description` field

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — fix-frontmatter

**Concern:** Fix YAML frontmatter parse error in playwright-cli/SKILL.md by quoting the `description` field.

**Files:**
- `.opencode/skills/playwright-cli/SKILL.md`

**Success Criteria:**
- SC-1: `description` field is wrapped in double quotes (string evidence)
- SC-2: Content-verification test suite passes for playwright-cli (behavioral evidence)
- SC-3: No other content modified (string evidence)

**Dependencies:** None

**Entry conditions:**
- Feature branch created from `dev`
- Spec #1585 approved with `approved-for-plan` label

**Exit conditions:**
- `.opencode/skills/playwright-cli/SKILL.md` line 3 `description` value wrapped in double quotes
- Content-verification test suite passes for playwright-cli
- `git diff` shows only the description line changed

- [ ] 1. **Pre-RED baseline (**clean-room**).** Verify current state of `.opencode/skills/playwright-cli/SKILL.md` — confirm `description` field is unquoted and contains `REQUIRED:`. **→ SC-1, SC-3**

- [ ] 2. **SC-coherence gate (**clean-room**).** Verify plan coherence against spec #1585 — confirm single-phase, single-file scope matches spec decomposition. **→ All SCs**

- [ ] 3. **RED phase — write content-verification test assertion (**sub-agent**).** Write a content-verification test assertion that verifies the `description` field is wrapped in double quotes. The test MUST FAIL at this point because the fix hasn't been applied yet. **→ SC-1**

- [ ] 4. **Z3 check — RED (**inline**).** Run `bash .opencode/tests/test-enforcement.sh --tag pr-creation` and confirm the RED test fails (expected: YAML parse error or assertion failure). **→ SC-2**

- [ ] 5. **RED doublecheck (**clean-room**).** Confirm the RED test assertion correctly targets the unquoted description — verify the test would PASS after the fix is applied. **→ SC-1**

- [ ] 6. **Z3 check — RED doublecheck (**inline**).** Re-run the RED test to confirm consistent failure. **→ SC-2**

- [ ] 7. **Post-RED enforcement (**clean-room**).** Verify no implementation work has been done yet — confirm `git diff` is clean. **→ SC-3**

- [ ] 8. **Z3 check — post-RED (**inline**).** Confirm enforcement gate passes — no premature changes detected. **→ All SCs**

- [ ] 9. **GREEN phase — apply fix (**sub-agent**).** Edit `.opencode/skills/playwright-cli/SKILL.md` line 3: wrap the `description` value in double quotes. **→ SC-1**

- [ ] 10. **Z3 check — GREEN (**inline**).** Verify the YAML frontmatter parses correctly — run `python -c "import yaml; yaml.safe_load(open('.opencode/skills/playwright-cli/SKILL.md'))"`. **→ SC-1**

- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Verify `git diff` shows ONLY the description line changed — no other content modified. **→ SC-3**

- [ ] 12. **Z3 check — post-GREEN (**inline**).** Confirm enforcement gate passes — only the description line was modified. **→ SC-3**

- [ ] 13. **Checkpoint tag create (**inline**).** Create checkpoint tag: `opencode-config/checkpoint/1585/phase-1-fix-frontmatter-opencode`. **→ All SCs**

- [ ] 14. **Checkpoint commit (**inline**).** Commit the fix with message: `fix(playwright-cli): quote description field in YAML frontmatter (#1585)`. **→ All SCs**

- [ ] 15. **Structural checks (**clean-room**).** Verify:
  - `grep 'description: "' .opencode/skills/playwright-cli/SKILL.md` returns a match (SC-1)
  - `git diff .opencode/skills/playwright-cli/SKILL.md` shows only the description line changed (SC-3)
  - YAML frontmatter parses without error (SC-1) **→ SC-1, SC-3**

- [ ] 16. **GREEN doublecheck (**clean-room**).** Re-run all structural checks to confirm the fix is correct and isolated. **→ SC-1, SC-3**

- [ ] 17. **GREEN VbC (**clean-room**).** Run content-verification test suite: `bash .opencode/tests/test-enforcement.sh --tag pr-creation`. Confirm all scenarios PASS including playwright-cli. **→ SC-2**

- [ ] 18. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor to audit the fix against spec #1585 success criteria. **→ All SCs**

- [ ] 19. **Cross-validate (**sub-agent**).** Cross-validate auditor findings against VbC results. **→ All SCs**

- [ ] 20. **Regression check (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to confirm no regressions in other skills. **→ SC-2**

- [ ] 21. **Review prep (**sub-agent**).** Prepare PR body with Summary, Outcome, Fixes #1585, and compare URL. **→ All SCs**

- [ ] 22. **Executive summary (**inline**).** Report: fix applied, content-verification suite passes, no regressions. **→ All SCs**

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify all SCs: SC-1 (description quoted), SC-2 (test suite passes), SC-3 (only description changed). **→ SC-1, SC-2, SC-3**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1: `.opencode/skills/playwright-cli/SKILL.md` line 3 `description` value is wrapped in double quotes
- C2: `bash .opencode/tests/test-enforcement.sh --tag pr-creation` reports PASS for all scenarios
- C3: `git diff .opencode/skills/playwright-cli/SKILL.md` shows only the description line changed
- C4: YAML frontmatter parses without error via `yaml.safe_load`
- C5: No regressions in other skills (`bash .opencode/tests/test-enforcement.sh --changed` passes)
