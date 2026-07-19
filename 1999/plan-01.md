# Phase 1 — Git-state merge verification

## Phase Metadata

- **Concern:** Fix all 5 structural defects in cleanup workflow where PR metadata is used as evidence of merge status instead of actual git state
- **Files:**
  - `skills/git-workflow-cleanup/tasks/check-pr.md`
  - `skills/git-workflow-cleanup/tasks/cleanup/verify-merge.md`
  - `skills/git-workflow-cleanup/tasks/cleanup.md`
  - `tests-v2/behaviors/`
- **SCs:** SC-1 through SC-9
- **Dependencies:** None
- **Entry conditions:** Feature branch `feature/1996-1999-trunk-tip-cleanup-verify` exists and is checked out
- **Exit conditions:** All 9 SCs verified PASS, all changes committed

## Code Path Coverage

- `check-pr.md` Phase 2 mergeability diagnosis (6-field → 7-field with `merge_commit_sha`)
- `check-pr.md` Phase 2 Step 2.5 git log check (broken → fixed with populated SHA)
- `verify-merge.md` Step 1 merge verification (API-only → API + git state)
- `verify-merge.md` Step 1 branch reachability (missing → added)
- `verify-merge.md` Step 1 PR-to-spec cross-reference (missing → added)
- `cleanup.md` Step 1 Live Verification Table (missing merge commit row → added)
- `cleanup.md` Step 1 PR-to-spec cross-reference step (missing → added)

## Cross-Cutting SCs

- SC-5 (semantic): PR-to-spec cross-reference applies to both verify-merge.md and cleanup.md
- SC-7, SC-8, SC-9 (behavioral): All three behavioral tests share the same test infrastructure

## Interface Boundaries

- `check-pr.md` Phase 2 output feeds into `verify-merge.md` Step 1 — the `merge_commit_sha` extracted in check-pr must be available to verify-merge
- `verify-merge.md` Step 1 output feeds into `cleanup.md` branch deletion — merge verification must pass before branch deletion

## State Transitions

- Pre-change: PR metadata check → branch deletion (no git state verification)
- Post-change: PR metadata check → git log merge commit verification → branch reachability check → PR-to-spec cross-reference → branch deletion

## Step-by-step

### Step 1.1: Add `merge_commit_sha` to check-pr.md mergeability diagnosis

- [ ] 1.1.1 Read `skills/git-workflow-cleanup/tasks/check-pr.md` Phase 2 mergeability diagnosis table
- [ ] 1.1.2 Add `merge_commit_sha` field to the 6-field table (making it 7 fields):
  ```
  | `merge_commit_sha` | PR API response | Merge commit SHA for git log verification |
  ```
- [ ] 1.1.3 Add Step 2.1.5 to read `merge_commit_sha` from PR API response
- [ ] 1.1.4 **Verify:** grep for `merge_commit_sha` in check-pr.md — must find at least 2 occurrences (table row + step reference)
- [ ] 1.1.5 **SC-1 verification:** `grep -c "merge_commit_sha" skills/git-workflow-cleanup/tasks/check-pr.md` >= 2

### Step 1.2: Fix check-pr.md Step 2.5 git log check

- [ ] 1.2.1 Read `check-pr.md` Step 2.5 — locate the `git log --oneline "$DEFAULT_BRANCH" | grep <merge_sha>` line
- [ ] 1.2.2 Replace `<merge_sha>` with `$merge_commit_sha` so the step reads:
  ```
  git log --oneline "$DEFAULT_BRANCH" | grep "$merge_commit_sha"
  ```
- [ ] 1.2.3 **Verify:** grep for `git log.*merge_commit_sha` in check-pr.md — must match
- [ ] 1.2.4 **SC-2 verification:** `grep "git log.*merge_commit_sha" skills/git-workflow-cleanup/tasks/check-pr.md` returns non-empty

### Step 1.3: Add merge commit verification to verify-merge.md Step 1

