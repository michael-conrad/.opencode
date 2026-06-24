# Implementation Plan — [`.opencode#1374`](https://github.com/michael-conrad/.opencode/issues/1374) — writing-plans Plan Format Requirements fix

- [ ] **Goal:** Fix `create.md` §Plan Format Requirements which hardcodes step sequences instead of referencing `implementation-pipeline/SKILL.md`. Fix dispatch indicator semantics (3 distinct modes). Fix stale references in `write.md`, `audit-fidelity.md`, `audit-concern.md`, `SKILL.md`, `validate.md`. 6 fix items across 5 phases.
- [ ] **Architecture:** Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 (sequential). Phase 1 rewrites the Plan Format Requirements section. Phases 2-5 fix individual task files. Each phase is independent except Phase 1 must complete first (it defines the format the other files should reference).
- [ ] **Files:**
  - `.opencode/skills/writing-plans/tasks/create.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/write.md` — Phase 2
  - `.opencode/skills/writing-plans/tasks/audit-fidelity.md` — Phase 3
  - `.opencode/skills/writing-plans/tasks/audit-concern.md` — Phase 3
  - `.opencode/skills/writing-plans/SKILL.md` — Phase 4
  - `.opencode/skills/writing-plans/tasks/validate.md` — Phase 5

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1 — Fix create.md §Plan Format Requirements

**Concern:** create.md Plan Format Requirements section — remove hardcoded step sequences, fix dispatch indicators, fix validation rules
**Files:** `.opencode/skills/writing-plans/tasks/create.md`
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-13, SC-14
**Dependencies:** None
**Entry condition:** create.md §Plan Format Requirements hardcodes RED+green chain (lines 121-123), phase completion block (lines 125-132), concern transition format (lines 134-139), exit criteria format (lines 141-143). Dispatch indicators `(**sub-agent**)` and `(**clean-room**)` defined as identical. Validation rules include step sequence checks.
**Exit condition:** All hardcoded step sequences removed. Discovery directive references `implementation-pipeline/SKILL.md`. Dispatch indicators have 3 distinct modes. Validation rules check format only — no step sequence. Prohibited patterns present.

