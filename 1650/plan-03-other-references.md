# Phase 3 — Replace `/skill` in Other References

**Concern:** 11 remaining `/skill` references in prose, `.issues/`, `.guidelines/README.md`, `README.md`, and `dispatch-table.yaml`.

**Files:** `brainstorming/tasks/enforcement.md`, `.issues/1372/spec.md` (2 refs), `.guidelines/README.md` (3 refs), `README.md` (3 refs), `dispatch-table.yaml` (2 refs)

**SCs:** SC-4

**Dependencies:** Phase 2 complete

**Entry:** Phase 2 verified, zero `/skill` in task files

**Exit:** All 11 remaining references use `skill()` syntax

- [ ] 9. **Pre-RED baseline (**clean-room**).** Run `grep -rn '/skill ' .opencode/ --include='*.md' --include='*.yaml'` to capture remaining matches. Save to `./tmp/1650/baseline-other.txt`. **→ SC-4**
- [ ] 10. **RED (**sub-agent**).** Write content-verification test for remaining `/skill` matches. **→ SC-4**
- [ ] 11. **GREEN (**sub-agent**).** Replace each `/skill` reference with appropriate `skill()` syntax. For prose mentions, use `` `skill({name: "..."})` ``. For dispatch-table.yaml, use the same pattern. **→ SC-4**
- [ ] 12. **GREEN doublecheck (**clean-room**).** Re-run `grep -rn '/skill ' .opencode/ --include='*.md' --include='*.yaml'` — confirm zero matches across entire `.opencode/`. **→ SC-4**

#### Phase 3 VbC

- [ ] 12a. **VbC (**clean-room**).** Verify: baseline captured, RED test written, all 11 remaining references updated, zero `/skill` matches remain across `.opencode/`. **→ SC-4**

**Concern transition:** Leaving other references → entering behavioral testing. Phase 4 depends on Phase 3's zero `/skill` in all non-skill files.
