# Phase 2 — Replace `/skill` in Task File Examples

**Concern:** 8 task file examples use `/skill <name> --task <task>` or `/skill <name>` patterns. Replace with `skill()` + `task()` syntax.

**Files:** 7 task files with `--task` + 1 task file without `--task` (squash-push.md)

**SCs:** SC-2, SC-3

**Dependencies:** Phase 1 complete

**Entry:** Phase 1 verified, zero `/skill` in SKILL.md files

**Exit:** All 8 task file examples use `skill()` + `task()` patterns

- [ ] 5. **Pre-RED baseline (**clean-room**).** Run `grep -rn '/skill ' .opencode/skills/*/tasks/ --include='*.md'` to capture current state. Save to `./tmp/1650/baseline-tasks.txt`. **→ SC-2, SC-3**
- [ ] 6. **RED (**sub-agent**).** Write content-verification test that greps for `/skill` in task files and expects matches. **→ SC-2, SC-3**
- [ ] 7. **GREEN (**sub-agent**).** For each of the 8 task files, replace `/skill <name> --task <task>` with `` `task(..., prompt: "execute <task> from <skill>")` `` and `/skill <name>` (without `--task`) with `` `skill({name: "<name>"})` ``. **→ SC-2, SC-3**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Re-run `grep -rn '/skill ' .opencode/skills/*/tasks/ --include='*.md'` — confirm zero matches. **→ SC-2, SC-3**

#### Phase 2 VbC

- [ ] 8a. **VbC (**clean-room**).** Verify: baseline captured, RED test written, all 8 task files updated, zero `/skill` matches remain in task files. **→ SC-2, SC-3**

**Concern transition:** Leaving task file examples → entering other references. Phase 3 depends on Phase 2's zero `/skill` in task files.