**Artifact paths:** `./tmp/1374/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 1. **Coherence gate (**clean-room**).** Verify all 8 SCs are coherent and non-conflicting. Read spec SC table, confirm evidence types match verification methods. Read current create.md Plan Format Requirements section to confirm all defects exist.
- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture current state of create.md Plan Format Requirements section.
  - [ ] 2a. grep for "RED → GREEN" in create.md — present
  - [ ] 2b. grep for "Phase completion" in Plan Format Requirements — present
  - [ ] 2c. grep for "Concern transition" in Plan Format Requirements — present
  - [ ] 2d. grep for "C1 through C{N}" in Plan Format Requirements — present
  - [ ] 2e. grep for "clean-room sub-agent" in create.md — present (defective dispatch indicator)
  - [ ] 2f. grep for "implementation-pipeline/SKILL.md" in Plan Format Requirements — absent (no discovery directive)
  - [ ] 2g. grep for "sub-step expansion" in create.md — absent
  - [ ] 2h. grep for "Prohibited Patterns" in create.md — present
  - [ ] 2i. Save all baselines

#### RED+green P1-I1 — Remove hardcoded step sequences, add discovery directive

- [ ] 3. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read create.md Plan Format Requirements section and report what step sequences it defines' --model <model>`. Save to `./tmp/1374/artifacts/red-p1i1-stderr.log`.
- [ ] 4. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/red-p1i1-stderr.log`. Assert agent reports that create.md defines a RED+green chain, phase completion block, concern transition format, and exit criteria format. Must FAIL because these should not be in the format spec. **→ SC-1**
- [ ] 5. **RED doublecheck (**clean-room**).** Confirm Step 4 returned FAIL as expected.
- [ ] 6. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 7. **GREEN (**clean-room**).** Rewrite create.md §Plan Format Requirements to remove all hardcoded step sequences. **→ SC-1, SC-2, SC-3**
  - [ ] 7a. Remove RED+green chain specification (lines 121-123)
  - [ ] 7b. Remove phase completion block (lines 125-132)
  - [ ] 7c. Remove concern transition format (lines 134-139)
  - [ ] 7d. Remove exit criteria format (lines 141-143)
  - [ ] 7e. Add discovery directive: "Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table at plan-creation time. Every gate in that table becomes a numbered step in the plan."
  - [ ] 7f. Add sub-step expansion directive: "Gates with sub-steps (e.g., adversarial-audit with resolve-models → auditor_1 → remediate → auditor_2 → cross-validate) MUST be expanded into multiple `- [ ] N.` entries."
- [ ] 8. **Post-GREEN enforcement (**clean-room**).** Verify create.md modified.
- [ ] 9. **Structural checks (**clean-room**).** `wc -w` on create.md — under 3,000 words.
- [ ] 10. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read create.md Plan Format Requirements section and report what step sequences it defines' --model <model>` again. Save to `./tmp/1374/artifacts/green-p1i1-stderr.log`.
- [ ] 11. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/green-p1i1-stderr.log`. Assert agent reports that create.md does NOT define any step sequence and references implementation-pipeline for gate discovery. Must PASS. **→ SC-1, SC-2, SC-3**
  - [ ] 11a. grep for "RED → GREEN" in create.md — absent
  - [ ] 11b. grep for "Phase completion" in Plan Format Requirements — absent
  - [ ] 11c. grep for "Concern transition" in Plan Format Requirements — absent
  - [ ] 11d. grep for "C1 through C{N}" in Plan Format Requirements — absent
  - [ ] 11e. grep for "implementation-pipeline/SKILL.md" in Plan Format Requirements — present
  - [ ] 11f. grep for "sub-step expansion" in create.md — present
- [ ] 12. **Checkpoint commit (**inline**).** `git commit -m "create.md: remove hardcoded step sequences from Plan Format Requirements, add discovery directive"`

#### RED+green P1-I2 — Fix dispatch indicators to 3 distinct modes

- [ ] 13. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read create.md dispatch indicators section and report what each indicator means' --model <model>`. Save to `./tmp/1374/artifacts/red-p1i2-stderr.log`.
- [ ] 14. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/red-p1i2-stderr.log`. Assert agent reports that `(**sub-agent**)` and `(**clean-room**)` are defined as the same thing. Must FAIL because they should be distinct. **→ SC-4, SC-5, SC-6**
- [ ] 15. **RED doublecheck (**clean-room**).** Confirm Step 14 returned FAIL as expected.
- [ ] 16. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 17. **GREEN (**clean-room**).** Fix dispatch indicators in create.md §Plan Format Requirements. **→ SC-4, SC-5, SC-6**
  - [ ] 17a. Change `(**sub-agent**)` definition from "clean-room sub-agent" to "sub-agent with context (not blind)"
  - [ ] 17b. Change `(**clean-room**)` definition from "same as sub-agent" to "blind sub-agent (no prior context)"
  - [ ] 17c. Verify `(**inline**)` is defined as "orchestrator executes directly"
- [ ] 18. **Post-GREEN enforcement (**clean-room**).** Verify dispatch indicators modified.
- [ ] 19. **Structural checks (**clean-room**).** `wc -w` on create.md — under 3,000 words.
- [ ] 20. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read create.md dispatch indicators section and report what each indicator means' --model <model>` again. Save to `./tmp/1374/artifacts/green-p1i2-stderr.log`.
- [ ] 21. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/green-p1i2-stderr.log`. Assert agent reports 3 distinct modes with correct semantics. Must PASS. **→ SC-4, SC-5, SC-6**
  - [ ] 21a. grep for "sub-agent with context" in create.md — present
  - [ ] 21b. grep for "blind" in create.md dispatch indicators — present
  - [ ] 21c. grep for "orchestrator executes directly" in create.md — present
  - [ ] 21d. grep for "clean-room sub-agent" in create.md — absent (old defective definition)
- [ ] 22. **Checkpoint commit (**inline**).** `git commit -m "create.md: fix dispatch indicators — 3 distinct modes with correct semantics"`

#### RED+green P1-I3 — Fix prohibited patterns and validation rules

- [ ] 23. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read create.md Plan Format Requirements validation rules and report what they check' --model <model>`. Save to `./tmp/1374/artifacts/red-p1i3-stderr.log`.
- [ ] 24. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/red-p1i3-stderr.log`. Assert agent reports validation rules include step sequence checks (RED, GREEN, doublecheck, commit). Must FAIL because validation rules should check format only. **→ SC-13, SC-14**
- [ ] 25. **RED doublecheck (**clean-room**).** Confirm Step 24 returned FAIL as expected.
- [ ] 26. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 27. **GREEN (**clean-room**).** Fix validation rules and prohibited patterns in create.md §Plan Format Requirements. **→ SC-13, SC-14**
  - [ ] 27a. Remove validation rule 8 (RED+green interleaved ordering)
  - [ ] 27b. Ensure no validation rule references "RED", "GREEN", "doublecheck", or "commit" as a sequence
  - [ ] 27c. Verify prohibited patterns list is present (no dispatch tables, no TBD/TODO, no zero-indexed numbering, no line number references)
- [ ] 28. **Post-GREEN enforcement (**clean-room**).** Verify validation rules modified.
- [ ] 29. **Structural checks (**clean-room**).** `wc -w` on create.md — under 3,000 words.
- [ ] 30. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read create.md Plan Format Requirements validation rules and report what they check' --model <model>` again. Save to `./tmp/1374/artifacts/green-p1i3-stderr.log`.
- [ ] 31. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/green-p1i3-stderr.log`. Assert agent reports validation rules check format only — no step sequence. Must PASS. **→ SC-13, SC-14**
  - [ ] 31a. grep for "Prohibited Patterns" in create.md — present
  - [ ] 31b. Count validation rules — none reference "RED" or "GREEN" or "doublecheck" or "commit" as a sequence
- [ ] 32. **Checkpoint commit (**inline**).** `git commit -m "create.md: fix validation rules — format only, no step sequence"`

#### Phase 1 completion

- [ ] 33. **VbC (**clean-room**).** Verify SC-1 through SC-6, SC-13, SC-14 all pass.
  - [ ] 33a. Run all grep assertions from each item's GREEN doublecheck
  - [ ] 33b. Re-run all 3 behavioral test artifacts and dispatch sub-agents to assert — all must PASS
  - [ ] 33c. Confirm create.md modified correctly
- [ ] 34. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors for verification-audit.
- [ ] 35. **Auditor 1: verification-audit (**clean-room**).** Dispatch `adversarial-audit --task verification-audit --issue 1374` with `audit_phase: post_implementation` to auditor_1. On non-clean-pass: remediate, re-run resolve-models, restart from Step 34.
- [ ] 36. **Auditor 2: verification-audit (**clean-room**).** Dispatch same to auditor_2. On non-clean-pass: remediate, re-run resolve-models, restart from Step 34. Both PASS: collect artifact paths.
- [ ] 37. **Cross-validate (**clean-room**).** Consensus check.
- [ ] 38. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 39. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving create.md Plan Format Requirements (Phase 1) → entering write.md fixes (Phase 2). Phase 2 depends on Phase 1 establishing the corrected format so write.md can reference it.

---

## Phase 2 — Fix write.md

**Concern:** write.md — remove stale dispatch table references, update to reference implementation-pipeline step sequence
**Files:** `.opencode/skills/writing-plans/tasks/write.md`
**SCs:** SC-7, SC-8
**Dependencies:** Phase 1
**Entry condition:** write.md line 5 says "validate dispatch table references". Line 22 says "Write each phase section with Pre-RED Common, Per-Item RED+green Chains, Post-RED/green".
**Exit condition:** write.md does not reference "dispatch table". References implementation-pipeline for step sequence.

**Artifact paths:** `./tmp/1374/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 40. **Coherence gate (**clean-room**).** Verify SC-7 and SC-8 consistent with Phase 1 exit state. Read current write.md to confirm defects exist.
- [ ] 41. **Pre-RED baseline (**clean-room**).** grep for "dispatch table" in write.md — present. grep for "Pre-RED Common" in write.md — present. grep for "implementation-pipeline" in write.md — absent.

