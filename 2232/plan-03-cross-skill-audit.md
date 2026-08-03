# Phase 3 — cross-skill audit for tracking-state violations

**Concern:** Audit all task cards across `.opencode/skills/` for tracking-state-in-spec violations (frontmatter `approved` fields, status markers, completion indicators in spec/plan documents).

**Files:**
- All `.opencode/skills/*/tasks/*.md` (audit scope)

**SCs:** SC-3

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: `analyze.md` uses `issue.yaml` labels
- Phase 2 complete: `research.md` generates `dependency-contract.yaml`
- Phase 1 and Phase 2 VbC passed

**Exit Conditions:**
- All task cards audited for tracking-state-in-spec violations
- grep for `approved` in `tasks/analyze.md` across all skills returns zero matches
- grep for `status.*completed\|status.*pending\|status.*in_progress` in spec/plan task files returns zero matches

---

- [ ] 12. **RED (**sub-agent**).** Write a failing enforcement test that asserts all task cards across `.opencode/skills/` have zero tracking-state-in-spec violations. **→ SC-3**
- [ ] 13. **GREEN (**sub-agent**).** Audit all `.opencode/skills/*/tasks/*.md` for:
    - Frontmatter `approved` fields in spec/plan task files
    - Status markers: `status.*completed`, `status.*pending`, `status.*in_progress`
    - Completion indicators in spec/plan documents
    - For each violation found, fix the file to remove the tracking state. **→ SC-3**
- [ ] 14. **GREEN doublecheck (**clean-room**).** Verify all violations are fixed: grep for `approved` in `tasks/analyze.md` across all skills returns zero matches; grep for tracking-state patterns returns zero matches. **→ SC-3**
- [ ] 15. **Checkpoint commit (**inline**).** Commit cross-skill audit fixes.

#### Phase 3 VbC

- [ ] 16. **VbC (**clean-room**).** Verify SC-3: grep for `approved` in `tasks/analyze.md` across all skills returns zero matches; grep for `status.*completed\|status.*pending\|status.*in_progress` in spec/plan task files returns zero matches. **→ SC-3**

**Concern transition:** All phases complete. Proceed to post-implementation steps.
