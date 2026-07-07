# Phase 4 — Update SKILL.md and Dispatch Logic

**Concern:** Update `adversarial-audit/SKILL.md` to reference DiMo architecture, remove `resolve-models` from dispatch routing, and update dispatch contract documentation.

**Files:**
- `.opencode/skills/adversarial-audit/SKILL.md` — Modify

**SCs:** SC-5

**Dependencies:** Phase 1, 2, 3 complete (old infrastructure deleted, auditor-role.md exists, task files refactored)

**Entry conditions:** All 15 task files refactored with DiMo roles, no old infrastructure remains

**Exit conditions:** SKILL.md updated with DiMo architecture, no resolve-models references in dispatch routing

---

- [ ] 57. **Coherence gate (**clean-room**).** Dispatch `adversarial-audit --task coherence-extraction` to verify SC-5 evidence type is correctly classified. **→ SC-5**

- [ ] 58. **Z3 check (**inline**).** Run `solve check` against coherence gate output contract.

- [ ] 59. **Pre-RED baseline (**clean-room**).** Dispatch `implementation-pipeline --task pre-red-baseline` to capture current SKILL.md state (grep for `resolve-models`, `audit_phase`, cross-model references). **→ SC-5**

- [ ] 60. **Z3 check (**inline**).** Run `solve check` against pre-red-baseline output contract.

- [ ] 61. **RED: Write string-pattern test (**sub-agent**).** Dispatch `test-driven-development --task red` to write a test that greps SKILL.md for:
  - `resolve-models` — should be absent
  - `audit_phase` in dispatch contract — should be absent
  - DiMo role references — should be present
  The test MUST fail at this point because SKILL.md still has old patterns. **→ SC-5**

- [ ] 62. **Z3 check RED (**inline**).** Run `solve check` against red-phase output contract.

- [ ] 63. **RED doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm the RED test correctly detects old patterns. **→ SC-5**

- [ ] 64. **Z3 check RED doublecheck (**inline**).** Run `solve check` against red-doublecheck output contract.

- [ ] 65. **Post-RED enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. **→ SC-5**

- [ ] 66. **Z3 check post-RED (**inline**).** Run `solve check` against post-red-enforcement output contract.

- [ ] 67. **GREEN: Update SKILL.md (**sub-agent**).** Dispatch `test-driven-development --task green` to modify `.opencode/skills/adversarial-audit/SKILL.md`:
  - **Remove `resolve-models` from dispatch routing** — replace the multi-dispatch adversarial-audit step (resolve-models → auditor_1 → remediate → auditor_2 → remediate) with a single DiMo role-dispatch step
  - **Update dispatch contract** — reduce to 2 fields: `spec_local_dir`, `artifact_evidence_dir`. Remove `audit_phase` (SC-5)
  - **Add DiMo architecture overview** — reference `auditor-role.md` as the single role card
  - **Update Trigger Dispatch Table** — remove `resolve-models` references, add DiMo role dispatch entries
  - **Update Dispatch Routing Table** — replace cross-model audit dispatch with DiMo role chain dispatch
  - **Update Pre-Flight section** — remove `resolve-models` precondition, remove `INSUFFICIENT_FAMILIES` error handling
  - **Update Persona** — reference DiMo role-differentiated chaining **→ SC-5**

- [ ] 68. **Z3 check GREEN (**inline**).** Run `solve check` against green-phase output contract.

- [ ] 69. **Post-GREEN enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-green-enforcement`. **→ SC-5**

- [ ] 70. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-green-enforcement output contract.

- [ ] 71. **Checkpoint commit (**inline**).** Run `git add -A && git commit -m "Phase 4: Update SKILL.md and dispatch logic"`. Create checkpoint tag: `opencode-config/checkpoint/1672/phase-4-opencode`. **→ SC-5**

- [ ] 72. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. **→ SC-5**

- [ ] 73. **GREEN doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SKILL.md has no `resolve-models` references and dispatch contract has 2 fields. **→ SC-5**

- [ ] 74. **VbC (**clean-room**).** Verify SC-5: dispatch contract reduced to 2 fields (`spec_local_dir`, `artifact_evidence_dir`), no `audit_phase` in SKILL.md. **→ SC-5**

**Concern transition:** Leaving SKILL.md update → entering behavioral tests. Phase 5 depends on Phase 4's updated SKILL.md (behavioral tests verify the new dispatch behavior).