- [ ] 1.3.1 Read `skills/git-workflow-cleanup/tasks/cleanup/verify-merge.md` Step 1
- [ ] 1.3.2 After the `merged_at is not None` check, add a git log verification block:
  ```
  # After confirming merged_at is not None, verify merge commit exists in trunk history
  merge_commit_sha = pr.get("merge_commit_sha")
  if merge_commit_sha:
      git_log_check = `git log --oneline "$DEFAULT_BRANCH" | grep "$merge_commit_sha"`
      if not git_log_check:
          report = f"Merge commit {merge_commit_sha} not found in trunk history. Possible force-push or revert."
          return report
  ```
- [ ] 1.3.3 Add `merge_commit_sha` to the evidence artifacts section
- [ ] 1.3.4 **Verify:** grep for `git log.*merge_commit_sha` in verify-merge.md — must match
- [ ] 1.3.5 **SC-3 verification:** `grep "git log.*merge_commit_sha" skills/git-workflow-cleanup/tasks/cleanup/verify-merge.md` returns non-empty

### Step 1.4: Add branch reachability check to verify-merge.md Step 1

- [ ] 1.4.1 After the git log verification, add a branch reachability check:
  ```
  # Verify feature branch commits are reachable from trunk
  branch_name = "<feature_branch_name>"
  reachable = `git branch --merged "$DEFAULT_BRANCH" | grep "$branch_name"`
  if not reachable:
      report = f"Branch {branch_name} is not reachable from trunk. Skipping branch deletion."
      return report
  ```
- [ ] 1.4.2 **Verify:** grep for `git branch --merged` in verify-merge.md — must match
- [ ] 1.4.3 **SC-4 verification:** `grep "git branch --merged" skills/git-workflow-cleanup/tasks/cleanup/verify-merge.md` returns non-empty

### Step 1.5: Add PR-to-spec cross-reference to verify-merge.md Step 1

- [ ] 1.5.1 After branch reachability check, add a PR-to-spec cross-reference step:
  ```
  # Cross-reference PR changed files against spec affected files
  pr_files = github_pull_request_read(method="get_files", owner=owner, repo=repo, pullNumber=N)
  spec_issue = github_issue_read(method="get", owner=owner, repo=repo, issue_number=<spec_issue>)
  # Extract affected files from spec body
  spec_files = extract_affected_files(spec_issue["body"])
  # Verify PR files intersect with spec files
  if not set(pr_files) & set(spec_files):
      report = f"PR #{pullNumber} changed files do not intersect with spec affected files. Possible incorrect PR-to-issue mapping."
      return report
  ```
- [ ] 1.5.2 **Verify:** Sub-agent reads verify-merge.md — confirms PR-to-spec cross-reference step exists
- [ ] 1.5.3 **SC-5 verification:** Semantic check — sub-agent reads verify-merge.md and confirms the cross-reference step is present and functional

### Step 1.6: Add merge commit verification to cleanup.md Live Verification Table

- [ ] 1.6.1 Read `skills/git-workflow-cleanup/tasks/cleanup.md` — locate the Live Verification Table (Step 1 area)
- [ ] 1.6.2 Add a row for merge commit verification:
  ```
  | Merge commit verified | `git log --oneline "$DEFAULT_BRANCH" | grep <merge_sha>` | Must return match |
  ```
- [ ] 1.6.3 Add a PR-to-spec cross-reference step to cleanup.md Step 1 procedure (after verify-merge dispatch)
- [ ] 1.6.4 **Verify:** grep for merge commit verification row in cleanup.md — must match
- [ ] 1.6.5 **SC-6 verification:** `grep "Merge commit verified\|git log.*DEFAULT_BRANCH" skills/git-workflow-cleanup/tasks/cleanup.md` returns non-empty

### Step 1.7: Create behavioral test for git log merge commit verification

- [ ] 1.7.1 Read existing behavioral tests in `tests-v2/behaviors/` for pattern reference
- [ ] 1.7.2 Create `tests-v2/behaviors/cleanup-verify-merge-git-log.sh`:
  - Test setup: create test repo, create PR, merge it
  - Prompt: "pr merged" or equivalent
  - Assert: stderr shows `git log --oneline "$DEFAULT_BRANCH"` or equivalent git log command on trunk
  - Use `assert_stderr_pattern_present` for the git log pattern
