# Task: cleanup

## Purpose

Delete merged branches after PR merge, clean stale references, and verify repository state is ready for next work session.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

## Operating Protocol

- [ ] 1. **After PR merge:** Run when human confirms "PR merged" or similar
- [ ] 2. **Automatic detection:** Can also run when invoked to check for merged branches
- [ ] 3. **Mandatory cleanup:** ALL merged branches must be deleted (local and remote)

## Entry Criteria

- Human confirms "PR merged" or similar
- OR skill invoked with cleanup detection enabled

## Exit Criteria

- Local merged branch deleted
- Remote merged branch deleted (if applicable)
- Stale remote references pruned
- Working tree clean
- Submodule dev restored via sub-agent task()

## Procedure

### Step 0: Detect Submodules and Build Routing Context

Before any cleanup operations, detect and build routing context for submodules using filesystem glob scan.

- [ ] 1. **Glob scan for git repos at project root:**

   ```bash
   REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')
   ```

   Filter out `.` (self) and collect only submodule paths (non-root repos):
   ```bash
   SUBMODULE_PATHS=""
   for RP in $REPO_PATHS; do
       [ "$RP" = "." ] && continue
       SUBMODULE_PATHS="$SUBMODULE_PATHS $RP"
   done
   ```

   If `SUBMODULE_PATHS` is empty: no submodules detected, proceed normally (no submodule routing context).

- [ ] 2. **Resolve owner/repo for each discovered repo:**

   For each repo path in `SUBMODULE_PATHS`:
   ```bash
   REMOTE_URL=$(git -C "$RP" remote get-url origin 2>/dev/null || echo "")
   # Parse owner/repo from SSH (git@github.com:owner/repo.git) or HTTPS (https://github.com/owner/repo.git)
   # sed extraction pattern for SSH: s|.*:\(.*\)/\(.*\)\.git|\1 \2|
   # sed extraction pattern for HTTPS: s|.*/[^/]*/\([^/]*\)/\([^/]*\)\.git|\1 \2|
   ```

- [ ] 3. **Build routing context dictionary:**

   ```yaml
   submodule_paths:
     <path1>:
       owner: <resolved_owner>
       repo: <resolved_repo>
       platform: github
     <path2>:
       owner: <resolved_owner>
       repo: <resolved_repo>
       platform: github
   ```

- [ ] 4. **Pass routing context to sub-tasks:**

   - Include `submodule_paths` in task context for `issue-closure` and `branch-cleanup` sub-tasks
   - Each sub-task uses the routing context to route API calls to the correct owner/repo for files under a submodule path

- [ ] 5. **If no submodules detected** (glob scan returned only root repo): proceed normally, no routing context needed.

### Step 1: Verify PR Merge and Run Gates

**Route to:** `cleanup/verify-merge`

Verifies PR merge via GitHub API, runs SC-verification gate, phase-completion gate, and rebase pending PRs.


### Step 1.5: Post-Merge Release Detection

If the merged PR was a release PR (detected via branch name pattern `release/` or PR label), dispatch release-promoter tasks:

- [ ] 1. Check if merged branch name starts with `release/` or PR has a `release` label
- [ ] 2. If release PR detected: dispatch `release-promoter --task tag` then `release-promoter --task create-release`
- [ ] 3. If not a release PR: proceed normally (no release promotion)

### Step 2: Hierarchical Issue Closure

**Route to:** `cleanup/issue-closure`

Collects all referenced issues from PR body, classifies each (plan/spec/other), closes hierarchically, and runs transitive graph reconciliation.

### Step 2.5: Post-Merge Issue-Closure Sweep

**Route to:** `cleanup/issue-closure-sweep`

Scans all open repository issues, checks each for linked merged PRs, and closes qualified candidates. Parent issues with open children are skipped.

### Step 3: Branch Cleanup and Sync

**Route to:** `cleanup/branch-cleanup`

Switches to dev, syncs with remote, removes feature worktree, deletes merged branches, tasks sub-agent via task() for each submodule, verifies clean state.

### Step 4: Post-Cleanup Dev-Tip Verification

Run AFTER all sub-tasks (verify-merge, issue-closure, branch-cleanup) AND all submodule iterations are complete. This is the final verification gate — nothing runs after it.

- [ ] 1. **Determine the parent repo path:**

   - Run `git rev-parse --show-superproject-working-tree 2>/dev/null` to detect parent repo
   - If output is non-empty: this is the parent repo path (we are inside a submodule)
   - If output is empty: we are in the parent repo (standalone or no superproject)

- [ ] 2. **Build repo list for verification:**

   ```
   repos_to_check:
     - repo_name: <parent or current repo name>
       repo_path: <parent_path | current_toplevel>
     - repo_name: <submodule_1_name>
       repo_path: <parent_path>/<submodule_1_path>
     - repo_name: <submodule_2_name>
       repo_path: <parent_path>/<submodule_2_path>
     ...
   ```

   - Include the parent (or current) repo at index 0
   - Append each submodule path from `submodule_paths` (resolved relative to parent repo)

