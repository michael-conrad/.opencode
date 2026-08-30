# Phase 2 — ORCHESTRATOR_GUARD

**Concern:** Add guard note to `cleanup.md` Step 0 and create behavioral enforcement test verifying no git/gh inline calls before dispatch.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`
- `.opencode/tests-v2/behaviors/` (new behavioral test file)

**SCs:** SC-2, SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: SKILL.md dispatch prompt updated
- Phase 1 VbC passed
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` exists and is readable

**Exit Conditions:**
- cleanup.md Step 0 has explicit guard note against orchestrator pre-investigation
- Behavioral enforcement test exists and verifies no git/gh calls before dispatch

---

**Cost frame:** This phase spans two files — a documentation change (guard note in cleanup.md) and a new behavioral test file. The guard note is a string-level change verified by grep. The behavioral test requires one `opencode run` invocation against a real model, which is the dominant cost factor. The RED/GREEN/verify/commit cycle with a single behavioral test dispatch is the minimum viable sequence.

- [ ] 9. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-2, SC-4**
- [ ] 10. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-2, SC-4**

- [ ] 11. **RED (**sub-agent**).** Write a failing behavioral enforcement test asserting orchestrator does NOT run git/gh calls inline before dispatching cleanup sub-agent. **→ SC-2**
- [ ] 12. **GREEN (**sub-agent**).** Add guard note in cleanup.md Step 0 against orchestrator pre-investigation. **→ SC-4**
- [ ] 13. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-2, SC-4**
- [ ] 14. **Verify (**clean-room**).** Verify SC-4: grep cleanup.md for guard note text. Verify SC-2: run behavioral test and check stderr for no git/gh calls before dispatch. **→ SC-2, SC-4**
- [ ] 15. **Commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/tasks/cleanup.md .opencode/tests-v2/behaviors/ && git commit -m "Phase 2: add guard note and behavioral test for orchestrator pre-investigation"`. **→ SC-2, SC-4**

#### Phase 2 VbC

- [ ] 16. **VbC (**clean-room**).** Verify SC-4: grep cleanup.md for guard note text — must find the guard note. Verify SC-2: run behavioral test via `opencode run` + stderr inspection — no git/gh calls before dispatch. **→ SC-2, SC-4**

**Concern transition:** Leaving orchestrator guard addition → entering result ordering reinforcement. Phase 3 depends on Phase 2's guard note being in place in cleanup.md.
