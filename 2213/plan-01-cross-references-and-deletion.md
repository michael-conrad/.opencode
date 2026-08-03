# Phase 1 — Cross-References and Deletion

**Concern:** Update all cross-references from `plan-creation-pipeline` to `writing-plans`, then delete the obsolete skill directory.

**Files:**
- `.opencode/skills/plan/SKILL.md` (modify)
- `.opencode/skills/plan-creation-pipeline/SKILL.md` (delete)
- `.opencode/skills/plan-creation-pipeline/tasks/authorization-context.md` (delete)

**SCs:** SC-5, SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2213 is approved
- Feature branch exists
- Pre-deletion checkpoint: `plan-creation-pipeline/` directory exists

**Exit Conditions:**
- `grep -r "plan-creation-pipeline" .opencode/` returns zero matches
- `ls .opencode/skills/plan-creation-pipeline/` returns "No such file or directory"

---

### Item 1 — SC-5: Update cross-references

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test that verifies `grep -r "plan-creation-pipeline" .opencode/` returns zero matches. **→ SC-5**
- [ ] 2. **GREEN (**sub-agent**).** Update `plan/SKILL.md` description: replace `plan-creation-pipeline` with `writing-plans`. **→ SC-5**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify `grep -r "plan-creation-pipeline" .opencode/` returns zero matches. **→ SC-5**
- [ ] 4. **Checkpoint commit (**inline**).** Commit cross-reference update. **→ SC-5**

### Item 2 — SC-1: Delete plan-creation-pipeline directory

- [ ] 5. **RED (**sub-agent**).** Write a failing enforcement test that verifies `ls .opencode/skills/plan-creation-pipeline/` returns "No such file or directory". **→ SC-1**
- [ ] 6. **GREEN (**sub-agent**).** Delete `plan-creation-pipeline/` directory via `git rm -r .opencode/skills/plan-creation-pipeline/`. **→ SC-1**
- [ ] 7. **GREEN doublecheck (**clean-room**).** Verify `ls .opencode/skills/plan-creation-pipeline/` fails. **→ SC-1**
- [ ] 8. **Checkpoint commit (**inline**).** Commit deletion. **→ SC-1**

#### Phase 1 VbC

- [ ] 9. **VbC (**clean-room**).** Verify SC-5 (no `plan-creation-pipeline` references remain) and SC-1 (directory deleted). **→ SC-5, SC-1**

**Concern transition:** Leaving cross-reference cleanup → entering workflow changes. Phase 2 depends on Phase 1's deletion of the old skill.
