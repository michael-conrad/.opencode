# Phase 2 — verify-plan-pipeline

**Concern:** Add a `verify-plan-pipeline` task to approval-gate that checks whether the writing-plans 22-step pipeline was followed before accepting a plan.

**Files:**
- `.opencode/skills/approval-gate/tasks/verify-plan-pipeline.md` (new)
- `.opencode/skills/approval-gate/SKILL.md` (update — add task to task list and Trigger Dispatch Table)

**SCs:** SC-1

**Dependencies:** None

**Entry conditions:** Phase 1 complete and committed

**Exit conditions:** `verify-plan-pipeline` task file written, SKILL.md updated with task reference, behavioral test passes

---

- [ ] 8. (**RED**) Write behavioral enforcement test that verifies the verify-plan-pipeline gate checks pipeline completeness. Test sends a prompt with a plan that skipped pipeline steps and asserts the agent returns FAIL. Save to `.opencode/tests/behaviors/verify-plan-pipeline.sh`.
- [ ] 9. (**inline**) Run the behavioral test — confirm it FAILS (RED phase passes).
- [ ] 10. (**GREEN**) Create `.opencode/skills/approval-gate/tasks/verify-plan-pipeline.md` with: Purpose (verify writing-plans 22-step pipeline was followed), Entry Criteria (plan artifacts exist), Exit Criteria (PASS if all pipeline artifacts present, FAIL if any missing), Procedure (check local spec file exists, check feature branch exists, check Z3 check artifacts exist, check audit artifacts exist, check completion artifact exists, return PASS/FAIL).
- [ ] 11. (**GREEN**) Update `.opencode/skills/approval-gate/SKILL.md`: add `verify-plan-pipeline` to the task list, add to Trigger Dispatch Table with dispatch mode `sub-task`.
- [ ] 12. (**inline**) Run the behavioral test — confirm it PASSES (GREEN phase passes).
- [ ] 13. (**inline**) VbC: Verify `verify-plan-pipeline` task file exists and SKILL.md references it. Verify behavioral test passes.
- [ ] 14. (**inline**) Phase completion: Commit phase 2 artifacts to feature branch.
