# Phase 4 — Add pr-body-audit Task to Audit Skill

**Concern:** Add a PR body audit task to the audit skill so that generated PR bodies can be verified against the template.

**Files:**
- `.opencode/skills/audit/SKILL.md`

**SCs:** SC-20, SC-21

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: template exists for audit to verify against
- Phase 1 VbC passed

**Exit Conditions:**
- `pr-body-audit` task added to audit skill Trigger Dispatch Table
- Task verifies all 11 enumerated PR body requirements (a) through (k)

**Cost frame:** Implementation cost is measured in defect-discovery latency, not tool-call count. Creating the pr-body-audit task and Trigger Dispatch Table entry costs ~2 file operations — each operation is a discovery point where a missing section check or wrong table entry would surface. Skipping either SC costs an unverifiable PR body pipeline where structural defects go undetected. Correctness is the only success metric — there is no score for speed.

---

### Item 20 — SC-20: pr-body-audit task added to audit skill

- [ ] 111. **RED (**sub-agent**).** Write a failing enforcement test asserting "pr-body-audit" is present in the audit skill Trigger Dispatch Table. **→ SC-20**
- [ ] 112. **GREEN (**sub-agent**).** Add the `pr-body-audit` task entry to the audit skill SKILL.md Trigger Dispatch Table. **→ SC-20**
- [ ] 113. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 114. **Verify (**clean-room**).** Verify "pr-body-audit" is present in the audit SKILL.md. **→ SC-20**
- [ ] 115. **Commit (**inline**).** `git add .opencode/skills/audit/SKILL.md && git commit -m "Phase 4 Item 20: Add pr-body-audit task to audit skill"`

### Item 21 — SC-21: pr-body-audit verifies all 11 enumerated PR body requirements

- [ ] 116. **RED (**sub-agent**).** Write a failing behavioral enforcement test: run `opencode run` with a prompt to create a PR body, then verify the audit catches structural defects. **→ SC-21**
- [ ] 117. **GREEN (**sub-agent**).** Create the `pr-body-audit` task file that verifies all 11 requirements: (a) Summary section, (b) Outcome section, (c) Verification Attestation section, (d) VbC Table section, (e) DiMo Chain Attestation section, (f) Spec-Card-Mapped Commits section, (g) closing keywords, (h) correct DiMo Chain Attestation table columns, (i) DiMo 4-role chain attestation line, (j) no synthesis corrections attestation line, (k) byline in correct format. **→ SC-21**
- [ ] 118. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 119. **Verify (**clean-room**).** Verify the task file exists and covers all 11 requirements. **→ SC-21**
- [ ] 120. **Commit (**inline**).** `git add .opencode/skills/audit/ && git commit -m "Phase 4 Item 21: Create pr-body-audit task with 11 verification requirements"`

#### Phase 4 VbC

- [ ] 121. **VbC (**clean-room**).** Verify both SCs in Phase 4 (SC-20, SC-21) pass with correct evidence types. **→ SC-20, SC-21**

**Concern transition:** Leaving PR body audit creation → entering terminology update. Phase 5 depends on Phase 1's template attestation definition being finalized.
