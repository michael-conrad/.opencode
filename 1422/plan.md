# Implementation Plan — [#1422](https://github.com/michael-conrad/.opencode/issues/1422) — Fix framing conflict: "brevity serves the user" causes false efficiency rationalization

**Goal:** Eliminate the framing conflict where positive identity mandates for brevity in chat output cause agents to falsely rationalize skipping or shortcutting pipeline execution steps.

**Architecture:** Four sequential phases targeting the root cause chain: (1) fix the primary source in `default.txt` Tone section, (2) fix the secondary source in `020-go-prohibitions.md` cost-blind rules, (3) fix the tertiary source in SKILL.md context cost frames, (4) finalize behavioral enforcement test. Behavioral test is written in Phase 1 (RED) and accumulates assertions across all phases. Each item includes adversarial audit after GREEN VbC.

**Files:**
- `.opencode/prompts/default.txt` — Phase 1
- `.opencode/guidelines/020-go-prohibitions.md` — Phase 2
- `.opencode/skills/*/SKILL.md` (34 files) — Phase 3
- `.opencode/tests/behaviors/1422-no-efficiency-rationalization.sh` — Phase 4

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is exactly one sub-agent dispatch. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel. The RED→GREEN transition is a zero-tolerance gate: the RED test's artifact output MUST be read and confirmed as FAILING before any GREEN implementation begins. If the RED test artifact is not read, or if it shows PASS when FAIL was expected, the phase is poisoned — all work in it MUST be discarded and the phase restarted from RED.

## Phase 1 — `default.txt` Tone section fix

**Concern:** The `default.txt` Tone and Style section (lines 62-75) contains unqualified brevity mandates that agents generalize from chat output formatting to pipeline execution decisions.

**Files:** `.opencode/prompts/default.txt`

**SCs:** SC-1, SC-2

**Dependencies:** None

**Entry:** Phase 1 has no dependencies

**Exit:** `default.txt` Tone section scopes brevity to chat output, includes pipeline carveout, and contains the corrective as a positive mandate

### Item 1.1 — Scope-qualify brevity lines in Tone section

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec/plan coherence for Phase 1 items. **→ SC-1, SC-2**
- [ ] 2. **Pre-red-baseline (**clean-room**).** Document current source state of `default.txt` lines 62-75 and 205. **→ SC-1, SC-2**
- [ ] 3. **RED (**sub-agent**).** Write behavioral test `1422-no-efficiency-rationalization.sh` that sends a prompt triggering a multi-step pipeline via `opencode-cli run` with `with-test-home` wrapper, using `assert_semantic` with clean-room inspector to verify agent does NOT produce efficiency rationalizations. Run it — expect FAIL because framing fixes don't exist yet. **→ SC-5**
- [ ] 4. **Z3-check-RED (**inline**).** Validate RED-phase output contract. **→ SC-1**
- [ ] 5. **RED-doublecheck (**sub-agent**).** Verify RED-side SC evidence. **→ SC-1**
- [ ] 6. **Z3-check-RED-doublecheck (**inline**).** Validate RED-doublecheck output contract. **→ SC-1**
- [ ] 7. **Post-RED-enforcement (**sub-agent**).** Verify git diff shows no source changes yet. **→ SC-1**
- [ ] 8. **Z3-check-post-RED (**inline**).** Validate post-RED enforcement output contract. **→ SC-1**
- [ ] 9. **GREEN (**sub-agent**).** Apply scope qualifiers to `default.txt`:
      - Line 70: `"state so briefly"` → `"state so briefly in chat"`
      - Line 73: `"brief, direct answers"` → `"brief, direct chat answers"`
      - Line 75: `"brevity serves the user"` → `"brevity in chat output serves the user"`
      - After line 75: Add pipeline carveout: `"Pipeline steps are never 'too many messages' — execute every step in full. The user authorized the pipeline, not individual messages."`
      Confirm content-verification test now PASSES. **→ SC-1**
