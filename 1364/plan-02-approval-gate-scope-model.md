# Phase 2 — Update approval-gate scope model and routing rule

**Concern:** Update the approval-gate `for_pr` scope model so the PR is the output of plan execution rather than a standalone gap-fill action, and add the mandatory routing rule that dispatches executing-plans when a plan exists.

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`

**SCs:** SC-3, SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: executing-plans skill exists (SC-5 verified PASS)
- Phase 1 VbC passed

**Exit Conditions:**
- SC-3 verified PASS: `for_pr` row uses Pre-Flight + Pipeline columns; `auto-PR` removed as a gap-fill action
- SC-4 verified PASS: routing rule present mandating executing-plans dispatch for for_pr with existing plan
- Both changes committed

---

### Item 2 (SC-3): Update Authorization Scope Model table

- [ ] 10. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-1364}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-3**
- [ ] 11. **RED (**sub-agent**).** Write a failing check asserting the Pre-Flight and Pipeline column headers are absent from the Authorization Scope Model table in `.opencode/skills/approval-gate/SKILL.md` (the check fails because the table still uses the Gap-Fill column). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-3**
- [ ] 12. **GREEN (**sub-agent**).** Update the `for_pr` row in `.opencode/skills/approval-gate/SKILL.md` to use Pre-Flight (auto-create spec+plan+auto-approve) and Pipeline (execute plan via executing-plans) columns, and remove the `auto-PR` gap-fill action so the PR is the output of executing the plan. No scope creep. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-3**
- [ ] 13. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the table change introduces no regression. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-3**
- [ ] 14. **Verify (**clean-room**).** Verify SC-3: the Authorization Scope Model table in `.opencode/skills/approval-gate/SKILL.md` contains the Pre-Flight and Pipeline column headers, and the `for_pr` row no longer lists `auto-PR` as a gap-fill action. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-3**
- [ ] 15. **Commit (**inline**).** Commit the scope table change (test + change together as one atomic slice). `git add .opencode/skills/approval-gate/SKILL.md && git commit -m "<scope model table message>"`. **→ SC-3**

### Item 3 (SC-4): Add the mandatory plan-execution routing rule

- [ ] 16. **Pre-clean (**inline**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-1364}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-4**
- [ ] 17. **RED (**sub-agent**).** Write a failing check asserting the routing rule text is absent from `.opencode/skills/approval-gate/SKILL.md` (the check fails because no for_pr-with-existing-plan routing rule exists yet). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-4**
- [ ] 18. **GREEN (**sub-agent**).** Add the mandatory routing rule to `.opencode/skills/approval-gate/SKILL.md`: for_pr with an existing plan MUST dispatch executing-plans; direct PR creation without plan execution is a critical violation. No scope creep. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-4**
- [ ] 19. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the routing rule addition introduces no regression. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-4**
- [ ] 20. **Verify (**clean-room**).** Verify SC-4: the routing rule text (for_pr with existing plan MUST call executing-plans; direct PR creation without plan execution is a critical violation) is present in `.opencode/skills/approval-gate/SKILL.md`. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-4**
- [ ] 21. **Commit (**inline**).** Commit the routing rule change (test + change together as one atomic slice). `git add .opencode/skills/approval-gate/SKILL.md && git commit -m "<routing rule message>"`. **→ SC-4**

#### Phase 2 VbC

- [ ] 22. **VbC (**clean-room**).** Verify SC-3 and SC-4 are clean PASS (evidence type `string` — grep confirms the Pre-Flight/Pipeline column headers and the routing rule text in `approval-gate/SKILL.md`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-3, SC-4**

**Concern transition:** Leaving approval-gate scope model and routing rule → entering behavioral enforcement. Phase 3 depends on both the executing-plans skill (Phase 1) and the routing rule (Phase 2) being in place before the routing behavior is observable.
