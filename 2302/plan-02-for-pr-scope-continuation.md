# Phase 2 — for_pr scope continuation

**Concern:** Ensure that under `for_pr` scope, spec revision + plan regeneration does not cause a premature halt before `pr_created`.

**Files:**
- `.opencode/skills/approval-gate/` (scope handling on spec revision)

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: spec-revision → plan-regeneration linkage exists (SC-1, SC-2)
- Phase 1 VbC passed

**Exit Conditions:**
- Under `for_pr` scope, spec revision + plan regeneration does not cause a premature halt before `pr_created` (SC-3)

---

- [ ] 14. **Pre-regression (**sub-agent**).** Run regression test patterns before the RED phase. **→ SC-3**
- [ ] 15. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-3**
- [ ] 16. **RED (**sub-agent**).** Write a failing enforcement test asserting that under `for_pr` scope, spec revision + plan regeneration does not cause a premature halt before `pr_created`. **→ SC-3**
- [ ] 17. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass — adjust approval-gate scope handling so the pipeline continues to `pr_created`. **→ SC-3**
- [ ] 18. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC-3**
- [ ] 19. **Verify (**clean-room**).** Verify implementation against SC-3. **→ SC-3**
- [ ] 20. **Commit (**inline**).** Stage and commit the SC-3 test + change together as one atomic slice.

#### Phase 2 VbC

- [ ] 21. **VbC (**clean-room**).** Verify SC-3 is implemented: under `for_pr` scope, spec revision + plan regeneration does not cause a premature halt before `pr_created`. **→ SC-3**

**Concern transition:** Leaving for_pr scope continuation → entering post-implementation. All SCs (SC-1, SC-2, SC-3) are covered.

---

## Post-Implementation

- [ ] 22. **Audit (**clean-room**).** Run adversarial audit of the deliverable (verification-audit DiMo investigator → validator → evaluator → arbiter). **→ SC-1, SC-2, SC-3**
- [ ] 23. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify the phase DAG constraint. **→ SC-1, SC-2, SC-3**
- [ ] 24. **Structural checks (**sub-agent**).** Run finishing checklist (lint, typecheck, etc.). **→ SC-1, SC-2, SC-3**
- [ ] 25. **Pre-PR gate (**clean-room**).** Verify all SC verdicts; BLOCK if any FAIL. **→ SC-1, SC-2, SC-3**
- [ ] 26. **Regression check (**sub-agent**).** Final regression check before PR. **→ SC-1, SC-2, SC-3**
- [ ] 27. **Review prep (**sub-agent**).** Prepare PR review context. **→ SC-1, SC-2, SC-3**
- [ ] 28. **Create PR (**sub-agent**).** Create the pull request. **→ SC-1, SC-2, SC-3**
- [ ] 29. **Exec summary (**sub-agent**).** Generate completion executive summary. **→ SC-1, SC-2, SC-3**