#### RED+green P2-I1 — Fix write.md

- [ ] 42. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read write.md and report what format it tells the agent to produce' --model <model>`. Save to `./tmp/1374/artifacts/red-p2i1-stderr.log`.
- [ ] 43. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/red-p2i1-stderr.log`. Assert agent reports write.md references dispatch tables and old RED+green format. Must FAIL. **→ SC-7, SC-8**
- [ ] 44. **RED doublecheck (**clean-room**).** Confirm Step 43 returned FAIL as expected.
- [ ] 45. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 46. **GREEN (**clean-room**).** Fix write.md. **→ SC-7, SC-8**
  - [ ] 46a. Replace "validate dispatch table references" with "validate checklist format"
  - [ ] 46b. Replace "Write each phase section with Pre-RED Common, Per-Item RED+green Chains, Post-RED/green" with "Write each phase section following the implementation-pipeline step sequence"
- [ ] 47. **Post-GREEN enforcement (**clean-room**).** Verify write.md modified.
- [ ] 48. **Structural checks (**clean-room**).** `wc -w` on write.md — under 3,000 words.
- [ ] 49. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read write.md and report what format it tells the agent to produce' --model <model>` again. Save to `./tmp/1374/artifacts/green-p2i1-stderr.log`.
- [ ] 50. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/green-p2i1-stderr.log`. Assert agent reports write.md references checklist format and implementation-pipeline. Must PASS. **→ SC-7, SC-8**
  - [ ] 50a. grep for "dispatch table" in write.md — absent
  - [ ] 50b. grep for "implementation-pipeline" in write.md — present
- [ ] 51. **Checkpoint commit (**inline**).** `git commit -m "write.md: remove dispatch table references, add implementation-pipeline reference"`

#### Phase 2 completion

- [ ] 52. **VbC (**clean-room**).** Verify SC-7 and SC-8 pass.
- [ ] 53. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 54. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, restart from Step 53.
- [ ] 55. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, restart from Step 53. Both PASS.
- [ ] 56. **Cross-validate (**clean-room**).** Consensus.
- [ ] 57. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 58. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving write.md (Phase 2) → entering audit file fixes (Phase 3). Phase 3 fixes the sub-agent context violation in both audit files.

---

## Phase 3 — Fix audit-fidelity.md and audit-concern.md

**Concern:** audit-fidelity.md and audit-concern.md — remove "with auditor sub-agent type context" which sub-agents cannot set
**Files:** `.opencode/skills/writing-plans/tasks/audit-fidelity.md`, `.opencode/skills/writing-plans/tasks/audit-concern.md`
**SCs:** SC-9, SC-10
**Dependencies:** None
**Entry condition:** Both files contain "with auditor sub-agent type context" at line 5.
**Exit condition:** Both files do not contain the phrase. Replaced with "auditor subagent_type is passed by orchestrator in task context".

**Artifact paths:** `./tmp/1374/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 59. **Coherence gate (**clean-room**).** Verify SC-9 and SC-10 consistent. Read both files to confirm defects.
- [ ] 60. **Pre-RED baseline (**clean-room**).** grep for "with auditor sub-agent type context" in audit-fidelity.md — present. Same for audit-concern.md — present.

