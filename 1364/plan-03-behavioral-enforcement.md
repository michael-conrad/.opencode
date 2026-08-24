# Phase 3 — Behavioral enforcement of for_pr routing

**Concern:** Add behavioral tests verifying that under for_pr scope the agent routes through executing-plans (both when a plan exists and when one must be auto-created) rather than jumping directly to PR creation.

**Files:**
- `.opencode/tests-v2/behaviors/` (new behavioral test scripts)
- `.opencode/tests-v2/behaviors/fixtures/issues/` (new fixture spec/plan files)

**SCs:** SC-1, SC-2

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: executing-plans skill exists (SC-5 verified PASS)
- Phase 2 complete: routing rule present (SC-3, SC-4 verified PASS)
- Phase 2 VbC passed

**Exit Conditions:**
- SC-1 verified PASS: behavioral evidence confirms for_pr with existing plan routes through executing-plans, not direct PR creation
- SC-2 verified PASS: behavioral evidence confirms for_pr without existing plan auto-creates plan then executes it via executing-plans
- Both behavioral test changes committed

---

### Item 4 (SC-1): Behavioral test — for_pr with existing plan routes through executing-plans

- [ ] 23. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-1364}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-1**
- [ ] 24. **RED (**sub-agent**).** Write a failing behavioral test asserting that under for_pr scope with an existing plan, the agent routes through executing-plans and does not directly call `git commit` / `github_create_pull_request`. The test dispatches a real-domain prompt via the behavioral harness (per tests-v2/AGENTS.md §11 Prompt Construction Mandate) and fails while the routing rule is absent. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-1**
- [ ] 25. **GREEN (**sub-agent**).** Add the fixture (spec + plan in `.opencode/tests-v2/behaviors/fixtures/issues/`) and the behavioral test script under `.opencode/tests-v2/behaviors/`, so the agent under for_pr scope dispatches executing-plans and reads the plan rather than directly creating a PR. No scope creep. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-1**
- [ ] 26. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the behavioral test addition introduces no regression. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1**
- [ ] 27. **Verify (**clean-room**).** Verify SC-1: a clean-room sub-agent reads the generated `session.yaml` (the SQLite DB export — the PRIMARY evidence source) and confirms the agent dispatched executing-plans and read the plan, with no direct `git commit` / `github_create_pull_request` call. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1**
- [ ] 28. **Commit (**inline**).** Commit the behavioral test change (test + fixture + change together as one atomic slice). `git add .opencode/tests-v2/behaviors/ && git commit -m "<SC-1 behavioral test message>"`. **→ SC-1**

### Item 5 (SC-2): Behavioral test — for_pr without existing plan auto-creates plan then executes it

- [ ] 29. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-1364}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-2**
- [ ] 30. **RED (**sub-agent**).** Write a failing behavioral test asserting that under for_pr scope with no existing plan, the agent auto-creates a plan then dispatches executing-plans to execute it. The test dispatches a real-domain prompt via the behavioral harness and fails while the routing rule is absent. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-2**
- [ ] 31. **GREEN (**sub-agent**).** Add the fixture (spec without a plan in `.opencode/tests-v2/behaviors/fixtures/issues/`) and the behavioral test script under `.opencode/tests-v2/behaviors/`, so the agent under for_pr scope creates the plan then executes it via executing-plans. No scope creep. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-2**
- [ ] 32. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the behavioral test addition introduces no regression. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-2**
- [ ] 33. **Verify (**clean-room**).** Verify SC-2: a clean-room sub-agent reads the generated `session.yaml` (the PRIMARY evidence source) and confirms the agent created a plan and then dispatched executing-plans to execute it. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-2**
- [ ] 34. **Commit (**inline**).** Commit the behavioral test change (test + fixture + change together as one atomic slice). `git add .opencode/tests-v2/behaviors/ && git commit -m "<SC-2 behavioral test message>"`. **→ SC-2**

#### Phase 3 VbC

- [ ] 35. **VbC (**clean-room**).** Verify SC-1 and SC-2 are clean PASS (evidence type `behavioral` — clean-room evaluation of `session.yaml` from the behavioral harness confirming executing-plans dispatch and no direct `git commit` / `github_create_pull_request`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1, SC-2**

**Concern transition:** Behavioral enforcement of for_pr routing is the final phase. It depends on the executing-plans skill (Phase 1) and the routing rule (Phase 2). After Phase 3, post-implementation steps (structural checks, audit, review-prep, PR creation) complete the plan.
