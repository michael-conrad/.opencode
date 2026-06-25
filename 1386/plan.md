# Implementation Plan — Spec: #1386 — Fix C1: Pipeline skill descriptions — mandatory language + narrative cleanup (D4, D5)

- **Goal:** Fix 8 pipeline skill descriptions to add mandatory language (D4) and remove narrative-only sentences (D5), preserving consequence statements and D2/D3 compliance.
- **Architecture:** Per-file RED/GREEN chains — each skill is an independent item. P0 establishes baseline, P1a–P1h fix each file through the full implementation-pipeline gate sequence, P2 verifies all 4 SCs.
- **Files:** `.opencode/skills/{adversarial-audit,approval-gate,brainstorming,implementation-pipeline,executing-plans,finishing-a-development-branch,verification-before-completion,verification-enforcement}/SKILL.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 0 — Setup: Verify spec approval, read all 8 SKILL.md descriptions, establish baseline

- **Concern:** Pre-work — verify authorization, read all affected files, establish baseline content for audit comparison.
- **Files:** `.opencode/.issues/1386/` (spec), all 8 SKILL.md files
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** None
- **Entry:** Spec #1386 approved with `approved-for-plan` label
- **Exit:** Baseline established, all 8 descriptions read and logged

- [ ] 1. **Verify spec approval (**inline**).** Check `approved-for-plan` label on issue #1386. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 2. **Read all 8 SKILL.md descriptions (**sub-agent**).** Read the description line from each of the 8 SKILL.md files. Log current descriptions to `./tmp/1386-baseline-descriptions.txt`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 3. **Establish baseline (**inline**).** Confirm all 8 descriptions are logged. Report PASS with baseline artifact path. **→ SC-1, SC-2, SC-3, SC-4**

#### Phase 0 VbC

- [ ] 4. **VbC (**clean-room**).** Verify baseline artifact contains all 8 descriptions. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving setup → entering per-file fixes. Phase 1a–1h are independent and may be executed in any order.

## Phase 1a — Fix `adversarial-audit` description

- **Concern:** Replace narrative sentence with dispatch-relevant content. Current: "Audits are not optional — they are how trustworthy work is verified." D4: PASS, D5: FAIL.
- **Files:** `.opencode/skills/adversarial-audit/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 5. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for adversarial-audit fix. **→ SC-3, SC-4**
- [ ] 6. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for adversarial-audit. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 7. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description contains mandatory language and no narrative-only sentences. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-1, SC-2**
- [ ] 8. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-1, SC-2**
- [ ] 9. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-1, SC-2**
- [ ] 10. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1, SC-2**
- [ ] 11. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-1, SC-2**
- [ ] 12. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1, SC-2**
- [ ] 13. **GREEN — green-phase (**sub-agent**).** Edit description: replace narrative sentence with dispatch-relevant content. Preserve mandatory language. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 14. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 15. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-1, SC-2**
- [ ] 16. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1, SC-2**
- [ ] 17. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1a-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 18. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/adversarial-audit/SKILL.md && git commit -m "fix(adversarial-audit): add mandatory language, remove narrative sentence"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 19. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 20. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 21. **green-vbc (**clean-room**).** VbC completion artifact for adversarial-audit fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving adversarial-audit → entering approval-gate.

## Phase 1b — Fix `approval-gate` description

