---
plan_schema_version: 1
issue: 2219
title: "Submodule pointer discipline: pre-work ordering, dead-branch cleanup, PR guards, and pre-commit enforcement"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - pr-creation-workflow
  - completion-core
---

# Implementation Plan — #2219 — Submodule Pointer Discipline

**Issue:** [https://github.com/michael-conrad/.opencode/issues/2219](https://github.com/michael-conrad/.opencode/issues/2219)

**Goal:** Fix the submodule pointer lifecycle end-to-end: reorder pre-work so submodule sync precedes branch creation, add dead-branch detection to cleanup, add guards against submodule-only PR creation, and add pre-commit enforcement for stale pointer SHAs.

**Architecture:** Four independent work items in a single stacked PR:
1. Reorder `pre-work.md` steps (submodule sync before feature branch)
2. Add dead-branch detection to `check-pr.md` Phase 5
3. Add guards to `implementation.md`, `pr-creation.md`, `020-go-prohibitions.md`
4. Add pre-commit enforcement for stale submodule pointers

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- `.opencode/skills/git-workflow-commit/tasks/implementation.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/skills/git-workflow/SKILL.md`
- `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md`
- `.opencode/hooks/pre-push`
- `.opencode/tests-v2/behaviors/` (new behavioral enforcement tests)

**Dispatch:** `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`, `pr-creation-workflow`, `completion-core`

## Blast Radius

- **Pre-work:** `pre-work.md` step reordering — affects all feature branch creation
- **Cleanup:** `check-pr.md` Phase 5 — new dead-branch detection step
- **PR guards:** `implementation.md`, `pr-creation.md`, `020-go-prohibitions.md` — guard logic and prohibition scope
- **Pre-commit:** `hooks/pre-push`, `git-workflow/SKILL.md`, `create-pr.md` — enforcement and release workflow
- **Tests:** 10+ new behavioral enforcement tests in `tests-v2/behaviors/`
- **No changes to:** other phases of check-pr.md, other cleanup task files, other skills

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Pre-work reorder | Submodule sync before branch creation | SC-1, SC-2, SC-3, SC-4, SC-5 | — | 1–4 | test-driven-development, verification-before-completion |
| 2 | Dead-branch detection | Identify and delete pointer-only branches | SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | — | 5–8 | test-driven-development, verification-before-completion |
| 3 | PR guards | Prevent submodule-only staging | SC-12, SC-13, SC-14, SC-15 | — | 9–12 | test-driven-development, verification-before-completion |
| 4 | Pre-commit enforcement | Block stale pointer SHAs | SC-16, SC-17, SC-18, SC-19 | — | 13–16 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate:** Verify spec/plan coherence — confirm the spec at `.opencode/.issues/2219/spec.md` matches the plan structure. The spec defines 19 SCs across 4 work items — this plan covers all 19. (**inline**)
- [ ] 2. **Baseline check:** Verify all target files exist and are readable: `pre-work.md`, `check-pr.md`, `implementation.md`, `pr-creation.md`, `020-go-prohibitions.md`, `git-workflow/SKILL.md`, `create-pr.md`, `hooks/pre-push`. (**inline**)

---

## Phase 1 — Pre-Work Reorder

**Concern:** Submodule sync before feature branch creation
**Files:** `pre-work.md`
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5
**Dependencies:** —
**Entry:** Pre-implementation complete
**Exit:** pre-work.md reordered with submodule sync before branch creation

**Code Path Coverage:** pre-work.md steps 2-5. Current order: sync trunk → create branch → submodule sync. New order: sync trunk → submodule sync → tag → create parent branch → create submodule branches.

**Cross-Cutting SCs:** None — all SCs are pre-work specific.

**Interface Boundaries:** Git operations (checkout, pull, submodule update, branch creation, tag). No external API calls.

**State Transitions:** Trunk synced → submodules synced to trunk tip → submodules tagged → parent feature branch created from state with up-to-date pointers → submodule feature branches created from tagged commits.

**Cost frame:** Verifying pre-work step ordering costs one grep search. Skipping means the parent branch captures a stale submodule pointer on every feature branch.

- [ ] 3. **RED** — Write a behavioral enforcement test that sends a pre-work prompt and asserts the agent syncs submodules before creating the parent feature branch. Verify the test FAILS. Save to `tmp/2219/behaviors/sc3-prework-ordering.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-3, test_type: behavioral, prompt: "setup branch for issue N", assertion: assert_semantic for submodule-before-branch ordering}`
- [ ] 4. **GREEN** — Reorder `pre-work.md` steps: move submodule sync (current Step 3.5) before feature branch creation (current Step 3). Add submodule feature branch creation step from tagged commit. Add existence check for submodule branches. Renumber all steps. (**sub-agent**)
  - Context: `{issue_number: 2219, file: skills/git-workflow-branch/tasks/pre-work.md, action: reorder steps, new_order: [sync trunk, submodule sync, tag submodules, create parent branch, create submodule branches]}`
- [ ] 5. **Verify** — Run the RED test from step 3. Confirm it now PASSES. Verify SC-1 (grep for submodule steps before branch creation), SC-2 (grep for tag reference), SC-4 (grep for orphan step references), SC-5 (grep for existence check). (**inline**)
- [ ] 6. **Commit** — `git add .opencode/skills/git-workflow-branch/tasks/pre-work.md tmp/2219/behaviors/sc3-prework-ordering.sh && git commit -m "phase-1(#2219): reorder pre-work — submodule sync before branch creation (SC-1 through SC-5)"` (**inline**)

> **Phase 1 complete.** VbC: SC-1 through SC-5 all PASS. pre-work.md reordered. Proceed to Phase 2.

---

## Phase 2 — Dead-Branch Detection

**Concern:** Identify and delete pointer-only branches
**Files:** `check-pr.md` Phase 5
**SCs:** SC-6, SC-7, SC-8, SC-9, SC-10, SC-11
**Dependencies:** —
**Entry:** Phase 1 complete
**Exit:** Dead-branch detection added to check-pr.md Phase 5

**Code Path Coverage:** New conditional step at end of Phase 5. Checks `git diff --stat origin/$DEFAULT_BRANCH...HEAD`, identifies submodule-only changes, verifies submodule PR merge status via API, deletes branch, parks at trunk tip.

**Cross-Cutting SCs:** None — all SCs are cleanup specific.

**Interface Boundaries:** Platform API call for submodule PR merge status. Git operations for branch deletion and trunk parking.

**State Transitions:** Unmerged branch detected → pointer-only check → submodule PR merge verification → branch deletion → trunk parking → dirty pointer acknowledgment.

**Cost frame:** Verifying dead-branch detection costs one behavioral test run per SC. Skipping means dead branches accumulate in the repo indefinitely.

- [ ] 7. **RED** — Write behavioral enforcement tests for SC-6 (detection), SC-7 (submodule PR verification), SC-8 (deletion + parking), SC-9 (dirty pointer), SC-10 (non-pointer guard), SC-11 (existing cleanup). Verify all FAIL. Save to `tmp/2219/behaviors/`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-6 through SC-11, test_type: behavioral, prompt: "check prs" with various branch states, assertion: assert_semantic per SC}`
- [ ] 8. **GREEN** — Add dead-branch detection step at end of Phase 5 in `check-pr.md`: unmerged check → git diff → submodule path check → submodule PR API query → branch deletion → trunk parking → dirty pointer acknowledgment → non-pointer guard. (**sub-agent**)
  - Context: `{issue_number: 2219, file: skills/git-workflow-cleanup/tasks/check-pr.md, target: end of Phase 5, logic: full dead-branch detection and deletion pipeline}`
- [ ] 9. **Verify** — Run all 6 RED tests from step 7. Confirm all PASS. (**inline**)
- [ ] 10. **Commit** — `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md tmp/2219/behaviors/ && git commit -m "phase-2(#2219): add dead-branch detection to cleanup (SC-6 through SC-11)"` (**inline**)

> **Phase 2 complete.** VbC: SC-6 through SC-11 all PASS. Dead-branch detection added. Proceed to Phase 3.

---

## Phase 3 — PR Guards

**Concern:** Prevent submodule-only staging
**Files:** `implementation.md`, `pr-creation.md`, `020-go-prohibitions.md`
**SCs:** SC-12, SC-13, SC-14, SC-15
**Dependencies:** —
**Entry:** Phase 2 complete
**Exit:** Guards added to implementation.md, pr-creation.md, 020-go-prohibitions.md

**Code Path Coverage:** implementation.md submodule pointer staging step, pr-creation.md submodule pointer staging step, 020-go-prohibitions.md prohibition text.

**Cross-Cutting SCs:** None — all SCs are PR guard specific.

**Interface Boundaries:** No external API calls. Text changes to task files and guidelines.

**State Transitions:** No state transitions — guard logic only.

**Cost frame:** Verifying PR guards costs one grep + one behavioral test. Skipping means the agent continues creating submodule-only PRs.

- [ ] 11. **RED** — Write a behavioral enforcement test that sends a prompt with a dirty submodule pointer and no real changes, and asserts the agent declines to create a PR. Verify the test FAILS. Save to `tmp/2219/behaviors/sc15-decline-submodule-pr.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-15, test_type: behavioral, prompt: "the submodule pointer is dirty, create a PR", assertion: assert_semantic for decline behavior}`
- [ ] 12. **GREEN** — Add guards to `implementation.md` and `pr-creation.md`: before staging submodule pointer, verify non-submodule changes exist. If not, HALT. Widen prohibition in `020-go-prohibitions.md` from "during cleanup" to "in ANY context, for ANY reason". (**sub-agent**)
  - Context: `{issue_number: 2219, files: [skills/git-workflow-commit/tasks/implementation.md, skills/git-workflow-pr/tasks/pr-creation.md, guidelines/020-go-prohibitions.md], action: add guard logic + widen prohibition scope}`
- [ ] 13. **Verify** — Run the RED test from step 11. Confirm it now PASSES. Verify SC-12 (grep for guard in implementation.md), SC-13 (grep for guard in pr-creation.md), SC-14 (grep for universal scope in 020-go-prohibitions.md). (**inline**)
- [ ] 14. **Commit** — `git add .opencode/skills/git-workflow-commit/tasks/implementation.md .opencode/skills/git-workflow-pr/tasks/pr-creation.md .opencode/guidelines/020-go-prohibitions.md tmp/2219/behaviors/sc15-decline-submodule-pr.sh && git commit -m "phase-3(#2219): add PR guards and universal prohibition (SC-12 through SC-15)"` (**inline**)

> **Phase 3 complete.** VbC: SC-12 through SC-15 all PASS. PR guards added. Proceed to Phase 4.

---

## Phase 4 — Pre-Commit Enforcement

**Concern:** Block stale submodule pointer SHAs
**Files:** `hooks/pre-push`, `git-workflow/SKILL.md`, `create-pr.md`
**SCs:** SC-16, SC-17, SC-18, SC-19
**Dependencies:** —
**Entry:** Phase 3 complete
**Exit:** Pre-commit enforcement added, release-pr dispatch added, --release mode added

**Code Path Coverage:** pre-push hook stale pointer check, git-workflow SKILL.md Trigger Dispatch Table, create-pr.md --release mode section.

**Cross-Cutting SCs:** None — all SCs are pre-commit specific.

**Interface Boundaries:** Git hook execution, platform API for submodule SHA verification.

**State Transitions:** Commit attempted → stale pointer detected → commit blocked.

**Cost frame:** Verifying pre-commit enforcement costs one behavioral test. Skipping means stale submodule pointer SHAs are committed without detection.

- [ ] 15. **RED** — Write a behavioral enforcement test that creates a stale submodule pointer, attempts a commit, and asserts the hook blocks it. Save to `tmp/2219/behaviors/sc16-stale-pointer-block.sh`. (**clean-room**)
  - Context: `{issue_number: 2219, sc: SC-16, test_type: behavioral, prompt: create stale pointer and commit, assertion: assert_semantic for block behavior}`
- [ ] 16. **GREEN** — Add pre-commit enforcement to `hooks/pre-push`: block submodule-pointer commits where local SHA != remote trunk tip SHA. Add release-pr trigger dispatch entry to `git-workflow/SKILL.md`. Add --release mode section to `create-pr.md` with submodule SHA verification. (**sub-agent**)
  - Context: `{issue_number: 2219, files: [hooks/pre-push, skills/git-workflow/SKILL.md, skills/git-workflow/tasks/pr-creation/create-pr.md], action: add enforcement + dispatch + release mode}`
- [ ] 17. **Verify** — Run the RED test from step 15. Confirm it now PASSES. Verify SC-17 (grep for release-pr in SKILL.md), SC-18 (grep for --release in create-pr.md). (**inline**)
- [ ] 18. **Commit** — `git add .opencode/hooks/pre-push .opencode/skills/git-workflow/SKILL.md .opencode/skills/git-workflow/tasks/pr-creation/create-pr.md tmp/2219/behaviors/sc16-stale-pointer-block.sh && git commit -m "phase-4(#2219): add pre-commit enforcement and release workflow (SC-16 through SC-19)"` (**inline**)

> **Phase 4 complete.** VbC: SC-16 through SC-19 all PASS. Pre-commit enforcement added. Proceed to post-implementation.

---

## Post-Implementation Steps

- [ ] 19. **Structural checks** — Run lint and typecheck on modified files. (**inline**)
- [ ] 20. **Verification** — Run all behavioral enforcement tests. Confirm all PASS. (**inline**)
- [ ] 21. **Audit** — Dispatch adversarial audit of the deliverable. (**sub-agent**)
- [ ] 22. **Cross-validate** — Verify audit findings against SC evidence. (**sub-agent**)
- [ ] 23. **Review-prep** — Prepare PR review context. (**sub-agent**)
- [ ] 24. **Create PR** — Create the pull request. (**sub-agent**)
- [ ] 25. **Completion** — Generate completion executive summary. (**sub-agent**)

---

## Exit Criteria

- [ ] C1: pre-work.md reordered — submodule sync before feature branch creation
- [ ] C2: Submodule feature branches created from tagged commits
- [ ] C3: pre-work.md step numbers internally consistent
- [ ] C4: Dead-branch detection added to check-pr.md Phase 5
- [ ] C5: Submodule PR merge verification queries platform API before deletion
- [ ] C6: Dead branches deleted (local + remote) and repo parked at trunk tip
- [ ] C7: Dirty submodule pointer acknowledged but NOT committed
- [ ] C8: Branches with real code changes preserved
- [ ] C9: Existing merged-branch cleanup logic unmodified
- [ ] C10: implementation.md guards against submodule-only staging
- [ ] C11: pr-creation.md guards against submodule-only staging
- [ ] C12: 020-go-prohibitions.md has universal prohibition
- [ ] C13: Pre-commit hook blocks stale submodule pointer commits
- [ ] C14: git-workflow SKILL.md has release-pr trigger dispatch entry
- [ ] C15: create-pr.md has --release mode with submodule SHA verification
- [ ] C16: All behavioral enforcement tests PASS
- [ ] C17: Post-implementation audit passes with no critical findings
- [ ] C18: Structural checks (lint, typecheck) pass
- [ ] C19: PR created and review-ready
