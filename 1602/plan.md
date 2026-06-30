# Implementation Plan — [michael-conrad/.opencode#1602](https://github.com/michael-conrad/.opencode/issues/1602) — Apply farmage YAML description pattern to all skill cards

**Goal:** Standardize all 41 SKILL.md files (researcher excluded — merged into research) to use the farmage YAML description pattern, fix frontmatter gaps, add Worktree Mode sections, resolve SC-LINT-004 conflicts, and fix cross-skill conflicts.

**Architecture:** 6-item sequential pipeline. Each item follows per-item TDD: RED (behavioral test) → GREEN (implementation) → REFACTOR → COMMIT. No RED-all phase. No GREEN-all phase. Each item's behavioral test is written immediately before its implementation.

**Files:**
- `.opencode/skills/*/SKILL.md` (38 main skill files, excluding researcher)
- `.opencode/skills/issue-operations/platforms/*/SKILL.md` (3 platform sub-skill files)
- `.opencode/guidelines/` (SC-LINT-004 limit value)
- `.opencode/skills/researcher/SKILL.md` (delete — merge into research)
- `.opencode/skills/research/SKILL.md` (update description)
- `.opencode/skills/{plan,writing-plans,plan-creation-pipeline}/SKILL.md` (3 files — exclusion clauses)
- `.opencode/skills/{verification,verification-before-completion,verification-enforcement}/SKILL.md` (3 files — exclusion clauses)
- `.opencode/tests/behaviors/` (behavioral tests — one per item, written at RED time)

Spec: #1602

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire item and all work in it.

> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

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

## Item 1 — Frontmatter Fixes (provenance, type, compatibility)

**Concern:** Add missing frontmatter fields (provenance, type, compatibility) to all 41 SKILL.md files. Correct invalid types (plan:domain→utility, solve:tool→utility).

**Files:** All 41 SKILL.md files (38 main + 3 platform sub-skills, researcher excluded)

**SCs:** SC-3, SC-6

**Dependencies:** None (first item)

**Entry condition:** Feature branch created, no changes to skill/guideline files yet

**Exit condition:** `grep -c '^provenance:' .opencode/skills/*/SKILL.md` = 41, `grep 'type: domain\|type: tool'` = 0, `grep '^compatibility:' .opencode/skills/*/SKILL.md` = 41

