# Phase 3 — Fix cross-reference

**Concern:** cross-reference

**Files:**
- `.opencode/skills/git-workflow-pr/SKILL.md`

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `critical-rules-PR-ORG` exists in `000-critical-rules.md`
- Phase 1 VbC passed
- `.opencode/skills/git-workflow-pr/SKILL.md` line 74 reads `Read [critical-rules-PR-ORG](guidelines/000-critical-rules.md) for stacked PR strategy`

**Exit Conditions:**
- `.opencode/skills/git-workflow-pr/SKILL.md` line 74 cross-reference resolves to the actual rule location
- `grep` confirms `critical-rules-PR-ORG` exists at the referenced path

---

- [ ] 11. **RED (**sub-agent**).** Write a failing enforcement test asserting the `Read [critical-rules-PR-ORG](guidelines/000-critical-rules.md)` cross-reference in `.opencode/skills/git-workflow-pr/SKILL.md` resolves to an existing rule. **→ SC-3**
- [ ] 12. **GREEN (**sub-agent**).** Verify the cross-reference target `guidelines/000-critical-rules.md` contains `critical-rules-PR-ORG`; if the reference path is stale, update it to the actual rule location. **→ SC-3**
- [ ] 13. **GREEN doublecheck (**clean-room**).** Verify `grep` confirms the referenced rule exists at the referenced path. **→ SC-3**
- [ ] 14. **Checkpoint commit (**inline**).** Commit the cross-reference fix.

#### Phase 3 VbC

- [ ] 15. **VbC (**clean-room**).** Verify `grep` confirms `critical-rules-PR-ORG` exists at the path referenced by line 74. **→ SC-3**

**Concern transition:** Leaving cross-reference → entering post-implementation. All three SCs are now covered.
