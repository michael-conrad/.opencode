# Phase 3 — Behavioral Tests

**Concern:** Write behavioral enforcement tests for SC-8 and SC-9

**Files:**
- `.opencode/tests/behaviors/gap-fill-cascade-for-pr.sh` — create
- `.opencode/tests/behaviors/gap-fill-cascade-missing-plan.sh` — create

**SCs:** SC-8, SC-9

**Dependencies:** Phase 2

**Entry conditions:** Phase 2 complete and verified PASS

**Exit conditions:** Both behavioral tests exist and pass, SC-8 and SC-9 verified PASS

---

- [ ] 23. **RED (**sub-agent**).** Write behavioral test `gap-fill-cascade-for-pr.sh`. Test sends `for_pr` scope prompt with existing spec+plan, verifies stderr contains `Skill "gap-fill-cascade"` and `Skill "implementation-pipeline"`. Use `with-test-home` wrapper. **→ SC-8**

- [ ] 24. **GREEN (**sub-agent**).** Run `bash .opencode/tests/behaviors/gap-fill-cascade-for-pr.sh`. Verify PASS. If FAIL: remediate and re-run. **→ SC-8**

- [ ] 25. **RED (**sub-agent**).** Write behavioral test `gap-fill-cascade-missing-plan.sh`. Test sends `for_pr` scope prompt with missing plan, verifies stderr contains `Skill "writing-plans"`. Use `with-test-home` wrapper. **→ SC-9**

- [ ] 26. **GREEN (**sub-agent**).** Run `bash .opencode/tests/behaviors/gap-fill-cascade-missing-plan.sh`. Verify PASS. If FAIL: remediate and re-run. **→ SC-9**

- [ ] 27. **VbC (**clean-room**).** Verify all Phase 3 SCs PASS. Run behavioral tests for SC-8 and SC-9. If any FAIL: remediate and re-run. **→ SC-8, SC-9**

- [ ] 28. **Global VbC (**clean-room**).** Verify ALL 11 SCs PASS across all phases. Run all verification commands. If any FAIL: remediate and re-run. **→ SC-1 through SC-11**

- [ ] 29. **Audit fidelity (**sub-agent**).** Dispatch `audit --task plan-fidelity` to verify plan faithfully reflects spec. If FAIL: remediate and re-run. **→ All**

- [ ] 30. **Audit concern (**sub-agent**).** Dispatch `audit --task concern-separation` to verify concerns properly separated across phases. If FAIL: remediate and re-run. **→ All**

- [ ] 31. **Cross-validate (**sub-agent**).** Dispatch cross-validate to verify all verification results are consistent. If FAIL: remediate and re-run. **→ All**

- [ ] 32. **Regression check (**sub-agent**).** Run full behavioral test suite to verify no regressions. If FAIL: remediate and re-run. **→ All**

- [ ] 33. **Review prep (**sub-agent**).** Dispatch `git-workflow --task review-prep` to prepare for PR. **→ All**

- [ ] 34. **Executive summary (**inline**).** Report completion with plan path, phase summary, and next steps. **→ All**

**Concern transition:** Leaving behavioral tests → plan complete. All 11 SCs verified PASS.
