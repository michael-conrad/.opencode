# Implementation Plan — [michael-conrad/.opencode#1602](https://github.com/michael-conrad/.opencode/issues/1602) — Apply farmage YAML description pattern to all skill cards

**Goal:** Standardize all 41 SKILL.md files (researcher excluded — merged into research) to use the farmage YAML description pattern, fix frontmatter gaps, add Worktree Mode sections, resolve SC-LINT-004 conflicts, and fix cross-skill conflicts.

**Architecture:** 8-phase sequential pipeline with execution order [0, 1, 5, 2, 3, 4, 6, 7]. Phase 0 (behavioral tests RED) must complete before any changes. Phase 5 (SC-LINT-004 resolution) must complete before Phase 2 (farmage descriptions exceed 300-char limit). Phase 1 (frontmatter) must complete before Phase 2. Phase 2 must complete before Phases 3 and 4. Phases 2+5 must complete before Phase 6. All phases 0-6 must complete before Phase 7 (global post-phase).

**Files:**
- `.opencode/skills/*/SKILL.md` (38 main skill files, excluding researcher)
- `.opencode/skills/issue-operations/platforms/*/SKILL.md` (3 platform sub-skill files)
- `.opencode/guidelines/` (SC-LINT-004 limit value)
- `.opencode/skills/researcher/SKILL.md` (delete — merge into research)
- `.opencode/skills/research/SKILL.md` (update description)
- `.opencode/skills/{plan,writing-plans,plan-creation-pipeline}/SKILL.md` (3 files — exclusion clauses)
- `.opencode/skills/{verification,verification-before-completion,verification-enforcement}/SKILL.md` (3 files — exclusion clauses)
- `.opencode/tests/behaviors/farmage-pattern.sh` (behavioral test)
- `.opencode/tests/behaviors/cross-skill-conflicts.sh` (behavioral test)
- `.opencode/tests/behaviors/exclusion-clauses.sh` (behavioral test)

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

## Phase 0 — Behavioral Tests RED

**Concern:** Test infrastructure only. No skill/guideline modifications.

**Files:**
- `.opencode/tests/behaviors/farmage-pattern.sh`
- `.opencode/tests/behaviors/cross-skill-conflicts.sh`
- `.opencode/tests/behaviors/exclusion-clauses.sh`

**SCs:** SC-9

**Dependencies:** None (first phase)

**Entry condition:** Feature branch created, no changes to skill/guideline files yet

**Exit condition:** All 3 behavioral tests exist and FAIL when run against current (unchanged) codebase

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction to verify spec/plan coherence. Verify evidence-type uplift and substrate classification. **→ SC-9**

- [ ] 2. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify doc-source currency and SC-ID cross-reference traceability. **→ SC-9**

- [ ] 3. **RED — farmage-pattern test (**sub-agent**).** Dispatch test-driven-development --task red. Write `.opencode/tests/behaviors/farmage-pattern.sh` — behavioral test that sends `opencode-cli run "list skills"` and asserts stderr shows all 5 farmage components per skill. Verify test FAILS (RED state confirmed). **→ SC-9**

- [ ] 4. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-9**

- [ ] 5. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side SC evidence: test file exists, test execution shows FAIL. **→ SC-9**

- [ ] 6. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-9**

- [ ] 7. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify git diff --name-only -- src/ shows zero lines (no source changes in RED phase). **→ SC-9**

- [ ] 8. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-9**

- [ ] 9. **RED — cross-skill-conflicts test (**sub-agent**).** Dispatch test-driven-development --task red. Write `.opencode/tests/behaviors/cross-skill-conflicts.sh` — behavioral test that dispatches ambiguous prompts to conflict groups and verifies correct skill fires. Verify test FAILS. **→ SC-9**

- [ ] 10. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-9**

- [ ] 11. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side SC evidence. **→ SC-9**

- [ ] 12. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-9**

- [ ] 13. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-9**

- [ ] 14. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-9**

- [ ] 15. **RED — exclusion-clauses test (**sub-agent**).** Dispatch test-driven-development --task red. Write `.opencode/tests/behaviors/exclusion-clauses.sh` — behavioral test that verifies exclusion clauses prevent false-positive dispatch matches. Verify test FAILS. **→ SC-9**

