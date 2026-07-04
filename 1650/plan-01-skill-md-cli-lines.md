# Phase 1 — Replace `/skill` in SKILL.md CLI Equivalent Lines

**Concern:** All 32 SKILL.md files have a "CLI equivalent" line using `/skill <name>` pattern. Replace with `skill({name: "<name>"})`.

**Files:** 32 SKILL.md files under `.opencode/skills/*/SKILL.md` + `routing-only-template.md`

**SCs:** SC-1

**Dependencies:** None

**Entry:** Spec approved, plan written

**Exit:** All 32 SKILL.md CLI equivalent lines use `skill({name: "..."})` syntax

- [ ] 1. **Pre-RED baseline (**clean-room**).** Run `grep -rn '/skill ' .opencode/skills/ --include='SKILL.md'` to capture current state. Save to `./tmp/1650/baseline-skills.txt`. **→ SC-1**
- [ ] 2. **RED (**sub-agent**).** Write a content-verification test that greps for `/skill` in SKILL.md files and expects it to be present (test passes because `/skill` still exists). Save to `./tmp/1650/red-test-skills.sh`. **→ SC-1**
- [ ] 3. **GREEN (**sub-agent**).** For each of the 32 SKILL.md files, replace the "CLI equivalent" line from `/skill <name>` to `` `skill({name: "<name>"})` ``. Use `grep -l '/skill ' .opencode/skills/*/SKILL.md .opencode/skills/routing-only-template.md` to enumerate targets. Apply edit tool per file. **→ SC-1**
- [ ] 4. **GREEN doublecheck (**clean-room**).** Re-run `grep -rn '/skill ' .opencode/skills/ --include='SKILL.md'` — confirm zero matches. If any remain, remediate. **→ SC-1**

#### Phase 1 VbC

- [ ] 4a. **VbC (**clean-room**).** Verify: baseline captured, RED test written, all 32 SKILL.md files updated, zero `/skill` matches remain in SKILL.md files. **→ SC-1**

**Concern transition:** Leaving SKILL.md CLI equivalent lines → entering task file examples. Phase 2 depends on Phase 1's zero `/skill` in SKILL.md files.
