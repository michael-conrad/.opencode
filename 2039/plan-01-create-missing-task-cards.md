# Phase 1 — Create the 10 STILL-MISSING Task Cards

**Concern:** Establish the 10 confirmed STILL-MISSING task cards as `.md` files with the canonical task card structure (entry criteria, inline-only steps, exit criteria), including full procedure content on the two brainstorming cards per the spec's §Brainstorming Task Card Requirements.

**Files:**
- `.opencode/skills/brainstorming/tasks/top-down-analysis.md` (new)
- `.opencode/skills/brainstorming/tasks/cross-scope.md` (new)
- `.opencode/skills/programming-principles/tasks/check-limits.md` (new)
- `.opencode/skills/programming-principles/tasks/decompose.md` (new)
- `.opencode/skills/skill-creator/tasks/init.md` (new)
- `.opencode/skills/skill-creator/tasks/package.md` (new)
- `.opencode/skills/skill-creator/tasks/fragment-management.md` (new)
- `.opencode/skills/using-git-worktrees/tasks/verify-worktree.md` (new)
- `.opencode/skills/issue-operations-core/tasks/push-artifacts.md` (new — thin core dispatcher; full resolution deferred to Phase 2)
- `.opencode/skills/multimodal-dispatch/tasks/route.md` (resolution deferred to Phase 2 — see SC-4)

**SCs:** SC-1, SC-1.1, SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2039 is approved (`approved-for-for_pr` label present in `.opencode/.issues/2039/issue.yaml`)
- Feature branch exists per git-workflow pre-work
- The 7 analytical artifacts exist in `.opencode/.issues/2039/artifacts/` (backfilled)
- Deliverables are already present in the working tree (implementation is pre-complete); this phase verifies and finalizes them

**Exit Conditions:**
- The 9 non-special-case card files exist and contain entry criteria, inline steps, exit criteria
- The two brainstorming cards contain all required procedure per §Brainstorming Task Card Requirements
- `issue-operations-core/tasks/push-artifacts.md` exists (thin core dispatcher scaffold)
- SC-1, SC-1.1, SC-2 verified PASS

---

- [ ] 1. **Pre-regression (**sub-agent**).** Execute the `pre-regression` step from the implementation-workflow reference card: run regression test patterns to establish the baseline for the string-evidence verification of task card existence. **→ establishes baseline before RED**

- [ ] 2. **Pre-regression verify (**clean-room**).** Execute the `pre-regression-verify` step: verify the pre-regression results before proceeding to RED. **→ baseline verified**

- [ ] 3. **RED — SC-1 (item 1) (**clean-room**).** Execute the `red` task from test-driven-development: write a failing enforcement test asserting that each of the 10 STILL-MISSING task card `.md` files exists on disk (evidence type `string`). The test FAILS because the cards do not yet exist. **→ SC-1**

- [ ] 4. **GREEN — SC-1 (item 1) (**clean-room**).** Execute the `green` task from test-driven-development: create the 10 STILL-MISSING task card files in their respective `tasks/` directories so the RED test passes. For the two special cases (`route`, `push-artifacts`), create the card per the spec's special-case decisions — the `route` resolution is finalized in Phase 2, and `push-artifacts` is created as a thin core dispatcher scaffold. **→ SC-1**

- [ ] 5. **Post-regression (**clean-room**).** Execute the `post-regression` step: run regression test patterns after the GREEN phase to confirm no regression. **→ post-GREEN regression clean**

- [ ] 6. **Verify — SC-1 (item 1) (**clean-room**).** Execute the `verify` task from verification-before-completion: verify each of the 10 task card `.md` files exists on disk (or, for the two special cases, the dangling reference is resolved per SC-4). **→ SC-1**

- [ ] 7. **Commit — SC-1 (**inline**).** Orchestrator stages and commits the 10 task card files with their enforcement test as one atomic slice. **→ SC-1 committed**

- [ ] 8. **RED — SC-1.1 (item 2) (**clean-room**).** Execute the `red` task: write a failing enforcement test asserting that `top-down-analysis.md` and `cross-scope.md` contain all required procedure per §Brainstorming Task Card Requirements (TDT triggers, entry criteria, content requirements, exit criteria, source-material references, context). **→ SC-1.1**

- [ ] 9. **GREEN — SC-1.1 (item 2) (**clean-room**).** Execute the `green` task: populate `top-down-analysis.md` and `cross-scope.md` with the full procedure content from §Brainstorming Task Card Requirements so the RED test passes. **→ SC-1.1**

- [ ] 10. **Post-regression (**clean-room**).** Execute the `post-regression` step after the GREEN phase. **→ post-GREEN regression clean**

- [ ] 11. **Verify — SC-1.1 (item 2) (**clean-room**).** Execute the `verify` task: verify both brainstorming card files exist and contain the required sections. **→ SC-1.1**

- [ ] 12. **Commit — SC-1.1 (**inline**).** Orchestrator stages and commits the two brainstorming cards with their enforcement test as one atomic slice. **→ SC-1.1 committed**

- [ ] 13. **RED — SC-2 (item 3) (**clean-room**).** Execute the `red` task: write a failing enforcement test asserting that each of the 10 new task cards has entry criteria, inline-only steps, and exit criteria (sample audit). **→ SC-2**

- [ ] 14. **GREEN — SC-2 (item 3) (**clean-room**).** Execute the `green` task: normalize all 10 new task cards to the canonical structure (entry criteria, inline-only steps, exit criteria) so the RED test passes. **→ SC-2**

- [ ] 15. **Post-regression (**clean-room**).** Execute the `post-regression` step after the GREEN phase. **→ post-GREEN regression clean**

- [ ] 16. **Verify — SC-2 (item 3) (**clean-room**).** Execute the `verify` task: sample-audit the 10 new task cards for the presence of entry criteria, inline steps, and exit criteria. **→ SC-2**

- [ ] 17. **Commit — SC-2 (**inline**).** Orchestrator stages and commits the structure normalization with its enforcement test as one atomic slice. **→ SC-2 committed**

#### Phase 1 VbC

- [ ] 18. **VbC (**clean-room**).** Verify SC-1, SC-1.1, SC-2 all PASS against the present deliverables: all 10 task card files exist; the two brainstorming cards carry the full required procedure; all 10 carry the canonical entry/inline/exit structure. Any non-clean verdict coerces to FAIL per the reference card's Coercion Rules. **→ SC-1, SC-1.1, SC-2**

**Concern transition:** Leaving CONCERN-1 (Card Creation) → entering CONCERN-2 (TDT Reference Integrity). Phase 2 depends on Phase 1's created cards (especially the `push-artifacts` scaffold and the `route` decision target).
