# Phase 1 — Task-Card Safe-State Semantics

**Concern:** Safe-state-vs-hazard-state classification — steps 2 and 7 of the trunk-tip-verification gate must stop re-classifying the safe state (submodule checkout == its `origin/<default>` tip AND merged pointer commit) as failure; the hazard state remains detected independently by step 8.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` (Step 2, Step 7, Step 8 fail-open branch, Exit Criteria, Result Contract)
- `.opencode/tests-v2/behaviors/` (new safe-state behavioral scenario script)
- `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` (assertion sync, item 4 only)

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None (plan pre-implementation steps 1-4 complete)

**Entry Conditions:**
- Coherence gate passed (step 1)
- Working tree clean, feature branch created (step 2)
- Pre-regression baseline recorded (steps 3-4)

**Exit Conditions:**
- Steps 2 and 7 classify the safe-state signals as WARN; FAIL retained for genuine dirt
- Step 8 fail-open branch is if/else-valid inside `git submodule foreach`
- Exit Criteria and Result Contract document the WARN classification; `SUBMODULE_UNMERGED_COMMIT` is the only documented BLOCKED trigger
- All four items committed as separate atomic slices

---

## Code Path Coverage

- `trunk-tip-verification.md` Procedure Step 2 (`parent_clean`) — item 1
- `trunk-tip-verification.md` Procedure Step 7 (`submodule_pointer_match`) — item 2
- `trunk-tip-verification.md` Procedure Step 8 fail-open branch — item 3; `2313-sc1-prework-merged-commit.sh` must stay green for the merged/ancestor path
- `trunk-tip-verification.md` Exit Criteria + Result Contract; `trunk-tip-enforcement.sh` assertion sync — item 4
- Read-only: `pre-work.md` (consumes gate status — must treat WARN as non-blocking), `git-workflow-branch/SKILL.md`

## Cross-Cutting SCs

- Behavioral evidence mandate (guideline 080): SC-1 and SC-2 require `with-test-home opencode run` stderr-based behavioral evidence; no grep/static substitution.
- Per-SC decomposition (guideline 091): one RED/GREEN/verify/commit cycle per item; behavioral items commit and push before any behavioral regression run.
- Test integrity: item 4's assertion updates in `trunk-tip-enforcement.sh` must NOT weaken the `SUBMODULE_UNMERGED_COMMIT` blocking assertion.
- Test framework mandate: `bash .opencode/tests-v2/with-test-home ...` with `>=600s` bash timeout; `rm -f tmp/.behavior-run.lock` before re-runs; never GNU `timeout`.
- Provenance: preserve existing attribution lines in all modified files.

## Interface Boundaries

- Gate status contract (`parent_clean`, `submodule_pointer_match` enums): gains WARN — additive, backward compatible; `pre-work.md` consumers branch on FAIL/BLOCKED and are unaffected.
- `SUBMODULE_UNMERGED_COMMIT` blocker reason: unchanged.
- Step 8 fail-open shell contract: internal-only; externally observable behavior (WARN-skip message on unreachable remote, merged-commit check skip) unchanged.

## State Transitions

- NEW edge: pointer-only dirt + safe state → DONE (with WARN) — previously routed to BLOCKED (item 1: ` M ` entry; item 2: `+` prefix).
- No state change from item 3 — fail-open branch still ends in SKIP/WARN for unreachable remotes.
- Item 4 documents the new DONE-with-WARN state in the contract.
- Invariants: `SUBMODULE_UNMERGED_COMMIT` always BLOCKs; FAIL retained for genuine parent/submodule dirt; WARN never blocks pre-work; SKIP remains the step-8 outcome for unreachable remotes.

---

- [ ] 5. **Item 1 RED — safe-state `parent_clean` WARN (**task-card**).** Write the failing enforcement test: fixture parent repo with one submodule checked out at its own `origin/<default>` tip, merged pointer commit, stale committed parent pointer; assert `parent_clean` classifies WARN and gate status is DONE, not BLOCKED. Test FAILS against the current gate text. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")` with the safe-state scenario context.
  - Pre-clean: `rm -f tmp/.behavior-run.lock`; `rm -f tmp/2440/artifacts/pipeline-red-*`.
