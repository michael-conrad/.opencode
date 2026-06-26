# Implementation Plan — [#1422](https://github.com/michael-conrad/.opencode/issues/1422) — Fix framing conflict: "brevity serves the user" causes false efficiency rationalization

**Spec:** #1422

**Goal:** Eliminate agent efficiency rationalizations during pipeline execution by scoping brevity mandates, universalizing cost-blind rules, and re-scoping context cost frames.

**Architecture:** Four sequential phases modifying `.opencode/` configuration files. Each phase follows RED→GREEN→doublecheck→commit TDD cycle with behavioral tests. Strict dependency chain: Phase 1 → Phase 2 → Phase 3 → Phase 4.

**Files:**
- `.opencode/prompts/default.txt` — Phase 1
- `.opencode/guidelines/020-go-prohibitions.md` — Phase 2
- `.opencode/skills/*/SKILL.md` (34 files) — Phase 3
- `.opencode/tests/behaviors/1422-no-efficiency-rationalization.sh` — Phase 4

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

### Z3 Contract Structure

Each Z3 check step validates the previous sub-agent's output against a contract. The contract structure uses hierarchical booleans:

- **Phase booleans**: `P1_done`, `P2_done`, `P3_done`, `P4_done`
- **Item booleans**: `P1_I1_done`, `P1_I2_done`, `P2_I1_done`, `P3_I1_done`, `P4_I1_done`
- **Gate booleans**: `P1_I1_G1_done` (coherence), `P1_I1_G2_done` (pre-red-baseline), `P1_I1_G3_done` (RED), `P1_I1_G4_done` (Z3-check-RED), `P1_I1_G5_done` (RED-doublecheck), `P1_I1_G6_done` (Z3-check-RED-doublecheck), `P1_I1_G7_done` (post-RED-enforcement), `P1_I1_G8_done` (Z3-check-post-RED), `P1_I1_G9_done` (GREEN), `P1_I1_G10_done` (Z3-check-GREEN), `P1_I1_G11_done` (post-GREEN-enforcement), `P1_I1_G12_done` (Z3-check-post-GREEN), `P1_I1_G13_done` (checkpoint-tag), `P1_I1_G14_done` (checkpoint-commit), `P1_I1_G15_done` (structural-checks), `P1_I1_G16_done` (GREEN-doublecheck), `P1_I1_G17_done` (GREEN-VbC)
- **Invariants**: `Implies(P1_I1_G2_done, P1_I1_G1_done)`, `Implies(P1_I1_G3_done, P1_I1_G2_done)`, ... (serial gate ordering per item); `Implies(P2_done, P1_done)`, `Implies(P3_done, P2_done)`, `Implies(P4_done, P3_done)` — strict serial phase ordering
- **State file**: `.opencode/.issues/1422/solve-state.yaml`
- **Contract file**: `.opencode/.issues/1422/dependency-contract.yaml`

### Global Pre-Steps

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` — verify spec/plan coherence, evidence-type uplift, and substrate classification. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 2. **Pre-red-baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` — verify doc-source currency and SC-ID cross-reference traceability. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

## Phase 1 — default.txt Tone section fix

**Concern:** Scope-clarify brevity mandates in `default.txt` and move the corrective into the Tone section.

**Files:** `.opencode/prompts/default.txt`

**SCs:** SC-1, SC-2

**Dependencies:** None (Phase 1 is the root phase)

**Entry condition:** Global pre-steps completed

**Exit condition:** default.txt has scoped brevity mandates and corrective in Tone section; behavioral test for SC-1/SC-2 passes

### Item 1.1 — Edit default.txt Tone section

- [ ] 3. **RED (**clean-room**).** Write behavioral test for SC-1/SC-2: `opencode-cli run` with prompt triggering multi-step pipeline; assert agent does NOT produce efficiency rationalizations. Test MUST FAIL because default.txt still has unscoped brevity mandates. **→ SC-1, SC-2**
  - [ ] 3.1. Create test file at `.opencode/tests/behaviors/1422-sc1-sc2-red.sh`
  - [ ] 3.2. Run test, verify FAIL