- **Concern:** Add mandatory language. Current: "Use when checking or enforcing: authorization scope, approval cascade, pipeline halt boundaries, label application, spec-to-plan cascade, revision revocation, and bug discovery protocol. All conditions are mandatory — no implementation without authorization." D4: FAIL, D5: PASS.
- **Files:** `.opencode/skills/approval-gate/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 22. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for approval-gate fix. **→ SC-3, SC-4**
- [ ] 23. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for approval-gate. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 24. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description contains mandatory language. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-1**
- [ ] 25. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-1**
- [ ] 26. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-1**
- [ ] 27. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1**
- [ ] 28. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-1**
- [ ] 29. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1**
- [ ] 30. **GREEN — green-phase (**sub-agent**).** Edit description: add mandatory language (MUST, REQUIRED, always, not optional, mandatory). Preserve consequence sentence. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 31. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 32. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-1**
- [ ] 33. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1**
- [ ] 34. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1b-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 35. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/approval-gate/SKILL.md && git commit -m "fix(approval-gate): add mandatory language"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 36. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 37. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 38. **green-vbc (**clean-room**).** VbC completion artifact for approval-gate fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving approval-gate → entering brainstorming.

## Phase 1c — Fix `brainstorming` description

- **Concern:** Add mandatory language and replace metaphor sentence. Current: "Use when creating a spec, planning a feature, or exploring requirements before implementation. Agents who implement without brainstorming build solutions to problems they do not understand." D4: FAIL, D5: FAIL.
- **Files:** `.opencode/skills/brainstorming/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 39. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for brainstorming fix. **→ SC-3, SC-4**
- [ ] 40. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for brainstorming. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 41. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description contains mandatory language and no narrative-only sentences. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-1, SC-2**
- [ ] 42. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-1, SC-2**
- [ ] 43. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-1, SC-2**
- [ ] 44. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1, SC-2**
- [ ] 45. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-1, SC-2**
- [ ] 46. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1, SC-2**
- [ ] 47. **GREEN — green-phase (**sub-agent**).** Edit description: add mandatory language. Replace metaphor sentence with dispatch-relevant content. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 48. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 49. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-1, SC-2**
- [ ] 50. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1, SC-2**
- [ ] 51. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1c-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 52. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/brainstorming/SKILL.md && git commit -m "fix(brainstorming): add mandatory language, replace narrative sentence"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 53. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 54. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 55. **green-vbc (**clean-room**).** VbC completion artifact for brainstorming fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving brainstorming → entering implementation-pipeline.

## Phase 1d — Fix `implementation-pipeline` description

- **Concern:** Replace narrative sentence with dispatch-relevant content. Current: "Use when executing an approved plan through the implementation pipeline. MUST dispatch here after plan approval, before any file modification. Professional engineers route each step through clean-room sub-agents." D4: PASS, D5: FAIL.
- **Files:** `.opencode/skills/implementation-pipeline/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 56. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for implementation-pipeline fix. **→ SC-3, SC-4**
- [ ] 57. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for implementation-pipeline. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 58. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description has no narrative-only sentences. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-2**
- [ ] 59. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-2**
- [ ] 60. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-2**
- [ ] 61. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-2**
- [ ] 62. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-2**
- [ ] 63. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-2**
- [ ] 64. **GREEN — green-phase (**sub-agent**).** Edit description: replace narrative sentence with dispatch-relevant content. Preserve mandatory language and consequence. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 65. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 66. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-2**
- [ ] 67. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-2**
- [ ] 68. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1d-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 69. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/implementation-pipeline/SKILL.md && git commit -m "fix(implementation-pipeline): replace narrative sentence"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 70. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 71. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 72. **green-vbc (**clean-room**).** VbC completion artifact for implementation-pipeline fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving implementation-pipeline → entering executing-plans.

## Phase 1e — Fix `executing-plans` description

- **Concern:** Add mandatory language. Current: "Use when executing an approved plan step-by-step or moving through implementation gates sequentially. Every skipped step is a defect waiting for CI to find." D4: FAIL, D5: PASS.
- **Files:** `.opencode/skills/executing-plans/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 73. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for executing-plans fix. **→ SC-3, SC-4**
- [ ] 74. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for executing-plans. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 75. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description contains mandatory language. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-1**
- [ ] 76. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-1**
- [ ] 77. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-1**
- [ ] 78. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1**
- [ ] 79. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-1**
- [ ] 80. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1**
- [ ] 81. **GREEN — green-phase (**sub-agent**).** Edit description: add mandatory language. Preserve consequence sentence. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 82. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 83. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-1**
- [ ] 84. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1**
- [ ] 85. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1e-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 86. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "fix(executing-plans): add mandatory language"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 87. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 88. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 89. **green-vbc (**clean-room**).** VbC completion artifact for executing-plans fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving executing-plans → entering finishing-a-development-branch.

