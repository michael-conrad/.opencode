# Phase 5 — Clean-room semantic audit

**Concern:** Run a clean-room semantic-preservation audit verifying no content loss across relocation boundaries (SC-11a, SC-11b, SC-11c) and no compaction artifacts remain (SC-12).

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/guidelines/065-verification-honesty.md`
- `.opencode/guidelines/130-authority-source.md`

**SCs:** SC-11a, SC-11b, SC-11c, SC-12

**Dependencies:** Phase 4

**Entry Conditions:**
- Phase 4 complete: no mechanical compaction artifacts
- Phase 4 VbC passed

**Exit Conditions:**
- Semantic preservation verified for all three relocations
- No content loss across relocation boundaries
- No compaction artifacts remain

**Cost frame:** Verifying semantic preservation costs one clean-room sub-agent read of two files per relocation. Skipping permits content loss that grep cannot detect — discovered at review 10x-100x later.

---

- [ ] 61. **RED (**clean-room**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent compares source (`spec-creation/SKILL.md`) and original (`130-authority-source.md`) and finds at least one of the three Superseding Issues content items (four-tier classification, overlap detection checklist, evidence artifacts recording format) missing. **→ SC-11a**
- [ ] 62. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Restore any missing Superseding Issues content in the target location. **→ SC-11a**
- [ ] 63. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Two-file comparison per SC-11a verification method. **→ SC-11a**
- [ ] 64. **Checkpoint commit (**inline**).** Stage and commit `.opencode/skills/spec-creation/SKILL.md` (plus `130-authority-source.md` if restoration requires it).

- [ ] 65. **RED (**clean-room**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent compares source (`065-verification-honesty.md`) and original (`130-authority-source.md`) and finds at least one of the two Verification First content items (filename/symbol existence verification, Drift Protocol trigger condition) missing. **→ SC-11b**
- [ ] 66. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Restore any missing Verification First content in the target location. **→ SC-11b**
- [ ] 67. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Two-file comparison per SC-11b verification method. **→ SC-11b**
- [ ] 68. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/065-verification-honesty.md` (plus `130-authority-source.md` if restoration requires it).

- [ ] 69. **RED (**clean-room**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent compares source (`spec-creation/SKILL.md`) and original (`130-authority-source.md`) and finds at least one of the two Plan Audit content items (mandatory code deep dive requirement, filesystem-grounding requirement) missing. **→ SC-11c**
- [ ] 70. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Restore any missing Plan Audit content in the target location. **→ SC-11c**
- [ ] 71. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Two-file comparison per SC-11c verification method. **→ SC-11c**
- [ ] 72. **Checkpoint commit (**inline**).** Stage and commit `.opencode/skills/spec-creation/SKILL.md` (plus `130-authority-source.md` if restoration requires it).

- [ ] 73. **RED (**clean-room**).** Dispatch `execute red task from test-driven-development`. Clean-room sub-agent content-free-header check finds a content-free section header in the final guideline. **→ SC-12**
- [ ] 74. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Remove the content-free section header; ensure no compaction artifacts remain. **→ SC-12**
- [ ] 75. **GREEN doublecheck (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Absence grep plus clean-room sub-agent content-free-header check per SC-12 verification method. **→ SC-12**
- [ ] 76. **Checkpoint commit (**inline**).** Stage and commit `.opencode/guidelines/130-authority-source.md`.

#### Phase 5 VbC

- [ ] 77. **VbC (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Verify SC-11a, SC-11b, SC-11c (semantic preservation) and SC-12 (no compaction) per their verification methods. **→ SC-11a, SC-11b, SC-11c, SC-12**

---

## Post-implementation

- [ ] 78. **Audit (**clean-room**).** Dispatch `execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first`, followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable against the spec.
- [ ] 79. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify workflow constraints.
- [ ] 80. **Structural checks (**sub-agent**).** Dispatch `execute checklist task from finishing-a-development-branch`. Run finishing checklist (markdown lint, format check).
- [ ] 81. **Pre-PR gate (**sub-agent**).** Dispatch `execute verify task from verification-before-completion`. Reads all SC verdicts; BLOCKs if any FAIL.
- [ ] 82. **Regression check (**sub-agent**).** Dispatch `execute phase-4 task from test-driven-development`. Final regression check before PR.
- [ ] 83. **Review prep (**sub-agent**).** Dispatch `execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first`. Prepare PR review context.
- [ ] 84. **Create PR (**sub-agent**).** Dispatch `execute create task from git-workflow-pr`. Create the pull request.
- [ ] 85. **Exec summary (**sub-agent**).** Dispatch `execute completion task from completion-core`. Generate completion executive summary.