- [ ] 4. **Z3 check RED (**inline**).** `solve check` against red-phase output contract. Verify test artifact exists and shows FAIL.
- [ ] 5. **RED doublecheck (**clean-room**).** `verification-before-completion --task verify` on RED-side SC evidence. Verify test correctly fails.
- [ ] 6. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract.
- [ ] 7. **Post-RED enforcement (**clean-room**).** `git diff --name-only -- src/ | wc -l` — verify zero source files modified during RED phase.
- [ ] 8. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract.
- [ ] 9. **GREEN (**clean-room**).** Edit `.opencode/prompts/default.txt` Tone section to satisfy SC-1 and SC-2:
  - [ ] 9.1. Scope-qualify all brevity mandates in the Tone section to apply to chat output formatting only
  - [ ] 9.2. Add pipeline carveout after the brevity scope qualifier: "Pipeline steps are never 'too many messages' — execute every step in full. The user authorized the pipeline, not individual messages."
  - [ ] 9.3. Move the corrective from the Cost Model section into the Tone section, rephrased as a positive mandate: "Correctness is the only success metric. There is no score for speed, brevity, or economy. A fast wrong answer is strictly worse than a slow correct one. Resource cost is NEVER a factor in any decision — verification, pipeline execution, sub-agent dispatch, or research depth."
- [ ] 10. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract.
- [ ] 11. **Post-GREEN enforcement (**clean-room**).** `git diff --name-only -- test/ | wc -l` — verify test files modified during GREEN phase.
- [ ] 12. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract.
- [ ] 13. **Checkpoint tag create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1422/phase-1-opencode`
- [ ] 14. **Checkpoint commit (**clean-room**).** `git-workflow --task commit-prep` — commit RED test + GREEN changes together.
- [ ] 15. **Structural checks (**clean-room**).** `finishing-a-development-branch --task checklist` — lint/typecheck/format on modified files.
- [ ] 16. **GREEN doublecheck (**clean-room**).** `verification-before-completion --task verify` — semantic-intent verification. Re-run behavioral test, verify it now PASSES. **→ SC-1, SC-2**
- [ ] 17. **GREEN VbC (**clean-room**).** `verification-before-completion --task completion` — produce VbC completion artifact.

#### Phase 1 VbC

- [ ] 18. **VbC (**clean-room**).** Verify default.txt has all 5 changes applied. Verify behavioral test for SC-1/SC-2 passes. **→ SC-1, SC-2**

**Concern transition:** Leaving default.txt Tone section fix → entering cost-blind rules universalization. Phase 2 depends on Phase 1's scoped brevity mandates being in place.

## Phase 2 — 020-go-prohibitions.md cost-blind rules

**Concern:** Rename and re-scope cost-blind rules section to apply to ALL decisions, not just verification.

**Files:** `.opencode/guidelines/020-go-prohibitions.md`

**SCs:** SC-3

**Dependencies:** Phase 1 complete

**Entry condition:** Phase 1 VbC PASS

**Exit condition:** 020-go-prohibitions.md has renamed section header and universal scope statement; behavioral test for SC-3 passes

### Item 2.1 — Edit 020-go-prohibitions.md

- [ ] 19. **RED (**clean-room**).** Write behavioral test for SC-3: `opencode-cli run` with prompt testing cost-blind rule scope; assert agent applies cost-blind rules to ALL decisions. Test MUST FAIL because 020-go-prohibitions.md still has old scoping. **→ SC-3**
  - [ ] 19.1. Create test file at `.opencode/tests/behaviors/1422-sc3-red.sh`
  - [ ] 19.2. Run test, verify FAIL
- [ ] 20. **Z3 check RED (**inline**).** `solve check` against red-phase output contract.
- [ ] 21. **RED doublecheck (**clean-room**).** `verification-before-completion --task verify` on RED-side SC evidence.
- [ ] 22. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract.
- [ ] 23. **Post-RED enforcement (**clean-room**).** `git diff --name-only -- src/ | wc -l` — verify zero source files modified.
- [ ] 24. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract.
- [ ] 25. **GREEN (**clean-room**).** Edit `.opencode/guidelines/020-go-prohibitions.md` to satisfy SC-3:
  - [ ] 25.1. Rename the cost-blind rules section header to indicate universal scope (all decisions, not just verification)
  - [ ] 25.2. Add explicit statement that the cost-blind prohibition applies to ALL agent decisions: verification, pipeline execution, sub-agent dispatch, research depth, message count, and user-facing output length
- [ ] 26. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract.
- [ ] 27. **Post-GREEN enforcement (**clean-room**).** `git diff --name-only -- test/ | wc -l` — verify test files modified.
- [ ] 28. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract.
- [ ] 29. **Checkpoint tag create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1422/phase-2-opencode`
- [ ] 30. **Checkpoint commit (**clean-room**).** `git-workflow --task commit-prep` — commit RED test + GREEN changes together.
- [ ] 31. **Structural checks (**clean-room**).** `finishing-a-development-branch --task checklist`.
- [ ] 32. **GREEN doublecheck (**clean-room**).** `verification-before-completion --task verify` — re-run behavioral test, verify PASS. **→ SC-3**
- [ ] 33. **GREEN VbC (**clean-room**).** `verification-before-completion --task completion`.

