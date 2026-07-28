---
plan_schema_version: "1.0"
issue: 2170
title: "Git workflow regression: three root causes in cleanup/authorization/pointer lifecycle"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2170 — Git Workflow Regression Fixes

**Goal:** Resolve three distinct root causes in the git workflow: dirty pointer deadlock, check-pr authorization ambiguity, and excessive deliberation about cleanup authorization.

**Architecture:** Each phase targets a separate concern with independent file modifications. All 4 phases are independent — no phase depends on the output of another phase. Each item follows the per-task cycle: RED → GREEN → VERIFY → COMMIT.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- `.git/hooks/pre-push`
- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/guidelines/020-go-prohibitions.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Resolve dirty pointer deadlock | `test-driven-development` | `red` | branch-cleanup.md, pre-work.md | SC-1a, SC-1b, SC-1c | — |
| 2 — Fix check-pr authorization ambiguity | `test-driven-development` | `red` | check-pr.md | SC-2, SC-3 | — |
| 3 — Update pre-push hook Gate 2 message | `test-driven-development` | `red` | pre-push hook | SC-4 | — |
| 4 — Update approval-gate.md and 020-go-prohibitions.md | `test-driven-development` | `red` | approval-gate.md, 020-go-prohibitions.md | SC-5, SC-6 | — |

---

## Phase Details

### Phase 1 — Resolve Dirty Pointer Deadlock

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`, `.opencode/skills/git-workflow-branch/tasks/pre-work.md` |
| SCs | SC-1a, SC-1b, SC-1c |
| Depends On | — |

**Context:**
```yaml
scs:
  SC-1a:
    evidence_type: string
    target: branch-cleanup.md
    requirement: "Pointer commits only alongside real code changes on a feature branch, never during cleanup"
  SC-1b:
    evidence_type: string
    target: pre-work.md
    requirement: "No-Op Branch Guard cross-references branch-cleanup.md's dirty pointer rule instead of repeating the deadlock"
  SC-1c:
    evidence_type: behavioral
    target: branch-cleanup.md, pre-work.md
    requirement: "Agent does not deliberate about submodule pointer handling during cleanup"
```

### Phase 2 — Fix check-pr Authorization Ambiguity

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` |
| SCs | SC-2, SC-3 |
| Depends On | — |

**Context:**
```yaml
scs:
  SC-2:
    evidence_type: string
    target: check-pr.md Phase 3
    requirement: "Merge verification (Phase 2) satisfies the authorization requirement for issue closure"
  SC-3:
    evidence_type: behavioral
    target: check-pr.md
    requirement: "Agent does not deliberate about authorization for post-merge cleanup operations"
```

### Phase 3 — Update Pre-push Hook Gate 2 Message

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.git/hooks/pre-push` |
| SCs | SC-4 |
| Depends On | — |

**Context:**
```yaml
scs:
  SC-4:
    evidence_type: string
    target: pre-push hook Gate 2
    requirement: "Message states only the block and reason — no instructions, no workarounds"
```

### Phase 4 — Update approval-gate.md and 020-go-prohibitions.md Wording

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/010-approval-gate.md`, `.opencode/guidelines/020-go-prohibitions.md` |
| SCs | SC-5, SC-6 |
| Depends On | — |

**Context:**
```yaml
scs:
  SC-5:
    evidence_type: string
    target: approval-gate.md rule 10
    requirement: "'confirmed' means 'verified by check-pr Phase 2' not 'requires developer authorization'"
  SC-6:
    evidence_type: string
    target: 020-go-prohibitions.md, branch-cleanup.md
    requirement: "Remove 'resolves on next pre-work cycle' language, replace with accurate pointer lifecycle description"
```

---

## Pre-Implementation Steps

- [ ] P1. **SC coherence gate (**clean-room**).** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence. **Context:** `{issue_number: 2170}`

- [ ] P2. **Pre-RED baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current state of all affected files before any modifications. **Context:** `{issue_number: 2170}`

---

## Phase 1 — Resolve Dirty Pointer Deadlock

