# Phase 2 — Structural enforcement

**Concern:** Add a structural content-verification enforcement test that asserts the harness contains no git-mutating operation that can target the live project root, preventing regression of the Phase 1 fix.

**Files:**
- `.opencode/tests-v2/test-enforcement.sh`
- `.opencode/tests-v2/test-2292-sc4-live-root-mutation.sh` (new)

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: fallback eliminated, guard added, remote-wiring ordering fixed
- Phase 1 VbC passed

**Exit Conditions:**
- A content-verification enforcement test asserts the harness contains no git-mutating operation that can target the live project root
- The enforcement test passes (zero grep matches for live-root mutation patterns)
- The enforcement test is registered in `test-enforcement.sh` (scenario/tag) so it runs via `--changed`/`--tag` or standalone

---

## Item 4 — SC-4: Structural regression enforcement test

- [ ] 19. **RED (**sub-agent**).** Write a failing content-verification enforcement test at `.opencode/tests-v2/test-2292-sc4-live-root-mutation.sh` that greps the harness source for live-root git-mutation patterns (`-C "$PROJECT_DIR"` mutation, `${TEST_PROJECT:-$project_root}` fallback, unguarded bare git mutation) and asserts zero matches. The test FAILS because the live-root mutation pattern is present. **→ SC-4**
- [ ] 20. **GREEN (**sub-agent**).** Register the enforcement test in `test-enforcement.sh` (add scenario/tag and file-to-scenario mapping) so it runs via `--changed`/`--tag` or standalone. The test now passes because the Phase 1 fix removed the live-root mutation patterns. **→ SC-4**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Verify the enforcement test passes: run `test-enforcement.sh --changed`/`--tag` or the standalone test and assert PASS (zero grep matches for live-root mutation patterns). **→ SC-4**
- [ ] 22. **Checkpoint commit (**inline**).** Commit the enforcement test file + registration as one atomic slice. **→ SC-4**

#### Item 4 VbC

- [ ] 23. **VbC (**clean-room**).** Verify the enforcement test asserts the absence of live-root git-mutation patterns and passes (zero grep matches). **→ SC-4**

---

## Post-implementation (once per plan)

- [ ] 24. **Structural checks (**sub-agent**).** Run the finishing checklist: lint, typecheck, and any applicable structural checks on the modified files. **→ all SCs**
- [ ] 25. **Verification (**clean-room**).** Verify all SC verdicts (SC-1, SC-2, SC-3, SC-4) are PASS; BLOCK if any FAIL. **→ all SCs**
- [ ] 26. **Audit (**clean-room**).** Run the adversarial audit (verification-audit DiMo investigator → validator → evaluator → arbiter) on the deliverable. **→ all SCs**
- [ ] 27. **Cross-validate (**clean-room**).** Cross-validate the verification results against the audit findings; reconcile any discrepancies. **→ all SCs**
- [ ] 28. **Regression check (**sub-agent**).** Run the final regression check before PR. **→ all SCs**
- [ ] 29. **Review-prep (**sub-agent**).** Prepare the PR review context. **→ all SCs**
- [ ] 30. **Create PR (**sub-agent**).** Create the pull request. **→ all SCs**
- [ ] 31. **Exec summary (**sub-agent**).** Generate the completion executive summary. **→ all SCs**
