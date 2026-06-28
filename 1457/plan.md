# Implementation Plan — [.opencode#1457](https://github.com/michael-conrad/.opencode/issues/1457) — D5 Narrative Cleanup

- **Goal:** Remove narrative-only sentences from 24 skill descriptions while preserving mandatory "Use when" prefix, dispatch conditions, and all non-narrative content.
- **Architecture:** Single-field SKILL.md description edits. Each skill's `description` field in YAML frontmatter is an independent edit — no code changes, no file creation, no dependency between edits.
- **Files:** 24 `.opencode/skills/*/SKILL.md` files (one per skill in the spec table; skill #22 `verification-before-completion` is already correct per #1455 — RED will fail, GREEN skipped).

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

---

## Phase 0 — Pre-work and branch verification

- **Concern:** git_setup
- **Files:** (none — git state only)
- **SCs:** SC-1 through SC-5 (all depend on branch isolation)
- **Dependencies:** None
- **Entry:** Feature branch exists on `.opencode` submodule at dev tip
- **Exit:** Branch confirmed, submodule tag created

- [ ] 1. **Verify branch state (**inline**).** Confirm `.opencode` submodule is on `feature/1455-d1-description-fix` and at dev tip. **→ SC-1**
- [ ] 2. **Verify git status (**inline**).** Confirm no uncommitted changes in either repo. **→ SC-1**
- [ ] 3. **Create submodule checkpoint tag (**inline**).** Tag the current submodule HEAD as `opencode-config/checkpoint/1457/phase-0-.opencode`. **→ SC-1**

**Concern transition:** Leaving git_setup → entering file_edit. Phase 1 depends on Phase 0 branch isolation.

---

## Phase 1 — adversarial-audit SKILL.md

- **Concern:** file_edit
- **Files:** `.opencode/skills/adversarial-audit/SKILL.md`
- **SCs:** SC-1 (adversarial-audit description updated)
- **Dependencies:** None
- **Entry:** Phase 0 complete
- **Exit:** Phase 1 committed with checkpoint tag

- [ ] 4. **RED: Confirm narrative text exists (**inline**).** Read `.opencode/skills/adversarial-audit/SKILL.md`. Confirm `description:` field contains `"Every unverified deliverable is a defect."` (the narrative-only phrase to remove). If not found, HALT with REPORT. **→ SC-1**
- [ ] 5. **GREEN: Edit description (**sub-agent**).** Dispatch sub-agent to replace the `description:` line with the spec's proposed description: `"Use when running adversarial audits of specs, plans, or code. Dispatch to spec-audit, plan-fidelity, concern-separation, coherence-extraction, coherence-maintenance, guideline-audit, drift-detection, spec-summary, closure-verification, test-quality-audit, verification-audit, resolve-models, cross-validate, or completion. Audits are not optional — dispatch is MANDATORY."` **→ SC-1**
- [ ] 6. **GREEN doublecheck (**sub-agent**).** Dispatch sub-agent to verify description still starts with `"Use when"` and the narrative phrase is gone. **→ SC-1**
- [ ] 7. **Checkpoint commit (**inline**).** `git add .opencode/skills/adversarial-audit/SKILL.md && git commit -m "Phase 1: adversarial-audit SKILL.md description cleanup"`. Create tag `opencode-config/checkpoint/1457/phase-1-.opencode`. **→ SC-1**

**Concern transition:** Leaving Phase 1 → entering Phase 2. Both are independent file_edit phases — no dependency.

---

## Phase 2 — correspondence SKILL.md

- **Concern:** file_edit
- **Files:** `.opencode/skills/correspondence/SKILL.md`
- **SCs:** SC-1 (correspondence description updated)
- **Dependencies:** None
- **Entry:** Phase 1 complete
- **Exit:** Phase 2 committed with checkpoint tag

- [ ] 8. **RED: Confirm narrative text exists (**inline**).** Read `.opencode/skills/correspondence/SKILL.md`. Confirm `description:` field contains `"always required for professional credibility"`. **→ SC-1**
- [ ] 9. **GREEN: Edit description (**sub-agent**).** Dispatch sub-agent to replace the `description:` line with the spec's proposed description: `"Use when drafting stakeholder emails, status updates, or external communications. Audience separation MUST be maintained — always required."` **→ SC-1**
- [ ] 10. **GREEN doublecheck (**sub-agent**).** Verify description structure preserved and narrative phrase removed. **→ SC-1**
- [ ] 11. **Checkpoint commit (**inline**).** `git add .opencode/skills/correspondence/SKILL.md && git commit -m "Phase 2: correspondence SKILL.md description cleanup"`. Create tag `opencode-config/checkpoint/1457/phase-2-.opencode`. **→ SC-1**

**Concern transition:** Leaving Phase 2 → entering Phase 3.

---

## Phase 3 — executing-plans SKILL.md

- **Files:** `.opencode/skills/executing-plans/SKILL.md`
- **SCs:** SC-1 (executing-plans description updated)

- [ ] 12. **RED: Confirm narrative text exists (**inline**).** Read description, confirm contains `"Every skipped step is a defect waiting for CI to find."`. **→ SC-1**
- [ ] 13. **GREEN: Edit description (**sub-agent**).** Remove narrative phrase while preserving `"Use when"` prefix and all other content. **→ SC-1**
- [ ] 14. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 15. **Checkpoint commit (**inline**).** `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "Phase 3: executing-plans description cleanup"`. Tag. **→ SC-1**

**Concern transition:** → Phase 4.

---

## Phase 4 — git-workflow SKILL.md

- **Files:** `.opencode/skills/git-workflow/SKILL.md`
- **SCs:** SC-1 (git-workflow description updated)

- [ ] 16. **RED: Confirm narrative (**inline**).** Confirm `"for maintainable projects — always follow the workflow."` exists. **→ SC-1**
- [ ] 17. **GREEN: Edit (**sub-agent**).** Replace `description:` line with spec's proposed description: `"Use when creating a branch, committing, pushing, or creating a PR, rebase/merge conflicts (invoke conflict-resolution), "check pr"/"check prs"/"check merged prs"/"pr merged" (PR state verification + cleanup), "release PR"/"promote to main"/"dev to main" (release-promotion). Branch-and-PR discipline is REQUIRED — always follow the workflow."` **→ SC-1**
- [ ] 18. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 19. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 5.

---

## Phase 5 — issue-operations SKILL.md

- **Files:** `.opencode/skills/issue-operations/SKILL.md`
- **SCs:** SC-1 (issue-operations description updated)

- [ ] 20. **RED: Confirm (**inline**).** Confirm `"untracked work is lost work"` exists. **→ SC-1**
- [ ] 21. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 22. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 23. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 6.

---

## Phase 6 — issue-review SKILL.md

- **Files:** `.opencode/skills/issue-review/SKILL.md`
- **SCs:** SC-1 (issue-review description updated)

- [ ] 24. **RED: Confirm (**inline**).** Confirm `"every unread comment is a defect risk"` exists. **→ SC-1**
- [ ] 25. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 26. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 27. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 7.

---

## Phase 7 — multimodal-dispatch SKILL.md

- **Files:** `.opencode/skills/multimodal-dispatch/SKILL.md`
- **SCs:** SC-1 (multimodal-dispatch description updated)

- [ ] 28. **RED: Confirm (**inline**).** Confirm `"for professional systems"` exists. **→ SC-1**
- [ ] 29. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 30. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 31. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 8.

---

## Phase 8 — plan SKILL.md

- **Files:** `.opencode/skills/plan/SKILL.md`
- **SCs:** SC-1 (plan description updated)

- [ ] 32. **RED: Confirm (**inline**).** Confirm `"every unplanned phase is a risk"` exists. **→ SC-1**
- [ ] 33. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 34. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 35. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 9.

---

## Phase 9 — programming-principles SKILL.md

- **Files:** `.opencode/skills/programming-principles/SKILL.md`
- **SCs:** SC-1 (programming-principles description updated)

- [ ] 36. **RED: Confirm (**inline**).** Confirm `"every violated principle is technical debt incurred, not saved"` exists. **→ SC-1**
- [ ] 37. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 38. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 39. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 10.

---

## Phase 10 — receiving-code-review SKILL.md

- **Files:** `.opencode/skills/receiving-code-review/SKILL.md`
- **SCs:** SC-1 (receiving-code-review description updated)

- [ ] 40. **RED: Confirm (**inline**).** Confirm `"every unresolved comment is a regression waiting to surface"` exists. **→ SC-1**
- [ ] 41. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 42. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 43. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 11.

---

## Phase 11 — research SKILL.md

- **Files:** `.opencode/skills/research/SKILL.md`
- **SCs:** SC-1 (research description updated)

- [ ] 44. **RED: Confirm (**inline**).** Confirm `"every unverified finding is a liability, not evidence"` exists. **→ SC-1**
- [ ] 45. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 46. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 47. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 12.

---

## Phase 12 — researcher SKILL.md

- **Files:** `.opencode/skills/researcher/SKILL.md`
- **SCs:** SC-1 (researcher description updated)

- [ ] 48. **RED: Confirm (**inline**).** Confirm `"every unverified finding is a liability, not evidence"` exists. **→ SC-1**
- [ ] 49. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 50. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 51. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 13.

---

## Phase 13 — skill-creator SKILL.md

- **Files:** `.opencode/skills/skill-creator/SKILL.md`
- **SCs:** SC-1 (skill-creator description updated)

- [ ] 52. **RED: Confirm (**inline**).** Confirm `"Every unvalidated skill is a gap in your quality system"` exists. **→ SC-1**
- [ ] 53. **GREEN: Edit (**sub-agent**).** Replace `description:` line with spec's proposed description: `"Use when creating a new skill, updating an existing skill, validating skill cards, or managing duplicate content blocks (fragments) across guidelines or skills. Validation is REQUIRED."` **→ SC-1**
- [ ] 54. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 55. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 14.

---

## Phase 14 — solve SKILL.md

- **Files:** `.opencode/skills/solve/SKILL.md`
- **SCs:** SC-1 (solve description updated)

- [ ] 56. **RED: Confirm (**inline**).** Confirm `"every unverified constraint is a defect"` exists. **→ SC-1**
- [ ] 57. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 58. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 59. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 15.

---

## Phase 15 — spec-creation SKILL.md

- **Files:** `.opencode/skills/spec-creation/SKILL.md`
- **SCs:** SC-1 (spec-creation description updated)

- [ ] 60. **RED: Confirm (**inline**).** Confirm `"professional engineers spec first"` exists. **→ SC-1**
- [ ] 61. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 62. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 63. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 16.

---

## Phase 16 — sre-runbook SKILL.md

- **Files:** `.opencode/skills/sre-runbook/SKILL.md`
- **SCs:** SC-1 (sre-runbook description updated)

- [ ] 64. **RED: Confirm (**inline**).** Confirm `"produces procedures that survive the next on-call"` exists. **→ SC-1**
- [ ] 65. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 66. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 67. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 17.

---

## Phase 17 — sync-guidelines SKILL.md

- **Files:** `.opencode/skills/sync-guidelines/SKILL.md`
- **SCs:** SC-1 (sync-guidelines description updated)

- [ ] 68. **RED: Confirm (**inline**).** Confirm `"not overhead"` exists. **→ SC-1**
- [ ] 69. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 70. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 71. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 18.

---

## Phase 18 — systematic-debugging SKILL.md

- **Files:** `.opencode/skills/systematic-debugging/SKILL.md`
- **SCs:** SC-1 (systematic-debugging description updated)

- [ ] 72. **RED: Confirm (**inline**).** Confirm `"it finds root causes"` exists. **→ SC-1**
- [ ] 73. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 74. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 75. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 19.

---

## Phase 19 — test-driven-development SKILL.md

- **Files:** `.opencode/skills/test-driven-development/SKILL.md`
- **SCs:** SC-1 (test-driven-development description updated)

- [ ] 76. **RED: Confirm (**inline**).** Confirm `"produces testable, correct code"` exists. **→ SC-1**
- [ ] 77. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 78. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 79. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 20.

---

## Phase 20 — using-git-worktrees SKILL.md

- **Files:** `.opencode/skills/using-git-worktrees/SKILL.md`
- **SCs:** SC-1 (using-git-worktrees description updated)

- [ ] 80. **RED: Confirm (**inline**).** Confirm `"for professional isolation"` exists. **→ SC-1**
- [ ] 81. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 82. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 83. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 21.

---

## Phase 21 — verification SKILL.md

- **Files:** `.opencode/skills/verification/SKILL.md`
- **SCs:** SC-1 (verification description updated)

- [ ] 84. **RED: Confirm (**inline**).** Confirm `"turns guesses into facts"` exists. **→ SC-1**
- [ ] 85. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 86. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 87. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 22.

---

## Phase 22 — verification-before-completion SKILL.md

- **Concern:** skip
- **Files:** `.opencode/skills/verification-before-completion/SKILL.md`
- **SCs:** SC-1 (already fixed by #1455)
- **Dependencies:** None
- **Entry:** Phase 21 complete
- **Exit:** Phase 22 checkpoint (RED fails — confirmed correct, no GREEN)

- [ ] 88. **RED: Confirm narrative text NOT found (**inline**).** Read description. Confirm `"Verification is REQUIRED and not optional"` is the correct description (already per `#1455`). Confirm the target narrative phrase from the spec table is NOT present — RED test will fail (text not found to remove). Report: "RED fails for verification-before-completion — already corrected by #1455. No GREEN needed." **→ SC-1**
- [ ] 89. **Skip GREEN (**inline**).** No edit needed. **→ SC-1**
- [ ] 90. **Checkpoint commit (**inline**).** No changes to commit for this phase. Tag `opencode-config/checkpoint/1457/phase-22-.opencode`. **→ SC-1**

**Concern transition:** → Phase 23.

---

## Phase 23 — verification-enforcement SKILL.md

- **Files:** `.opencode/skills/verification-enforcement/SKILL.md`
- **SCs:** SC-1 (verification-enforcement description updated)

- [ ] 91. **RED: Confirm (**inline**).** Confirm `"Every unverified claim in generated content is a trust deficit."` exists. **→ SC-1**
- [ ] 92. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 93. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 94. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** → Phase 24.

---

## Phase 24 — writing-plans SKILL.md

- **Files:** `.opencode/skills/writing-plans/SKILL.md`
- **SCs:** SC-1 (writing-plans description updated)

- [ ] 95. **RED: Confirm (**inline**).** Confirm `"agents who skip them get lost"` exists. **→ SC-1**
- [ ] 96. **GREEN: Edit (**sub-agent**).** Remove narrative phrase. **→ SC-1**
- [ ] 97. **GREEN doublecheck (**sub-agent**).** Verify. **→ SC-1**
- [ ] 98. **Checkpoint commit (**inline**).** Commit + tag. **→ SC-1**

**Concern transition:** Leaving file_edit → entering verification_only. Phase 25 depends on all 24 earlier phases completing.

---

## Phase 25 — Verify all 5 success criteria

- **Concern:** verification_only
- **Files:** `.opencode/skills/*/SKILL.md` (24 files)
- **SCs:** SC-1 through SC-5
- **Dependencies:** All phases 1–24 complete
- **Entry:** All 24 per-skill phases committed
- **Exit:** All 5 success criteria PASS

- [ ] 99. **Verify SC-1: All narrative-only sentences removed (**sub-agent**).** Dispatch sub-agent to grep all 24 SKILL.md files for the removed narrative phrases. Confirm NONE found. **→ SC-1**
- [ ] 100. **Verify SC-2: Mandatory language preserved (**sub-agent**).** Dispatch sub-agent to verify all descriptions retain "MUST", "REQUIRED", "never optional" or equivalent mandatory language. **→ SC-2**
- [ ] 101. **Verify SC-3: Dispatch conditions preserved (**sub-agent**).** Dispatch sub-agent to verify all descriptions retain all dispatch conditions/trigger descriptions, not just "Use when". **→ SC-3**
- [ ] 102. **Verify SC-4: No new narrative content introduced (**sub-agent**).** Dispatch sub-agent to diff descriptions against spec-proposed descriptions and verify no additional narrative-only sentences were added. **→ SC-4**
- [ ] 103. **Verify SC-5: All descriptions start with "Use when" (**sub-agent**).** Dispatch sub-agent to confirm all 24 descriptions start with `"Use when"`. **→ SC-5**

**Concern transition:** Leaving verification_only → entering commit_push. Phase 26 depends on Phase 25 PASS.

---

## Phase 26 — Lint, final commit, push

- **Concern:** commit_push
- **Files:** `.opencode/skills/*/SKILL.md` (24 files)
- **SCs:** SC-1 through SC-5 (closeout)
- **Dependencies:** Phase 25 complete
- **Entry:** All 5 SCs verified PASS
- **Exit:** Branch pushed

- [ ] 104. **Run lint (**inline**).** `uvx ruff check .opencode/skills/` (advisory). **→ SC-1, SC-5**
- [ ] 105. **Final commit + tag (**inline**).** `git add .opencode/skills/*/SKILL.md && git commit -m "Phase 26: D5 narrative cleanup complete — all 24 skills verified"`. Tag `opencode-config/checkpoint/1457/phase-26-.opencode`. **→ SC-1 through SC-5**
- [ ] 106. **Push branch (**inline**).** `git push origin feature/1455-d1-description-fix`. **→ SC-1 through SC-5**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- **C1:** All 24 SKILL.md files have descriptions that start with `"Use when"`.
- **C2:** All narrative-only sentences removed from all 24 descriptions.
- **C3:** Mandatory language (`MUST`, `REQUIRED`, `always required`, etc.) preserved in all descriptions.
- **C4:** All dispatch conditions/triggers preserved in all descriptions.
- **C5:** No new narrative-only content introduced.
- **C6:** Lint and typecheck clean.
- **C7:** Branch pushed to remote.
- **C8:** All checkpoint tags created (Phases 0–26).