#### RED+green P3-I1 — Fix both audit files

- [ ] 61. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute audit-fidelity task from writing-plans' --model <model>`. Save to `./tmp/1374/artifacts/red-p3i1-stderr.log`.
- [ ] 62. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/red-p3i1-stderr.log`. Assert stderr contains "with auditor sub-agent type context". Must FAIL. **→ SC-9, SC-10**
- [ ] 63. **RED doublecheck (**clean-room**).** Confirm Step 62 returned FAIL as expected.
- [ ] 64. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 65. **GREEN (**clean-room**).** Fix both audit files. **→ SC-9, SC-10**
  - [ ] 65a. In audit-fidelity.md: remove "with auditor sub-agent type context". Replace with "auditor subagent_type is passed by orchestrator in task context, not set by sub-agent".
  - [ ] 65b. In audit-concern.md: same change.
- [ ] 66. **Post-GREEN enforcement (**clean-room**).** Verify both files modified.
- [ ] 67. **Structural checks (**clean-room**).** `wc -w` on both files — each under 3,000 words.
- [ ] 68. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'execute audit-fidelity task from writing-plans' --model <model>` again. Save to `./tmp/1374/artifacts/green-p3i1-stderr.log`.
- [ ] 69. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/green-p3i1-stderr.log`. Assert stderr does NOT contain "with auditor sub-agent type context". Must PASS. **→ SC-9, SC-10**
  - [ ] 69a. grep for "with auditor sub-agent type context" in audit-fidelity.md — absent
  - [ ] 69b. grep for "with auditor sub-agent type context" in audit-concern.md — absent
- [ ] 70. **Checkpoint commit (**inline**).** `git commit -m "audit-fidelity.md, audit-concern.md: remove sub-agent context violation"`

#### Phase 3 completion

- [ ] 71. **VbC (**clean-room**).** Verify SC-9 and SC-10 pass.
- [ ] 72. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 73. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, restart from Step 72.
- [ ] 74. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, restart from Step 72. Both PASS.
- [ ] 75. **Cross-validate (**clean-room**).** Consensus.
- [ ] 76. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 77. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving audit files (Phase 3) → entering SKILL.md fix (Phase 4). Phase 4 replaces the hardcoded 21-step pipeline with a reference to plan-creation-pipeline.

---

## Phase 4 — Fix SKILL.md

**Concern:** SKILL.md — replace hardcoded 21-step pipeline with reference to plan-creation-pipeline skill
**Files:** `.opencode/skills/writing-plans/SKILL.md`
**SCs:** SC-11
**Dependencies:** None
**Entry condition:** SKILL.md lines 58-84 hardcode a 21-step plan-creation pipeline.
**Exit condition:** SKILL.md does not hardcode 21-step pipeline. References plan-creation-pipeline skill instead.

**Artifact paths:** `./tmp/1374/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 78. **Coherence gate (**clean-room**).** Verify SC-11 consistent. Read SKILL.md to confirm 21-step pipeline is hardcoded.
- [ ] 79. **Pre-RED baseline (**clean-room**).** grep for "21-step" in SKILL.md — present. grep for "plan-creation-pipeline" in SKILL.md — absent.