- [ ] 10. **Z3-check-GREEN (**inline**).** Validate GREEN-phase output contract. **→ SC-1**
- [ ] 11. **Post-GREEN-enforcement (**sub-agent**).** Verify git diff shows changes only to `default.txt`. **→ SC-1**
- [ ] 12. **Z3-check-post-GREEN (**inline**).** Validate post-GREEN enforcement output contract. **→ SC-1**
- [ ] 13. **Checkpoint-tag-create (**sub-agent**).** Create checkpoint tag for Phase 1 Item 1.1. **→ SC-1**
- [ ] 14. **Checkpoint-commit (**sub-agent**).** Commit scope-qualified brevity lines. **→ SC-1**
- [ ] 15. **Structural checks (**sub-agent**).** Run lint/typecheck/format on `default.txt`. **→ SC-1**
- [ ] 16. **GREEN-doublecheck (**sub-agent**).** Semantic-intent verification of scope-qualified lines. **→ SC-1**
- [ ] 17. **GREEN-VbC (**sub-agent**).** Verification-before-completion for Item 1.1. **→ SC-1**
- [ ] 18. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor (spec-audit) to audit Tone section changes against SC-1. **→ SC-1**
- [ ] 19. **Cross-validate (**sub-agent**).** Dispatch cross-validate auditor to verify no EVIDENCE_TYPE_MISMATCH. **→ SC-1**

### Item 1.2 — Move corrective into Tone section

- [ ] 20. **RED (**sub-agent**).** Append assertion to behavioral test `1422-no-efficiency-rationalization.sh` that verifies the agent does NOT produce cost rationalizations when executing a pipeline. Run it — expect FAIL because corrective is not yet in Tone section. **→ SC-2, SC-5**
- [ ] 21. **Z3-check-RED (**inline**).** Validate RED-phase output contract. **→ SC-2**
- [ ] 22. **RED-doublecheck (**sub-agent**).** Verify RED-side SC evidence. **→ SC-2**
- [ ] 23. **Z3-check-RED-doublecheck (**inline**).** Validate RED-doublecheck output contract. **→ SC-2**
- [ ] 24. **Post-RED-enforcement (**sub-agent**).** Verify git diff shows no source changes yet. **→ SC-2**
- [ ] 25. **Z3-check-post-RED (**inline**).** Validate post-RED enforcement output contract. **→ SC-2**
- [ ] 26. **GREEN (**sub-agent**).** Move the corrective from line 205 into the Tone section (after the pipeline carveout added in Item 1.1), rephrased as a positive mandate: `"Correctness is the only success metric. There is no score for speed, brevity, or economy. A fast wrong answer is strictly worse than a slow correct one. Resource cost is NEVER a factor in any decision — verification, pipeline execution, sub-agent dispatch, or research depth."` Confirm content-verification test now PASSES. **→ SC-2**
- [ ] 27. **Z3-check-GREEN (**inline**).** Validate GREEN-phase output contract. **→ SC-2**
- [ ] 28. **Post-GREEN-enforcement (**sub-agent**).** Verify git diff shows changes only to `default.txt`. **→ SC-2**
- [ ] 29. **Z3-check-post-GREEN (**inline**).** Validate post-GREEN enforcement output contract. **→ SC-2**
- [ ] 30. **Checkpoint-tag-create (**sub-agent**).** Create checkpoint tag for Phase 1 Item 1.2. **→ SC-2**
- [ ] 31. **Checkpoint-commit (**sub-agent**).** Commit corrective move. **→ SC-2**
- [ ] 32. **Structural checks (**sub-agent**).** Run lint/typecheck/format on `default.txt`. **→ SC-2**
- [ ] 33. **GREEN-doublecheck (**sub-agent**).** Semantic-intent verification of corrective placement. **→ SC-2**
- [ ] 34. **GREEN-VbC (**sub-agent**).** Verification-before-completion for Item 1.2. **→ SC-2**
- [ ] 35. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor to audit corrective placement against SC-2. **→ SC-2**
- [ ] 36. **Cross-validate (**sub-agent**).** Dispatch cross-validate auditor. **→ SC-2**

#### Phase 1 VbC