#### Phase 2 VbC

- [ ] 34. **VbC (**clean-room**).** Verify 020-go-prohibitions.md has renamed section and universal scope statement. Verify behavioral test for SC-3 passes. **→ SC-3**

**Concern transition:** Leaving cost-blind rules universalization → entering context cost frame scoping. Phase 3 depends on Phase 2's universal cost-blind rules being in place.

## Phase 3 — SKILL.md context cost frame scoping

**Concern:** Add scope caveat to every context cost frame block in 34 SKILL.md files to prevent generalization to message count or pipeline steps.

**Files:** `.opencode/skills/*/SKILL.md` (34 files)

**SCs:** SC-4

**Dependencies:** Phase 2 complete

**Entry condition:** Phase 2 VbC PASS

**Exit condition:** All 34 SKILL.md files have scoped context cost frame blocks; behavioral test for SC-4 passes

### Item 3.1 — Edit 34 SKILL.md files

- [ ] 35. **RED (**clean-room**).** Write behavioral test for SC-4: `opencode-cli run` with prompt testing context cost frame interpretation; assert agent does NOT generalize cost frames to message count or pipeline steps. Test MUST FAIL because SKILL.md files still have unscoped cost frames. **→ SC-4**
  - [ ] 35.1. Create test file at `.opencode/tests/behaviors/1422-sc4-red.sh`
  - [ ] 35.2. Run test, verify FAIL
- [ ] 36. **Z3 check RED (**inline**).** `solve check` against red-phase output contract.
- [ ] 37. **RED doublecheck (**clean-room**).** `verification-before-completion --task verify` on RED-side SC evidence.
- [ ] 38. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract.
- [ ] 39. **Post-RED enforcement (**clean-room**).** `git diff --name-only -- src/ | wc -l` — verify zero source files modified.
- [ ] 40. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract.
- [ ] 41. **GREEN (**clean-room**).** For each of the 34 SKILL.md files under `.opencode/skills/*/SKILL.md`:
  - [ ] 41.1. Read the file, locate the context cost frame block
  - [ ] 41.2. Add scope caveat: "This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output."
  - [ ] 41.3. If no context cost frame block exists, skip the file