#### RED+green P4-I1 — Fix SKILL.md

- [ ] 80. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read writing-plans SKILL.md and report how plan creation works' --model <model>`. Save to `./tmp/1374/artifacts/red-p4i1-stderr.log`.
- [ ] 81. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/red-p4i1-stderr.log`. Assert agent reports a 21-step pipeline for plan creation. Must FAIL because it should reference plan-creation-pipeline. **→ SC-11**
- [ ] 82. **RED doublecheck (**clean-room**).** Confirm Step 81 returned FAIL as expected.
- [ ] 83. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 84. **GREEN (**clean-room**).** Fix SKILL.md. **→ SC-11**
  - [ ] 84a. Replace hardcoded 21-step pipeline (lines 58-84) with reference to plan-creation-pipeline skill
  - [ ] 84b. Add cross-reference to plan-creation-pipeline in Cross-References section
- [ ] 85. **Post-GREEN enforcement (**clean-room**).** Verify SKILL.md modified.
- [ ] 86. **Structural checks (**clean-room**).** `wc -w` on SKILL.md — under 4,000 words.
- [ ] 87. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read writing-plans SKILL.md and report how plan creation works' --model <model>` again. Save to `./tmp/1374/artifacts/green-p4i1-stderr.log`.
- [ ] 88. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/green-p4i1-stderr.log`. Assert agent reports plan creation uses plan-creation-pipeline skill. Must PASS. **→ SC-11**
  - [ ] 88a. grep for "21-step" in SKILL.md — absent
  - [ ] 88b. grep for "plan-creation-pipeline" in SKILL.md — present
- [ ] 89. **Checkpoint commit (**inline**).** `git commit -m "SKILL.md: replace hardcoded 21-step pipeline with plan-creation-pipeline reference"`

#### Phase 4 completion

- [ ] 90. **VbC (**clean-room**).** Verify SC-11 passes.
- [ ] 91. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 92. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, restart from Step 91.
- [ ] 93. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, restart from Step 91. Both PASS.
- [ ] 94. **Cross-validate (**clean-room**).** Consensus.
- [ ] 95. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 96. **Review prep (**clean-room**).** `git-workflow review-prep`.

**Concern transition:** Leaving SKILL.md (Phase 4) → entering validate.md fix (Phase 5). Phase 5 adds implementation-pipeline validation rule.

---

## Phase 5 — Fix validate.md

**Concern:** validate.md — add validation rule for implementation-pipeline step sequence match
**Files:** `.opencode/skills/writing-plans/tasks/validate.md`
**SCs:** SC-12
**Dependencies:** None
**Entry condition:** validate.md does not validate against implementation-pipeline step sequence.
**Exit condition:** validate.md has validation rule checking plan steps match implementation-pipeline gates.

**Artifact paths:** `./tmp/1374/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 97. **Coherence gate (**clean-room**).** Verify SC-12 consistent. Read validate.md to confirm no implementation-pipeline validation.
- [ ] 98. **Pre-RED baseline (**clean-room**).** grep for "implementation-pipeline" in validate.md — absent.

