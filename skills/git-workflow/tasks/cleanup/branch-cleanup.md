# Task: cleanup/branch-cleanup

## Purpose

Delete merged branches, clean stale references, remove worktrees, sync dev, and verify clean repository state after PR merge.

## Entry Criteria

- PR merge verified (cleanup/verify-merge completed)
- Issue closure completed (cleanup/issue-closure completed)

## Exit Criteria

- Local merged branch deleted
- Remote merged branch deleted (if applicable)
- Stale remote references pruned
- Dev branch synced with remote (verified via hash comparison)
- Submodule on `dev` branch (not detached HEAD)
- Submodule pointer matches submodule dev HEAD (or dependency-sync PR created)
- Working tree clean

## Procedure

### Step 0: Detect and Resolve Stuck Git States (MANDATORY)

**⚠️ CRITICAL: Proceeding without detecting stuck rebase/merge states causes `git checkout dev` to fail or produce confusing output. This step MUST run before Step 1.**

Check for stuck git states that block branch operations:

1. **Check for interactive rebase in progress:**
   ```bash
   test -d .git/rebase-merge && echo "REBASE-MERGE: interactive rebase in progress" || echo "NO-REBASE-MERGE"
   ```

2. **Check for non-interactive rebase in progress:**
   ```bash
   test -d .git/rebase-apply && echo "REBASE-APPLY: non-interactive rebase in progress" || echo "NO-REBASE-APPLY"
   ```

3. **Check for merge in progress:**
   ```bash
   test -f .git/MERGE_HEAD && echo "MERGE: merge in progress" || echo "NO-MERGE"
   ```

4. **Check for cherry-pick/revert in progress:**
   ```bash
   test -f .git/CHERRY_PICK_HEAD && echo "CHERRY-PICK: cherry-pick in progress" || echo "NO-CHERRY-PICK"
   test -f .git/REVERT_HEAD && echo "REVERT: revert in progress" || echo "NO-REVERT"
   ```

5. **If any stuck state is detected:**
   a. **If the branch has already been merged into dev** (PR confirmed merged via GitHub API):
      - **Abort** the stuck operation:
        ```bash
        # Interactive rebase
        git rebase --abort 2>/dev/null || true
        # Non-interactive rebase
        git rebase --abort 2>/dev/null || true
        # Merge
        git merge --abort 2>/dev/null || true
        # Cherry-pick
        git cherry-pick --abort 2>/dev/null || true
        # Revert
        git revert --abort 2>/dev/null || true
        ```
      - The work is already on dev — the rebase is stale and safe to abort
   b. **If the branch has NOT been merged** (no PR or PR not merged):
      - **HALT** and report the stuck state to the developer
      - Do NOT abort — the rebase may contain unmerged work
      - Report: "Stuck [rebase/merge/cherry-pick/revert] detected on branch. This may contain unmerged work. Resolve manually before continuing cleanup."

6. **After resolving stuck state, verify clean working tree:**
   ```bash
   git status --porcelain  # Must be empty or only expected changes
   ```

**Evidence artifact (MANDATORY):** Tool-call output showing detection check results MUST be present before proceeding to Step 1.

### Step 1: Switch to Dev and Sync (Fast-Forward Only)

```bash
git checkout dev
git pull origin dev --ff-only
```

**🚫 CRITICAL: The `--ff-only` flag is MANDATORY.** A plain `git pull origin dev` can silently succeed with a merge commit, hiding divergence issues.

**If `--ff-only` fails (diverged history):**
```bash
# HALT and report. Suggest manual resolution.
# Do NOT proceed with stale codebase
```

**Verify local dev matches the merge commit:**
```bash
git log --oneline -1 origin/dev
git log --oneline -1 dev
```

The two commit hashes MUST match. If they differ, re-pull and verify.

**Worktree context:** If running from a worktree, operate on the main working tree:
```bash
git -C /path/to/main/repo checkout dev && git -C /path/to/main/repo pull origin dev --ff-only
```

### Step 1.5: Dev Sync Verification Gate (MANDATORY — ZERO TOLERANCE)