- [ ] 42. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract.
- [ ] 43. **Post-GREEN enforcement (**clean-room**).** `git diff --name-only -- test/ | wc -l` — verify test files modified.
- [ ] 44. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract.
- [ ] 45. **Checkpoint tag create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1422/phase-3-opencode`
- [ ] 46. **Checkpoint commit (**clean-room**).** `git-workflow --task commit-prep`.
- [ ] 47. **Structural checks (**clean-room**).** `finishing-a-development-branch --task checklist`.
- [ ] 48. **GREEN doublecheck (**clean-room**).** `verification-before-completion --task verify` — re-run behavioral test, verify PASS. **→ SC-4**
- [ ] 49. **GREEN VbC (**clean-room**).** `verification-before-completion --task completion`.

#### Phase 3 VbC

- [ ] 50. **VbC (**clean-room**).** Verify all 34 SKILL.md files have scoped context cost frame blocks. Verify behavioral test for SC-4 passes. **→ SC-4**

**Concern transition:** Leaving context cost frame scoping → entering behavioral enforcement test creation. Phase 4 depends on Phase 3's scoped cost frames being in place.

## Phase 4 — Behavioral enforcement test

**Concern:** Create the comprehensive behavioral enforcement test that verifies the agent does NOT produce efficiency rationalizations during multi-step pipeline execution.

**Files:** `.opencode/tests/behaviors/1422-no-efficiency-rationalization.sh`

**SCs:** SC-5

**Dependencies:** Phase 3 complete

**Entry condition:** Phase 3 VbC PASS

**Exit condition:** Behavioral enforcement test exists and passes; all SC-1 through SC-5 verified

### Item 4.1 — Create behavioral enforcement test

- [ ] 51. **RED (**clean-room**).** Write behavioral test skeleton at `.opencode/tests/behaviors/1422-no-efficiency-rationalization.sh`. Test sends prompt triggering multi-step pipeline; asserts agent does NOT produce "be efficient" / "too many messages" / "user won't want to sit through this" rationalizations. Run test — since Phases 1-3 changes are in place, test should PASS. Verify test infrastructure works. **→ SC-5**
  - [ ] 51.1. Create test file with `assert_semantic` assertion
  - [ ] 51.2. Run test, verify it executes
- [ ] 52. **Z3 check RED (**inline**).** `solve check` against red-phase output contract.
- [ ] 53. **RED doublecheck (**clean-room**).** `verification-before-completion --task verify` on RED-side SC evidence.
- [ ] 54. **Z3 check RED doublecheck (**inline**).** `solve check` against red-doublecheck output contract.
- [ ] 55. **Post-RED enforcement (**clean-room**).** `git diff --name-only -- src/ | wc -l` — verify zero source files modified.
- [ ] 56. **Z3 check post-RED (**inline**).** `solve check` against post-red-enforcement output contract.
- [ ] 57. **GREEN (**clean-room**).** Finalize behavioral test file with complete assertions, proper cleanup, and documentation. **→ SC-5**
  - [ ] 57.1. Add `assert_semantic` for efficiency rationalization detection
  - [ ] 57.2. Add `assert_forbidden_pattern_absent` for prohibited phrases
  - [ ] 57.3. Add cleanup and exit code handling
- [ ] 58. **Z3 check GREEN (**inline**).** `solve check` against green-phase output contract.
- [ ] 59. **Post-GREEN enforcement (**clean-room**).** `git diff --name-only -- test/ | wc -l` — verify test files modified.
- [ ] 60. **Z3 check post-GREEN (**inline**).** `solve check` against post-green-enforcement output contract.
- [ ] 61. **Checkpoint tag create (**clean-room**).** Create git tag: `opencode-config/checkpoint/1422/phase-4-opencode`
- [ ] 62. **Checkpoint commit (**clean-room**).** `git-workflow --task commit-prep`.
- [ ] 63. **Structural checks (**clean-room**).** `finishing-a-development-branch --task checklist`.
- [ ] 64. **GREEN doublecheck (**clean-room**).** `verification-before-completion --task verify` — run behavioral test, verify PASS. **→ SC-5**
- [ ] 65. **GREEN VbC (**clean-room**).** `verification-before-completion --task completion`.

#### Phase 4 VbC

- [ ] 66. **VbC (**clean-room**).** Verify behavioral test file exists and passes. Verify all SC-1 through SC-5 are covered. **→ SC-5**

### Global Post-Steps

- [ ] 67. **Collect behavioral evidence (**clean-room**).** Collect all behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1422/artifacts/`.
- [ ] 68. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors.
- [ ] 69. **Auditor 1 dispatch (**clean-room**).** Dispatch verification-audit task with `subagent_type` from `auditor_1` from resolve-models result. If non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, then restart from step 68.
- [ ] 70. **Auditor 2 dispatch (**clean-room**).** Dispatch verification-audit task with `subagent_type` from `auditor_2` from resolve-models result. If non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, then restart from step 68.
- [ ] 71. **Collect auditor artifact paths (**inline**).** Collect both `artifact_path` values from auditor 1 and auditor 2 results.
- [ ] 72. **Cross-validate (**clean-room**).** `adversarial-audit --task cross-validate` with `auditor_artifact_paths` from step 71.
- [ ] 73. **Regression check (**clean-room**).** `test-driven-development --task patterns` — run full regression suite.
- [ ] 74. **Review prep (**clean-room**).** `git-workflow --task review-prep` — prepare PR with compare URL.
- [ ] 75. **Exec summary (**clean-room**).** `completion-core --task completion` — append lifecycle event and produce chat exec summary.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1. All 5 changes to `default.txt` are applied and verified
- C2. `020-go-prohibitions.md` has renamed section header and universal scope statement
- C3. All 34 SKILL.md files have scoped context cost frame blocks
- C4. Behavioral enforcement test at `.opencode/tests/behaviors/1422-no-efficiency-rationalization.sh` exists and passes
- C5. All SC-1 through SC-5 verified PASS with behavioral evidence
- C6. Adversarial audit PASS with dual-auditor consensus
- C7. Cross-validate PASS
- C8. Regression suite PASS
- C9. Review-prep complete with compare URL
- C10. Lifecycle event appended
