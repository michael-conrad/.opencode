# Task: rebase-pending

## Purpose

After a PR merge is verified, automatically rebase all other pending PRs from the same developer onto the updated `dev` branch. Classify conflicts using the conflict-resolution skill's Tier 1-3 system: Tier 1-2 auto-resolve, Tier 3 (intent) conflicts HALT for developer review. Operates in direct-branch context by default; uses temporary worktrees only when needed.

## Operating Protocol

1. **After merge verification:** Run immediately after Step 2 (verify PR merge) in cleanup
2. **Before dev sync:** Must complete before Step 3 (switch to dev and sync)
3. **Sequential processing:** Rebase one PR at a time to avoid branch switching collisions
4. **Force-push after rebase:** Rebased branches must be force-pushed to update remote PRs
5. **Submodule re-sync after rebase:** Always re-sync submodules after rebase to maintain consistency

## Entry Criteria

- PR merge verified via GitHub API (Step 2 of cleanup complete)
- `merged_at` timestamp confirmed on the just-merged PR
- Local dev branch is up to date (`git pull origin dev`)

## Exit Criteria

- All pending PRs rebased onto updated `dev` OR
- Tier 3 conflicts identified and reported to developer with rebase paused
- Summary report generated listing: rebased cleanly, auto-resolved, blocked
- Existing cleanup steps can proceed after rebase-pending completes

## Procedure

### Step 0: Verify PR Merge (Existing Cleanup Step 2)

This task assumes Step 2 (verify PR merge) has already been completed. The merged PR number is available as context.

```python
# Already verified by cleanup Step 2:
merged_pr_number = <PR number from context>
pr_merge_verified = True  # Passed as entry criteria
```

### Step 1: Identify Pending PRs

List all open PRs and identify candidates for rebasing.

```python
# List all open PRs on the repo
open_prs = github_list_pull_requests(
    owner=<github.owner>,
    repo=<github.repo>,
    state="open"
)

# Filter out the just-merged PR
pending_prs = [pr for pr in open_prs if pr["number"] != merged_pr_number]
```

**If no pending PRs:** Skip to Step 6 (proceed to existing cleanup steps).

**Report candidate PRs:**

```
Rebase candidates: #<N1> (<title1>), #<N2> (<title2>), ...
```

### Step 2: Attempt Rebase for Each Pending PR

Process one PR at a time to avoid branch switching collisions.

For each pending PR:

```
a. Fetch latest remote: git fetch origin
b. Switch to the PR branch:
   git checkout <branch-name>
   (If branch doesn't exist locally, create tracking branch: git checkout -b <branch-name> origin/<branch-name>)
c. Rebase onto updated dev:
   git rebase origin/dev
d. Handle outcome:
   - Clean rebase → proceed to Step 4 (submodule re-sync) then Step 5 (force-push)
   - Conflicts → proceed to Step 3 (conflict classification)
```

**Branch switching management:**

```bash
# Switch to the PR branch
git checkout <branch-name>

# After rebase (success or HALT), switch back to dev or next branch
git checkout dev
```

### Step 3: Conflict Classification

When rebase produces conflicts, invoke the conflict-resolution skill's tier system:

**For each conflicting file, classify:**

| Tier | Name | Criteria | Action |
|------|------|----------|--------|
| 1 | **Trivial** | Whitespace, formatting, reordering of unchanged lines | Auto-resolve, silent |
| 2 | **Textual but safe** | Same intent on both sides, just different text | Auto-resolve, note in chat |
| 3 | **Intent conflict** | Different goals, or resolution could alter spec compliance | HALT for developer review |

**Classification rule:** When in doubt, classify UP to the next tier. Tier 2 vs Tier 3 → treat as Tier 3.

**Auto-resolution for Tier 1-2:**

```bash
# After classifying as Tier 1 or Tier 2:
git add <resolved-files>
git rebase --continue
# Then proceed to Step 4 (submodule re-sync)
```

**Tier 2 notification (chat only):**

```
**Conflict Resolution (Tier 2 - Textual):**
- File: <path>
- Reason: <why it's textual but safe>
- Resolution: <which side was accepted>
```

**Tier 3 conflicts:** Proceed to Step 4.

### Step 4: Tier 3 Intent Analysis

When a Tier 3 conflict is detected, perform spec-aware analysis:

