# Phase 3 — No-Change Verification

**Concern:** Verify that the Z3/planning steps (solve-model, solve-check, plan-plan) in `research.md` are unchanged after the workflow reorder.

**Files:**
- `.opencode/skills/writing-plans/tasks/research.md` (read-only verification)

**SCs:** SC-7

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: workflow changes applied
- Phase 2 VbC passed
- Pre-change baseline of Z3 dispatch patterns exists (captured per spec SC-7)

**Exit Conditions:**
- All 3 Z3 dispatch strings (solve-model, solve-check, plan-plan) appear in stderr in the same order
- No Z3 dispatch is missing, reordered, or new Z3-related dispatch appears

---

- [ ] 16. **RED (**sub-agent**).** Write a failing enforcement test that runs `opencode run "create plan for #2213"` and asserts the 3 Z3 dispatch strings appear in order. **→ SC-7**
- [ ] 17. **GREEN (**sub-agent**).** Verify `research.md` steps 10-12 are unchanged — read the file and confirm solve-model, solve-check, plan-plan are present and in the same order. **→ SC-7**
- [ ] 18. **GREEN doublecheck (**clean-room**).** Run the behavioral test from step 16 and confirm it passes (all 3 Z3 dispatch strings present in order). **→ SC-7**
- [ ] 19. **Checkpoint commit (**inline**).** Commit no-change verification.

#### Phase 3 VbC

- [ ] 20. **VbC (**clean-room**).** Verify SC-7: Z3 steps unchanged, dispatch patterns match pre-change baseline. **→ SC-7**

**Concern transition:** All phases complete. Proceed to post-implementation steps.