#### RED+green P5-I1 — Fix validate.md

- [ ] 99. **RED: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read validate.md and report what validation rules it has' --model <model>`. Save to `./tmp/1374/artifacts/red-p5i1-stderr.log`.
- [ ] 100. **RED: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/red-p5i1-stderr.log`. Assert agent reports no validation rule for implementation-pipeline step sequence match. Must FAIL. **→ SC-12**
- [ ] 101. **RED doublecheck (**clean-room**).** Confirm Step 100 returned FAIL as expected.
- [ ] 102. **Post-RED enforcement (**clean-room**).** Verify FAIL artifacts.
- [ ] 103. **GREEN (**clean-room**).** Add validation rule to validate.md. **→ SC-12**
  - [ ] 103a. Add validation rule: "Plan step sequence matches `implementation-pipeline/SKILL.md` §Dispatch Routing Table"
- [ ] 104. **Post-GREEN enforcement (**clean-room**).** Verify validate.md modified.
- [ ] 105. **Structural checks (**clean-room**).** `wc -w` on validate.md — under 3,000 words.
- [ ] 106. **GREEN doublecheck: generate artifact (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run 'read validate.md and report what validation rules it has' --model <model>` again. Save to `./tmp/1374/artifacts/green-p5i1-stderr.log`.
- [ ] 107. **GREEN doublecheck: assert (**clean-room**).** Dispatch sub-agent to inspect `./tmp/1374/artifacts/green-p5i1-stderr.log`. Assert agent reports validation rule for implementation-pipeline step sequence match. Must PASS. **→ SC-12**
  - [ ] 107a. grep for "implementation-pipeline" in validate.md — present
- [ ] 108. **Checkpoint commit (**inline**).** `git commit -m "validate.md: add implementation-pipeline step sequence validation rule"`

#### Phase 5 completion

- [ ] 109. **VbC (**clean-room**).** Verify SC-12 passes.
- [ ] 110. **Resolve models (**inline**).** Run `resolve-models`.
- [ ] 111. **Auditor 1: verification-audit (**clean-room**).** Dispatch to auditor_1. On non-clean-pass: remediate, restart from Step 110.
- [ ] 112. **Auditor 2: verification-audit (**clean-room**).** Dispatch to auditor_2. On non-clean-pass: remediate, restart from Step 110. Both PASS.
- [ ] 113. **Cross-validate (**clean-room**).** Consensus.
- [ ] 114. **Regression check (**clean-room**).** `bash .opencode/tests/test-enforcement.sh --tag plan` — pass.
- [ ] 115. **Review prep (**clean-room**).** `git-workflow review-prep`.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: All 6 files modified — create.md, write.md, audit-fidelity.md, audit-concern.md, SKILL.md, validate.md.
- [ ] C2: create.md §Plan Format Requirements has no hardcoded step sequences — discovery directive references implementation-pipeline.
- [ ] C3: Dispatch indicators have 3 distinct modes: `(**sub-agent**)` (with context), `(**clean-room**)` (blind), `(**inline**)` (direct).
- [ ] C4: write.md does not reference "dispatch table" — references implementation-pipeline.
- [ ] C5: audit-fidelity.md and audit-concern.md do not contain "with auditor sub-agent type context".
- [ ] C6: SKILL.md does not hardcode 21-step pipeline — references plan-creation-pipeline.
- [ ] C7: validate.md has implementation-pipeline step sequence validation rule.
- [ ] C8: All SC-1 through SC-14 pass verification.
- [ ] C9: Plan stored at `.opencode/.issues/1374/plan.md`.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
