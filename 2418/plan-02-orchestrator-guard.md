# Phase 2 — ORCHESTRATOR_GUARD

**Concern:** Prevent orchestrator pre-investigation by adding a guard note and behavioral enforcement test.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`
- `.opencode/tests-v2/behaviors/` (new behavioral test file)

**SCs:** SC-2, SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: SKILL.md uses `pr_merged_event: true` flag
- Phase 1 VbC passed

**Exit Conditions:**
- cleanup.md Step 0 contains explicit guard note against orchestrator pre-investigation
- Behavioral test exists and passes (verifies no git/gh calls before dispatch via `opencode run` + stderr inspection)

---

- [ ] 6. **RED (**sub-agent**).** Write a failing behavioral enforcement test for SC-2: send a real-domain prompt via `opencode run`, inspect stderr for git/gh tool calls before dispatch. Assert that git/gh calls DO appear (test fails initially because the orchestrator currently does inline investigation). **→ SC-2**
- [ ] 7. **GREEN (**sub-agent**).** Add guard note to cleanup.md Step 0: explicit instruction that the orchestrator MUST NOT run git/gh tool calls inline before dispatching the cleanup sub-agent. **→ SC-4**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Verify the behavioral test still fails (SC-2 requires code change in SKILL.md from Phase 1 which is already committed; the test should now pass because the dispatch prompt no longer forces inline resolution). **→ SC-2**
- [ ] 9. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/tasks/cleanup.md .opencode/tests-v2/behaviors/ && git commit -m "Phase 2: add guard note and behavioral enforcement test"`

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify SC-4: grep cleanup.md for guard note text — confirm present at Step 0. Verify SC-2: run behavioral test via `opencode run` + stderr inspection — confirm PASS. **→ SC-2, SC-4**

**Concern transition:** Orchestrator guard in place → entering result ordering phase. Phase 3 depends on Phase 2's behavioral test being in place.