- [ ] 16. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-9**

- [ ] 17. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side SC evidence. **→ SC-9**

- [ ] 18. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-9**

- [ ] 19. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-9**

- [ ] 20. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-9**

- [ ] 21. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. Create git tag for Phase 0 checkpoint. **→ SC-9**

- [ ] 22. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit all 3 behavioral test files. **→ SC-9**

- [ ] 23. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format on test files. **→ SC-9**

- [ ] 24. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Semantic-intent verification of RED phase. **→ SC-9**

- [ ] 25. **GREEN VbC (**sub-agent**).** Dispatch verification-before-completion --task completion. Produce VbC completion artifact. **→ SC-9**

#### Phase 0 VbC

- [ ] 26. **VbC (**clean-room**).** Verify all 3 behavioral tests exist, execute each and confirm FAIL, zero source changes in skill/guideline files. **→ SC-9**

**Concern transition:** Leaving test infrastructure setup → entering frontmatter fixes. Phase 1 depends on Phase 0 providing test infrastructure.

## Phase 1 — Frontmatter Fixes

**Concern:** Add missing frontmatter fields (provenance, type, compatibility) to all 41 SKILL.md files. Correct invalid types (plan:domain→utility, solve:tool→utility).

**Files:** All 41 SKILL.md files (38 main + 3 platform sub-skills, researcher excluded)

**SCs:** SC-3, SC-6

**Dependencies:** Phase 0 (test infrastructure)

**Entry condition:** Phase 0 complete, all 3 behavioral tests exist and FAIL

**Exit condition:** `grep -c 'provenance:' .opencode/skills/*/SKILL.md` = 41, `grep 'type: domain\|type: tool' .opencode/skills/*/SKILL.md` = 0

- [ ] 27. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify frontmatter scope matches spec. **→ SC-3, SC-6**

- [ ] 28. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current frontmatter state. **→ SC-3, SC-6**

- [ ] 29. **RED — frontmatter count (**sub-agent**).** Dispatch test-driven-development --task red. Run `grep -c 'provenance:' .opencode/skills/*/SKILL.md` — verify count < 41 (RED state). **→ SC-3**

- [ ] 30. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-3**

- [ ] 31. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-3**

- [ ] 32. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-3**

- [ ] 33. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-3**

- [ ] 34. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-3**

- [ ] 35. **GREEN — add provenance (**sub-agent**).** Dispatch test-driven-development --task green. Add `provenance: AI-generated` to all 40 SKILL.md files missing it. **→ SC-3**

- [ ] 36. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-3**

- [ ] 37. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify git diff --name-only -- test/ shows zero lines. **→ SC-3**

- [ ] 38. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-3**

- [ ] 39. **GREEN — add type (**sub-agent**).** Dispatch test-driven-development --task green. Add `type: discipline-enforcing` to 4 files missing type. Correct `plan:domain` → `plan:utility` and `solve:tool` → `solve:utility`. **→ SC-3, SC-6**

- [ ] 40. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-3, SC-6**

- [ ] 41. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-3, SC-6**

- [ ] 42. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-3, SC-6**

- [ ] 43. **GREEN — add compatibility (**sub-agent**).** Dispatch test-driven-development --task green. Add `compatibility: opencode` to 2 files missing it. **→ SC-3**

- [ ] 44. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-3**

- [ ] 45. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-3**

- [ ] 46. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-3**

- [ ] 47. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-3, SC-6**

- [ ] 48. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit all frontmatter changes. **→ SC-3, SC-6**

- [ ] 49. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-3, SC-6**

