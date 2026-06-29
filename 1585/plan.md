# Implementation Plan — [#1585](https://github.com/michael-conrad/.opencode/issues/1585) — Fix YAML frontmatter in playwright-cli/SKILL.md

- **Goal:** Fix YAML parse error in `.opencode/skills/playwright-cli/SKILL.md` by wrapping the `description` field value in double quotes
- **Architecture:** Single-file YAML frontmatter edit — no structural or behavioral changes
- **Files:** `.opencode/skills/playwright-cli/SKILL.md` — line 3, `description` field

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — fix-frontmatter

**Concern:** Fix YAML parse error in playwright-cli/SKILL.md by quoting the `description` field value.

**Files:**
- `.opencode/skills/playwright-cli/SKILL.md` — line 3, `description` field

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry conditions:**
- Feature branch exists on `dev`
- Spec #1585 approved with `approved-for-plan` label
- No other open issues modify playwright-cli/SKILL.md

**Exit conditions:**
- `description` field wrapped in double quotes
- Content-verification test suite passes for playwright-cli
- No other content modified

---

- [ ] 1. **SC-coherence gate (**clean-room**).** Verify spec SCs are coherent with the codebase: read `.opencode/skills/playwright-cli/SKILL.md` line 3, confirm the `description` field is unquoted and contains `REQUIRED:`. **→ SC-1, SC-3**
- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture pre-change state: run `grep 'description:' .opencode/skills/playwright-cli/SKILL.md` and save output to `./tmp/behavioral-evidence-SC-1-baseline.log`. **→ SC-1, SC-3**
- [ ] 3. **RED phase (**sub-agent**).** Write a content-verification test that asserts the `description` field is wrapped in double quotes. The test MUST FAIL because the field is currently unquoted. Save test to `./tmp/behavioral-evidence-SC-1-red-test.log`. **→ SC-1**
- [ ] 4. **Z3 check — RED (**clean-room**).** Verify the RED test artifact exists and shows FAIL. Read `./tmp/behavioral-evidence-SC-1-red-test.log` — confirm the assertion failed. **→ SC-1**
- [ ] 5. **RED doublecheck (**clean-room**).** Re-run the RED test to confirm consistent FAIL. Save second output to `./tmp/behavioral-evidence-SC-1-red-doublecheck.log`. **→ SC-1**
- [ ] 6. **Z3 check — RED doublecheck (**clean-room**).** Verify the RED doublecheck artifact exists and shows FAIL. **→ SC-1**
- [ ] 7. **Post-RED enforcement (**clean-room**).** Confirm no GREEN implementation has occurred yet: `git diff .opencode/skills/playwright-cli/SKILL.md` must be empty. **→ SC-3**
- [ ] 8. **Z3 check — post-RED (**clean-room**).** Verify post-RED enforcement artifact shows clean diff. **→ SC-3**
- [ ] 9. **GREEN phase (**sub-agent**).** Edit `.opencode/skills/playwright-cli/SKILL.md` line 3: wrap the `description` value in double quotes. Use `edit_text` to replace the unquoted line with the quoted version. **→ SC-1**
- [ ] 10. **Z3 check — GREEN (**clean-room**).** Verify the edit was applied: `grep 'description: "' .opencode/skills/playwright-cli/SKILL.md` must return a match. Save to `./tmp/behavioral-evidence-SC-1-green.log`. **→ SC-1**
- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Confirm only the description line changed: `git diff .opencode/skills/playwright-cli/SKILL.md` must show exactly one line changed (the description field). **→ SC-3**
- [ ] 12. **Z3 check — post-GREEN (**clean-room**).** Verify post-GREEN enforcement artifact shows single-line diff. **→ SC-3**
- [ ] 13. **Checkpoint tag — create (**inline**).** Create a checkpoint tag: `git tag -f .opencode/checkpoint/1585/phase-1-fix-frontmatter`. **→ SC-1, SC-2, SC-3**
- [ ] 14. **Checkpoint commit (**inline**).** Stage and commit the change: `git add .opencode/skills/playwright-cli/SKILL.md && git commit -m "fix: quote description field in playwright-cli SKILL.md frontmatter"`. **→ SC-1, SC-3**
- [ ] 15. **Structural checks (**clean-room**).** Run `uvx pymarkdownlnt scan -r .opencode/skills/playwright-cli/SKILL.md` to confirm no markdown lint regressions. **→ SC-2**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Re-read `.opencode/skills/playwright-cli/SKILL.md` line 3 — confirm the `description` field is wrapped in double quotes. Save to `./tmp/behavioral-evidence-SC-1-doublecheck.log`. **→ SC-1**
- [ ] 17. **GREEN VbC (**clean-room**).** Run content-verification test: `bash .opencode/tests/test-enforcement.sh --tag pr-creation`. Verify all scenarios including playwright-cli report PASS. Save output to `./tmp/behavioral-evidence-SC-2-vbc.log`. **→ SC-2**
- [ ] 18. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor to audit the fix: verify the description field is quoted, no other content changed, and content-verification tests pass. **→ SC-1, SC-2, SC-3**
- [ ] 19. **Cross-validate (**clean-room**).** Run cross-validate on the adversarial audit verdict. Confirm consensus: PASS for all SCs. **→ SC-1, SC-2, SC-3**
- [ ] 20. **Regression check (**clean-room**).** Run `git diff --stat` to confirm only `.opencode/skills/playwright-cli/SKILL.md` was modified. Run `uvx pymarkdownlnt scan -r .opencode/guidelines/` to confirm no regressions in other files. **→ SC-3**
- [ ] 21. **Review prep (**sub-agent**).** Prepare PR body with Summary, Outcome, Fixes #1585, and SC verification table. **→ SC-1, SC-2, SC-3**
- [ ] 22. **Executive summary (**inline**).** Report completion: summary of what was done, SC verification results, and next steps. **→ SC-1, SC-2, SC-3**

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify all SCs:
  - SC-1: `grep 'description: "' .opencode/skills/playwright-cli/SKILL.md` returns a match → PASS
  - SC-2: Content-verification test suite (`--tag pr-creation`) reports PASS → PASS
  - SC-3: `git diff .opencode/skills/playwright-cli/SKILL.md` shows only the description line changed → PASS
  **→ SC-1, SC-2, SC-3**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

### Exit Criteria

- [ ] C1: `description` field in YAML frontmatter is wrapped in double quotes (SC-1)
- [ ] C2: Content-verification test suite passes for playwright-cli (SC-2)
- [ ] C3: No other content in SKILL.md was modified beyond the description line (SC-3)
- [ ] C4: All 23 plan steps completed in order with no skipped gates
- [ ] C5: Adversarial audit and cross-validate both report PASS for all SCs

---

## Approval Cascade

**Status:** AUTO-APPROVED (plan)

- **authorization_scope:** `for_plan`
- **halt_at:** `plan_created`
- **pr_strategy:** `none`
- **Cascade rule:** Plan is auto-approved per `approval-gate-001a-cascade` (faithful plan for approved spec). Implementation requires separate authorization (`for_implementation` or above scope).
- **Applied by:** Step 4 of 6 — write task from writing-plans
