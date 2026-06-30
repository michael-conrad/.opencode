# Implementation Plan — [.opencode#1605](https://github.com/michael-conrad/.opencode/issues/1605) — Position pipeline-readiness-gate in spec-creation SKILL.md

- **Goal:** Add `pipeline-readiness-gate` to the spec-creation SKILL.md Tasks table, insert a numbered step (4.5) in the Operating Protocol, add an Invocation table entry, and update the symbolic rule trigger condition.
- **Architecture:** Single file, 4 independent edits to `.opencode/skills/spec-creation/SKILL.md`. No other files modified.
- **Files:**
  - `.opencode/skills/spec-creation/SKILL.md` — 4 edits (Tasks table, Operating Protocol, Invocation table, symbolic rules block)

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

## Phase 1 — 4 edits to spec-creation SKILL.md

**Concern:** Add `pipeline-readiness-gate` to Tasks table, Operating Protocol, Invocation table, and symbolic rules block.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

**Entry conditions:** Feature branch exists, spec approved

**Exit conditions:** All 4 edits applied, `git diff --stat` shows only SKILL.md changed, all SCs verified

- [ ] 1. **Pre-RED baseline (**clean-room**).** Verify current state of `.opencode/skills/spec-creation/SKILL.md` — confirm Tasks table has only `create` and `completion`, Operating Protocol has step 4 (traceability) followed by step 5 (risk) with no step between, Invocation table has no `pipeline-readiness-gate` entry, and symbolic rule `spec-creation-pipeline-readiness` fires on `spec_sc_finalized == true`. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 2. **RED — Write behavioral enforcement test (**sub-agent**).** Write a behavioral test that sends a prompt to create a spec and verifies the agent dispatches `pipeline-readiness-gate` between traceability and risk. The test MUST FAIL at this point because the change doesn't exist yet. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 3. **Edit 1 — Add `pipeline-readiness-gate` to Tasks table (**sub-agent**).** Add a row for `pipeline-readiness-gate` to the Tasks table in `.opencode/skills/spec-creation/SKILL.md`, alongside the existing `create` and `completion` rows. **→ SC-1**

- [ ] 4. **Edit 2 — Insert step 4.5 in Operating Protocol (**sub-agent**).** Insert a new numbered step between step 4 (traceability) and step 5 (risk) in the Operating Protocol section. The step dispatches via `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")` with `chain: step_4`. Renumber subsequent steps (5→6, 6→7, 7→8, 8→9, 9→10, 10→11). **→ SC-2**

- [ ] 5. **Edit 3 — Add Invocation table entry (**sub-agent**).** Add a `pipeline-readiness-gate` row to the Invocation table with the canonical dispatch string `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")`. **→ SC-4**

- [ ] 6. **Edit 4 — Update symbolic rule trigger condition (**sub-agent**).** Change the `spec-creation-pipeline-readiness` symbolic rule trigger condition from `spec_sc_finalized == true` to fire at the correct pipeline position (between traceability and risk). The new condition should reference the pipeline position after traceability output is available and before risk analysis begins. **→ SC-3**

- [ ] 7. **GREEN — Verify behavioral test passes (**sub-agent**).** Re-run the behavioral enforcement test from step 2. It MUST PASS now that the edits are applied. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 8. **Structural verification (**inline**).** Run `git diff --stat` to confirm only `.opencode/skills/spec-creation/SKILL.md` is modified. Run grep assertions for each SC:
  - SC-1: `grep -c 'pipeline-readiness-gate'` in Tasks table section
  - SC-2: Verify step ordering: traceability step precedes pipeline-readiness-gate step which precedes risk step
  - SC-3: Verify updated trigger condition in symbolic rules block
  - SC-4: Verify `pipeline-readiness-gate` in Invocation table
  - SC-5: `git diff --stat` shows only SKILL.md changed **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 9. **Checkpoint commit (**inline**).** Commit all changes with message: `feat(spec-creation): position pipeline-readiness-gate in Tasks table, Operating Protocol, Invocation table, and symbolic rules`

- [ ] 10. **Adversarial audit (**clean-room**).** Dispatch adversarial audit of the plan deliverable. **→ All SCs**

- [ ] 11. **Cross-validate (**clean-room**).** Cross-validate audit findings against spec SCs. **→ All SCs**

- [ ] 12. **Regression check (**clean-room**).** Run existing enforcement tests to verify no regressions. **→ All SCs**

- [ ] 13. **Review prep (**clean-room**).** Prepare PR with summary of changes. **→ All SCs**

- [ ] 14. **Executive summary (**inline**).** Report completion with plan file path and PR URL. **→ All SCs**

#### Phase 1 VbC

- [ ] 15. **VbC (**clean-room**).** Verify all SCs: SC-1 (Tasks table entry), SC-2 (step ordering), SC-3 (trigger condition), SC-4 (Invocation entry), SC-5 (only SKILL.md changed). **→ SC-1, SC-2, SC-3, SC-4, SC-5**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1. Plan document written to `.opencode/.issues/1605/plan.md`
- C2. All 4 edits to `.opencode/skills/spec-creation/SKILL.md` applied
- C3. Behavioral enforcement test written (RED) and verified passing (GREEN)
- C4. `git diff --stat` shows only SKILL.md changed (SC-5)
- C5. All spec SCs (SC-1 through SC-5) verified PASS
- C6. Adversarial audit and cross-validate completed with PASS consensus
- C7. Regression check passes
- C8. Review prep completed