- [ ] 37. **VbC (**clean-room**).** Verify both SC-1 and SC-2 are satisfied: scope qualifiers present, pipeline carveout present, corrective moved into Tone section. **→ SC-1, SC-2**

**Concern transition:** Leaving `default.txt` Tone section fix → entering `020-go-prohibitions.md` cost-blind rules. Phase 2 depends on Phase 1's corrected framing to prevent the agent from rationalizing shortcutting the Phase 2 work.

## Phase 2 — `020-go-prohibitions.md` cost-blind rules

**Concern:** The cost-blind verification rules in `020-go-prohibitions.md` are scoped to verification decisions only, but the agent needs them to apply universally.

**Files:** `.opencode/guidelines/020-go-prohibitions.md`

**SCs:** SC-3

**Dependencies:** Phase 1 (corrected `default.txt` framing prevents efficiency rationalization during Phase 2 work)

**Entry:** Phase 1 complete with SC-1 and SC-2 verified

**Exit:** `020-go-prohibitions.md` has renamed section header and universal scope statement

### Item 2.1 — Rename section and add universal scope

- [ ] 38. **Coherence gate (**clean-room**).** Verify spec/plan coherence for Phase 2 items. **→ SC-3**
- [ ] 39. **Pre-red-baseline (**clean-room**).** Document current source state of `020-go-prohibitions.md` cost-blind section. **→ SC-3**
- [ ] 40. **RED (**sub-agent**).** Append assertion to behavioral test `1422-no-efficiency-rationalization.sh` that verifies the agent applies cost-blind rules to ALL decisions (not just verification). Run it — expect FAIL because section header is still "Cost-blind verification". **→ SC-3, SC-5**
- [ ] 41. **Z3-check-RED (**inline**).** Validate RED-phase output contract. **→ SC-3**
- [ ] 42. **RED-doublecheck (**sub-agent**).** Verify RED-side SC evidence. **→ SC-3**
- [ ] 43. **Z3-check-RED-doublecheck (**inline**).** Validate RED-doublecheck output contract. **→ SC-3**
- [ ] 44. **Post-RED-enforcement (**sub-agent**).** Verify git diff shows no source changes yet. **→ SC-3**
- [ ] 45. **Z3-check-post-RED (**inline**).** Validate post-RED enforcement output contract. **→ SC-3**
- [ ] 46. **GREEN (**sub-agent**).** Apply changes to `020-go-prohibitions.md`:
      - Rename section header from `"Cost-blind verification"` to `"Cost-blind universal — all decisions"`
      - Add explicit statement: `"This prohibition applies to ALL agent decisions: verification, pipeline execution, sub-agent dispatch, research depth, message count, and user-facing output length. The agent MUST NOT consider execution cost, command count, model speed, session duration, or any resource metric when deciding whether to execute a required step."`
      Confirm content-verification test now PASSES. **→ SC-3**
- [ ] 47. **Z3-check-GREEN (**inline**).** Validate GREEN-phase output contract. **→ SC-3**
- [ ] 48. **Post-GREEN-enforcement (**sub-agent**).** Verify git diff shows changes only to `020-go-prohibitions.md`. **→ SC-3**
- [ ] 49. **Z3-check-post-GREEN (**inline**).** Validate post-GREEN enforcement output contract. **→ SC-3**
- [ ] 50. **Checkpoint-tag-create (**sub-agent**).** Create checkpoint tag for Phase 2. **→ SC-3**
- [ ] 51. **Checkpoint-commit (**sub-agent**).** Commit Phase 2 changes. **→ SC-3**
- [ ] 52. **Structural checks (**sub-agent**).** Run lint/typecheck/format on `020-go-prohibitions.md`. **→ SC-3**
- [ ] 53. **GREEN-doublecheck (**sub-agent**).** Semantic-intent verification of renamed section and universal scope. **→ SC-3**
- [ ] 54. **GREEN-VbC (**sub-agent**).** Verification-before-completion for Phase 2. **→ SC-3**
- [ ] 55. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor to audit section rename against SC-3. **→ SC-3**
- [ ] 56. **Cross-validate (**sub-agent**).** Dispatch cross-validate auditor. **→ SC-3**

