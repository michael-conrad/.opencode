# Phase 01 — Trigger Phrase Expansion

**Concern:** Add article-variant triggers to spec-creation and writing-plans skill descriptions so that natural language phrases like "create a spec" dispatch the correct skill instead of being inlined.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — description field
- `.opencode/skills/writing-plans/SKILL.md` — description field
- `.opencode/tests/behaviors/` — behavioral enforcement tests

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry conditions:** Feature branch created, pre-red-baseline complete

**Exit conditions:** All 4 SCs verified PASS, behavioral tests pass

---

- [ ] 1. **Coherence gate (**clean-room**).** Verify that the spec's Phase 1 scope (article-variant trigger expansion) is coherent with the current state of both SKILL.md files. Read both files, confirm no existing article-variant triggers, and report the current description text. **→ SC-1, SC-2**

- [ ] 2. **Pre-red-baseline (**clean-room**).** Run `grep -c "create a spec" .opencode/skills/spec-creation/SKILL.md` and `grep -c "create a plan" .opencode/skills/writing-plans/SKILL.md`. Confirm both return 0 (no article-variant triggers exist yet). Record baseline. **→ SC-1, SC-2**

- [ ] 3. **RED: spec-creation behavioral test (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/spec-creation-article-variant.sh` that sends `"create a spec for X"` via `opencode-cli run` and asserts stderr contains `Skill "spec-creation"`. Run the test — it MUST FAIL (RED) because the trigger doesn't exist yet. **→ SC-3**

- [ ] 4. **RED: writing-plans behavioral test (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/writing-plans-article-variant.sh` that sends `"create a plan for X"` via `opencode-cli run` and asserts stderr contains `Skill "writing-plans"`. Run the test — it MUST FAIL (RED) because the trigger doesn't exist yet. **→ SC-4**

- [ ] 5. **GREEN: spec-creation description (**sub-agent**).** Edit `.opencode/skills/spec-creation/SKILL.md` description field. Append article-variant triggers: `create a spec`, `write a spec`, `draft a spec`, `create a specification`, `write a specification`, `draft a specification`, `author a spec`, `make a spec`, `make specification`, `spec it out`. **→ SC-1**

- [ ] 6. **GREEN: writing-plans description (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md` description field. Append article-variant triggers: `create a plan`, `write a plan`, `draft a plan`, `make a plan`, `make plan`, `create an implementation plan`, `write an implementation plan`, `implementation steps`, `task list`, `break down the work`, `create the tasks`, `define the phases`. **→ SC-2**

- [ ] 7. **GREEN doublecheck (**clean-room**).** Run `grep -q "create a spec" .opencode/skills/spec-creation/SKILL.md` and `grep -q "create a plan" .opencode/skills/writing-plans/SKILL.md`. Confirm both return 0 exit code (triggers present). **→ SC-1, SC-2**

- [ ] 8. **GREEN: re-run behavioral tests (**clean-room**).** Run both behavioral tests from steps 3 and 4. Both MUST PASS (GREEN) now that the triggers exist. **→ SC-3, SC-4**

- [ ] 9. **Checkpoint commit (**inline**).** Commit all changes: `git add .opencode/skills/spec-creation/SKILL.md .opencode/skills/writing-plans/SKILL.md .opencode/tests/behaviors/ && git commit -m "Phase 1: Add article-variant triggers to spec-creation and writing-plans"`. Create checkpoint tag. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 10. **VbC (**clean-room**).** Verify all 4 SCs: grep for article-variant triggers in both SKILL.md files (SC-1, SC-2), run both behavioral tests and confirm PASS (SC-3, SC-4). **→ SC-1, SC-2, SC-3, SC-4**

#### Phase 01 VbC

- [ ] 10. **VbC (**clean-room**).** Verify: SC-1 (spec-creation triggers present), SC-2 (writing-plans triggers present), SC-3 (behavioral test passes), SC-4 (behavioral test passes). **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving trigger phrase expansion → entering dispatch table fixes. Phase 2 modifies spec-creation SKILL.md Tasks table, Invocation section, and Trigger Dispatch Table. No dependency on Phase 1 output.