- [ ] 3. **For each repo in the list:**

   a. Get local dev HEAD:
      ```bash
      git -C "$REPO_PATH" rev-parse "$DEFAULT_BRANCH"
      ```

   b. Get remote dev HEAD:
      ```bash
      git -C "$REPO_PATH" rev-parse origin/"$DEFAULT_BRANCH"
      ```

   c. Collect evidence artifact:
      ```bash
      git -C "$REPO_PATH" log --oneline -1 "$DEFAULT_BRANCH"
      ```

   d. Verify checked-out branch:
      ```bash
      CURRENT_BRANCH=$(git -C "$REPO_PATH" branch --show-current 2>/dev/null || true)
      if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
          echo "WARNING: $REPO_PATH is on branch '$CURRENT_BRANCH', not '$DEFAULT_BRANCH'"
          echo "Branch mismatch detected — repo is parked on wrong branch"
      fi
      ```

   e. Compare local vs remote:
      - If hashes match → repo is at dev tip
      - If hashes differ → repo has diverged

- [ ] 4. **Report results as a comparison table:**

   ```
   | Repo | Local $DEFAULT_BRANCH HEAD | Remote $DEFAULT_BRANCH HEAD | Status |
   |------|---------------|-----------------|--------|
   | opencode-config | abc1234 | abc1234 | ✅ At tip |
   | .opencode | def5678 | def5678 | ✅ At tip |
   ```

- [ ] 5. **Outcome:**

   - **All repos at dev tip:** Report "All repos at dev tip — ready for next dev cycle"
   - **Any repo diverged:** Report which repo, the local vs remote hashes, and flag for human review:

     ```
     ⚠️ Repo <name> diverged from origin/$DEFAULT_BRANCH:
       Local $DEFAULT_BRANCH:  <hash>
       Origin/$DEFAULT_BRANCH: <hash>
       Action required: Human review — determine whether to push, pull --rebase, or investigate.
     ```

### Step 2.9: Behavioral Evidence Artifact Cleanup

After merger confirmation (Step 2.8), remove behavioral evidence artifacts that were preserved for cross-validation:

```bash
rm -f {project_root}/tmp/{issue-N}/behavioral-evidence-*.{log,json} {project_root}/tmp/behavioral-evidence-*.{log,json}
```

This is the ONLY authorized cleanup point for behavioral evidence artifacts. They MUST NOT be removed during VbC, verification, or audit stages.

## Branch Cleanup After Merge — MANDATORY

**⚠️ CRITICAL: Cleanup is NOT Optional**

After EVERY merged PR, cleanup is MANDATORY — no exceptions.

### ✅ ALWAYS DO — IMMEDIATELY After Merge Confirmation

- [ ] 1. Switch to dev and sync: `git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"`
- [ ] 2. Verify dev sync: `git log --oneline -5` must show the merge commit
- [ ] 3. Delete local feature branch: `git branch -d <branch-name>`
- [ ] 4. Delete remote branch: `git push origin --delete <branch-name>`
- [ ] 5. Verify cleanup: `git branch -vv`
- [ ] 6. Prune remote references: `git fetch --prune && git remote prune origin`

## Branch Status Categories

| Status | Condition | Action |
| -- | -- | -- |
| **Fully merged** | `ahead=0, behind=0` or PR merged | **DELETE IMMEDIATELY** |
| **Superseded** | PR closed/merged, changes incorporated | **DELETE IMMEDIATELY** |
| **Stale** | Behind main by many commits, no PR, no recent work | Safe to delete |
| **Active** | Has unmerged commits, open PR, or active work | **Do NOT delete** |

## Automatic Cleanup Detection

**Entry triggers:** "PR merged" confirmation, "cleanup branches" request, or "check pr" / "check prs" / "check pull request" / "check pull requests" phrases.

### "Check PR" Workflow

- [ ] 1. List all PRs (open and merged) using `github_list_pull_requests`
- [ ] 2. For each merged PR with local branch still existing → activate full cleanup
- [ ] 3. For each open PR → report PR number, title, and status
- [ ] 4. If only open PRs exist → report and HALT

### Safety Checks Before Deletion

| Check | Purpose | Method |
| -- | -- | -- |
| Branch merged | Prevent deleting unmerged work | `git branch --merged "$DEFAULT_BRANCH"` |
| PR status | Confirm merge (not just closed) | GitHub API |
| Not current | Prevent deleting active branch | `git branch --show-current` |
| Not protected | Block main/master deletion | Hardcoded exclusion |
| Clean working tree | Ensure no uncommitted changes | `git status --porcelain` |

**If ANY check fails → SKIP that branch with warning.**

## Sub-Issue Closure Enforcement (CRITICAL)

**⚠️ CRITICAL: Sub-issues are closed by the cleanup task via API, NOT by platform autoclose.**