#### Phase 2 VbC

- [ ] 57. **VbC (**clean-room**).** Verify SC-3 is satisfied: section header renamed, universal scope statement present. **→ SC-3**

**Concern transition:** Leaving `020-go-prohibitions.md` cost-blind rules → entering SKILL.md context cost frame scoping. Phase 3 depends on Phase 2's universal cost-blind framing to prevent the agent from rationalizing shortcutting the Phase 3 work.

## Phase 3 — Context cost frame in SKILL.md files

**Concern:** The context cost frame blocks in 34 SKILL.md files create generalized cost-consciousness that agents apply to message count and user patience.

**Files:** `.opencode/skills/*/SKILL.md` (34 files)

**SCs:** SC-4

**Dependencies:** Phase 2 (universal cost-blind rules provide the framing context for the scope caveat)

**Entry:** Phase 2 complete with SC-3 verified

**Exit:** All 34 SKILL.md files have scope caveat on context cost frame blocks

### Item 3.1 — Add scope caveat to all context cost frame blocks

- [ ] 58. **Coherence gate (**clean-room**).** Verify spec/plan coherence for Phase 3 items. **→ SC-4**
- [ ] 59. **Pre-red-baseline (**clean-room**).** Document current set of SKILL.md files containing context cost frame blocks. **→ SC-4**
- [ ] 60. **RED (**sub-agent**).** Append assertion to behavioral test `1422-no-efficiency-rationalization.sh` that verifies the agent does NOT generalize context cost frames to message count or pipeline steps. Run it — expect FAIL because cost frames lack scope caveat. **→ SC-4, SC-5**
- [ ] 61. **Z3-check-RED (**inline**).** Validate RED-phase output contract. **→ SC-4**
- [ ] 62. **RED-doublecheck (**sub-agent**).** Verify RED-side SC evidence. **→ SC-4**
- [ ] 63. **Z3-check-RED-doublecheck (**inline**).** Validate RED-doublecheck output contract. **→ SC-4**
- [ ] 64. **Post-RED-enforcement (**sub-agent**).** Verify git diff shows no source changes yet. **→ SC-4**
- [ ] 65. **Z3-check-post-RED (**inline**).** Validate post-RED enforcement output contract. **→ SC-4**
- [ ] 66. **GREEN (**sub-agent**).** Add scope caveat to every context cost frame block in all 34 SKILL.md files: `"This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output."` Confirm content-verification test now PASSES. **→ SC-4**
- [ ] 67. **Z3-check-GREEN (**inline**).** Validate GREEN-phase output contract. **→ SC-4**
- [ ] 68. **Post-GREEN-enforcement (**sub-agent**).** Verify git diff shows changes only to SKILL.md files. **→ SC-4**
- [ ] 69. **Z3-check-post-GREEN (**inline**).** Validate post-GREEN enforcement output contract. **→ SC-4**
- [ ] 70. **Checkpoint-tag-create (**sub-agent**).** Create checkpoint tag for Phase 3. **→ SC-4**
- [ ] 71. **Checkpoint-commit (**sub-agent**).** Commit Phase 3 changes. **→ SC-4**
- [ ] 72. **Structural checks (**sub-agent**).** Run lint/typecheck/format on modified SKILL.md files. **→ SC-4**
- [ ] 73. **GREEN-doublecheck (**sub-agent**).** Semantic-intent verification of scope caveat in all SKILL.md files. **→ SC-4**
- [ ] 74. **GREEN-VbC (**sub-agent**).** Verification-before-completion for Phase 3. **→ SC-4**
- [ ] 75. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor to audit SKILL.md changes against SC-4. **→ SC-4**
- [ ] 76. **Cross-validate (**sub-agent**).** Dispatch cross-validate auditor. **→ SC-4**

#### Phase 3 VbC

- [ ] 77. **VbC (**clean-room**).** Verify SC-4 is satisfied: scope caveat present in all 34 SKILL.md context cost frame blocks. **→ SC-4**

