# Phase 3 — auto-dispatch-fix

**Concern:** Fix the approval-gate `auto-dispatch` task for `for_pr` gap-fill to route plan creation through the writing-plans pipeline (task: `create`) instead of dispatching a single sub-agent with a custom prompt.

**Files:**
- `.opencode/skills/approval-gate/tasks/auto-dispatch.md` (update)

**SCs:** SC-3

**Dependencies:** Phase 2 (references `verify-plan-pipeline` task)

**Entry conditions:** Phase 2 complete and committed

**Exit conditions:** `auto-dispatch.md` updated to route through writing-plans create task, behavioral test passes

---

- [ ] 15. (**RED**) Write behavioral enforcement test that verifies `for_pr` gap-fill routes through writing-plans create task. Test sends a `for_pr` authorization and asserts the agent dispatches the writing-plans create task. Save to `.opencode/tests/behaviors/auto-dispatch-for-pr.sh`.
- [ ] 16. (**inline**) Run the behavioral test — confirm it FAILS (RED phase passes).
- [ ] 17. (**GREEN**) Update `.opencode/skills/approval-gate/tasks/auto-dispatch.md`: change the plan creation dispatch from a single sub-agent with custom prompt to route through `writing-plans --task create`. Update the dispatch instruction to use the canonical writing-plans create task string.
- [ ] 18. (**inline**) Run the behavioral test — confirm it PASSES (GREEN phase passes).
- [ ] 19. (**inline**) VbC: Verify `auto-dispatch.md` references `writing-plans create` task. Verify behavioral test passes.
- [ ] 20. (**inline**) Phase completion: Commit phase 3 artifacts to feature branch.