```
a. Read the conflicting file content (both sides of the conflict markers)
b. Read the merged PR's issue/spec body:
   github_issue_read(method="get", owner=<github.owner>, repo=<github.repo>, issue_number=<merged_pr_number>)
   (Or locate the spec issue linked from the PR)
c. Read the conflicting PR's issue/spec body:
   github_issue_read(method="get", owner=<github.owner>, repo=<github.repo>, issue_number=<conflicting_pr_number>)
   (Or locate the spec issue linked from the PR)
d. Compare intent:
   - Same intent: Both PRs modify the same file for compatible purposes
     → Auto-resolve (keep both changes), note in chat
   - Different intent: PRs make contradictory changes to the same file/section
     → HALT rebase, report to developer
```

**Intent comparison framework:**

| Scenario | Merged PR Intent | Conflicting PR Intent | Classification |
|----------|-----------------|----------------------|----------------|
| Same file, compatible changes | Add new function | Add different new function | Same intent, auto-resolve |
| Same file, contradictory changes | Delete function X | Modify function X | Different intent, HALT |
| Same file, overlapping changes | Refactor module A | Also refactor module A | Needs analysis, HALT if ambiguous |
| Different files | N/A | N/A | Not Tier 3 (misclassified) |

**Same-intent auto-resolve (Tier 3 → resolved):**

```
**Tier 3 Conflict Resolved (Same Intent):**
- File: <path>
- Merged PR (#N): <spec intent summary>
- Conflicting PR (#M): <spec intent summary>
- Classification: Same intent — both PRs make compatible changes
- Resolution: Kept both changes
```

**Different-intent HALT (Tier 3 → blocked):**

```
⚠️ Intent Conflict Detected (Tier 3)

**File:** <path>
**Merged PR (#N):** <merged PR title> — <spec intent for this file>
**Conflicting PR (#M):** <conflicting PR title> — <spec intent for this file>
**Conflict type:** <description of conflicting goals>

**Agent recommendation:** <summary of why intents differ>

Rebase paused for PR #M. Developer action required:
1. Review the conflict in <file>
2. Resolve manually: git rebase --continue (after editing)
3. Force-push: git push --force-with-lease origin <branch-name>
```

### Step 4: Submodule Re-Sync After Rebase (MANDATORY)

**After every successful rebase, submodules MUST be re-synced to maintain consistency with the updated `dev` base.** This step is non-negotiable — rebasing changes the base commit, which may alter submodule pointers.

```bash
# If .gitmodules exists, re-sync all submodules to dev
test -f .gitmodules && git submodule foreach "git checkout dev && git pull"
```

**Why this is mandatory:** Rebasing onto a different `dev` HEAD may move the submodule pointer to a different commit. Without re-sync:

1. Submodules may point to SHAs that no longer exist or are stale
2. Build may fail due to mismatched submodule state
3. CI may produce different results than the developer's local environment

**Report submodule sync status:**

```
PR #<N> (<title>): Submodules re-synced to dev after rebase.
```

**If `.gitmodules` does not exist:** Skip this step entirely.

### Step 5: Force-Push Rebased Branches

After successful rebase (or after auto-resolving all conflicts), re-sync submodules (Step 4), then force-push:

```bash
git push --force-with-lease origin <branch-name>
```

**Why `--force-with-lease`:** Prevents overwriting changes made by others since the last fetch. Safer than bare `--force`.

**Report force-push:**

```
PR #<N> (<title>): Rebased and force-pushed successfully.
```

### Step 6: Proceed to Existing Cleanup Steps

After all pending PRs are processed (rebased, auto-resolved, or blocked for developer):

1. Switch back to `dev`: `git checkout dev`
2. Report summary to developer
3. Continue with existing cleanup: Step 3 (switch to dev and sync), Step 4+ (delete branch, close issues, etc.)

**Rebase-pending as post-merge step for all open PRs:** This task should be invoked after EVERY confirmed PR merge, not just when convenient. It keeps all pending branches current with the updated `dev`, reducing merge conflicts and integration drift.

**Rebase hygiene for branch switching:** Whenever switching between feature branches (not just during rebase-pending), always rebase against `dev` then sync submodules:

```bash
git checkout <branch-name>
git fetch origin
git rebase origin/dev
test -f .gitmodules && git submodule foreach "git checkout dev && git pull"
```