GitHub autoclose is inert for this repo (PRs merge to the trunk). The cleanup task is the SOLE closure mechanism.

## Issue Closure Timing

**Issues are closed ONLY AFTER the PR is merged — NEVER before.**

| Step | Action | Agent Role |
| -- | -- | -- |
| Implementation complete | Create PR with `Fixes #123` | ✅ Agent creates PR |
| PR created | Report URL, HALT | ✅ Agent waits |
| Human merges PR | Merge happens | 🚫 Human ONLY |
| User confirms merge | Call `github_pull_request_read method=get` | ✅ Agent verifies |
| PR state = merged | Close issue | ✅ Agent closes |

## Parent/Child Issue Closure

**Parent issues MUST NOT be closed while ANY child issues remain open.**

Example:

```
SPEC #100 (parent)
├── Task #101: Phase 1 → PR merges → Close #101 ONLY
├── Task #102: Phase 2 → PR merges → Close #102 ONLY
└── Task #103: Phase 3 → PR merges → Close #103 AND #100
```

**Parent spec issues MUST be closed after ALL child issues are verified complete.** Plans are local artifacts — they are not closed as GitHub Issues.

### Step 2.8: Parent Spec Closure After Sub-Issues

After closing sub-issues (Step 2), check whether the parent spec issue should be closed:

- [ ] 1. **Identify the parent spec issue:**

   - Use `issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues")` on the spec to list all sub-issues <!-- Routes through issue-operations per SPEC #683 -->
   - If the current closure context came from a PR body referencing a spec, use that spec issue number

- [ ] 2. **Verify ALL sub-issues are closed with legitimate completion evidence:**

   - Each sub-issue must have `state == "closed"` and `state_reason == "completed"` (not `"not_planned"` or `"duplicate"` without merged PR evidence)
   - Closed sub-issues with `state_reason == "completed"` must have merged PR evidence (verified via `github_pull_request_read` or `github_search_pull_requests`)
   - If any sub-issue has `state_reason == "not_planned"` without explicit developer justification → flag for review, do NOT auto-close parent

- [ ] 3. **If ALL sub-issues are legitimately closed:**

   - Close the parent spec issue with `issue-operations -> update-issue (github_issue_write(method="update", state="closed", state_reason="completed")` <!-- Routes through issue-operations per SPEC #683 -->
   - Post a verification comment documenting per-sub-issue evidence:
     ```
     All sub-issues verified complete. Closing parent spec.

     Sub-issue closure evidence:
     - #<N1>: Merged PR #<P1> — <brief description>
     - #<N2>: Verified already implemented via autoclose — <brief description>
     - ...

     Parent spec closure is legitimate because all child issues are verified complete.
     ```

- [ ] 4. **If ANY sub-issue is NOT closed or NOT legitimately completed:**

   - Do NOT close the parent spec
   - Report in cleanup output: "Parent spec #\<spec_number> remains open — sub-issue #\<open_num> is not yet complete"

## Closing Summary (Conditional)

Post a closing comment ONLY if it conveys substantive information stakeholders need. Skip for routine closures.

## Archive Workflow

**All specs use GitHub Issues as the authoritative source.**

⚠️ **CRITICAL:** NEVER edit the issue body when closing. Status updates MUST be added as comments.

**Body-Preservation Safeguard:** `len(new_body) >= 0.8 * len(original_body)` — HALT if content erasure detected.

## Live Verification (MANDATORY)

Each verification point requires a tool call for evidence. Assertions without tool-call artifacts are VERIFICATION-GAP findings.

| Check | Tool Call | Expected Result | On Failure |
| -- | -- | -- | -- |
| PR merge status | `github_pull_request_read(method=get, ...)` | `merged_at` is not None | CONFLICTING → HALT |
| Local dev synced | `git log --oneline -1 "$DEFAULT_BRANCH"` equals remote | Hashes match exactly | VERIFICATION-GAP → re-pull |
| Sub-issues closed | `issue-operations -> read-sub-issues (github_issue_read(method=get_sub_issues, ...)` | All state=closed | VERIFICATION-GAP → close or investigate | <!-- Routes through issue-operations per SPEC #683 -->
| All repos at dev tip | `git -C $REPO_PATH rev-parse "$DEFAULT_BRANCH"` vs `rev-parse origin/"$DEFAULT_BRANCH"` for parent + each submodule | Every repo's local dev HEAD matches origin/dev | VERIFICATION-GAP → report which repo diverged, flag for human review |

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `cleanup/verify-merge` | PR merge verification, SC gate, phase gate | ≈750 |
| `cleanup/issue-closure` | Hierarchical issue closure, graph reconciliation | ≈800 |
| `cleanup/branch-cleanup` | Dev sync, worktree removal, branch deletion | ≈700 |

## Context Required

- Related skills: `issue-operations`, `conflict-resolution`
- Related tasks: `rebase-pending`, `check-pr`
