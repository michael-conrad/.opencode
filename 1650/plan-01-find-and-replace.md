# Phase 1 — Find-and-replace `/skill` → `skill()`

**Concern:** Replace all 58 `/skill` references across `.opencode/` with `skill({name: "..."})` and `task()` syntax.

**Files:**
- `.opencode/skills/*/SKILL.md` (32 CLI lines)
- `.opencode/skills/*/tasks/*.md` (7 `--task` examples)
- `.opencode/skills/*/tasks/**/*.md` (7 additional locations)
- `.opencode/skills/brainstorming/tasks/enforcement.md` (1 prose mention)
- `.opencode/.guidelines/README.md` (3 references)
- `.opencode/README.md` (3 references)
- `.opencode/dispatch-table.yaml` (2 references)
- `.opencode/.issues/1372/spec.md` (2 references)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Research complete (58 locations identified)

**Entry condition:** Research evidence artifact exists at `tmp/1650/research/evidence-artifact.md`

**Exit condition:** All 58 `/skill` references replaced; `grep -rn '/skill' .opencode/` returns 0

- [ ] 1. **RED: write grep-based verification scripts (**clean-room**).** Write verification scripts to `./tmp/1650/`:
  - `sc-1-red.sh`: grep for `/skill` in `.opencode/skills/*/SKILL.md` and `.opencode/skills/routing-only-template.md` — must FAIL (≥1 match)
  - `sc-2-red.sh`: grep for `/skill.*--task` in `.opencode/skills/*/tasks/` — must FAIL (≥1 match)
  - `sc-3-red.sh`: grep for `/skill` in `squash-push.md` — must FAIL (≥1 match)
  - `sc-4-red.sh`: grep for `/skill` in `enforcement.md` — must FAIL (≥1 match)
  - `sc-5-red.sh`: grep for `/skill` across all `.opencode/` — must FAIL (≥58 matches)
  Run all 5 scripts and confirm they FAIL. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 2. **GREEN: replace `/skill` in all 32 SKILL.md CLI lines (**sub-agent**).** For each of the 32 SKILL.md files, replace the `CLI equivalent:` line from `/skill <name>` to `` `skill({name: "<name>"})` ``. Use `skill({name: "writing-plans"})` for the writing-plans skill's own CLI line. **→ SC-1**

- [ ] 3. **GREEN: replace `/skill --task` in all 7 task file examples (**sub-agent**).** For each of the 7 task files with `--task` examples, replace `/skill <name> --task <task>` with `` `skill({name: "<name>"})` `` followed by `` `task(..., prompt: "execute <task> from <skill>")` ``. **→ SC-2**

- [ ] 4. **GREEN: replace `/skill` in remaining files (**sub-agent**).** Replace:
  - `squash-push.md`: `/skill changelog-generator --since-last-release` → `` `skill({name: "changelog-generator"})` `` **→ SC-3**
  - `enforcement.md`: `Say '/skill brainstorming'` → `` `skill({name: "brainstorming"})` `` **→ SC-4**
  - `.guidelines/README.md`, `README.md`, `dispatch-table.yaml`, `.issues/1372/spec.md`: all `/skill` references → `skill()` syntax **→ SC-3, SC-4**
  - 7 additional locations in TDD red/green/refactor, changelog backfill/date-range, sre-runbook reference docs: all `/skill` references → `skill()` syntax **→ SC-5**

- [ ] 5. **GREEN doublecheck: verify SC-1 through SC-4 (**clean-room**).** Run the verification scripts from Step 1. SC-1 through SC-4 must now PASS (exit zero). **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 6. **GREEN doublecheck: verify SC-5 (**clean-room**).** Run `grep -rn '/skill' .opencode/ --include='*.md' --include='*.yaml' --include='*.yml'` and confirm zero matches. **→ SC-5**

- [ ] 7. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 1: replace all /skill references with skill() syntax across .opencode/"` **→ SC-1, SC-2, SC-3, SC-4, SC-5**

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Run `grep -rn '/skill' .opencode/` — verify zero matches across ALL file types. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving find-and-replace → entering behavioral test and verification. Phase 2 depends on Phase 1 completing all `/skill` replacements.