1. Run: `git checkout dev && git pull origin dev --ff-only`
2. Capture local hash: `git log --oneline -1 dev`
3. Capture remote hash: `git log --oneline -1 origin/dev`
4. Compare hashes — they MUST match exactly
5. If hashes differ → re-pull and verify again (maximum 3 attempts)
6. If still different after 3 attempts → HALT and report

**Evidence artifact (MANDATORY):** Tool-call output showing matching hashes MUST be present before proceeding.

🚫 FORBIDDEN: Proceeding past this gate without matching hash evidence.

### Step 2: Remove Feature Worktree

```bash
SANITIZED=$(echo "<merged-branch-name>" | tr '/' '-')
WT_PATH=".worktrees/${SANITIZED}"

if [ -d ".worktrees" ] && git worktree list | grep -q "$WT_PATH"; then
    git worktree remove "$WT_PATH"
fi
```

### Step 2.5: Check for Active Parallel Worktrees

```bash
REMAINING=$(git worktree list | grep -c ".worktrees/spec-\|.worktrees/feature-")
if [ "$REMAINING" -gt 0 ]; then
    echo "Other feature worktrees still active: $REMAINING remaining"
    echo "Skipping git worktree prune"
else
    git worktree prune
fi
```

In parallel sub-agent mode, other agents may still be working in their worktrees. Only prune when ALL parallel work is confirmed complete.

### Step 3: Content Verification Gate (MANDATORY — ZERO TOLERANCE)

**⚠️ CRITICAL: Declaring a branch deletable without content verification is a CRITICAL GUIDELINE VIOLATION (see `000-critical-rules.md` §Content Verification Before Branch Deletion).**

Before deleting ANY merged branch, verify that all branch content is present on the target branch (dev):

1. **List changed files:** `git diff --stat origin/dev...HEAD` — identify all files changed on the branch vs dev
2. **For each file in the diff:**
   a. If file exists on dev AND content matches: status = `IDENTICAL` — safe to delete
   b. If file exists on dev BUT has newer/different content: `git diff origin/dev...HEAD -- <file>` to compare; if dev version supersedes branch version, status = `SUPERSEDED` — safe to delete with note
   c. If file does NOT exist on dev: status = `UNIQUE` — MUST NOT delete branch, flag for developer review
3. **For tool/script files:** check version indicators (interface signatures, flag patterns, function presence) to determine supersession
4. **Produce content comparison table (MANDATORY evidence artifact):**

| File | Branch Version | Dev Version | Status |
|------|---------------|-------------|--------|
| path/to/file | v4 (old interface) | v5 (new interface) | SUPERSEDED |
| path/to/unique | present | absent | UNIQUE — needs review |
| path/to/identical | match | match | IDENTICAL |

5. **Decision:**
   - If ANY file has `UNIQUE` status: HALT deletion, report unique files to developer, do NOT auto-delete
   - If ALL files have `SUPERSEDED` or `IDENTICAL` status: proceed with deletion

**🚫 FORBIDDEN:**
- Declaring a branch deletable based on PR merge status alone
- Declaring a branch deletable based on branch name pattern matching
- Declaring a branch deletable based on issue closure state
- Declaring a branch deletable based on commit count ahead/behind
- Deleting a branch without producing the content comparison table

**✅ REQUIRED:**
- `git diff --stat` to identify changed files
- Per-file content comparison (IDENTICAL/SUPERSEDED/UNIQUE)
- Content comparison table as evidence artifact before any deletion
- HALT and flag for developer review when UNIQUE content is found

### Step 3.5: Delete Current Merged Branch

```bash
git branch -d <merged-branch-name>
git push origin --delete <merged-branch-name> 2>/dev/null || echo "Remote already deleted"
git fetch --prune
git remote prune origin
```

**Why `git remote prune origin` is mandatory:** Stale remote-tracking references cause confusion and can interfere with new branch creation.

### Step 3.6: Work Branch Cleanup

When the merged branch was a work branch (created by `assemble-work`):

1. Delete individual feature branches that were squash-merged into the work branch
2. Delete the work branch itself
3. Remove individual feature worktrees
4. Remove work state file: `rm .opencode/tmp/work-*.md`
5. Prune remote references

