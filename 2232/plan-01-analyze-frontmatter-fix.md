# Phase 1 — analyze.md frontmatter fix

**Concern:** Replace the spec frontmatter `approved` field check in `analyze.md` with a check against `issue.yaml` labels for `approved-for-*`.

**Files:**
- `.opencode/skills/writing-plans/tasks/analyze.md`

**SCs:** SC-1, SC-4

**Dependencies:** None

**Entry Conditions:**
- Spec #2232 is approved
- Feature branch exists
- `issue.yaml` exists at `.opencode/.issues/2232/issue.yaml` with `approved-for-pr` label

**Exit Conditions:**
- `analyze.md` checks `issue.yaml` labels for `approved-for-*` instead of spec frontmatter `approved` field
- `analyze.md` Entry Criteria and Procedure no longer reference spec frontmatter `approved` field
- grep for `frontmatter` in `analyze.md` returns zero matches

---

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test that asserts `analyze.md` checks `issue.yaml` labels for `approved-for-*` and does NOT reference spec frontmatter `approved`. **→ SC-1, SC-4**
- [ ] 2. **GREEN (**sub-agent**).** Modify `analyze.md` Entry Criteria: replace `"The spec frontmatter \`approved\` field must be present and truthy"` with `"The \`{issues_prefix}/{N}/issue.yaml\` labels must contain an \`approved-for-*\` pattern"`. **→ SC-1, SC-4**
- [ ] 3. **GREEN (**sub-agent**).** Modify `analyze.md` Procedure Step 2: replace frontmatter `approved` check with `issue.yaml` labels check. **→ SC-1, SC-4**
- [ ] 4. **GREEN doublecheck (**clean-room**).** Verify `analyze.md` has no remaining references to `frontmatter` or `approved` field. **→ SC-1, SC-4**
- [ ] 5. **Checkpoint commit (**inline**).** Commit analyze.md frontmatter fix.

#### Phase 1 VbC

- [ ] 6. **VbC (**clean-room**).** Verify SC-1 and SC-4: grep for `issue.yaml` and `approved-for` in `analyze.md` returns matches; grep for `frontmatter` in `analyze.md` returns zero matches. **→ SC-1, SC-4**

**Concern transition:** Leaving analyze.md frontmatter fix → entering research.md dependency-contract generation. Phase 2 depends on Phase 1's pattern being established.
