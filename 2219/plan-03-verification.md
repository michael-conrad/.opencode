# Phase 3 — Verification

**Concern:** Existing cleanup preservation — verify existing merged-branch cleanup logic continues to work unchanged.

**Files:**
- `.opencode/tests-v2/behaviors/` (regression test updates)

**SCs:** SC-6

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 2 complete: dead-branch deletion and dirty pointer handling implemented
- Phase 2 VbC passed

**Exit Conditions:**
- Existing cleanup behavioral tests pass
- Grep confirms Phase 5 merged-branch deletion logic is unmodified
- All 6 SCs verified PASS

---

- [ ] 21. **RED: SC-6 — existing cleanup preservation (**sub-agent**).** Write a behavioral enforcement test that runs the existing cleanup workflow and asserts the merged-branch deletion logic works unchanged. Also add a grep-based content-verification assertion that Phase 5's original merged-branch deletion steps are unmodified. The test MUST FAIL because the existing cleanup tests may not have a dedicated SC-6 assertion. **→ SC-6**
- [ ] 22. **GREEN: SC-6 — verify existing logic unmodified (**sub-agent**).** Run the existing cleanup behavioral tests to confirm they still pass. Run `grep` to confirm Phase 5's merged-branch deletion steps (switch to trunk, content verification, branch deletion, remote deletion, checkpoint tag deletion, prune) are unmodified. No code changes needed — this is a verification-only phase. **→ SC-6**
- [ ] 23. **Post-regression (**sub-agent**).** Run full regression test suite. **→ SC-6**
- [ ] 24. **Verify (**clean-room**).** Verify SC-6: existing cleanup behavioral tests pass, grep confirms Phase 5 logic unmodified. **→ SC-6**
- [ ] 25. **Checkpoint commit (**inline**).** Stage and commit: `git add .opencode/tests-v2/behaviors/ && git commit -m "Phase 3: existing cleanup preservation verification (SC-6)"`

#### Phase 3 VbC

- [ ] 26. **VbC (**clean-room**).** Verify SC-6 behavioral test PASS. Verify grep output shows Phase 5 merged-branch deletion logic unmodified. **→ SC-6**

**Concern transition:** Verification complete — all 6 SCs verified. Proceeding to post-implementation steps.

---

## Post-Implementation

- [ ] 27. **Audit (**clean-room**).** Dispatch adversarial audit of the deliverable. Read `audit/tasks/verification-audit-investigator.md` first. Followed by validator, evaluator, arbiter in sequence. **→ All SCs**
- [ ] 28. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify workflow constraints. **→ All SCs**
- [ ] 29. **Structural checks (**sub-agent**).** Run finishing checklist: lint, typecheck, format check. **→ All SCs**
- [ ] 30. **Pre-PR gate (**clean-room**).** Read all SC verdicts. BLOCK if any FAIL. **→ All SCs**
- [ ] 31. **Regression check (**sub-agent**).** Final regression check before PR. **→ All SCs**
- [ ] 32. **Review prep (**sub-agent**).** Prepare PR review context. Read `git-workflow-pr/tasks/review-prep.md` first. **→ All SCs**
- [ ] 33. **Create PR (**sub-agent**).** Create the pull request. **→ All SCs**
- [ ] 34. **Executive summary (**sub-agent**).** Generate completion executive summary. **→ All SCs**
