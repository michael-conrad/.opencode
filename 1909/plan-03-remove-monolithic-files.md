# Phase 03 — Remove Monolithic Task Files

**Concern:** Delete 9 monolithic task files and resolve Path Provider role ambiguity

**Files:**
- `.opencode/skills/audit/tasks/spec-audit.md` — delete
- `.opencode/skills/audit/tasks/verification-audit.md` — delete
- `.opencode/skills/audit/tasks/plan-fidelity.md` — delete
- `.opencode/skills/audit/tasks/concern-separation.md` — delete
- `.opencode/skills/audit/tasks/coherence-maintenance.md` — delete
- `.opencode/skills/audit/tasks/guideline-audit.md` — delete
- `.opencode/skills/audit/tasks/drift-detection.md` — delete
- `.opencode/skills/audit/tasks/content-audit.md` — delete
- `.opencode/skills/audit/tasks/test-quality-audit.md` — delete

**SCs:** SC-9, SC-10

**Dependencies:** Phase 2 (36 role-specific task files exist)

**Entry conditions:** Phase 2 complete, all 36 role-specific task files exist

**Exit conditions:** 0 monolithic task files remain, exactly one Path Provider

## Code Path Coverage

- `audit/tasks/spec-audit.md` — delete
- `audit/tasks/verification-audit.md` — delete
- `audit/tasks/plan-fidelity.md` — delete
- `audit/tasks/concern-separation.md` — delete
- `audit/tasks/coherence-maintenance.md` — delete
- `audit/tasks/guideline-audit.md` — delete
- `audit/tasks/drift-detection.md` — delete
- `audit/tasks/content-audit.md` — delete
- `audit/tasks/test-quality-audit.md` — delete

## Cross-Cutting SCs

- DiMo 4-role chain dispatch (all phases)
- File deletion safety (Phases 2 and 3)
- Path Provider role ambiguity (Phases 1 and 3)

## Interface Boundaries

- All 9 monolithic task files — removed, breaking change
- `audit/tasks/completion.md` — already modified in Phase 1
- `audit/tasks/cross-validate.md` — already modified in Phase 1

## State Transitions

- 9 monolithic task files exist → 0 monolithic task files exist
- Two task files claim Path Provider → one task file claims Path Provider

## Steps

- [ ] 55. **Verify role-specific files exist before deletion (**inline**).** `ls .opencode/skills/audit/tasks/*-generator.md .opencode/skills/audit/tasks/*-knowledge-supporter.md .opencode/skills/audit/tasks/*-evaluator.md .opencode/skills/audit/tasks/*-path-provider.md | wc -l` — must return 36. **→ SC-10**

- [ ] 56. **Delete spec-audit.md (**inline**).** `git rm .opencode/skills/audit/tasks/spec-audit.md` **→ SC-10**

- [ ] 57. **Delete verification-audit.md (**inline**).** `git rm .opencode/skills/audit/tasks/verification-audit.md` **→ SC-10**

- [ ] 58. **Delete plan-fidelity.md (**inline**).** `git rm .opencode/skills/audit/tasks/plan-fidelity.md` **→ SC-10**

- [ ] 59. **Delete concern-separation.md (**inline**).** `git rm .opencode/skills/audit/tasks/concern-separation.md` **→ SC-10**

- [ ] 60. **Delete coherence-maintenance.md (**inline**).** `git rm .opencode/skills/audit/tasks/coherence-maintenance.md` **→ SC-10**

- [ ] 61. **Delete guideline-audit.md (**inline**).** `git rm .opencode/skills/audit/tasks/guideline-audit.md` **→ SC-10**

- [ ] 62. **Delete drift-detection.md (**inline**).** `git rm .opencode/skills/audit/tasks/drift-detection.md` **→ SC-10**

- [ ] 63. **Delete content-audit.md (**inline**).** `git rm .opencode/skills/audit/tasks/content-audit.md` **→ SC-10**

- [ ] 64. **Delete test-quality-audit.md (**inline**).** `git rm .opencode/skills/audit/tasks/test-quality-audit.md` **→ SC-10**

- [ ] 65. **Verify no monolithic files remain (**inline**).** `ls .opencode/skills/audit/tasks/spec-audit.md .opencode/skills/audit/tasks/verification-audit.md .opencode/skills/audit/tasks/plan-fidelity.md .opencode/skills/audit/tasks/concern-separation.md .opencode/skills/audit/tasks/coherence-maintenance.md .opencode/skills/audit/tasks/guideline-audit.md .opencode/skills/audit/tasks/drift-detection.md .opencode/skills/audit/tasks/content-audit.md .opencode/skills/audit/tasks/test-quality-audit.md 2>&1` — must return "No such file or directory" for all 9. **→ SC-10**

- [ ] 66. **Verify exactly one Path Provider (**inline**).** `grep -rl 'Path Provider' .opencode/skills/audit/tasks/*.md` — must return exactly one file: cross-validate.md. **→ SC-9**

- [ ] 67. **Checkpoint commit (**inline**).** `git commit -m "Phase 3: Remove 9 monolithic audit task files, resolve Path Provider role ambiguity"` **→ SC-9, SC-10**

#### Phase 3 VbC

- [ ] 67. **VbC (**clean-room**).** Verify SC-9 (exactly one Path Provider), SC-10 (0 monolithic task files remain). **→ SC-9, SC-10**

**Concern transition:** Leaving monolithic task file removal → entering behavioral test verification. Phase 4 depends on Phase 3 completion.