## Phase 1f — Fix `finishing-a-development-branch` description

- **Concern:** Add mandatory language and replace slogan sentence. Current: "Use when implementation is complete and branch needs final checks before PR. A finished branch is a clean branch." D4: FAIL, D5: FAIL.
- **Files:** `.opencode/skills/finishing-a-development-branch/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 90. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for finishing-a-development-branch fix. **→ SC-3, SC-4**
- [ ] 91. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for finishing-a-development-branch. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 92. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description contains mandatory language and no narrative-only sentences. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-1, SC-2**
- [ ] 93. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-1, SC-2**
- [ ] 94. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-1, SC-2**
- [ ] 95. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1, SC-2**
- [ ] 96. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-1, SC-2**
- [ ] 97. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1, SC-2**
- [ ] 98. **GREEN — green-phase (**sub-agent**).** Edit description: add mandatory language. Replace slogan sentence with dispatch-relevant content. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 99. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 100. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-1, SC-2**
- [ ] 101. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1, SC-2**
- [ ] 102. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1f-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 103. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/finishing-a-development-branch/SKILL.md && git commit -m "fix(finishing-a-development-branch): add mandatory language, replace slogan"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 104. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 105. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 106. **green-vbc (**clean-room**).** VbC completion artifact for finishing-a-development-branch fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving finishing-a-development-branch → entering verification-before-completion.

## Phase 1g — Fix `verification-before-completion` description

- **Concern:** Add mandatory language. Current: "Use when claiming a task is complete, marking a step done, or closing an issue. A completion claim without verification is not a completion — it is a placeholder for undiscovered defects." D4: FAIL, D5: PASS.
- **Files:** `.opencode/skills/verification-before-completion/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 107. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for verification-before-completion fix. **→ SC-3, SC-4**
- [ ] 108. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for verification-before-completion. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 109. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description contains mandatory language. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-1**
- [ ] 110. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-1**
- [ ] 111. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-1**
- [ ] 112. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1**
- [ ] 113. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-1**
- [ ] 114. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1**
- [ ] 115. **GREEN — green-phase (**sub-agent**).** Edit description: add mandatory language. Preserve consequence sentence. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 116. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 117. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-1**
- [ ] 118. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1**
- [ ] 119. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1g-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 120. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/verification-before-completion/SKILL.md && git commit -m "fix(verification-before-completion): add mandatory language"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 121. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 122. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 123. **green-vbc (**clean-room**).** VbC completion artifact for verification-before-completion fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving verification-before-completion → entering verification-enforcement.

## Phase 1h — Fix `verification-enforcement` description

