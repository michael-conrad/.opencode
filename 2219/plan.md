---
plan_schema_version: 1
issue: 2219
title: "Dead-branch detection and deletion in cleanup workflow"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - pr-creation-workflow
  - completion-core
---

# Implementation Plan — #2219 — Dead-Branch Detection and Deletion in Cleanup Workflow

**Issue:** [https://github.com/michael-conrad/.opencode/issues/2219](https://github.com/michael-conrad/.opencode/issues/2219)

**Goal:** Add a dead-branch detection step at the end of Phase 5 in `check-pr.md` that detects submodule-pointer-only branches, verifies submodule PR merge status, deletes the dead branch, parks at trunk tip, and leaves the submodule pointer dirty.

**Architecture:** The fix adds a conditional step at the end of Phase 5 (Parent Branch Cleanup) in `check-pr.md`. The step runs only when the current branch is unmerged. It uses `git diff --stat origin/$DEFAULT_BRANCH...HEAD` to check if all changed files are submodule paths. If so, it verifies the submodule PR merge status via platform API, deletes the branch (local + remote), parks at trunk tip, and acknowledges the dirty pointer. Branches with non-submodule changes fall through to Phase 6's existing branch-aware parking.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- `.opencode/tests-v2/behaviors/` (new behavioral enforcement tests)

**Dispatch:** `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`, `pr-creation-workflow`, `completion-core`

## Blast Radius

- **Primary target:** `check-pr.md` Phase 5 — new conditional step at end of phase
- **Reference patterns:** `branch-cleanup.md` Step 1.7 (dirty pointer), Step 3.4 (branch deletion)
- **Reference guard:** `pre-work.md` Step 4 (No-Op Branch Guard) — complementary, not modified
- **Tests:** 6 new behavioral enforcement tests in `tests-v2/behaviors/`
- **No changes to:** other phases of check-pr.md, other cleanup task files, other skills

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Detection | Identify pointer-only branches | SC-1 | — | 1–4 | test-driven-development, verification-before-completion |
| 2 | Submodule PR verification | Verify submodule merge status | SC-2 | 1 | 5–8 | test-driven-development, verification-before-completion |
| 3 | Deletion | Delete dead branch, park at trunk tip | SC-3 | 1, 2 | 9–12 | test-driven-development, verification-before-completion |
| 4 | Dirty pointer | Acknowledge dirty pointer, no commit | SC-4 | 3 | 13–16 | test-driven-development, verification-before-completion |
| 5 | Non-pointer guard | Preserve branches with real changes | SC-5 | 1 | 17–20 | test-driven-development, verification-before-completion |
| 6 | Existing cleanup | Verify existing cleanup unchanged | SC-6 | — | 21–24 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate:** Verify spec/plan coherence — confirm the spec at `.opencode/.issues/2219/spec.md` matches the plan structure. The spec defines 6 SCs across 6 phases — this plan covers all 6. (**inline**)
- [ ] 2. **Baseline check:** Verify the target file exists at `skills/git-workflow-cleanup/tasks/check-pr.md` and is readable. (**inline**)
- [ ] 3. **Baseline check:** Verify reference files exist: `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`, `skills/git-workflow-branch/tasks/pre-work.md`. (**inline**)

---

## Phase 1 — Detection

**Concern:** Identify pointer-only branches
**Files:** `check-pr.md` Phase 5
**SCs:** SC-1
**Dependencies:** —
**Entry:** Pre-implementation complete
**Exit:** Detection logic added to check-pr.md Phase 5

**Code Path Coverage:** The detection step runs at the end of Phase 5, after merged-branch deletion and checkpoint tag cleanup. It checks `git diff --stat origin/$DEFAULT_BRANCH...HEAD` and inspects the changed file list.

**Cross-Cutting SCs:** None — SC-1 is self-contained.

**Interface Boundaries:** The detection step reads `$DEFAULT_BRANCH` from git remote and the current branch name from `git branch --show-current`. No external API calls.

**State Transitions:** Current branch state → unmerged branch identified → pointer-only classification → proceed to Phase 2 or fall through to Phase 6.

**Cost frame:** Verifying the detection logic costs one behavioral test run. Skipping means a dead branch is never detected and the repo stays parked on an unmergeable branch indefinitely.

- [ ] 4. **RED** — Write a behavioral enforcement test that sends a prompt with a pointer-only branch (submodule changes only) and asserts the agent detects it as dead. Verify the test FAILS (no detection logic exists yet). Save to `tmp/2219/behaviors/sc1-detection.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-1, test_type: behavioral, prompt: "check prs" with pointer-only branch, assertion: assert_semantic for detection decision}`
- [ ] 5. **GREEN** — Add a conditional step at the end of Phase 5 in `check-pr.md` that checks if the current branch is unmerged, runs `git diff --stat origin/$DEFAULT_BRANCH...HEAD`, and checks if all changed files are submodule paths. (**sub-agent**)
  - Context: `{issue_number: 2219, file: skills/git-workflow-cleanup/tasks/check-pr.md, target: end of Phase 5, logic: unmerged check → git diff → submodule path check}`
- [ ] 6. **Verify** — Run the RED test from step 4. Confirm it now PASSES. (**inline**)
- [ ] 7. **Commit** — `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md tmp/2219/behaviors/sc1-detection.sh && git commit -m "phase-1(#2219): add dead-branch detection (SC-1)"` (**inline**)

> **Phase 1 complete.** VbC: SC-1 behavioral test PASSES. Detection logic added to check-pr.md Phase 5. Proceed to Phase 2.

---

## Phase 2 — Submodule PR Verification

**Concern:** Verify submodule merge status before deleting parent branch
**Files:** `check-pr.md` Phase 5
**SCs:** SC-2
**Dependencies:** Phase 1
**Entry:** Phase 1 complete (detection logic in place)
**Exit:** Submodule PR merge verification logic added

**Code Path Coverage:** After detection identifies a pointer-only branch, the verification step identifies the submodule repo from the changed submodule path, queries the platform API for merge status, and conditionally proceeds to deletion.

**Cross-Cutting SCs:** None — SC-2 is self-contained.

**Interface Boundaries:** Platform API call to query submodule PR merge status. Must handle merged, unmerged, and unreachable states.

**State Transitions:** Pointer-only branch detected → submodule repo identified → API query → merged: proceed to Phase 3 | unmerged: fall through to Phase 6.

**Cost frame:** Verifying the API query logic costs one behavioral test run. Skipping means the agent deletes a parent branch whose submodule work hasn't merged yet, losing unmerged work.

- [ ] 8. **RED** — Write a behavioral enforcement test that sends a prompt with a pointer-only branch whose submodule PR is merged, and another where the submodule PR is unmerged. Assert the agent verifies merge status before deciding. Verify the test FAILS. Save to `tmp/2219/behaviors/sc2-submodule-pr-verify.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-2, test_type: behavioral, prompt: "check prs" with merged vs unmerged submodule PR, assertion: assert_semantic for verification decision}`
- [ ] 9. **GREEN** — Add submodule PR merge verification logic to the detection step: identify the submodule repo from the changed submodule path, query the platform API for merge status, only proceed to deletion if confirmed merged, fall through to Phase 6 deferral if unmerged. (**sub-agent**)
  - Context: `{issue_number: 2219, file: skills/git-workflow-cleanup/tasks/check-pr.md, logic: submodule repo identification → platform API query → conditional deletion}`
- [ ] 10. **Verify** — Run the RED test from step 8. Confirm it now PASSES. (**inline**)
- [ ] 11. **Commit** — `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md tmp/2219/behaviors/sc2-submodule-pr-verify.sh && git commit -m "phase-2(#2219): add submodule PR merge verification (SC-2)"` (**inline**)

> **Phase 2 complete.** VbC: SC-2 behavioral test PASSES. Submodule PR verification logic added. Proceed to Phase 3.

---

## Phase 3 — Deletion

**Concern:** Delete dead branch and park at trunk tip
**Files:** `check-pr.md` Phase 5
**SCs:** SC-3
**Dependencies:** Phase 1, Phase 2
**Entry:** Phase 2 complete (submodule PR merge verified)
**Exit:** Deletion logic added

**Code Path Coverage:** After submodule PR merge is confirmed, the deletion step deletes the local branch, deletes the remote branch, and parks at trunk tip. Reuses branch-cleanup.md Step 3.4 pattern.

**Cross-Cutting SCs:** None — SC-3 is self-contained.

**Interface Boundaries:** Git operations (branch -d, push --delete, checkout, pull --ff-only). No external API calls.

**State Transitions:** Submodule PR merged confirmed → local branch deleted → remote branch deleted → trunk checkout + pull → repo at trunk tip.

**Cost frame:** Verifying the deletion logic costs one behavioral test run. Skipping means the dead branch remains in the repo indefinitely, accumulating stale references.

- [ ] 12. **RED** — Write a behavioral enforcement test that sends a prompt with a confirmed-dead branch and asserts the agent deletes it (local + remote) and parks at trunk tip. Verify the test FAILS. Save to `tmp/2219/behaviors/sc3-deletion.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-3, test_type: behavioral, prompt: "check prs" with confirmed-dead branch, assertion: assert_semantic for deletion + parking}`
- [ ] 13. **GREEN** — Add deletion logic: delete local branch (`git branch -d`), delete remote branch (`git push origin --delete`), park at trunk tip (`git checkout $DEFAULT_BRANCH && git pull --ff-only`). Reuse branch-cleanup.md Step 3.4 pattern. (**sub-agent**)
  - Context: `{issue_number: 2219, file: skills/git-workflow-cleanup/tasks/check-pr.md, logic: local delete → remote delete → trunk parking, reference: branch-cleanup.md Step 3.4}`
- [ ] 14. **Verify** — Run the RED test from step 12. Confirm it now PASSES. (**inline**)
- [ ] 15. **Commit** — `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md tmp/2219/behaviors/sc3-deletion.sh && git commit -m "phase-3(#2219): add dead-branch deletion and trunk parking (SC-3)"` (**inline**)

> **Phase 3 complete.** VbC: SC-3 behavioral test PASSES. Deletion logic added. Proceed to Phase 4.

---

## Phase 4 — Dirty Pointer

**Concern:** Acknowledge dirty submodule pointer without committing
**Files:** `check-pr.md` Phase 5
**SCs:** SC-4
**Dependencies:** Phase 3
**Entry:** Phase 3 complete (trunk parking in place)
**Exit:** Dirty pointer acknowledgment added

**Code Path Coverage:** After trunk parking, the dirty pointer step acknowledges the stale submodule pointer and explicitly does NOT commit it. Reuses branch-cleanup.md Step 1.7 pattern.

**Cross-Cutting SCs:** None — SC-4 is self-contained.

**Interface Boundaries:** Git status check for dirty submodule pointer. No external API calls.

**State Transitions:** Trunk parked → dirty pointer detected → acknowledged in output → no commit → repo stays on trunk with dirty pointer.

**Cost frame:** Verifying the no-commit behavior costs one behavioral test run. Skipping means the agent may silently commit the dirty pointer, creating a submodule-pointer-only commit on trunk.

- [ ] 16. **RED** — Write a behavioral enforcement test that sends a prompt with a dead branch, asserts the agent parks at trunk tip, and asserts the agent does NOT commit the dirty submodule pointer. Verify the test FAILS. Save to `tmp/2219/behaviors/sc4-dirty-pointer.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-4, test_type: behavioral, prompt: "check prs" with dead branch, assertion: assert_semantic for no-commit behavior}`
- [ ] 17. **GREEN** — Add dirty pointer acknowledgment: reuse branch-cleanup.md Step 1.7 pattern (acknowledge dirty pointer, do NOT commit). (**sub-agent**)
  - Context: `{issue_number: 2219, file: skills/git-workflow-cleanup/tasks/check-pr.md, logic: dirty pointer acknowledgment, reference: branch-cleanup.md Step 1.7}`
- [ ] 18. **Verify** — Run the RED test from step 16. Confirm it now PASSES. (**inline**)
- [ ] 19. **Commit** — `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md tmp/2219/behaviors/sc4-dirty-pointer.sh && git commit -m "phase-4(#2219): add dirty pointer acknowledgment (SC-4)"` (**inline**)

> **Phase 4 complete.** VbC: SC-4 behavioral test PASSES. Dirty pointer acknowledgment added. Proceed to Phase 5.

---

## Phase 5 — Non-Pointer Guard

**Concern:** Preserve branches with real code changes
**Files:** `check-pr.md` Phase 5
**SCs:** SC-5
**Dependencies:** Phase 1
**Entry:** Phase 1 complete (detection logic in place)
**Exit:** Non-pointer guard added

**Code Path Coverage:** After detection identifies changed files, the guard checks if any changed files are non-submodule paths. If so, it skips deletion and falls through to Phase 6's existing branch-aware parking.

**Cross-Cutting SCs:** None — SC-5 is self-contained.

**Interface Boundaries:** Git diff output parsing. No external API calls.

**State Transitions:** Pointer-only branch detected → non-submodule files found → skip deletion → fall through to Phase 6.

**Cost frame:** Verifying the guard logic costs one behavioral test run. Skipping means a branch with real code changes could be incorrectly deleted.

- [ ] 20. **RED** — Write a behavioral enforcement test that sends a prompt with a mixed-content branch (submodule + real code changes) and asserts the agent preserves it (falls through to Phase 6). Verify the test FAILS. Save to `tmp/2219/behaviors/sc5-non-pointer-guard.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-5, test_type: behavioral, prompt: "check prs" with mixed-content branch, assertion: assert_semantic for preservation decision}`
- [ ] 21. **GREEN** — Add non-pointer branch guard: if diff contains non-submodule files, skip deletion and fall through to Phase 6's existing branch-aware parking. (**sub-agent**)
  - Context: `{issue_number: 2219, file: skills/git-workflow-cleanup/tasks/check-pr.md, logic: non-submodule file check → skip deletion → fall through to Phase 6}`
- [ ] 22. **Verify** — Run the RED test from step 20. Confirm it now PASSES. (**inline**)
- [ ] 23. **Commit** — `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md tmp/2219/behaviors/sc5-non-pointer-guard.sh && git commit -m "phase-5(#2219): add non-pointer branch guard (SC-5)"` (**inline**)

> **Phase 5 complete.** VbC: SC-5 behavioral test PASSES. Non-pointer guard added. Proceed to Phase 6.

---

## Phase 6 — Existing Cleanup

**Concern:** Verify existing merged-branch cleanup unchanged
**Files:** Existing cleanup tests
**SCs:** SC-6
**Dependencies:** —
**Entry:** All prior phases complete
**Exit:** Existing cleanup verified unmodified

**Code Path Coverage:** No code changes. Verifies that Phase 5 merged-branch cleanup logic is unmodified by running existing cleanup behavioral tests.

**Cross-Cutting SCs:** None — SC-6 is self-contained.

**Interface Boundaries:** None — verification-only phase.

**State Transitions:** No state changes — verification only.

**Cost frame:** Verifying existing cleanup costs one behavioral test run. Skipping means a regression in existing cleanup behavior goes undetected.

- [ ] 24. **RED** — Write a behavioral enforcement test that verifies existing merged-branch cleanup (Phase 5) still works after the change. Verify the test FAILS (no baseline yet). Save to `tmp/2219/behaviors/sc6-existing-cleanup.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-6, test_type: behavioral, prompt: "check prs" with merged branch, assertion: assert_semantic for existing cleanup behavior}`
- [ ] 25. **GREEN** — Verify that Phase 5 merged-branch cleanup logic is unmodified. Run existing cleanup behavioral tests to confirm they still pass. (**inline**)
- [ ] 26. **Verify** — Run the RED test from step 24. Confirm it now PASSES. (**inline**)
- [ ] 27. **Commit** — `git add tmp/2219/behaviors/sc6-existing-cleanup.sh && git commit -m "phase-6(#2219): verify existing cleanup unchanged (SC-6)"` (**inline**)

> **Phase 6 complete.** VbC: SC-6 behavioral test PASSES. Existing cleanup verified unmodified. Proceed to post-implementation.

---

## Post-Implementation Steps

- [ ] 28. **Structural checks** — Run lint and typecheck on modified files. (**inline**)
- [ ] 29. **Verification** — Run all 6 behavioral enforcement tests. Confirm all PASS. (**inline**)
- [ ] 30. **Audit** — Dispatch adversarial audit of the deliverable. (**sub-agent**)
- [ ] 31. **Cross-validate** — Verify audit findings against SC evidence. (**sub-agent**)
- [ ] 32. **Review-prep** — Prepare PR review context. (**sub-agent**)
- [ ] 33. **Create PR** — Create the pull request. (**sub-agent**)
- [ ] 34. **Completion** — Generate completion executive summary. (**sub-agent**)

---

## Exit Criteria

- [ ] C1: All 6 SCs have passing behavioral enforcement tests
- [ ] C2: `check-pr.md` Phase 5 has dead-branch detection step
- [ ] C3: Submodule PR merge verification queries platform API before deletion
- [ ] C4: Dead branches are deleted (local + remote) and repo parked at trunk tip
- [ ] C5: Dirty submodule pointer is acknowledged but NOT committed
- [ ] C6: Branches with real code changes are preserved (fall through to Phase 6)
- [ ] C7: Existing merged-branch cleanup logic is unmodified
- [ ] C8: Post-implementation audit passes with no critical findings
- [ ] C9: Structural checks (lint, typecheck) pass
- [ ] C10: PR created and review-ready
