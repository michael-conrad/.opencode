# Phase 1 — Generalize

**Concern:** Replace project-specific paths and names with universal language (CONCERN-GENERALIZE).

**Files:**
- `.opencode/guidelines/080-code-standards.md`

**SCs:** SC-1, SC-2, SC-7

**Dependencies:** None

**Entry Conditions:**
- Spec #2131 is approved
- Feature branch exists
- `080-code-standards.md` is at its current state with project-specific references intact

**Exit Conditions:**
- Parsing Logic Changes section has no project-specific paths (`src/commons/parsing/`, `0100_ingest_xml.ipynb`)
- Libraries & Packages section has no project-specific names (`NLTK`, `ConfigurationManager`, `project-config.ini`, `210-scripting.md`)
- Generalized Parsing Logic Changes text preserves the pipeline-rerun constraint

---

- [ ] 1. **RED (**sub-agent**).** Write failing grep test asserting project-specific paths still exist in Parsing Logic Changes section. **→ SC-1**
- [ ] 2. **RED (**sub-agent**).** Write failing grep test asserting project-specific names still exist in Libraries & Packages section. **→ SC-2**
- [ ] 3. **GREEN (**sub-agent**).** Replace project-specific paths in Parsing Logic Changes with universal language: "Changes to data processing pipelines that affect extracted metadata require a full pipeline rerun". **→ SC-1, SC-7**
- [ ] 4. **GREEN (**sub-agent**).** Replace project-specific names in Libraries & Packages with universal language: "Use domain-appropriate libraries for specialized tasks. Use project-provided abstractions for data file paths." **→ SC-2**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify: (a) no project-specific paths remain in Parsing Logic Changes, (b) no project-specific names remain in Libraries & Packages, (c) pipeline-rerun constraint is preserved in generalized text. **→ SC-1, SC-2, SC-7**
- [ ] 6. **Checkpoint commit (**inline**).** Commit generalization changes.

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify SC-1 (grep absence of `src/commons/parsing`), SC-2 (grep absence of `ConfigurationManager`), SC-7 (semantic: pipeline-rerun constraint preserved). **→ SC-1, SC-2, SC-7**

**Concern transition:** Leaving generalization → entering move. Phase 2 depends on Phase 1's generalized sections.