**⚠️ CRITICAL: Never delete a work branch or its feature branches until the work PR is confirmed merged via GitHub API.**

### Step 4: Clean Other Merged Branches

```bash
git branch --merged dev
```

For each merged branch (except main/master/dev): `git branch -d <branch>`

### Step 5: Verify Clean State

```bash
git status --porcelain  # Must be empty
git branch -vv          # Should show minimal branches
```

### Step 5.5: Restore Submodule to Dev Branch (MANDATORY)

**⚠️ CRITICAL: Leaving submodules on detached HEAD after cleanup causes conflicts and lost work. This step MUST run after all branch deletions are complete.**

**Scope boundary:** This step ONLY restores the submodule to its `dev` branch. It does NOT perform any additional cleanup, branch deletion, or maintenance on the submodule beyond the checkout and pull. Discovering additional cleanup opportunities in the submodule does NOT authorize acting on them — report only.

For each submodule (detected via `.gitmodules` or `.git` file in submodule directories):

1. **Switch submodule to dev:**
   ```bash
   cd <submodule-path>
   git checkout dev
   git pull origin dev --ff-only
   cd <parent-repo-root>
   ```

2. **Verify submodule is NOT on detached HEAD:**
   ```bash
   cd <submodule-path>
   git rev-parse --abbrev-ref HEAD  # MUST return "dev", NOT "HEAD"
   cd <parent-repo-root>
   ```

3. **If `dev` branch doesn't exist locally:**
   ```bash
   cd <submodule-path>
   git checkout -b dev origin/dev
   cd <parent-repo-root>
   ```

4. **If checkout fails due to uncommitted changes:**
   ```bash
   cd <submodule-path>
   git stash
   git checkout dev
   git pull origin dev --ff-only
   git stash pop
   cd <parent-repo-root>
   ```

5. **Verify submodule is clean and on dev:**
   ```bash
   cd <submodule-path>
   git status --porcelain  # Check for unexpected changes
   git branch --show-current  # MUST return "dev"
   cd <parent-repo-root>
   ```

6. **Update parent repo submodule reference:**
   ```bash
   git submodule init
   git submodule update
   ```

**Evidence artifact (MANDATORY):** Tool-call output showing `git branch --show-current` returning `dev` for the submodule MUST be present before reporting cleanup complete.

**🚫 FORBIDDEN:**
- Leaving submodule on detached HEAD after cleanup
- Deleting the `dev` branch in the submodule and then trying to checkout `dev`
- Performing additional submodule cleanup beyond dev-restore (branch deletion, stash cleanup, etc.) without explicit developer authorization

### Step 5.6: Submodule Pointer Sync Check (MANDATORY)

**⚠️ CRITICAL: After restoring the submodule to `dev`, the parent repo's submodule reference MUST match the submodule's current dev HEAD. If they don't match, a dependency-sync PR MUST be auto-created. Leaving a mismatched submodule pointer causes detached HEAD on the next `git submodule update`.**

**Scope boundary:** This step ONLY checks and synchronizes the submodule pointer. It does NOT perform additional maintenance, branch deletion, or code changes in the submodule. The step creates a `dep-sync/` branch and PR in the PARENT repo — not in the submodule.

1. **Capture submodule's current dev HEAD:**
   ```bash
   cd <submodule-path>
   SUBMODULE_DEV_SHA=$(git rev-parse HEAD)
   cd <parent-repo-root>
   ```

2. **Capture parent repo's recorded submodule pointer:**
   ```bash
   PARENT_POINTER_SHA=$(git ls-tree HEAD -- <submodule-path> | awk '{print $3}')
   ```

3. **Compare the two SHAs:**
   - If `SUBMODULE_DEV_SHA == PARENT_POINTER_SHA`: Pointers match. No action needed. Report: "Submodule pointer is current (<sha-short>). No sync required."
   - If `SUBMODULE_DEV_SHA != PARENT_POINTER_SHA`: Pointers differ. Proceed to Step 5.6.4 to create a dependency-sync PR.