**Concern:** Submodule pointer lifecycle must have a single unambiguous path: cleanup leaves dirty, pointer commits only alongside real code changes on a feature branch.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`

**SCs:** SC-1a, SC-1b, SC-1c

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps P1-P2 complete
- Feature branch exists

**Exit Conditions:**
- branch-cleanup.md has explicit dirty pointer exemption statement
- pre-work.md No-Op Branch Guard cross-references branch-cleanup.md
- Behavioral test verifies no deliberation about pointer handling during cleanup

---

### Item 1 — SC-1a: branch-cleanup.md dirty pointer exemption

- [ ] 1. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a content-verification test asserting branch-cleanup.md contains the pointer lifecycle statement. **→ SC-1a**

- [ ] 2. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 3. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. **→ SC-1a**

- [ ] 4. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 5. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 6. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 7. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to update branch-cleanup.md with the pointer lifecycle statement. **→ SC-1a**

- [ ] 8. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 9. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 10. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 11. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 12. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-1a changes. **→ SC-1a**

- [ ] 13. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 14. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-1a content change is correct. **→ SC-1a**

- [ ] 15. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-1a verdict. **→ SC-1a**

---

### Item 2 — SC-1b: pre-work.md No-Op Branch Guard cross-reference

- [ ] 16. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a content-verification test asserting pre-work.md cross-references branch-cleanup.md. **→ SC-1b**

- [ ] 17. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 18. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. **→ SC-1b**

- [ ] 19. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 20. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 21. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 22. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to update pre-work.md with cross-reference to branch-cleanup.md. **→ SC-1b**

- [ ] 23. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 24. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 25. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 26. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 27. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-1b changes. **→ SC-1b**

- [ ] 28. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 29. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-1b content change is correct. **→ SC-1b**

- [ ] 30. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-1b verdict. **→ SC-1b**

---

### Item 3 — SC-1c: Behavioral test for no deliberation about pointer handling

- [ ] 31. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a behavioral enforcement test asserting agent does not deliberate about submodule pointer handling during cleanup. **→ SC-1c**

- [ ] 32. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 33. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED behavioral test fails as expected. **→ SC-1c**

- [ ] 34. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 35. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 36. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 37. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to update branch-cleanup.md and pre-work.md with unambiguous pointer lifecycle rules. **→ SC-1c**

- [ ] 38. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 39. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 40. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 41. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 42. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-1c changes. **→ SC-1c**

- [ ] 43. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 44. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-1c behavioral test passes. **→ SC-1c**

- [ ] 45. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-1c verdict. **→ SC-1c**

---

#### Phase 1 VbC

- [ ] 46. **SC count gate (**clean-room**).** Dispatch `implementation-pipeline --task sc-count-gate` to verify all 3 Phase 1 SCs have verdicts. **Context:** `{issue_number: 2170}`

- [ ] 47. **Pre-PR gate (**clean-room**).** Dispatch `verification-before-completion --task verify` to check all Phase 1 SC verdicts are PASS. **Context:** `{issue_number: 2170}`

**Concern transition:** Leaving dirty pointer deadlock resolution → entering check-pr authorization ambiguity fix. Phase 2 is independent — no dependency on Phase 1 output.

---

## Phase 2 — Fix check-pr Authorization Ambiguity

**Concern:** check-pr Phase 3 must explicitly state that merge verification (Phase 2) satisfies the authorization requirement for issue closure, and agent must not deliberate about authorization for post-merge cleanup.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`

**SCs:** SC-2, SC-3

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps P1-P2 complete
- Feature branch exists

**Exit Conditions:**
- check-pr.md Phase 3 explicitly states merge verification satisfies authorization
- Behavioral test verifies no deliberation about cleanup authorization

---

### Item 4 — SC-2: check-pr Phase 3 authorization clarity

- [ ] 48. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a content-verification test asserting check-pr.md Phase 3 contains the authorization statement. **→ SC-2**

- [ ] 49. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 50. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. **→ SC-2**

- [ ] 51. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 52. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 53. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 54. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to update check-pr.md Phase 3 with explicit authorization statement. **→ SC-2**

- [ ] 55. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 56. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 57. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 58. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 59. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-2 changes. **→ SC-2**

- [ ] 60. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 61. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-2 content change is correct. **→ SC-2**

- [ ] 62. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-2 verdict. **→ SC-2**

---

### Item 5 — SC-3: Behavioral test for no deliberation about cleanup authorization