- [ ] 6. **Item 1 GREEN — Step 2 classification (**task-card**).** Update Step 2 (`parent_clean`) in `trunk-tip-verification.md` to classify a pointer-only ` M <submodule>` entry as WARN (release-capture-pending) when the safe-state predicate holds (submodule checkout == submodule's `origin/<default>` tip from step 6 AND merged-commit check passes from step 8); predicate derived from existing computations only — no new checks, check IDs, or network calls. Minimum change; no scope creep. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.
- [ ] 7. **Item 1 post-regression (**task-card**).** Run regression test patterns after GREEN (test-driven-development phase-4 task) — confirm no unrelated gate behavior changed. **→ SC-1**
- [ ] 8. **Item 1 verify (**task-card**).** Verify SC-1 via `bash .opencode/tests-v2/with-test-home opencode run '<safe-state scenario>'` with `>=600s` timeout; assert stderr behavioral evidence: `parent_clean: WARN` and gate status DONE, no BLOCKED. Evidence to `tmp/2440/artifacts/pipeline-verify-*`. **→ SC-1**
- [ ] 9. **Item 1 commit-inline (**direct**).** Stage and commit the Step 2 change plus the new behavioral scenario script as one atomic slice: `git add <files> && git commit -m "<message>"`. No co-author trailers during implementation commits (added at squash). **→ SC-1**
  - Behavioral item: after commit, push the branch and fresh-fetch to verify the effective commit is contained in a remote ref — required before any behavioral regression run.

- [ ] 10. **Item 2 RED — safe-state `+` prefix WARN (**task-card**).** Write the failing enforcement test: assert a `+` prefix in `git submodule status` for a merged, trunk-tip-checked-out submodule yields `submodule_pointer_match: WARN` and gate status DONE. Test FAILS against current gate text. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.
  - Pre-clean: `rm -f tmp/.behavior-run.lock`; `rm -f tmp/2440/artifacts/pipeline-red-*`.
- [ ] 11. **Item 2 GREEN — Step 7 classification (**task-card**).** Update Step 7 (`submodule_pointer_match`) in `trunk-tip-verification.md` to classify the `+` prefix as WARN under the same safe-state predicate established in item 1. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.
- [ ] 12. **Item 2 post-regression (**task-card**).** Run regression test patterns after GREEN. **→ SC-2**
- [ ] 13. **Item 2 verify (**task-card**).** Verify SC-2 via `with-test-home opencode run`; assert stderr shows `submodule_pointer_match: WARN`, gate status DONE, no BLOCKED. **→ SC-2**
- [ ] 14. **Item 2 commit-inline (**direct**).** Commit the Step 7 change as one atomic slice. Push + fresh-fetch containment check before behavioral regression runs. **→ SC-2**

- [ ] 15. **Item 3 RED — structural check on fail-open branch (**task-card**).** Write the failing structural test: static inspection asserting `continue` is absent from the Step 8 foreach eval body and the WARN-skip path is preserved. Test FAILS against the current snippet. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.
  - Pre-clean: `rm -f tmp/2440/artifacts/pipeline-red-*`.
- [ ] 16. **Item 3 GREEN — rewrite fail-open branch (**task-card**).** Rewrite the Step 8 network-unreachable fail-open branch in `trunk-tip-verification.md` using if/else — a control-flow construct valid inside `git submodule foreach` — preserving the WARN-skip message and the merged-commit-check skip. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.
- [ ] 17. **Item 3 post-regression (**task-card**).** Run regression test patterns after GREEN — `2313-sc1-prework-merged-commit.sh` behavior for the merged/ancestor path must be unchanged. **→ SC-3**
- [ ] 18. **Item 3 verify (**task-card**).** Verify SC-3 by static inspection of the Step 8 snippet: grep asserts `continue` absent from the foreach eval body and the skip path preserved. **→ SC-3**
- [ ] 19. **Item 3 commit-inline (**direct**).** Commit the Step 8 snippet rewrite as one atomic slice. **→ SC-3**

- [ ] 20. **Item 4 RED — structural check on contract prose (**task-card**).** Write the failing structural test: assert the Exit Criteria and Result Contract sections contain the WARN classification (`PASS | WARN | FAIL` for both checks, WARN = release-capture-pending) and do not declare pointer staleness a failure. Test FAILS against current prose. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`.
  - Pre-clean: `rm -f tmp/2440/artifacts/pipeline-red-*`.
- [ ] 21. **Item 4 GREEN — sync Exit Criteria + Result Contract (**task-card**).** Update the Exit Criteria and Result Contract sections of `trunk-tip-verification.md`; sync `trunk-tip-enforcement.sh` assertions on `parent_clean`/`submodule_pointer_match` WITHOUT weakening the `SUBMODULE_UNMERGED_COMMIT` blocking assertion (test-integrity mandate — no lobotomized tests). **→ SC-4**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`.
- [ ] 22. **Item 4 post-regression (**task-card**).** Run regression test patterns after GREEN. **→ SC-4**
- [ ] 23. **Item 4 verify (**task-card**).** Verify SC-4 by static content check of both sections and grep of `trunk-tip-enforcement.sh` for stale FAIL assertions on the two checks (and confirm the blocking assertion is intact). **→ SC-4**
- [ ] 24. **Item 4 commit-inline (**direct**).** Commit the contract prose plus test-assertion sync as one atomic slice. Push + fresh-fetch containment check. **→ SC-4**

#### Phase 1 Completion Block

- [ ] 25. **Phase 1 VbC (**task-card**).** Verify all phase-1 exit conditions: Steps 2/7 WARN classification present with safe-state predicate; FAIL retained for genuine dirt; Step 8 if/else valid; contract prose synced; blocking assertion intact; items 1-4 each committed. Evidence to `tmp/2440/artifacts/pipeline-verify-*`. **→ SC-1, SC-2, SC-3, SC-4**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.

**Cost frame:** Running the safe-state behavioral tests (items 1, 2) costs minutes of execution time — the defect is caught at gate 1 where the fix costs the same bounded delay. Skipping costs the full pipeline of rework — every submodule-scoped feature session rediscovering the BLOCKED-unsatisfiable state. Inspecting the Step 8 snippet and contract prose statically (items 3, 4) costs one grep each — skipping means the invalid `continue` misbehaves during a network outage and consumers implement against stale FAIL semantics, a documentation-drift defect that surfaces as pipeline failures weeks later. Correctness is the only metric.

**Concern transition:** Leaving task-card safe-state semantics → entering behavioral regression verification. Phase 2 depends on Phase 1's WARN semantics (SC-1, SC-2, SC-4).
