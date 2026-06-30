# Implementation Plan — [.opencode#1605](https://github.com/michael-conrad/.opencode/issues/1605) — Position pipeline-readiness-gate in spec-creation SKILL.md

- **Goal:** Add `pipeline-readiness-gate` to the spec-creation SKILL.md Tasks table, insert a numbered step (4.5) in the Operating Protocol between traceability and risk, add an Invocation table entry, and update the symbolic rule trigger condition.
- **Architecture:** Single-file edit to `.opencode/skills/spec-creation/SKILL.md` — 4 targeted edits, no structural changes, no new files.
- **Files:**
  - `.opencode/skills/spec-creation/SKILL.md` (modify — 4 edits)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

> **Step Status instruction:** When reporting progress in chat, use the following format with exactly one status marker per step:
>
> | Marker | Meaning |
> |--------|---------|
> | ✅ | Step completed |
> | 🔄 | Step currently being worked on |
> | ⏳ | Step not yet started |
>
> **Format:**
> ```
> ✅ Step 1 — Title
> 🔄 Step 2 — Title
> ⏳ Step 3 — Title
> ```
>
> **Edge case rules:**
> - Omit the ✅ column entirely when no steps are completed (all steps are 🔄 or ⏳)
> - Omit the ⏳ column entirely when the current step is the last step (no steps remain)
> - Exactly one step MUST be marked 🔄 at any time
> - The 🔄 marker moves to the next step only after the current step's verification passes

## Phase 1 — Add pipeline-readiness-gate to spec-creation SKILL.md

**Concern:** Add `pipeline-readiness-gate` to Tasks table, Operating Protocol, Invocation table, and symbolic rules in `.opencode/skills/spec-creation/SKILL.md`

**Files:** `.opencode/skills/spec-creation/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

**Entry conditions:** Feature branch exists, spec approved

**Exit conditions:** All 4 edits applied, `git diff --stat` shows only SKILL.md changed, all SCs verified PASS

- [ ] 1. **SC coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` to verify SC evidence types and substrate classification for all 5 SCs. **→ All SCs**

- [ ] 2. **Pre-RED baseline (**clean-room**).** Read `.opencode/skills/spec-creation/SKILL.md` and verify current state: Tasks table has 2 rows (create, completion), Operating Protocol has steps 1-10 with traceability at step 4 and risk at step 5 with no intervening step, Invocation table has 2 entries, symbolic rule `spec-creation-pipeline-readiness` fires on `spec_sc_finalized == true`. **→ SC-5**

- [ ] 3. **RED phase (**sub-agent**).** Write behavioral enforcement test at `.opencode/tests/behaviors/spec-creation-pipeline-readiness-position.sh` that sends a spec-creation prompt and verifies the agent dispatches `pipeline-readiness-gate` between traceability and risk. Test MUST FAIL at this point (change doesn't exist yet). **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 4. **Z3 check RED (**inline**).** Run `solve check` against RED-phase output contract. **→ All SCs**

- [ ] 5. **RED doublecheck (**clean-room**).** Verify RED-side SC evidence — confirm behavioral test exists and fails. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 6. **Z3 check RED doublecheck (**inline**).** Run `solve check` against RED-doublecheck output contract. **→ All SCs**

- [ ] 7. **Post-RED enforcement (**clean-room**).** Run `git diff --name-only -- src/ | wc -l` — verify no source files modified during RED phase. **→ All SCs**

- [ ] 8. **Z3 check post-RED (**inline**).** Run `solve check` against post-RED enforcement output contract. **→ All SCs**

- [ ] 9. **GREEN phase (**sub-agent**).** Apply all 4 edits to `.opencode/skills/spec-creation/SKILL.md`:
  - Edit 1: Add `pipeline-readiness-gate` to Tasks table (SC-1)
  - Edit 2: Insert step 4.5 in Operating Protocol between traceability (step 4) and risk (step 5), with `chain: step_4` (SC-2)
  - Edit 3: Add Invocation table entry for `pipeline-readiness-gate` (SC-4)
  - Edit 4: Update symbolic rule `spec-creation-pipeline-readiness` trigger condition from `spec_sc_finalized == true` to correct pipeline position (SC-3)
  **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 10. **Z3 check GREEN (**inline**).** Run `solve check` against GREEN-phase output contract. **→ All SCs**

- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Run `git diff --name-only -- test/ | wc -l` — verify no test files modified during GREEN phase. **→ All SCs**

- [ ] 12. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-GREEN enforcement output contract. **→ All SCs**

- [ ] 13. **Checkpoint tag create (**clean-room**).** Create git checkpoint tag per `000-critical-rules.md` §Checkpoint Rollback Exception. **→ All SCs**

- [ ] 14. **Checkpoint commit (**clean-room**).** Commit all changes with message: `feat(spec-creation): position pipeline-readiness-gate in Tasks table, Operating Protocol, Invocation table, and symbolic rules`. **→ All SCs**

- [ ] 15. **Structural checks (**clean-room**).** Run lint/typecheck/format commands per `.opencode/AGENTS.md` Build/Lint/Test Commands. **→ All SCs**

- [ ] 16. **GREEN doublecheck (**clean-room**).** Verify GREEN-side SC evidence — confirm all 4 edits are present and correct. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 17. **GREEN VbC (**clean-room**).** Run verification-before-completion to verify all 5 SCs:
  - SC-1: `grep` for `pipeline-readiness-gate` in Tasks table section
  - SC-2: Verify step ordering: traceability step precedes pipeline-readiness-gate step which precedes risk step
  - SC-3: Verify updated trigger condition in symbolic rules block
  - SC-4: Verify `pipeline-readiness-gate` in Invocation table
  - SC-5: `git diff --stat` shows only SKILL.md changed
  **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 18. **Adversarial audit (**orchestrator multi-dispatch**).** Run `resolve-models` to select cross-family auditors. Dispatch `adversarial-audit --task verification-audit` with auditor_1 (remediate on non-clean-pass), then same task with auditor_2 (remediate on non-clean-pass). Collect both artifact paths. **→ All SCs**

- [ ] 19. **Cross-validate (**clean-room**).** Dispatch `adversarial-audit --task cross-validate` with auditor artifact paths from step 18. **→ All SCs**

- [ ] 20. **Regression check (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no existing enforcement tests regressed. **→ All SCs**

- [ ] 21. **Review prep (**clean-room**).** Dispatch `git-workflow --task review-prep` to prepare PR. **→ All SCs**

- [ ] 22. **Executive summary (**clean-room**).** Dispatch `completion-core --task completion` to append lifecycle event and produce chat exec summary. **→ All SCs**

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Re-run all SC verifications after commit. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

| ID | Criterion |
|----|-----------|
| C1 | `pipeline-readiness-gate` listed in spec-creation Tasks table |
| C2 | Numbered step for pipeline-readiness gate between traceability (step 4) and risk (step 5) in Operating Protocol |
| C3 | Symbolic rule `spec-creation-pipeline-readiness` trigger condition updated to fire at correct pipeline position |
| C4 | Invocation table includes task() call entry for pipeline-readiness-gate |
| C5 | Existing `pipeline-readiness-gate.md` task file is NOT modified — `git diff --stat` shows only SKILL.md changed |
| C6 | All 22 implementation-pipeline gate steps executed in order |
| C7 | Behavioral enforcement test written (RED) and verified passing (GREEN) |
| C8 | Adversarial audit and cross-validate completed with PASS consensus |
| C9 | Regression check passes |
| C10 | Review prep completed |