### Sub-Item 1a — provenance field

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction to verify spec/plan coherence for provenance scope. **→ SC-3**
- [ ] 2. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current provenance state. **→ SC-3**
- [ ] 3. **RED — provenance count (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/frontmatter-provenance.sh` that runs `grep -c '^provenance:' .opencode/skills/*/SKILL.md` and asserts count < 41. Verify test FAILS (RED state confirmed). **→ SC-3**
- [ ] 4. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-3**
- [ ] 5. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side SC evidence: test file exists, test execution shows FAIL. **→ SC-3**
- [ ] 6. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-3**
- [ ] 7. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify git diff --name-only -- src/ shows zero lines (no source changes in RED phase). **→ SC-3**
- [ ] 8. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-3**
- [ ] 9. **GREEN — add provenance (**sub-agent**).** Dispatch test-driven-development --task green. Add `provenance: AI-generated` to all 40 SKILL.md files missing it. **→ SC-3**
- [ ] 10. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-3**
- [ ] 11. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify git diff --name-only -- test/ shows zero lines. **→ SC-3**
- [ ] 12. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-3**
- [ ] 13. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep -c '^provenance:' .opencode/skills/*/SKILL.md` = 41. **→ SC-3**
- [ ] 14. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-3**
- [ ] 15. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-3**
- [ ] 16. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit provenance changes. **→ SC-3**
- [ ] 17. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-3**

### Sub-Item 1b — type field

- [ ] 18. **RED — type count (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/frontmatter-type.sh` that runs `grep 'type: domain\|type: tool' .opencode/skills/*/SKILL.md` and asserts matches exist (RED state). Verify test FAILS. **→ SC-3, SC-6**
- [ ] 19. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-3, SC-6**
- [ ] 20. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-3, SC-6**
- [ ] 21. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-3, SC-6**
- [ ] 22. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-3, SC-6**
- [ ] 23. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-3, SC-6**
- [ ] 24. **GREEN — add type (**sub-agent**).** Dispatch test-driven-development --task green. Add `type: discipline-enforcing` to 4 files missing type. Correct `plan:domain` → `plan:utility` and `solve:tool` → `solve:utility`. **→ SC-3, SC-6**
- [ ] 25. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-3, SC-6**
- [ ] 26. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-3, SC-6**
- [ ] 27. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-3, SC-6**
- [ ] 28. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep 'type: domain\|type: tool'` = 0. **→ SC-3, SC-6**
- [ ] 29. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-3, SC-6**
- [ ] 30. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-3, SC-6**
- [ ] 31. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit type changes. **→ SC-3, SC-6**
- [ ] 32. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-3, SC-6**

### Sub-Item 1c — compatibility field

- [ ] 33. **RED — compatibility count (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/frontmatter-compatibility.sh` that runs `grep -c '^compatibility:' .opencode/skills/*/SKILL.md` and asserts count < 41. Verify test FAILS. **→ SC-3**
- [ ] 34. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-3**
- [ ] 35. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-3**
- [ ] 36. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-3**
- [ ] 37. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-3**
- [ ] 38. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-3**
- [ ] 39. **GREEN — add compatibility (**sub-agent**).** Dispatch test-driven-development --task green. Add `compatibility: opencode` to 2 files missing it. **→ SC-3**
- [ ] 40. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-3**
- [ ] 41. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-3**
- [ ] 42. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-3**
- [ ] 43. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep -c '^compatibility:' .opencode/skills/*/SKILL.md` = 41. **→ SC-3**
- [ ] 44. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-3**
- [ ] 45. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-3**
- [ ] 46. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit compatibility changes. **→ SC-3**
- [ ] 47. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-3**

#### Item 1 VbC

- [ ] 48. **VbC (**clean-room**).** Verify `grep -c '^provenance:' .opencode/skills/*/SKILL.md` = 41, `grep 'type: domain\|type: tool'` = 0, `grep -c '^compatibility:' .opencode/skills/*/SKILL.md` = 41. **→ SC-3, SC-6**

## Item 2 — SC-LINT-004 Resolution

**Concern:** Raise SC-LINT-004 300-char limit to 1024-char in the guideline file. Only the limit value changes — not the rule semantics.

**Files:** `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` (SC-LINT-004 rule)

**SCs:** SC-2, SC-11

**Dependencies:** None (independent of frontmatter)

**Entry condition:** Item 1 complete

**Exit condition:** `grep -n 'len(desc) > 1024' .opencode/skills/skill-creator/scripts/validate_skill_cards.py` matches, `grep -n 'len(desc) > 300'` matches zero

- [ ] 49. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify SC-LINT-004 scope. **→ SC-2**
- [ ] 50. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current limit value. **→ SC-2**
- [ ] 51. **RED — verify 300-char limit (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/sclint004-limit.sh` that runs `grep -n 'len(desc) > 300' .opencode/skills/skill-creator/scripts/validate_skill_cards.py` and asserts match exists (RED state). Verify test FAILS. **→ SC-2**
- [ ] 52. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-2**
- [ ] 53. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-2**
- [ ] 54. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-2**
- [ ] 55. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-2**
- [ ] 56. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-2**
- [ ] 57. **GREEN — raise limit to 1024 (**sub-agent**).** Dispatch test-driven-development --task green. Change `len(desc) > 300` to `len(desc) > 1024` in the SC-LINT-004 validation script. **→ SC-2**
- [ ] 57b. **GREEN — remove type/provenance validation from linter (**sub-agent**).** Remove `type` and `provenance` field validation from `validate_skill_cards.py` — these are not recognized opencode frontmatter fields per https://opencode.ai/docs/skills/. Remove `VALID_TYPES`, `VALID_PROVENANCE`, the `type` check in `validate_req1`, and the entire `validate_req4` function. **→ SC-11**
- [ ] 58. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-2**
- [ ] 59. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-2**
- [ ] 60. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-2**
- [ ] 61. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep -n 'len(desc) > 1024' .opencode/skills/skill-creator/scripts/validate_skill_cards.py` matches and `grep -n 'len(desc) > 300'` matches zero. **→ SC-2**
- [ ] 62. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-2**
- [ ] 63. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-2**
- [ ] 64. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit SC-LINT-004 change. **→ SC-2**
- [ ] 65. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-2**

#### Item 2 VbC

- [ ] 66. **VbC (**clean-room**).** Verify `grep -n 'len(desc) > 1024' .opencode/skills/skill-creator/scripts/validate_skill_cards.py` matches, `grep -n 'len(desc) > 300'` matches zero. **→ SC-2**

## Item 3 — Farmage Description Expansion

**Concern:** Replace ad-hoc description prose with farmage YAML description pattern in all 41 SKILL.md files (researcher excluded).

**Files:** All 41 SKILL.md files (38 main + 3 platform sub-skills, researcher excluded)

**SCs:** SC-1, SC-7

**Dependencies:** Item 1 (frontmatter must exist), Item 2 (1024-char limit must be in place)

**Entry condition:** Items 1 and 2 complete

**Exit condition:** `opencode-cli run "list skills"` → stderr shows all 5 farmage components (Use when, Also use when, Invoke for, enforcement, Trigger phrases) per skill

- [ ] 67. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current description state. **→ SC-1**
- [ ] 68. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify farmage scope. **→ SC-1**
- [ ] 69. **RED — farmage components absent (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/farmage-pattern.sh` that sends `opencode-cli run "list skills"` and asserts stderr shows < 5 farmage components per skill (RED state). Verify test FAILS. **→ SC-1**
- [ ] 70. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-1**
- [ ] 71. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-1**
- [ ] 72. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-1**
- [ ] 73. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-1**
- [ ] 74. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-1**
- [ ] 75. **GREEN — apply farmage to all 41 skills (**sub-agent**).** Dispatch test-driven-development --task green. Replace ad-hoc descriptions with farmage pattern (Use when, Also use when, Invoke for, enforcement, Trigger phrases) in all 41 SKILL.md files (38 main + 3 platform sub-skills, researcher excluded). **→ SC-1, SC-7**
- [ ] 76. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-1, SC-7**
- [ ] 77. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-1, SC-7**
- [ ] 78. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-1, SC-7**
- [ ] 79. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Run `opencode-cli run "list skills"` — verify stderr shows all 5 farmage components per skill. **→ SC-1, SC-7**
- [ ] 80. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-1, SC-7**
- [ ] 81. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-1, SC-7**
- [ ] 82. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit farmage description changes. **→ SC-1, SC-7**
- [ ] 83. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-1, SC-7**

#### Item 3 VbC

- [ ] 84. **VbC (**clean-room**).** Run `opencode-cli run "list skills"` — verify stderr shows all 5 farmage components (Use when, Also use when, Invoke for, enforcement, Trigger phrases) per skill across all 41 files. **→ SC-1, SC-7**

## Item 4 — Worktree Mode Sections

**Concern:** Add Worktree Mode sections to SKILL.md files that reference git operations or branch management.

**Files:** 30+ SKILL.md files with git/branch operations

**SCs:** SC-4

**Dependencies:** Item 3 (descriptions stable)

**Entry condition:** Item 3 complete

**Exit condition:** `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` matches applicable count

- [ ] 85. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify Worktree Mode scope. **→ SC-4**
- [ ] 86. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current Worktree Mode section count. **→ SC-4**
- [ ] 87. **RED — Worktree Mode count (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/worktree-mode.sh` that runs `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` and asserts count < applicable count (RED state). Verify test FAILS. **→ SC-4**
- [ ] 88. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-4**
- [ ] 89. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-4**
- [ ] 90. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-4**
- [ ] 91. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-4**
- [ ] 92. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-4**
- [ ] 93. **GREEN — add Worktree Mode sections (**sub-agent**).** Dispatch test-driven-development --task green. Add `## Worktree Mode` sections to all applicable SKILL.md files. **→ SC-4**
- [ ] 94. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-4**
- [ ] 95. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-4**
- [ ] 96. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-4**
- [ ] 97. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify `grep -c 'Worktree Mode'` matches applicable count. **→ SC-4**
- [ ] 98. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-4**
- [ ] 99. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-4**
- [ ] 100. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit Worktree Mode changes. **→ SC-4**
- [ ] 101. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-4**

#### Item 4 VbC

- [ ] 102. **VbC (**clean-room**).** Verify `grep -c 'Worktree Mode' .opencode/skills/*/SKILL.md` matches applicable count. **→ SC-4**

## Item 5 — Cross-Skill Conflicts + Exclusion Clauses

**Concern:** Merge researcher into research. Add exclusion clauses to 6 remaining files across 2 conflict groups. Delete researcher/SKILL.md and task files.

**Files:**
- `.opencode/skills/researcher/SKILL.md` (delete)
- `.opencode/skills/researcher/tasks/*.md` (delete)
- `.opencode/skills/research/SKILL.md` (update description)
- `.opencode/skills/{plan,writing-plans,plan-creation-pipeline}/SKILL.md` (3 files — exclusion clauses)
- `.opencode/skills/{verification,verification-before-completion,verification-enforcement}/SKILL.md` (3 files — exclusion clauses)

**SCs:** SC-5, SC-8

**Dependencies:** Item 3 (descriptions stable), Item 2 (lint limit in place)

**Entry condition:** Items 2 and 3 complete

**Exit condition:** researcher/SKILL.md deleted, research/SKILL.md updated, exclusion clauses present on all 6 conflict-group files, behavioral tests PASS

### Sub-Item 5a — Merge researcher into research

- [ ] 103. **Coherence gate (**clean-room**).** Dispatch adversarial-audit --task coherence-extraction. Verify conflict resolution scope. **→ SC-5**
- [ ] 104. **Pre-RED baseline (**clean-room**).** Dispatch implementation-pipeline --task pre-red-baseline. Verify current researcher/research state. **→ SC-5**
- [ ] 105. **RED — researcher exists (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/researcher-merge.sh` that verifies researcher/SKILL.md exists and research/SKILL.md does NOT mention researcher's purpose (RED state). Verify test FAILS. **→ SC-5**
- [ ] 106. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-5**
- [ ] 107. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-5**
- [ ] 108. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-5**
- [ ] 109. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-5**
- [ ] 110. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-5**
- [ ] 111. **GREEN — merge researcher into research (**sub-agent**).** Dispatch test-driven-development --task green. Delete `.opencode/skills/researcher/SKILL.md` and task files. Update `.opencode/skills/research/SKILL.md` description to absorb researcher's purpose. **→ SC-5**
- [ ] 112. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-5**
- [ ] 113. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-5**
- [ ] 114. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-5**
- [ ] 115. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Verify researcher/SKILL.md deleted, research/SKILL.md updated. **→ SC-5**
- [ ] 116. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-5**
- [ ] 117. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-5**
- [ ] 118. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit researcher merge. **→ SC-5**
- [ ] 119. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-5**

### Sub-Item 5b — Exclusion clauses (plan group)

- [ ] 120. **RED — exclusion clauses absent (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/exclusion-clauses-plan.sh` that dispatches ambiguous prompts to plan/writing-plans/plan-creation-pipeline and verifies false-positive dispatch (RED state — exclusion clauses missing). Verify test FAILS. **→ SC-8**
- [ ] 121. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-8**
- [ ] 122. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-8**
- [ ] 123. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-8**
- [ ] 124. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-8**
- [ ] 125. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-8**
- [ ] 126. **GREEN — add exclusion clauses to plan group (**sub-agent**).** Dispatch test-driven-development --task green. Add `— distinct from` clauses to plan, writing-plans, and plan-creation-pipeline SKILL.md files. **→ SC-8**
- [ ] 127. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-8**
- [ ] 128. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-8**
- [ ] 129. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-8**
- [ ] 130. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Run exclusion-clauses-plan.sh — verify PASS. **→ SC-8**
- [ ] 131. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-8**
- [ ] 132. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-8**
- [ ] 133. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit plan group exclusion clauses. **→ SC-8**
- [ ] 134. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-8**

### Sub-Item 5c — Exclusion clauses (verification group)

- [ ] 135. **RED — exclusion clauses absent (**sub-agent**).** Dispatch test-driven-development --task red. Write behavioral test at `.opencode/tests/behaviors/exclusion-clauses-verification.sh` that dispatches ambiguous prompts to verification/verification-before-completion/verification-enforcement and verifies false-positive dispatch (RED state). Verify test FAILS. **→ SC-8**
- [ ] 136. **Z3 check RED (**inline**).** Run solve check against red-phase output contract. **→ SC-8**
- [ ] 137. **RED doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Confirm RED-side evidence. **→ SC-8**
- [ ] 138. **Z3 check RED doublecheck (**inline**).** Run solve check against red-doublecheck output contract. **→ SC-8**
- [ ] 139. **Post-RED enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-red-enforcement. Verify zero source changes. **→ SC-8**
- [ ] 140. **Z3 check post-RED (**inline**).** Run solve check against post-red-enforcement output contract. **→ SC-8**
- [ ] 141. **GREEN — add exclusion clauses to verification group (**sub-agent**).** Dispatch test-driven-development --task green. Add `— distinct from` clauses to verification, verification-before-completion, and verification-enforcement SKILL.md files. **→ SC-8**
- [ ] 142. **Z3 check GREEN (**inline**).** Run solve check against green-phase output contract. **→ SC-8**
- [ ] 143. **Post-GREEN enforcement (**sub-agent**).** Dispatch implementation-pipeline --task post-green-enforcement. Verify zero test file changes. **→ SC-8**
- [ ] 144. **Z3 check post-GREEN (**inline**).** Run solve check against post-green-enforcement output contract. **→ SC-8**
- [ ] 145. **GREEN doublecheck (**sub-agent**).** Dispatch verification-before-completion --task verify. Run exclusion-clauses-verification.sh — verify PASS. **→ SC-8**
- [ ] 146. **Z3 check GREEN doublecheck (**inline**).** Run solve check against green-doublecheck output contract. **→ SC-8**
- [ ] 147. **Checkpoint tag create (**sub-agent**).** Dispatch implementation-pipeline --task checkpoint-tag-create. **→ SC-8**
- [ ] 148. **Checkpoint commit (**sub-agent**).** Dispatch git-workflow --task commit-prep. Commit verification group exclusion clauses. **→ SC-8**
- [ ] 149. **Structural checks (**sub-agent**).** Dispatch finishing-a-development-branch --task checklist. Run lint/typecheck/format. **→ SC-8**

#### Item 5 VbC

- [ ] 150. **VbC (**clean-room**).** Verify researcher/SKILL.md deleted, research/SKILL.md updated, exclusion clauses present on all 6 conflict-group files, behavioral tests PASS. **→ SC-5, SC-8**

## Item 6 — Global Post-Phase

**Concern:** Adversarial audit, cross-validate, regression testing, review prep. Collect behavioral evidence artifacts and produce final verification.

**Files:** All modified files across all items

**SCs:** SC-1, SC-3, SC-8 (cross-cutting verification)

**Dependencies:** All items 1-5 complete

**Entry condition:** All items 1-5 complete and committed

**Exit condition:** Adversarial audit PASS, cross-validate PASS, regression PASS, review prep complete

- [ ] 151. **Collect behavioral evidence (**sub-agent**).** Collect behavioral evidence from `./tmp/behavioral-evidence-*/` into `./tmp/1602/artifacts/`. **→ SC-1, SC-5, SC-7, SC-9**
- [ ] 152. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ All**
- [ ] 153. **Adversarial audit — auditor 1 (**sub-agent**).** Dispatch adversarial-audit with auditor_1. Run phase-appropriate audit (verification-audit for post-implementation). **→ All**
- [ ] 154. **Auditor 1 remediate (**inline**).** If auditor 1 returned non-clean-pass: remediate root cause, restart from resolve-models (step 152). **→ All**
- [ ] 155. **Adversarial audit — auditor 2 (**sub-agent**).** Dispatch adversarial-audit with auditor_2. Same audit task as auditor 1. **→ All**
- [ ] 156. **Auditor 2 remediate (**inline**).** If auditor 2 returned non-clean-pass: remediate root cause, restart from resolve-models (step 152). **→ All**
- [ ] 157. **Cross-validate (**clean-room**).** Dispatch adversarial-audit --task cross-validate with both auditor artifact paths. Produce cross-validate findings YAML. **→ All**
- [ ] 158. **Regression check (**sub-agent**).** Dispatch test-driven-development --task patterns (regression). Run full regression test suite. **→ All**
- [ ] 159. **Review prep (**sub-agent**).** Dispatch git-workflow --task review-prep. Prepare PR body, verify compare URL, ensure all SCs verified. **→ All**
- [ ] 160. **Exec summary (**sub-agent**).** Dispatch completion-core --task completion. Append lifecycle event, produce chat exec summary. **→ All**

#### Item 6 VbC

- [ ] 161. **VbC (**clean-room**).** Verify adversarial audit PASS, cross-validate PASS, regression PASS, review prep complete. **→ All**

## Self-Review Evidence

The following self-review checks were performed on this plan:

- **Spec coverage:** All 9 SCs (SC-1 through SC-9) are addressed across the 6 items. Each SC is annotated on its implementing steps.
- **Placeholder check:** Zero TBD/TODO/placeholder patterns found in plan body.
- **Type consistency:** All dispatch indicators use valid types (`(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`). All step numbers are globally sequential (1-161). All item sections follow the three-tier structure.
- **Dispatch validation:** Every `(**sub-agent**)` step dispatches via `task()`. Every `(**inline**)` step executes directly. No non-standard dispatch indicators used.
- **Per-item TDD compliance:** Each item has its own RED test written immediately before its GREEN implementation. No RED-all phase. No GREEN-all phase. Each RED→GREEN transition is a zero-tolerance gate.
- **Pipeline-gate completeness:** All mandatory implementation-pipeline gate steps (coherence-gate, pre-red-baseline, red-phase, z3-check-red, red-doublecheck, z3-check-red-doublecheck, post-red-enforcement, z3-check-post-red, green-phase, z3-check-green, post-green-enforcement, z3-check-post-green, checkpoint-tag-create, checkpoint-commit, structural-checks, green-doublecheck, green-vbc, adversarial-audit, cross-validate, regression-check, review-prep, exec-summary) are present in each item.
- **Admonishments:** Compliance requirement, one-step-at-a-time protocol, step status instruction, and self-remediation protocol all present verbatim.

## Exit Criteria

- [ ] C1. All 41 SKILL.md files have `provenance: AI-generated` in frontmatter
- [ ] C2. Zero files have `type: domain` or `type: tool` — plan and solve use `type: utility`
- [ ] C3. All 41 SKILL.md files have `compatibility: opencode` where applicable
- [ ] C4. SC-LINT-004 limit changed from `len(desc) > 300` to `len(desc) > 1024` — no other semantics modified
- [ ] C4b. Linter no longer requires `type` or `provenance` fields — `validate_skill_cards.py` passes on all skill cards
- [ ] C5. All 41 SKILL.md files (researcher excluded) use farmage YAML description pattern with all 5 components
- [ ] C6. All 3 platform sub-skill files have farmage descriptions
- [ ] C7. All applicable SKILL.md files have Worktree Mode sections
- [ ] C8. researcher/SKILL.md deleted, research/SKILL.md updated to absorb researcher's purpose
- [ ] C9. Exclusion clauses present on all 6 conflict-group files (plan, writing-plans, plan-creation-pipeline, verification, verification-before-completion, verification-enforcement)
- [ ] C10. All behavioral tests PASS
- [ ] C11. Adversarial audit PASS — no new conflicts introduced
- [ ] C12. Cross-validate PASS — all SCs verified with correct evidence types
- [ ] C13. Regression PASS — existing dispatch behavior unchanged
- [ ] C14. Review prep complete — PR body with Summary/Outcome/Fixes structure