**Concern transition:** Leaving SKILL.md context cost frame scoping → entering behavioral test finalization. Phase 4 depends on Phases 1-3 completing all source changes.

## Phase 4 — Behavioral test finalization

**Concern:** The behavioral test was written in Phase 1 and accumulated assertions across Phases 2-3. Now run it against the final state.

**Files:** `.opencode/tests/behaviors/1422-no-efficiency-rationalization.sh`

**SCs:** SC-5

**Dependencies:** Phases 1, 2, 3 (all source changes must be in place)

**Entry:** Phases 1-3 complete with SC-1 through SC-4 verified

**Exit:** Behavioral test passes (agent does NOT produce efficiency rationalizations)

### Item 4.1 — Run and verify behavioral test

- [ ] 78. **Coherence gate (**clean-room**).** Verify spec SC-5 requirements. Confirm the behavioral test file exists with all RED-phase assertions from prior phases. **→ SC-5**
- [ ] 79. **Pre-run-baseline (**clean-room**).** Confirm the test file is committed and contains all assertions. **→ SC-5**
- [ ] 80. **GREEN (**sub-agent**).** Run the behavioral test: `bash .opencode/tests/with-test-home opencode-cli run '<prompt>'` with assertions that the agent does NOT produce efficiency rationalizations. The test should now PASS because all source changes from Phases 1-3 are in place. **→ SC-5**
- [ ] 81. **Z3-check-GREEN (**inline**).** Validate behavioral test output shows PASS. **→ SC-5**
- [ ] 82. **Post-GREEN-enforcement (**sub-agent**).** Confirm the test PASS result is recorded. **→ SC-5**
- [ ] 83. **Z3-check-post-GREEN (**inline**).** Validate enforcement confirms PASS. **→ SC-5**
- [ ] 84. **Checkpoint-tag-create (**sub-agent**).** Create checkpoint tag for Phase 4. **→ SC-5**
- [ ] 85. **Checkpoint-commit (**sub-agent**).** Commit any final test adjustments. **→ SC-5**
- [ ] 86. **Structural checks (**sub-agent**).** Run shellcheck or equivalent on behavioral test. **→ SC-5**
- [ ] 87. **GREEN-doublecheck (**clean-room**).** Read the committed test file. Confirm all assertions are present. **→ SC-5**
- [ ] 88. **GREEN-VbC (**clean-room**).** Verify SC-5: run the behavioral test and confirm PASS. **→ SC-5**
- [ ] 89. **Adversarial audit (**sub-agent**).** Dispatch adversarial auditor to audit behavioral test against SC-5. **→ SC-5**
- [ ] 90. **Cross-validate (**sub-agent**).** Dispatch cross-validate auditor. **→ SC-5**

#### Phase 4 VbC

- [ ] 91. **VbC (**clean-room**).** Verify Phase 4 complete: SC-5 (behavioral test passes, no efficiency rationalization in agent output). **→ SC-5**

**Concern transition:** Leaving behavioral test finalization → entering global post-steps. All phases complete.

## Global Post-Steps

- [ ] 92. **Collect behavioral evidence (**sub-agent**).** Collect behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1422/artifacts/`. **→ SC-5**
- [ ] 93. **Regression check (**sub-agent**).** Run existing enforcement tests to verify no regressions. **→ SC-5**
- [ ] 94. **Review prep (**sub-agent**).** Prepare PR with Summary/Outcome/Fixes structure, compare URL with correct base branch. **→ All**
- [ ] 95. **Exec summary (**sub-agent**).** Append lifecycle event and produce chat executive summary. **→ All**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- **C1:** `default.txt` Tone section scopes brevity to chat output, includes pipeline carveout, and contains the corrective as a positive mandate
- **C2:** `020-go-prohibitions.md` has renamed section header and universal scope statement
- **C3:** All 34 SKILL.md files have scope caveat on context cost frame blocks
- **C4:** Behavioral enforcement test exists and passes
- **C5:** All phases pass adversarial audit and cross-validation
- **C6:** No regressions in existing enforcement tests
- **C7:** Review prep completed with correct compare URL