- [ ] 63. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a behavioral enforcement test asserting agent does not deliberate about authorization for post-merge cleanup operations. **→ SC-3**

- [ ] 64. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 65. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED behavioral test fails as expected. **→ SC-3**

- [ ] 66. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 67. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 68. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 69. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to update check-pr.md with non-deliberation mandate for post-merge cleanup. **→ SC-3**

- [ ] 70. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 71. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 72. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 73. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 74. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-3 changes. **→ SC-3**

- [ ] 75. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 76. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-3 behavioral test passes. **→ SC-3**

- [ ] 77. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-3 verdict. **→ SC-3**

---

#### Phase 2 VbC

- [ ] 78. **SC count gate (**clean-room**).** Dispatch `implementation-pipeline --task sc-count-gate` to verify both Phase 2 SCs have verdicts. **Context:** `{issue_number: 2170}`

- [ ] 79. **Pre-PR gate (**clean-room**).** Dispatch `verification-before-completion --task verify` to check all Phase 2 SC verdicts are PASS. **Context:** `{issue_number: 2170}`

**Concern transition:** Leaving check-pr authorization fix → entering pre-push hook message update. Phase 3 is independent — no dependency on Phase 2 output.

---

## Phase 3 — Update Pre-push Hook Gate 2 Message

**Concern:** Pre-push hook Gate 2 message must state only the block and reason — no instructions, no workarounds.

**Files:**
- `.git/hooks/pre-push`

**SCs:** SC-4

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps P1-P2 complete
- Feature branch exists

**Exit Conditions:**
- Pre-push hook Gate 2 message contains only block and reason

---

### Item 6 — SC-4: Pre-push hook Gate 2 message cleanup

- [ ] 80. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a content-verification test asserting pre-push hook Gate 2 has no instructional text. **→ SC-4**

- [ ] 81. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 82. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. **→ SC-4**

- [ ] 83. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 84. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 85. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 86. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to update pre-push hook Gate 2 message to state only block and reason. **→ SC-4**

- [ ] 87. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 88. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 89. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 90. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 91. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-4 changes. **→ SC-4**

- [ ] 92. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 93. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-4 content change is correct. **→ SC-4**

- [ ] 94. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-4 verdict. **→ SC-4**

---

#### Phase 3 VbC

- [ ] 95. **SC count gate (**clean-room**).** Dispatch `implementation-pipeline --task sc-count-gate` to verify SC-4 has a verdict. **Context:** `{issue_number: 2170}`

- [ ] 96. **Pre-PR gate (**clean-room**).** Dispatch `verification-before-completion --task verify` to check SC-4 verdict is PASS. **Context:** `{issue_number: 2170}`

**Concern transition:** Leaving pre-push hook message update → entering approval-gate and go-prohibitions wording update. Phase 4 is independent — no dependency on Phase 3 output.

---

## Phase 4 — Update approval-gate.md and 020-go-prohibitions.md Wording

**Concern:** Clarify approval-gate.md rule 10 wording and remove stale "resolves on next pre-work cycle" language from 020-go-prohibitions.md and branch-cleanup.md.

**Files:**
- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

**SCs:** SC-5, SC-6

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps P1-P2 complete
- Feature branch exists

**Exit Conditions:**
- approval-gate.md rule 10 clarifies "confirmed" means "verified by check-pr Phase 2"
- "resolves on next pre-work cycle" removed from 020-go-prohibitions.md and branch-cleanup.md

---

### Item 7 — SC-5: approval-gate.md rule 10 clarification

- [ ] 97. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a content-verification test asserting approval-gate.md rule 10 has clarified wording. **→ SC-5**

- [ ] 98. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 99. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. **→ SC-5**

- [ ] 100. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 101. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 102. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 103. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to update approval-gate.md rule 10 with clarified wording. **→ SC-5**

- [ ] 104. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 105. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 106. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 107. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 108. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-5 changes. **→ SC-5**

- [ ] 109. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 110. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-5 content change is correct. **→ SC-5**

- [ ] 111. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-5 verdict. **→ SC-5**

---

### Item 8 — SC-6: Remove stale "resolves on next pre-work cycle" language

- [ ] 112. **RED phase (**clean-room**).** Dispatch `test-driven-development --task red` to write a content-verification test asserting "resolves on next pre-work cycle" is absent from 020-go-prohibitions.md and branch-cleanup.md. **→ SC-6**

