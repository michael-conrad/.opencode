# Phase 2 — Dependent Test Retirement + Ceremony Policy

**Concern:** Retire the five tests whose assertions target the removed Gate 2 behavior, confirm no orphaned runners remain, and record the ceremony-test retirement policy in the retire path.

**Files:**
- `.opencode/tests-v2/test-2264-sc3-different-trunk-submodule.sh` (delete)
- `.opencode/tests-v2/test-2264-sc4-shared-trunk-submodule.sh` (delete)
- `.opencode/tests-v2/test-2264-sc6-two-submodule-verification.sh` (delete)
- `.opencode/tests-v2/test-2264-sc7-bug-only-override-uses.sh` (delete)
- `.opencode/tests-v2/behaviors/2219-sc16-stale-pointer-block.sh` (delete)
- `.opencode/tests-v2/` index/runner registration files (orphan removal)
- Retire-path policy record (test card header / tests-v2 AGENTS note)

**SCs:** SC-3, SC-4 (+ CM-1)

**Dependencies:** Phase 1 (SC-1 → SC-3; CM-1 → SC-3)

**Entry Conditions:**
- Phase 1 complete: Gate 2 removed from the hook, SC-1/SC-2 verdicts PASS, CM-2 recorded
- Phase 1 VbC passed

**Exit Conditions:**
- The five test files no longer exist
- tests-v2 index/runner scan shows zero references to the five deleted test filenames
- Ceremony-test retirement policy recorded with both clauses (survival condition + verification-cost justification)

**Code Path Coverage:** Path 1 (commit-time — tests asserting the removed gate retire); test-runner index hygiene.

**Cross-Cutting SCs:** test integrity (retired tests must not leave orphaned registrations); agent-facing text (policy record text).

**Interface Boundaries:** tests-v2 runner index — registrations referencing deleted files are removed; no new runner interfaces added.

**State Transitions:** test suite state — before: five tests assert Gate 2 behavior (now removed); after: zero tests assert the removed behavior; policy text governs future test admission.

**Cost frame:** Running the file-existence check and index scan costs seconds — orphaned runners are surfaced before they poison the next test run. Skipping costs a failing test suite that asserts deleted behavior, discovered only when the suite next runs against the removed gate.

---

- [ ] 16. **RED (**task-card**).** File-existence check: the five dependent gate tests exist before deletion (RED for the retirement state). **→ SC-3**
- [ ] 17. **GREEN (**task-card**).** Delete exactly the five test files — test-2264-sc3-different-trunk-submodule.sh, test-2264-sc4-shared-trunk-submodule.sh, test-2264-sc6-two-submodule-verification.sh, test-2264-sc7-bug-only-override-uses.sh, and behaviors/2219-sc16-stale-pointer-block.sh. Re-run the file-existence check: all five absent. **→ SC-3**
- [ ] 18. **Verify (**task-card**).** Verify SC-3: file-existence check confirms absence of all five files. **→ SC-3**
- [ ] 19. **COMMIT (**direct**).** `git add -A` the five deletions; commit (message: retire dependent Gate 2 tests). **→ SC-3**
- [ ] 20. **RED (**task-card**).** Run the tests-v2 index/runner scan (grep/pattern over test-runner registrations and index files) for references to the five deleted test filenames — matches exist (RED for the orphan-free state). **→ SC-4**
- [ ] 21. **GREEN (**task-card**).** Remove every orphaned runner registration referencing the deleted tests. Re-run the scan: zero matches. **→ SC-4**
- [ ] 22. **Verify (**task-card**).** Verify SC-4: tests-v2 directory scan lists no references to the five deleted test filenames. **→ SC-4**
- [ ] 23. **COMMIT (**direct**).** `git add` the runner index edits; commit (message: remove orphaned runners for retired Gate 2 tests). **→ SC-4**
- [ ] 24. **CM-1 policy record (**task-card**).** Record the ceremony-test retirement policy in the retire path (test card header / tests-v2 AGENTS note) with both clauses: a test survives only if a real defect would escape without it, and every new test SC must justify its verification cost against the defect it catches (no string-grep documentation-phrasing checks). Dispatch issue-operations to record the policy content in the retire-path file. **→ CM-1**
- [ ] 25. **VbC (**task-card**).** Verify SC-3 and SC-4 verdicts are PASS with structural/string evidence artifacts on disk, and the CM-1 policy audit passes (recorded text contains both clauses). **→ SC-3, SC-4, CM-1**

#### Phase 2 Completion Block

- [ ] SC-3 verdict recorded with structural evidence (file-existence check output)
- [ ] SC-4 verdict recorded with string evidence (index scan output, zero matches)
- [ ] CM-1 policy record present with both clauses; policy audit read completed

**Concern transition:** Leaving test retirement and policy → entering advisory text rewrite. Phase 3 depends on Phase 1's SC-1 (the advisory must stop referencing the removed gate) but not on Phase 2's outputs.
