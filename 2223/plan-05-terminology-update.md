# Phase 5 — Update Stale Dual-Auditor Terminology

**Concern:** Replace all stale "dual-auditor" references with "DiMo chain" across 5 affected files.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/guidelines/250-dark-prose-reference.md`
- `.opencode/guidelines/255-distribution-shifting-reference.md`
- `.opencode/guidelines/257-procedural-discipline-reference.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

**SCs:** SC-22, SC-23, SC-24, SC-25, SC-26

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: template attestation definition finalized
- Phase 1 VbC passed

**Exit Conditions:**
- No "dual-auditor" references remain in any of the 5 affected files

**Cost frame:** Implementation cost is measured in defect-discovery latency, not tool-call count. Replacing stale terminology across 5 files costs ~5 find-and-replace operations — each operation is a discovery point where a missed occurrence would be caught. Skipping any SC costs a stale "dual-auditor" reference that propagates fabrication risk. Correctness is the only success metric — there is no score for speed.

---

### Item 22 — SC-22: Update 000-critical-rules.md dual-auditor reference

- [ ] 122. **RED (**sub-agent**).** Write a failing enforcement test asserting "dual-auditor" is absent from `000-critical-rules.md`. **→ SC-22**
- [ ] 123. **GREEN (**sub-agent**).** Replace "dual-auditor" with "DiMo chain" in `000-critical-rules.md`. **→ SC-22**
- [ ] 124. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 125. **Verify (**clean-room**).** Verify "dual-auditor" is absent from the file. **→ SC-22**
- [ ] 126. **Commit (**inline**).** `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 5 Item 22: Update dual-auditor reference in 000-critical-rules.md"`

### Item 23 — SC-23: Update 250-dark-prose-reference.md dual-auditor references

- [ ] 127. **RED (**sub-agent**).** Write a failing enforcement test asserting "dual-auditor" is absent from `250-dark-prose-reference.md`. **→ SC-23**
- [ ] 128. **GREEN (**sub-agent**).** Replace both "dual-auditor" occurrences with "DiMo chain" in `250-dark-prose-reference.md`. **→ SC-23**
- [ ] 129. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 130. **Verify (**clean-room**).** Verify "dual-auditor" is absent from the file. **→ SC-23**
- [ ] 131. **Commit (**inline**).** `git add .opencode/guidelines/250-dark-prose-reference.md && git commit -m "Phase 5 Item 23: Update dual-auditor references in 250-dark-prose-reference.md"`

### Item 24 — SC-24: Update 255-distribution-shifting-reference.md dual-auditor reference

- [ ] 132. **RED (**sub-agent**).** Write a failing enforcement test asserting "dual-auditor" is absent from `255-distribution-shifting-reference.md`. **→ SC-24**
- [ ] 133. **GREEN (**sub-agent**).** Replace "dual-auditor" with "DiMo chain" in `255-distribution-shifting-reference.md`. **→ SC-24**
- [ ] 134. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 135. **Verify (**clean-room**).** Verify "dual-auditor" is absent from the file. **→ SC-24**
- [ ] 136. **Commit (**inline**).** `git add .opencode/guidelines/255-distribution-shifting-reference.md && git commit -m "Phase 5 Item 24: Update dual-auditor reference in 255-distribution-shifting-reference.md"`

### Item 25 — SC-25: Update 257-procedural-discipline-reference.md dual-auditor reference

- [ ] 137. **RED (**sub-agent**).** Write a failing enforcement test asserting "dual-auditor" is absent from `257-procedural-discipline-reference.md`. **→ SC-25**
- [ ] 138. **GREEN (**sub-agent**).** Replace "dual-auditor" with "DiMo chain" in `257-procedural-discipline-reference.md`. **→ SC-25**
- [ ] 139. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 140. **Verify (**clean-room**).** Verify "dual-auditor" is absent from the file. **→ SC-25**
- [ ] 141. **Commit (**inline**).** `git add .opencode/guidelines/257-procedural-discipline-reference.md && git commit -m "Phase 5 Item 25: Update dual-auditor reference in 257-procedural-discipline-reference.md"`

### Item 26 — SC-26: Update branch-cleanup.md dual-auditor reference

- [ ] 142. **RED (**sub-agent**).** Write a failing enforcement test asserting "dual-auditor" is absent from `branch-cleanup.md`. **→ SC-26**
- [ ] 143. **GREEN (**sub-agent**).** Replace "dual-auditor" with "DiMo chain" in `branch-cleanup.md`. **→ SC-26**
- [ ] 144. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 145. **Verify (**clean-room**).** Verify "dual-auditor" is absent from the file. **→ SC-26**
- [ ] 146. **Commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md && git commit -m "Phase 5 Item 26: Update dual-auditor reference in branch-cleanup.md"`

#### Phase 5 VbC

- [ ] 147. **VbC (**clean-room**).** Verify all 5 SCs in Phase 5 (SC-22 through SC-26) pass with correct evidence types. **→ SC-22, SC-23, SC-24, SC-25, SC-26**

**Concern transition:** Leaving terminology update → entering cross-reference update. Phase 6 depends on Phase 2's skill deletion being complete so cross-references can be updated.