- [ ] 1.7.3 **Verify:** Run `bash .opencode/tests-v2/behaviors/cleanup-verify-merge-git-log.sh` — must PASS
- [ ] 1.7.4 **SC-7 verification:** Behavioral test passes with `opencode run` showing git log on trunk

### Step 1.8: Create behavioral test for git branch --merged verification

- [ ] 1.8.1 Create `tests-v2/behaviors/cleanup-verify-merge-branch-merged.sh`:
  - Test setup: create test repo, create PR, merge it
  - Prompt: "pr merged" or equivalent
  - Assert: stderr shows `git branch --merged "$DEFAULT_BRANCH"` or equivalent
  - Use `assert_stderr_pattern_present` for the git branch --merged pattern
- [ ] 1.8.2 **Verify:** Run `bash .opencode/tests-v2/behaviors/cleanup-verify-merge-branch-merged.sh` — must PASS
- [ ] 1.8.3 **SC-8 verification:** Behavioral test passes with `opencode run` showing `git branch --merged`

### Step 1.9: Create behavioral test for PR-to-spec cross-reference

- [ ] 1.9.1 Create `tests-v2/behaviors/cleanup-verify-merge-pr-spec-crossref.sh`:
  - Test setup: create test repo with a spec issue, create PR that modifies spec-affected files, merge it
  - Prompt: "pr merged" or equivalent
  - Assert: stderr shows PR file read + spec file read (e.g., `get_files` and `get` on the spec issue)
  - Use `assert_stderr_pattern_present` for both patterns
- [ ] 1.9.2 **Verify:** Run `bash .opencode/tests-v2/behaviors/cleanup-verify-merge-pr-spec-crossref.sh` — must PASS
- [ ] 1.9.3 **SC-9 verification:** Behavioral test passes with `opencode run` showing PR file read + spec file read

### Step 1.10: Run content-verification tests

- [ ] 1.10.1 Run `bash .opencode/tests-v2/test-enforcement.sh --changed` to verify content-verification tests pass
- [ ] 1.10.2 If any test fails: diagnose, remediate, re-run
- [ ] 1.10.3 **Verify:** All content-verification tests PASS

### Step 1.11: Commit all changes

- [ ] 1.11.1 `git status` — verify only intended files are modified
- [ ] 1.11.2 `git diff --stat` — review changes
- [ ] 1.11.3 `git add` all changed files
- [ ] 1.11.4 `git commit -m "fix: add git-state merge verification to cleanup workflow

- Add merge_commit_sha to check-pr.md mergeability diagnosis (SC-1)
- Fix check-pr.md Step 2.5 git log check with populated SHA (SC-2)
- Add git log merge commit verification to verify-merge.md (SC-3)
- Add git branch --merged reachability check to verify-merge.md (SC-4)
- Add PR-to-spec cross-reference to verify-merge.md (SC-5)
- Add merge commit verification row to cleanup.md Live Verification Table (SC-6)
- Add behavioral tests for git log, branch --merged, and PR-to-spec crossref (SC-7, SC-8, SC-9)

Co-authored with AI: OpenCode (deepseek-v4-flash)"`
- [ ] 1.11.5 **Verify:** `git log --oneline -1` shows the commit

### Step 1.12: Phase completion verification

- [ ] 1.12.1 Verify all SCs 1-9 are satisfied:
  - SC-1: grep for `merge_commit_sha` in check-pr.md
  - SC-2: grep for `git log.*merge_commit_sha` in check-pr.md
  - SC-3: grep for `git log.*merge_commit_sha` in verify-merge.md
  - SC-4: grep for `git branch --merged` in verify-merge.md
  - SC-5: semantic check — sub-agent reads verify-merge.md
  - SC-6: grep for merge commit verification row in cleanup.md
  - SC-7: behavioral test passes
  - SC-8: behavioral test passes
  - SC-9: behavioral test passes
- [ ] 1.12.2 Verify all exit criteria C1-C10 are met
- [ ] 1.12.3 Report phase completion with summary

## Phase Completion Block

**Phase 1 complete when:** All 9 SCs verified PASS, all changes committed to `feature/1996-1999-trunk-tip-cleanup-verify`.

**Concern transition:** This is the only phase — no concern transition needed. Proceed to post-implementation skills (verification-before-completion, finishing-a-development-branch, review-prep).
