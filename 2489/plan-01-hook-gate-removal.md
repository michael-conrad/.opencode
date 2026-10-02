# Phase 1 — Hook Gate Removal (Commit-Time Authority Transfer)

**Concern:** Remove the pre-commit hook Gate 2 stale-pointer check and its SKIP hatch so stacked-PR enforcement lives where it is actually true (PR creation), while Gate 1 trunk protection survives, and record the issue-graph semantics handover.

**Files:**
- `.opencode/hooks/pre-commit` (Gate 2 deletion)
- `.opencode/tests-v2/` (new behavioral test file for SC-1/SC-2)
- Issue store `.opencode/.issues/{2431,2258}` (CM-2 annotations, API-only)

**SCs:** SC-1, SC-2 (+ CM-2)

**Dependencies:** None (root phase)

**Entry Conditions:**
- Pre-implementation steps 1-4 complete (coherence gate, baseline, pre-regression, pre-regression-verify)
- Feature branch exists (for_pr scope; branch created before any file modification)

**Exit Conditions:**
- Hook contains no Gate 2 block, no `SKIP_STALE_POINTER_CHECK` hatch, no stale-pointer loop, no Gate 2 BLOCK message
- Behavioral run: feature-branch submodule commit at an unmerged SHA succeeds with no hatch set
- Behavioral run: trunk-branch commit still blocked (exit 1)
- CM-2 annotations recorded and verified on #2431 and #2258

**Code Path Coverage:** Path 1 (commit-time — Gate 2 removed, Gate 1 kept); Path 5 (hook installation — verify installer propagates removal, no installer code change).

**Cross-Cutting SCs:** runtime behavior (hook exit contract changes); agent-facing text (BLOCK message removed); test integrity (replacement behavioral assertions required); behavioral evidence duty (R-10 auto-uplift — no structural substitute permitted for SC-1/SC-2).

**Interface Boundaries:** `hooks/pre-commit` exit contract (Gate 2 removed, Gate 1 unchanged: exit 1 on trunk commit, exit 0 otherwise — backward compatible); `SKIP_STALE_POINTER_CHECK` env var becomes dead (setters see no behavior change).

**State Transitions:** commit-time — before: commit(non-trunk, stale/feature pointer) → BLOCK by Gate 2 unless SKIP=1; after: commit(non-trunk, any pointer) → pass (Gate 1 only). Installed `.git/hooks/pre-commit` copies carry old Gate 2 until session start re-install — verify installer overwrite behavior during verification; report any install gap as a finding, do not hand-edit installed copies.

**Cost frame:** Running the behavioral commit test costs minutes of execution time — the defect (a gate that blocks every legal mid-development commit) is caught at the earliest gate and fix cost is zero downstream. Skipping costs the full rework cycle every time an agent hits the block mid-development — habituated SKIP bypasses, wrong-action remediation messages, and a shipped false-positive compound per stacked-PR commit.

---

- [ ] 5. **RED (**task-card**).** Write a behavioral test that commits a submodule pointer at an unmerged feature-branch SHA in a feature branch without setting any hatch — assert it FAILS because the current hook blocks. Run via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` with a bash timeout of at least 600 seconds. **→ SC-1**
- [ ] 6. **GREEN (**task-card**).** Delete from the pre-commit hook exactly the Gate 2 lines — the `SKIP_STALE_POINTER_CHECK` env hatch, the stale-pointer loop with SHA extraction, and the Gate 2 BLOCK message — leaving Gate 1 trunk protection untouched. Re-run the behavioral test; it must now pass. **→ SC-1**
- [ ] 7. **Post-regression (**task-card**).** Run regression test patterns after GREEN phase per test-driven-development phase-4 task. **→ SC-1**
- [ ] 8. **Verify (**task-card**).** Verify SC-1: behavioral run passes with no hook block and no hatch set, plus grep for absence of `SKIP_STALE_POINTER_CHECK` and stale-pointer remnants in the hook. Evidence type is behavioral — a structural substitute is a hard FAIL. **→ SC-1**
- [ ] 9. **COMMIT (**direct**).** `git add` the hook edit and the behavioral test file; commit as one atomic slice (message: remove pre-commit Gate 2 stale-pointer check and SKIP hatch). **→ SC-1**
- [ ] 10. **RED (**task-card**).** Add a second behavioral assertion to the same test file: a trunk-branch submodule commit attempt is blocked (exit 1). This passes pre-change and MUST still pass post-change — it is the over-deletion guard. **→ SC-2**
- [ ] 11. **GREEN (**task-card**).** No code change. Confirm the trunk-branch block assertion passes after Item 1's deletion — the Gate 1 contract survived. If it fails, the deletion over-reached: restore per the self-remediation protocol. **→ SC-2**
- [ ] 12. **Verify (**task-card**).** Verify SC-2: behavioral run in the same harness — trunk-branch commit attempt blocked with exit 1. **→ SC-2**
- [ ] 13. **COMMIT (**direct**).** Fold SC-2's second assertion into Item 1's commit per the spec Item 2 commit rule (same behavioral test file, second assertion); amend only if the Item 1 commit has not been pushed, otherwise commit the test addition alone. **→ SC-2**
- [ ] 14. **CM-2 handover (**task-card**).** Dispatch issue-operations to post on issue #2431 a comment recording the commit-time semantics handover (SKIP hatch removed; PR-time scope untouched) and on issue #2258 a superseded-with-rationale annotation (its fix target, Gate 2, is deleted); #2313 is left unaffected. Verify by API read of both threads; clean-room evaluation against the handover/supersession criteria; confirm branch states of both issues before annotating. **→ CM-2**
- [ ] 15. **VbC (**task-card**).** Verify SC-1 and SC-2 verdicts are PASS with behavioral evidence artifacts on disk, and CM-2 annotations are API-verified. Report `[item 1] [PASS|FAIL]` style step status for each. **→ SC-1, SC-2, CM-2**

#### Phase 1 Completion Block

- [ ] SC-1 verdict recorded with behavioral evidence (test run output + hook grep)
- [ ] SC-2 verdict recorded with behavioral evidence (trunk-block exit 1)
- [ ] CM-2 policy/annotation evidence recorded (API thread reads + branch-state confirmation)
- [ ] Installer overwrite behavior verified; any install gap reported as a finding

**Concern transition:** Leaving commit-time enforcement transfer → entering dependent-test retirement and ceremony policy. Phase 2 depends on Phase 1's SC-1 (tests asserting removed Gate 2 behavior must retire after the hook change).