- **Concern:** Add mandatory language. Current: "Use when generating content that makes factual claims — specs, plans, runbooks, docs, or correspondence — to enforce live-source verification before generation. Every unverified claim in generated content is a trust deficit." D4: FAIL, D5: PASS.
- **Files:** `.opencode/skills/verification-enforcement/SKILL.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 0
- **Entry:** Phase 0 complete
- **Exit:** Description fixed, committed, verified

- [ ] 124. **sc-coherence-gate (**clean-room**).** Verify spec/plan coherence for verification-enforcement fix. **→ SC-3, SC-4**
- [ ] 125. **pre-red-baseline (**sub-agent**).** Establish doc-source currency and SC-ID cross-ref traceability for verification-enforcement. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 126. **RED — red-phase (**sub-agent**).** Write behavioral enforcement test that verifies the new description contains mandatory language. **red_checkpoint:** test MUST fail (behavioral enforcement test fails because description hasn't been updated yet). **failure_condition:** test passes (PASS when should be FAIL). **→ SC-1**
- [ ] 127. **z3-check-red (**inline**).** `solve check` against red-phase output contract. **→ SC-1**
- [ ] 128. **red-doublecheck (**clean-room**).** Verify RED-side SC evidence. **→ SC-1**
- [ ] 129. **z3-check-red-doublecheck (**inline**).** `solve check` against red-doublecheck output contract. **→ SC-1**
- [ ] 130. **post-red-enforcement (**sub-agent**).** `git diff --name-only -- src/ | wc -l` — verify no source files modified. **→ SC-1**
- [ ] 131. **z3-check-post-red (**inline**).** `solve check` against post-red-enforcement output contract. **→ SC-1**
- [ ] 132. **GREEN — green-phase (**sub-agent**).** Edit description: add mandatory language. Preserve consequence sentence. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 133. **z3-check-green (**inline**).** `solve check` against green-phase output contract. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 134. **post-green-enforcement (**sub-agent**).** `git diff --name-only -- test/ | wc -l` — verify test files modified. **→ SC-1**
- [ ] 135. **z3-check-post-green (**inline**).** `solve check` against post-green-enforcement output contract. **→ SC-1**
- [ ] 136. **checkpoint-tag-create (**sub-agent**).** Create git tag `opencode-config/1386/phase-1h-opencode`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 137. **checkpoint-commit (**sub-agent**).** `git add .opencode/skills/verification-enforcement/SKILL.md && git commit -m "fix(verification-enforcement): add mandatory language"`. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 138. **structural-checks (**sub-agent**).** Run lint/typecheck/format. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 139. **green-doublecheck (**clean-room**).** Semantic-intent verification — verify description has mandatory language (SC-1), no narrative-only sentences (SC-2), passes D2 (SC-3), passes D3 (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 140. **green-vbc (**clean-room**).** VbC completion artifact for verification-enforcement fix. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving per-file fixes → entering global verification.

## Phase 2 — Verify: Verify all 4 SCs pass across all 8 files

- **Concern:** Global verification — confirm all 8 descriptions satisfy all 4 success criteria.
- **Files:** All 8 SKILL.md files
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** Phase 1a–1h
- **Entry:** All 8 checkpoint commits complete
- **Exit:** All 4 SCs verified PASS across all 8 files

- [ ] 141. **resolve-models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 142. **adversarial-audit — auditor 1 (**sub-agent**).** Dispatch audit task with auditor_1. Verify all 4 SCs across all 8 files. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 143. **adversarial-audit — auditor 1 remediate (**inline**).** If non-clean-pass, remediate root cause and restart from step 141. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 144. **adversarial-audit — auditor 2 (**sub-agent**).** Dispatch audit task with auditor_2. Verify all 4 SCs across all 8 files. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 145. **adversarial-audit — auditor 2 remediate (**inline**).** If non-clean-pass, remediate root cause and restart from step 141. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 146. **cross-validate (**clean-room**).** Produce cross-validate findings from both auditor artifacts. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 147. **regression-check (**sub-agent**).** Run regression tests. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 148. **review-prep (**sub-agent**).** Prepare branch for review. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 149. **exec-summary (**sub-agent**).** Append lifecycle event and produce chat exec summary. **→ SC-1, SC-2, SC-3, SC-4**

#### Phase 2 VbC

- [ ] 150. **VbC (**clean-room**).** Verify all 4 SCs pass across all 8 files. Report PASS with evidence artifact. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving verification → plan complete.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- C1: Plan document written to `.opencode/.issues/1386/plan.md`
- C2: All 8 descriptions contain mandatory language (SC-1)
- C3: All 8 descriptions have no narrative-only sentences (SC-2)
- C4: All 8 descriptions pass D2 correctness against dispatch table (SC-3)
- C5: All 8 descriptions pass D3 completeness against dispatch table (SC-4)
- C6: All 8 per-file RED/GREEN chains completed with checkpoint commits
- C7: Global verification phase completed with adversarial audit, cross-validate, and regression check
- C8: Cross-reference synced to spec issue #1386