- [ ] 50. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep -c 'provenance:'` = 41 and `grep 'type: domain\|type: tool'` = 0. **→ SC-3, SC-6**

- [ ] 51. **GREEN VbC (**sub-agent**).** Dispatch verification-before-completion --task completion. **→ SC-3, SC-6**

#### Phase 1 VbC

- [ ] 52. **VbC (**clean-room**).** Verify `grep -c 'provenance:' .opencode/skills/*/SKILL.md` = 41, `grep 'type: domain\|type: tool'` = 0, `grep 'compatibility: opencode'` = 41. **→ SC-3, SC-6**

**Concern transition:** Leaving frontmatter fixes → entering SC-LINT-004 resolution. Phase 5 must complete before Phase 2 (farmage descriptions exceed 300-char limit).

## Phase 5 — SC-LINT-004 Resolution

**Concern:** Raise SC-LINT-004 300-char limit to 1024-char in the guideline file. Only the limit value changes — not the rule semantics.

**Files:** `.opencode/guidelines/` (SC-LINT-004 rule in validate_skill_cards.py)

**SCs:** SC-2

**Dependencies:** Phase 0 (test infrastructure)

**Entry condition:** Phase 0 complete

**Exit condition:** `grep 'max_length: 1024' .opencode/guidelines/` matches, `grep 'max_length: 300'` matches zero

- [ ] 53. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify SC-LINT-004 scope. **→ SC-2**

- [ ] 54. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current limit value. **→ SC-2**

- [ ] 55. **RED — verify 300-char limit (**sub-agent**).** Dispatch test-driven-development --task red. Run `grep 'max_length: 300' .opencode/guidelines/` — verify match exists (RED state). **→ SC-2**

- [ ] 56. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-2**

- [ ] 57. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-2**

- [ ] 58. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-2**

- [ ] 59. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-2**

- [ ] 60. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-2**

- [ ] 61. **GREEN — raise limit to 1024 (**sub-agent**).** Dispatch test-driven-development --task green. Change `max_length: 300` to `max_length: 1024` in the SC-LINT-004 guideline file. **→ SC-2**

- [ ] 62. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-2**

- [ ] 63. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-2**

- [ ] 64. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-2**

- [ ] 65. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-2**

- [ ] 66. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit SC-LINT-004 change. **→ SC-2**

- [ ] 67. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-2**

- [ ] 68. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep 'max_length: 1024'` matches and `grep 'max_length: 300'` matches zero. **→ SC-2**

- [ ] 69. **GREEN VbC (**sub-agent**).** Dispatch verification-before-completion --task completion. **→ SC-2**

#### Phase 5 VbC

- [ ] 70. **VbC (**clean-room**).** Verify `grep 'max_length: 1024' .opencode/guidelines/` matches, `grep 'max_length: 300'` matches zero. **→ SC-2**

**Concern transition:** Leaving SC-LINT-004 resolution → entering farmage description expansion. Phase 2 depends on Phase 1 (frontmatter must exist) and Phase 5 (1024-char limit must be in place).

## Phase 2 — Farmage Description Expansion

**Concern:** Replace ad-hoc description prose with farmage YAML description pattern in all 41 SKILL.md files (researcher excluded).

**Files:** All 41 SKILL.md files (38 main + 3 platform sub-skills, researcher excluded)

**SCs:** SC-1

**Dependencies:** Phase 1 (frontmatter complete), Phase 5 (1024-char limit)

**Entry condition:** Phase 1 and Phase 5 complete

**Exit condition:** `opencode-cli run "list skills"` → stderr shows all 5 farmage components (Use when, Also use when, Invoke for, enforcement, Trigger phrases) per skill

- [ ] 71. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify farmage scope. **→ SC-1**

- [ ] 72. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current description state. **→ SC-1**

- [ ] 73. **RED — farmage count (**sub-agent**).** Dispatch test-driven-development --task red. Run `opencode-cli run "list skills"` — verify stderr shows < 5 farmage components per skill (RED state). **→ SC-1**

- [ ] 74. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-1**

- [ ] 75. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-1**

- [ ] 76. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-1**

- [ ] 77. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-1**

- [ ] 78. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-1**

- [ ] 79. **GREEN — apply farmage to 38 main skills (**sub-agent**).** Dispatch test-driven-development --task green. Replace ad-hoc descriptions with farmage pattern (Use when, Also use when, Invoke for, enforcement, Trigger phrases) in all 38 main SKILL.md files. **→ SC-1**

- [ ] 80. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-1**

- [ ] 81. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-1**

- [ ] 82. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-1**

- [ ] 83. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-1**

- [ ] 84. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit farmage description changes. **→ SC-1**

- [ ] 85. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-1**

- [ ] 86. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Run `opencode-cli run "list skills"` — verify stderr shows all 5 farmage components per skill. **→ SC-1**

- [ ] 87. **GREEN VbC (**sub-agent**).** Dispatch verification-before-completion --task completion. **→ SC-1**

#### Phase 2 VbC

- [ ] 88. **VbC (**clean-room**).** Run `opencode-cli run "list skills"` — verify stderr shows all 5 farmage components (Use when, Also use when, Invoke for, enforcement, Trigger phrases) per skill across all 41 files. **→ SC-1**

**Concern transition:** Leaving farmage description expansion → entering platform sub-skills. Phase 3 depends on Phase 2 (farmage pattern established before sub-skill application).

## Phase 3 — Platform Sub-Skills

**Concern:** Apply farmage descriptions to 3 platform sub-skill files.

**Files:**
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
- `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md`
- `.opencode/skills/issue-operations/platforms/local/SKILL.md`

**SCs:** SC-7

**Dependencies:** Phase 2 (farmage pattern established)

**Entry condition:** Phase 2 complete

**Exit condition:** `opencode-cli run "show platform skills"` → stderr shows all 5 farmage components per platform sub-skill

- [ ] 89. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify platform sub-skill scope. **→ SC-7**

- [ ] 90. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current platform sub-skill descriptions. **→ SC-7**

- [ ] 91. **RED — platform farmage (**sub-agent**).** Dispatch test-driven-development --task red. Run `opencode-cli run "show platform skills"` — verify stderr shows < 5 farmage components (RED state). **→ SC-7**

- [ ] 92. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-7**

- [ ] 93. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-7**

- [ ] 94. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-7**

- [ ] 95. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-7**

- [ ] 96. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-7**

- [ ] 97. **GREEN — apply farmage to 3 platform sub-skills (**sub-agent**).** Dispatch test-driven-development --task green. Apply farmage descriptions to gitbucket-api, github-mcp, and local SKILL.md files. **→ SC-7**

- [ ] 98. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-7**

- [ ] 99. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-7**

- [ ] 100. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-7**

- [ ] 101. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-7**

- [ ] 102. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit platform sub-skill changes. **→ SC-7**

- [ ] 103. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-7**

- [ ] 104. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Run `opencode-cli run "show platform skills"` — verify stderr shows all 5 farmage components per platform sub-skill. **→ SC-7**

- [ ] 105. **GREEN VbC (**sub-agent**).** Dispatch verification-before-completion --task completion. **→ SC-7**

#### Phase 3 VbC

- [ ] 106. **VbC (**clean-room**).** Run `opencode-cli run "show platform skills"` — verify stderr shows all 5 farmage components per platform sub-skill. **→ SC-7**

**Concern transition:** Leaving platform sub-skills → entering Worktree Mode sections. Phase 4 depends on Phase 2 (descriptions stable before Worktree Mode).

## Phase 4 — Worktree Mode Sections

**Concern:** Add Worktree Mode sections to SKILL.md files that reference git operations or branch management.

**Files:** 30+ SKILL.md files with git/branch operations

**SCs:** SC-4

**Dependencies:** Phase 2 (descriptions stable)

**Entry condition:** Phase 2 complete

**Exit condition:** `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` matches applicable count

- [ ] 107. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify Worktree Mode scope. **→ SC-4**

- [ ] 108. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current Worktree Mode section count. **→ SC-4**

- [ ] 109. **RED — Worktree Mode count (**sub-agent**).** Dispatch test-driven-development --task red. Run `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` — verify count < applicable count (RED state). **→ SC-4**

- [ ] 110. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-4**

- [ ] 111. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-4**

- [ ] 112. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-4**

- [ ] 113. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-4**

- [ ] 114. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-4**

- [ ] 115. **GREEN — add Worktree Mode sections (**sub-agent**).** Dispatch test-driven-development --task green. Add `## Worktree Mode` sections to all applicable SKILL.md files. **→ SC-4**

- [ ] 116. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-4**

- [ ] 117. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-4**

- [ ] 118. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-4**

- [ ] 119. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-4**

- [ ] 120. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit Worktree Mode changes. **→ SC-4**

- [ ] 121. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-4**

- [ ] 122. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep -c 'Worktree Mode'` matches applicable count. **→ SC-4**

- [ ] 123. **GREEN VbC (**sub-agent**).** Dispatch verification-before-completion --task completion. **→ SC-4**

#### Phase 4 VbC

- [ ] 124. **VbC (**clean-room**).** Verify `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` matches applicable count. **→ SC-4**

**Concern transition:** Leaving Worktree Mode sections → entering cross-skill conflicts + exclusion clauses. Phase 6 depends on Phase 2 (descriptions stable) and Phase 5 (lint limit in place).

## Phase 6 — Cross-Skill Conflicts + Exclusion Clauses

**Concern:** Merge researcher into research. Add exclusion clauses to 6 remaining files across 2 conflict groups. Delete researcher/SKILL.md and task files.

**Files:**
- `.opencode/skills/researcher/SKILL.md` (delete)
- `.opencode/skills/researcher/tasks/*.md` (delete)
- `.opencode/skills/research/SKILL.md` (update description)
- `.opencode/skills/{plan,writing-plans,plan-creation-pipeline}/SKILL.md` (3 files — exclusion clauses)
- `.opencode/skills/{verification,verification-before-completion,verification-enforcement}/SKILL.md` (3 files — exclusion clauses)

**SCs:** SC-5, SC-8

**Dependencies:** Phase 2 (descriptions stable), Phase 5 (lint limit in place)

**Entry condition:** Phase 2 and Phase 5 complete

**Exit condition:** researcher/SKILL.md deleted, research/SKILL.md updated, exclusion clauses present on all 6 conflict-group files, behavioral tests PASS

- [ ] 125. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify conflict resolution scope. **→ SC-5, SC-8**

- [ ] 126. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current conflict state. **→ SC-5, SC-8**

- [ ] 127. **RED — ambiguous dispatch (**sub-agent**).** Dispatch test-driven-development --task red. Run cross-skill-conflicts.sh behavioral test — verify FAIL (ambiguous dispatch on conflict groups). **→ SC-5**

- [ ] 128. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-5**

- [ ] 129. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-5**

- [ ] 130. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-5**

- [ ] 131. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-5**

- [ ] 132. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-5**

- [ ] 133. **RED — exclusion clauses absent (**sub-agent**).** Dispatch test-driven-development --task red. Run exclusion-clauses.sh behavioral test — verify FAIL (exclusion clauses missing). **→ SC-8**

- [ ] 134. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-8**

- [ ] 135. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-8**

- [ ] 136. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-8**

- [ ] 137. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-8**

- [ ] 138. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-8**

- [ ] 139. **GREEN — merge researcher into research (**sub-agent**).** Dispatch test-driven-development --task green. Delete `.opencode/skills/researcher/SKILL.md` and task files. Update `.opencode/skills/research/SKILL.md` description to absorb researcher's purpose. **→ SC-5**

- [ ] 140. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-5**

- [ ] 141. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-5**

- [ ] 142. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-5**

- [ ] 143. **GREEN — add exclusion clauses to plan group (**sub-agent**).** Dispatch test-driven-development --task green. Add `— distinct from` clauses to plan, writing-plans, and plan-creation-pipeline SKILL.md files. **→ SC-5, SC-8**

- [ ] 144. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-5, SC-8**

- [ ] 145. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-5, SC-8**

- [ ] 146. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-5, SC-8**

- [ ] 147. **GREEN — add exclusion clauses to verification group (**sub-agent**).** Dispatch test-driven-development --task green. Add `— distinct from` clauses to verification, verification-before-completion, and verification-enforcement SKILL.md files. **→ SC-5, SC-8**

- [ ] 148. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-5, SC-8**

- [ ] 149. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-5, SC-8**

- [ ] 150. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-5, SC-8**

- [ ] 151. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-5, SC-8**

- [ ] 152. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit all conflict resolution changes. **→ SC-5, SC-8**

- [ ] 153. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-5, SC-8**

- [ ] 154. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Run cross-skill-conflicts.sh and exclusion-clauses.sh — verify both PASS. **→ SC-5, SC-8**

- [ ] 155. **GREEN VbC (**sub-agent**).** Dispatch verification-before-completion --task completion. **→ SC-5, SC-8**

#### Phase 6 VbC

- [ ] 156. **VbC (**clean-room**).** Verify researcher/SKILL.md deleted, research/SKILL.md updated, exclusion clauses present on all 6 conflict-group files, behavioral tests PASS. **→ SC-5, SC-8**

**Concern transition:** Leaving cross-skill conflicts → entering global post-phase. Phase 7 depends on all phases 0-6 complete.

## Phase 7 — Global Post-Phase

**Concern:** Adversarial audit, cross-validate, regression testing, review prep. Collect behavioral evidence artifacts and produce final verification.

**Files:** All modified files across all phases

**SCs:** SC-1, SC-3, SC-8 (cross-cutting verification)

**Dependencies:** All phases 0-6 complete

**Entry condition:** All phases 0-6 complete and committed

**Exit condition:** Adversarial audit PASS, cross-validate PASS, regression PASS, review prep complete

- [ ] 157. **Collect behavioral evidence (**sub-agent**).** Collect behavioral evidence from `./tmp/behavioral-evidence-*/` into `./tmp/1602/artifacts/`. **→ SC-1, SC-5, SC-7, SC-9**

- [ ] 158. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ All**

- [ ] 159. **Adversarial audit — auditor 1 (**sub-agent**).** Dispatch adversarial-audit with auditor_1. Run phase-appropriate audit (verification-audit for post-implementation). **→ All**

- [ ] 160. **Auditor 1 remediate (**inline**).** If auditor 1 returned non-clean-pass: remediate root cause, restart from resolve-models (step 158). **→ All**

- [ ] 161. **Adversarial audit — auditor 2 (**sub-agent**).** Dispatch adversarial-audit with auditor_2. Same audit task as auditor 1. **→ All**

- [ ] 162. **Auditor 2 remediate (**inline**).** If auditor 2 returned non-clean-pass: remediate root cause, restart from resolve-models (step 158). **→ All**

- [ ] 163. **Cross-validate (**clean-room**).** Dispatch adversarial-audit --task cross-validate with both auditor artifact paths. Produce cross-validate findings YAML. **→ All**

- [ ] 164. **Regression check (**sub-agent**).** Dispatch test-driven-development --task patterns (regression). Run full regression test suite. **→ All**

- [ ] 165. **Review prep (**sub-agent**).** Dispatch git-workflow --task review-prep. Prepare PR body, verify compare URL, ensure all SCs verified. **→ All**

- [ ] 166. **Exec summary (**sub-agent**).** Dispatch completion-core --task completion. Append lifecycle event, produce chat exec summary. **→ All**

#### Phase 7 VbC

- [ ] 167. **VbC (**clean-room**).** Verify adversarial audit PASS, cross-validate PASS, regression PASS, review prep complete. **→ All**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- [ ] C1. All 3 behavioral tests exist in `.opencode/tests/behaviors/` and were verified RED before any changes
- [ ] C2. All 41 SKILL.md files (researcher excluded) have `provenance: AI-generated` in frontmatter
- [ ] C3. Zero files have `type: domain` or `type: tool` — plan and solve use `type: utility`
- [ ] C4. All 41 SKILL.md files have `compatibility: opencode` where applicable
- [ ] C5. SC-LINT-004 limit changed from 300 to 1024 — no other semantics modified
- [ ] C6. All 41 SKILL.md files (researcher excluded) use farmage YAML description pattern with all 5 components
- [ ] C7. All 3 platform sub-skill files have farmage descriptions
- [ ] C8. All applicable SKILL.md files have Worktree Mode sections
- [ ] C9. researcher/SKILL.md deleted, research/SKILL.md updated to absorb researcher's purpose
- [ ] C10. Exclusion clauses present on all 6 conflict-group files (plan, writing-plans, plan-creation-pipeline, verification, verification-before-completion, verification-enforcement)
- [ ] C11. Cross-skill-conflicts behavioral test PASSES
- [ ] C12. Exclusion-clauses behavioral test PASSES
- [ ] C13. Adversarial audit PASS — no new conflicts introduced
- [ ] C14. Cross-validate PASS — all SCs verified with correct evidence types
- [ ] C15. Regression PASS — existing dispatch behavior unchanged
- [ ] C16. Review prep complete — PR body with Summary/Outcome/Fixes structure