**If any Tier 3 conflicts blocked a rebase:**

```
⚠️ Rebase Summary — Action Required

**Cleanly rebased:** #<N1>, #<N2>
**Auto-resolved (Tier 1-2):** #<N3> (files: <list>)
**Blocked for developer review (Tier 3):** #<M1> (files: <list>)
  - See Tier 3 conflict details above

**Next steps for blocked PRs:**
1. Resolve conflicts manually in each blocked worktree
2. Continue rebase: git rebase --continue
3. Force-push: git push --force-with-lease origin <branch-name>

Continuing with cleanup for the merged PR...
```

**If all PRs rebased successfully:**

```
Rebase Summary: All <count> pending PRs rebased onto updated dev.
Continuing with cleanup for the merged PR...
```

## Live Verification (MANDATORY)

**🚫 CRITICAL: Each verification point requires a tool call for evidence. Assertions without tool-call artifacts are VERIFICATION-GAP findings. Rebasing without verified branch state is a CRITICAL GUIDELINE VIOLATION.**

### Branch State Verification Before Rebase

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| On correct branch | `git branch --show-current` | PR branch name (not `main`/`dev`) | STRUCTURE-VIOLATION → HALT |
| Working tree clean | `git status --porcelain` | Empty output | VERIFICATION-GAP → stash or commit first |
| Dev is up to date | `git fetch origin && git log --oneline origin/dev -1` | Recent SHA, post-merge | MISSING-ELEMENT → re-fetch |

### Submodule State Verification After Rebase (when `.gitmodules` exists)

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| Submodules on dev | `git submodule foreach "git branch --show-current"` | `dev` for each submodule | MISSING-ELEMENT → re-sync submodules |

### Verification Procedure

**Before each rebase attempt (Step 2), verify branch state:**

```
1. git branch --show-current → EVIDENCE: <branch-name>
2. git status --porcelain → EVIDENCE: "(empty)" for clean tree
3. git fetch origin → EVIDENCE: fetch result
4. git log --oneline origin/dev -1 → EVIDENCE: recent dev SHA
```

**After each rebase (Step 4), verify submodule state (when `.gitmodules` exists):**

```
5. git submodule foreach "git branch --show-current" → EVIDENCE: <branch names>
```

### Finding Classification

| Failure | Problem Class | Classification | Action |
| -- | -- | -- | -- |
| On wrong branch | CONFLICTING | flag-for-review | Switch to correct branch before rebase |
| Dirty working tree | VERIFICATION-GAP | conditional | Stash changes before rebase (`git stash`) |
| Dev SHA is stale | MISSING-ELEMENT | auto-fix | `git fetch origin` to update |
| Submodule not on dev | MISSING-ELEMENT | auto-fix | `git submodule foreach "git checkout dev && git pull"` |
| Rebase conflicts (Tier 1-2) | VERIFICATION-GAP | auto-fix | Auto-resolve, note in chat |
| Rebase conflicts (Tier 3) | CONFLICTING | flag-for-review | HALT for developer review |

**These verifications are MANDATORY before each rebase. Skipping them is a CRITICAL GUIDELINE VIOLATION.**

## Edge Cases

| Scenario | Action |
|----------|--------|
| No pending PRs | Skip rebase-pending entirely, proceed to cleanup |
| PR branch force-push fails (stale remote) | Refetch and retry once, then report |
| Rebase has many Tier 1-2 conflicts | Auto-resolve all, report summary |
| Rebase has even one Tier 3 conflict | HALT that PR's rebase, continue others |
| Developer resolves Tier 3 and continues | Not handled by this task — developer runs `git rebase --continue` and force-pushes manually |
| Branch has been updated by another developer since last fetch | `--force-with-lease` will fail — report and move on |
| Submodule drift after rebase | Mandatory re-sync in Step 4 keeps submodules on dev |

## Integration Points

| Skill | When |
|-------|------|
| `conflict-resolution` | Invoked when rebase produces conflicts (Tier classification) |
| `git-workflow --task cleanup` | Rebase-pending runs between Steps 2 and 3 of cleanup |
| `git-workflow --task review-prep` | May also produce conflicts during pre-PR rebase |

## Cross-References

- Related skills: `conflict-resolution` (conflict classification and resolution)
- Related guidelines: `000-critical-rules.md` → "Critical Violation: Blind Conflict Resolution"