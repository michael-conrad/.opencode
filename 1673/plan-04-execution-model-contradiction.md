# Phase 04 — Execution Model Contradiction

**Concern:** Remove "no task() calls" language from writing-plans SKILL.md and update Mandatory Task Discipline, Persona, Sub-Agent Routing, and Operating Protocol to reflect the sub-agent dispatch model.

**Files:**
- `.opencode/skills/writing-plans/SKILL.md` — Mandatory Task Discipline, Persona, Sub-Agent Routing, Operating Protocol
- `.opencode/skills/writing-plans/tasks/create.md` — consistency verification
- `.opencode/tests/behaviors/` — behavioral test for sub-agent dispatch

**SCs:** SC-15, SC-16, SC-17

**Dependencies:** None

**Entry conditions:** Feature branch exists, pre-red-baseline complete

**Exit conditions:** All 3 SCs verified PASS

---

- [ ] 32. **Coherence gate (**clean-room**).** Read `.opencode/skills/writing-plans/SKILL.md`. Find all instances of "no task()" language. Read `create.md` to confirm it dispatches sub-agents. Report contradiction. **→ SC-15, SC-16**

- [ ] 33. **Pre-red-baseline (**clean-room**).** Run `grep -c "no task()" .opencode/skills/writing-plans/SKILL.md` (expect 2+). Run `grep -c "sub-agent" .opencode/skills/writing-plans/SKILL.md` in Mandatory Task Discipline section (expect 0). Record baselines. **→ SC-15, SC-16**

- [ ] 34. **RED: behavioral test (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/writing-plans-sub-agent-dispatch.sh` that sends a plan creation prompt via `opencode-cli run` and asserts stderr shows `task()` calls (sub-agent dispatch). Run the test — it MUST FAIL (RED) because the SKILL.md still says "no task()". **→ SC-17**

- [ ] 35. **GREEN: remove "no task()" language (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md`. Remove all instances of "no task() calls" language (lines 12, 22, 71, 84, 120 per evidence). Replace with language stating that the pipeline dispatches sub-agents for each step. **→ SC-15**

- [ ] 36. **GREEN: update Mandatory Task Discipline (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md` Mandatory Task Discipline section. State that the pipeline dispatches sub-agents for each step via `task()`. Reference the sub-agent dispatch model. **→ SC-16**

- [ ] 37. **GREEN: update Persona and Sub-Agent Routing (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md` Persona section to reflect sub-agent dispatch model. Update Sub-Agent Routing section to document the sub-agent dispatch pattern with dispatch indicators. **→ SC-16**

- [ ] 38. **GREEN: update Operating Protocol (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md` Operating Protocol section. Add dispatch indicators matching create.md's implementation. Ensure consistency with create.md's sub-agent dispatch pattern. **→ SC-16**

- [ ] 39. **GREEN doublecheck (**clean-room**).** Verify: `grep -c "no task()" .opencode/skills/writing-plans/SKILL.md` == 0 (SC-15), `grep -q "sub-agent" .opencode/skills/writing-plans/SKILL.md` in Mandatory Task Discipline (SC-16). Read create.md to confirm consistency. **→ SC-15, SC-16**

- [ ] 40. **Checkpoint commit (**inline**).** Commit: `git add .opencode/skills/writing-plans/SKILL.md && git commit -m "Phase 4: Fix writing-plans execution model contradiction"`. Create checkpoint tag. **→ SC-15, SC-16**

- [ ] 41. **VbC (**clean-room**).** Verify all 3 SCs: grep for "no task()" absence (SC-15), grep for "sub-agent" in Mandatory Task Discipline (SC-16), run behavioral test and confirm PASS (SC-17). **→ SC-15, SC-16, SC-17**

#### Phase 04 VbC

- [ ] 41. **VbC (**clean-room**).** Verify: SC-15 (no "no task()" language), SC-16 (sub-agent dispatch model stated), SC-17 (behavioral test passes). **→ SC-15, SC-16, SC-17**

**Concern transition:** Leaving execution model contradiction → entering missing pipeline steps. Phase 5 depends on Phase 2 (same file — spec-creation SKILL.md). Phase 5 adds adversarial-audit, change-control, and spec-to-plan dispatch paths.