4. **Create dependency-sync PR (when pointers differ):**

   **⚠️ This sub-step runs in a CLEAN SUB-AGENT with MINIMAL context. The sub-agent receives ONLY:**
   - `submodule_path`, `old_sha`, `new_sha`, `github.owner`, `github.repo`, `dev.name`, `dev.email`
   - The sub-agent MUST NOT receive implementation context, cleanup history, or agent memory.

   a. **Create tracking issue:**
      ```python
      issue = github_issue_write(
          method="create",
          owner=<github.owner>,
          repo=<github.repo>,
          title="chore: sync .opencode submodule to latest dev",
          body="""## Submodule Pointer Drift

      After cleanup, the `.opencode` submodule pointer in the parent repo drifted from the submodule's dev HEAD.

      | Field | Value |
      |-------|-------|
      | Submodule path | .opencode |
      | Old pointer | <old_sha_short> |
      | New pointer (dev HEAD) | <new_sha_short> |
      | Commits behind | <N> |

      Auto-created by cleanup task to prevent detached HEAD on next `git submodule update`.

      Co-authored with AI: <AgentName> (<ModelId>)"""
      )
      issue_number = extract from response
      ```

   b. **Create feature branch from dev:**
      ```bash
      git checkout dev
      git checkout -b dep-sync/<issue_number>
      ```

   c. **Stage and commit submodule pointer update:**
      ```bash
      git add <submodule-path>
      git commit -m "dep-sync(#<issue_number>): sync .opencode submodule to latest dev

      - .opencode: <old_sha_short>..<new_sha_short> (<N> commits)

      Fixes #<issue_number>"
      ```

   d. **Push and create PR:**
      ```bash
      git push -u origin dep-sync/<issue_number>
      ```

      ```python
      pr = github_create_pull_request(
          owner=<github.owner>,
          repo=<github.repo>,
          title="chore: sync .opencode submodule to latest dev",
          head=f"dep-sync/{issue_number}",
          base="dev",
          body=f"""## Summary

      Auto-created by cleanup task to sync `.opencode` submodule pointer to its dev HEAD, preventing detached HEAD on next checkout.

      **Outcome:** `.opencode` submodule pointer updated from `{old_sha_short}` to `{new_sha_short}`

      Fixes #{issue_number}

      Co-authored with AI: <AgentName> (<ModelId>)"""
      )
      pr_url = extract html_url from response
      ```

   e. **Report in cleanup output:**
      ```
      Submodule pointer drift detected. Dependency-sync PR auto-created: <pr_url>
      ```

5. **Evidence artifact (MANDATORY):**
   - If pointers match: Tool-call output showing equal SHAs
   - If pointers differ: PR URL extracted from `github_create_pull_request` response

**🚫 FORBIDDEN:**
- Leaving a mismatched submodule pointer after cleanup without creating a sync PR
- Performing code changes in the submodule as part of this sync
- Skipping the clean sub-agent dispatch for PR creation
- Combining this sync with other cleanup actions (branch deletion, issue closure)

**✅ REQUIRED:**
- Run `git submodule update --remote` to pull the latest dev tip before comparing SHAs
- Verify sub-agent receives ONLY minimal dispatch context
- Extract PR URL from `github_create_pull_request` response `html_url` field
- Report PR URL in cleanup output

### Step 6: Succinct Confirmation

**The `cleanup` task is THE END of the PR workflow. It MUST produce a one-line succinct confirmation and then HALT.**

```
PR #<number> merged. Branch `<branch-name>` deleted. Cleanup complete.
```

**⚠️ CRITICAL: Do NOT re-report PR details or issue lists. The PR was already reported at creation time.**

### Final HALT (CRITICAL)

After cleanup, the agent MUST HALT. No prompting, no questions, no next steps.

| Action | Status |
| -- | -- |
| Close issues | ✅ Done |
| Delete branches | ✅ Done |
| Post final summary | ✅ Done |
| Ask "What's next?" | 🚫 NEVER |

## Context Required

- Related tasks: `cleanup/verify-merge`, `cleanup/issue-closure`
- Related guidelines: `000-critical-rules.md` (branch deletion rules)