- [ ] 113. **Z3 check RED (**inline**).** Dispatch `solve --task check` to validate RED phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 114. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. **→ SC-6**

- [ ] 115. **Z3 check RED doublecheck (**inline**).** Dispatch `solve --task check` to validate RED doublecheck state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 116. **Post-RED enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-red-enforcement` to verify RED gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 117. **Z3 check post-RED (**inline**).** Dispatch `solve --task check` to validate post-RED state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 118. **GREEN phase (**clean-room**).** Dispatch `test-driven-development --task green` to remove "resolves on next pre-work cycle" from 020-go-prohibitions.md and branch-cleanup.md, replace with accurate pointer lifecycle description. **→ SC-6**

- [ ] 119. **Z3 check GREEN (**inline**).** Dispatch `solve --task check` to validate GREEN phase state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 120. **Post-GREEN enforcement (**clean-room**).** Dispatch `implementation-pipeline --task post-green-enforcement` to verify GREEN gate conditions. **Context:** `{issue_number: 2170}`

- [ ] 121. **Z3 check post-GREEN (**inline**).** Dispatch `solve --task check` to validate post-GREEN state transition. **Context:** `{issue_number: 2170, contract_path: ...}`

- [ ] 122. **Checkpoint tag create (**clean-room**).** Dispatch `implementation-pipeline --task checkpoint-tag-create` to create checkpoint tag. **Context:** `{issue_number: 2170}`

- [ ] 123. **Checkpoint commit (**clean-room**).** Dispatch `git-workflow --task commit-prep` to commit SC-6 changes. **→ SC-6**

- [ ] 124. **Structural checks (**clean-room**).** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck. **Context:** `{issue_number: 2170}`

- [ ] 125. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-6 content change is correct. **→ SC-6**

- [ ] 126. **GREEN VbC (**clean-room**).** Dispatch `verification-before-completion --task completion` to produce SC-6 verdict. **→ SC-6**

---

#### Phase 4 VbC

- [ ] 127. **SC count gate (**clean-room**).** Dispatch `implementation-pipeline --task sc-count-gate` to verify both Phase 4 SCs have verdicts. **Context:** `{issue_number: 2170}`

- [ ] 128. **Pre-PR gate (**clean-room**).** Dispatch `verification-before-completion --task verify` to check all Phase 4 SC verdicts are PASS. **Context:** `{issue_number: 2170}`

---

## Post-Implementation Steps

- [ ] 129. **Audit (**clean-room**).** Dispatch audit task from `audit` skill with `{spec_local_dir: .opencode/.issues/2170, artifact_evidence_dir: ...}`. If non-clean-pass, remediate and restart. **Context:** `{issue_number: 2170}`

- [ ] 130. **Cross-validate (**clean-room**).** Dispatch `audit --task cross-validate` to produce consensus findings. **Context:** `{issue_number: 2170}`

- [ ] 131. **Regression check (**clean-room**).** Dispatch `test-driven-development --task patterns` to run regression tests. **Context:** `{issue_number: 2170}`

- [ ] 132. **Review prep (**clean-room**).** Dispatch `git-workflow --task review-prep` to prepare PR for review. **Context:** `{issue_number: 2170}`

- [ ] 133. **Create PR (**clean-room**).** Dispatch `pr-creation-workflow --task create` to create the pull request. **Context:** `{issue_number: 2170, authorization_scope: for_pr, halt_at: pr_created}`

- [ ] 134. **Executive summary (**clean-room**).** Dispatch `completion-core --task completion` to produce final summary. **Context:** `{issue_number: 2170}`

---

## Exit Criteria

- [ ] C1. All 8 SCs (SC-1a through SC-6) have PASS verdicts from VbC
- [ ] C2. All 4 phases complete with clean SC count gate and pre-PR gate
- [ ] C3. Audit and cross-validate produce clean PASS
- [ ] C4. Regression tests pass
- [ ] C5. PR created with review-prep complete
- [ ] C6. No phase depends on another phase's output (all 4 phases are independent)

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-28T16:21:00Z | `plan_created` | Plan file: `.opencode/.issues/2170/plan.md`, Phase count: 4, Authorization scope: `for_pr`, PR strategy: `stacked` |
