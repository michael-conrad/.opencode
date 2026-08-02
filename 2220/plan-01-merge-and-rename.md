# Phase 1 — Merge and Rename

**Concern:** Merge SKILL.md content and update dispatch calls before deleting source files.

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/approval-gate-scope/SKILL.md` (read-only source)
- `.opencode/guidelines/000-critical-rules.md`

**SCs:** SC-1, SC-3

**Dependencies:** None

**Entry Conditions:**
- Spec #2220 is approved
- Feature branch exists
- `approval-gate-scope/SKILL.md` exists and is readable

**Exit Conditions:**
- `approval-gate/SKILL.md` contains all 4 section groups from `approval-gate-scope/SKILL.md`
- All `skill({name: 'approval-gate-scope'})` calls updated to `skill({name: 'approval-gate'})`

---

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ pre-implementation**
- [ ] 2. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ pre-implementation**

- [ ] 3. **RED — SC-1 (**sub-agent**).** Write a semantic test that verifies the merged content does not yet exist in `approval-gate/SKILL.md`. **→ SC-1**
- [ ] 4. **GREEN — SC-1 (**sub-agent**).** Merge all 4 section groups (routing metadata, scope model, bug discovery protocol, DISPATCH_GATE protocol) from `approval-gate-scope/SKILL.md` into `approval-gate/SKILL.md`. **→ SC-1**
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-1**
- [ ] 6. **Verify — SC-1 (**clean-room**).** Verify implementation against SC-1: clean-room sub-agent reads merged SKILL.md and verifies each of the 4 section groups contains all required subsections. **→ SC-1**
- [ ] 7. **Commit — SC-1 (**inline**).** `git add .opencode/skills/approval-gate/SKILL.md && git commit -m 'feat: merge approval-gate-scope SKILL.md content into approval-gate SKILL.md'`

- [ ] 8. **RED — SC-3 (**sub-agent**).** Write a grep test that shows `skill({name: 'approval-gate-scope'})` still exists in `.opencode/`. **→ SC-3**
- [ ] 9. **GREEN — SC-3 (**sub-agent**).** Replace all `skill({name: 'approval-gate-scope'})` with `skill({name: 'approval-gate'})` in `.opencode/skills/approval-gate/SKILL.md` and `.opencode/guidelines/000-critical-rules.md`. **→ SC-3**
- [ ] 10. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-3**
- [ ] 11. **Verify — SC-3 (**clean-room**).** Verify implementation against SC-3: grep for `approval-gate-scope` in dispatch calls returns zero matches. **→ SC-3**
- [ ] 12. **Commit — SC-3 (**inline**).** `git add .opencode/skills/approval-gate/SKILL.md .opencode/guidelines/000-critical-rules.md && git commit -m 'refactor: update skill() dispatch calls from approval-gate-scope to approval-gate'`

#### Phase 1 VbC

- [ ] 13. **VbC (**clean-room**).** Verify SC-1 (merged SKILL.md has all 4 section groups) and SC-3 (no stale dispatch calls). **→ SC-1, SC-3**

**Concern transition:** Leaving merge and rename → entering file deletion. Phase 2 depends on Phase 1's merged SKILL.md and updated dispatch calls.
