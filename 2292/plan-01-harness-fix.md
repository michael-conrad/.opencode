# Phase 1 — Harness fix

**Concern:** Eliminate the live-project-root git-mutation hazard in the behavioral test harness so no `BEHAVIOR_NEEDS_REMOTE=1` test can silently mutate the live `.opencode` repo's `origin` remote or `main` ref.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh`
- `.opencode/tests-v2/with-test-home`
- `.opencode/tests-v2/behaviors/2292-sc1-live-root-fallback.sh` (new)
- `.opencode/tests-v2/behaviors/2292-sc2-live-root-guard.sh` (new)
- `.opencode/tests-v2/behaviors/2292-sc3-remote-wiring-ordering.sh` (new)

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry Conditions:**
- Spec #2292 is approved (`approved-for-pr` label present in local `issue.yaml`)
- Feature branch exists
- `structure.yaml` artifact exists with phase_P1 → phase_P2 DAG

**Exit Conditions:**
- `__ensure_gitbucket()` no longer falls back to `$project_root` when `$TEST_PROJECT` is unset; it emits a BLOCKED diagnostic instead
- The harness detects when a git-mutating target resolves to the live repo and BLOCKs with a clear diagnostic before mutating
- The `__ensure_gitbucket()` remote-wiring block runs against a validated isolated repo established before remote wiring, or is relocated/guarded so it cannot hit the live repo
- All 18 existing `BEHAVIOR_NEEDS_REMOTE=1` tests remain functional (GitBucket origin still wired on the isolated repo)
- The isolation contract (`env -i`, test home, `TEST_PROJECT`/`attempt_workdir`) is preserved
- The artifact-only generator paradigm is preserved (scripts exit 0, no evaluation logic)

---

## Pre-implementation (once per plan)

- [ ] 1. **Coherence gate (**clean-room**).** Verify the plan is coherent with the spec: every SC in Phase 1 maps to exactly one item, no item covers multiple SCs, and the phase DAG (P1 → P2) is acyclic. **→ all SCs**
- [ ] 2. **Baseline check (**clean-room**).** Verify the current harness state: confirm `helpers.sh` line 267 contains `${TEST_PROJECT:-$project_root}`, confirm `__ensure_gitbucket()` runs at line 488 before `with-test-home` establishes `TEST_PROJECT` at line 620, and confirm the live `.opencode` repo `origin` remote and `main` ref are in a known-good state. **→ SC-1, SC-2, SC-3**

---

## Item 1 — SC-1: Live-root fallback elimination

- [ ] 3. **RED (**sub-agent**).** Write a failing behavioral enforcement test at `.opencode/tests-v2/behaviors/2292-sc1-live-root-fallback.sh` that runs a `BEHAVIOR_NEEDS_REMOTE=1` scenario and asserts the live `.opencode` repo `origin` remote and `main` ref are unchanged (`git remote -v`, `git rev-parse main` before/after). The test is an artifact-only generator (exit 0, no evaluation logic). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Remove the `${TEST_PROJECT:-$project_root}` fallback in `__ensure_gitbucket()` (helpers.sh line 267). When `$TEST_PROJECT` is unset, emit a BLOCKED diagnostic and halt instead of resolving to the live repo. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify the fallback is removed and the live repo is untouched: run a `BEHAVIOR_NEEDS_REMOTE=1` test and assert the live `.opencode` repo `origin`/`main` are unchanged via clean-room session.yaml evaluation. **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** Commit the fallback removal + behavioral enforcement test as one atomic slice. **→ SC-1**

#### Item 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify `__ensure_gitbucket()` no longer contains `${TEST_PROJECT:-$project_root}` and that an unset `$TEST_PROJECT` yields a BLOCKED diagnostic with no live-repo mutation. **→ SC-1**

---

## Item 2 — SC-2: Live-root mutation guard

- [ ] 8. **RED (**sub-agent**).** Write a failing behavioral enforcement test at `.opencode/tests-v2/behaviors/2292-sc2-live-root-guard.sh` that invokes a harness path with a git-mutating target equal to the live repo and asserts the repo is NOT mutated (guard absent → mutation occurs). Artifact-only generator (exit 0). **→ SC-2**
- [ ] 9. **GREEN (**sub-agent**).** Add a guard in `helpers.sh` that aborts any git-mutating op whose resolved target equals the live repo (`$PARENT_REPO_DIR` / `$PROJECT_DIR` / `$project_root`), emitting a clear BLOCKED diagnostic before mutating. The guard MUST only block when target == live repo; it MUST NOT block legitimate isolated-target operations. **→ SC-2**
- [ ] 10. **GREEN doublecheck (**clean-room**).** Verify the guard blocks a live-repo target: invoke the guard (or a harness path) with target == live repo and assert BLOCK + diagnostic with no mutation (`git remote -v` unchanged, no push). **→ SC-2**
- [ ] 11. **Checkpoint commit (**inline**).** Commit the guard logic + behavioral test as one atomic slice. **→ SC-2**

#### Item 2 VbC

- [ ] 12. **VbC (**clean-room**).** Verify the guard fires with a clear diagnostic when target == live repo, and does NOT block legitimate isolated-target operations. **→ SC-2**

---

## Item 3 — SC-3: Remote-wiring ordering dependency

- [ ] 13. **RED (**sub-agent**).** Write a failing behavioral enforcement test at `.opencode/tests-v2/behaviors/2292-sc3-remote-wiring-ordering.sh` that runs a `BEHAVIOR_NEEDS_REMOTE=1` scenario and asserts GitBucket origin is wired on the isolated `$attempt_workdir` and the live repo origin is untouched (remote wiring runs before an isolated target exists → hits the live repo). Artifact-only generator (exit 0). **→ SC-3**
- [ ] 14. **GREEN (**sub-agent**).** Ensure the `__ensure_gitbucket()` remote-wiring block runs against a validated isolated repo established before remote wiring, or is relocated/guarded so it cannot hit the live repo. Preserve the attempt_workdir origin wiring (helpers.sh line 615). **→ SC-3**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Verify remote wiring targets the isolated repo: run a `BEHAVIOR_NEEDS_REMOTE=1` test and assert GitBucket origin is wired on the isolated `$attempt_workdir` and the live repo origin is untouched via clean-room session.yaml evaluation. **→ SC-3**
- [ ] 16. **Checkpoint commit (**inline**).** Commit the ordering/guard fix + behavioral test as one atomic slice. **→ SC-3**

#### Item 3 VbC

- [ ] 17. **VbC (**clean-room**).** Verify the remote-wiring block runs against an established isolated repo (or is guarded to BLOCK when target == live repo), and that GitBucket origin is wired on the isolated `$attempt_workdir` with the live repo origin untouched. **→ SC-3**

---

## Phase 1 Completion Block

- [ ] 18. **Phase 1 VbC (**clean-room**).** Verify all three SCs (SC-1, SC-2, SC-3) pass: fallback eliminated, guard blocks live-repo targets, remote wiring targets the isolated repo. Confirm all 18 existing `BEHAVIOR_NEEDS_REMOTE=1` tests remain functional and the isolation contract is preserved. **→ SC-1, SC-2, SC-3**

**Concern transition:** Leaving harness runtime fix → entering structural enforcement. Phase 2 depends on Phase 1's harness fix (the enforcement test asserts the fix).
