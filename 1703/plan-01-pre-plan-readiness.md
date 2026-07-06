# Phase 1 — pre-plan-readiness

**Concern:** Add a `pre-plan-readiness` task to writing-plans that verifies the local spec file exists and the feature branch exists before allowing plan creation.

**Files:**
- `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` (new)
- `.opencode/skills/writing-plans/SKILL.md` (update — add task to task list and Trigger Dispatch Table)

**SCs:** SC-2

**Dependencies:** None

**Entry conditions:** Feature branch exists, spec file exists at `.opencode/.issues/1703/spec.md`

**Exit conditions:** `pre-plan-readiness` task file written, SKILL.md updated with task reference, behavioral test passes

---

- [ ] 1. (**RED**) Write behavioral enforcement test that verifies the pre-plan-readiness gate blocks when spec file is missing. Test sends a prompt that triggers plan creation without a spec file and asserts the agent returns BLOCKED. Save to `.opencode/tests/behaviors/pre-plan-readiness.sh`.
- [ ] 2. (**inline**) Run the behavioral test — confirm it FAILS (RED phase passes).
- [ ] 3. (**GREEN**) Create `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` with: Purpose (verify local spec file + feature branch exist before plan creation), Entry Criteria (spec file exists at `.issues/{N}/spec.md`, feature branch exists), Exit Criteria (BLOCKED if spec missing, BLOCKED if branch missing, PASS if both present), Procedure (check spec file exists, check feature branch exists, return PASS/BLOCKED).
- [ ] 4. (**GREEN**) Update `.opencode/skills/writing-plans/SKILL.md`: add `pre-plan-readiness` to the task list, add to Trigger Dispatch Table with dispatch mode `sub-task`.
- [ ] 5. (**inline**) Run the behavioral test — confirm it PASSES (GREEN phase passes).
- [ ] 6. (**inline**) VbC: Verify `pre-plan-readiness` task file exists and SKILL.md references it. Verify behavioral test passes.
- [ ] 7. (**inline**) Phase completion: Commit phase 1 artifacts to feature branch.
