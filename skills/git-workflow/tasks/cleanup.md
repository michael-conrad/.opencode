# Task: cleanup

## Purpose

Delete merged branches after PR merge, clean stale references, and verify repository state is ready for next work session.

## Operating Protocol

1. **After PR merge:** Run when human confirms "PR merged" or similar
2. **Automatic detection:** Can also run when invoked to check for merged branches
3. **Mandatory cleanup:** ALL merged branches must be deleted (local and remote)

## Entry Criteria

- Human confirms "PR merged" or similar
- OR skill invoked with cleanup detection enabled

## Exit Criteria

- Local merged branch deleted
- Remote merged branch deleted (if applicable)
- Stale remote references pruned
- Dev branch synced with remote (verified via hash comparison)
- Submodule on `dev` branch (not detached HEAD)
- Working tree clean

## Scope Boundary (CRITICAL)

**⚠️ CRITICAL: The cleanup task is scoped to the merged PR and its related branches ONLY.**

Discovering additional stale branches, stashes, or worktrees does NOT authorize cleanup beyond the merged PR's scope. The agent MUST NOT:

- Delete branches unrelated to the merged PR
- Perform submodule maintenance beyond dev-restore (checkout dev, pull)
- Create bug reports or fix issues discovered during cleanup
- Implement code changes as a side effect of cleanup

If the agent observes additional cleanup opportunities, it reports them in the completion message but does NOT act on them without explicit developer authorization ("approved" or "go").

**Examples of scope boundary:**

| Trigger | Authorized Scope | NOT Authorized |
|---------|-----------------|----------------|
| "pr merged for #184" | Delete branch for PR #184, sync dev, restore submodule to dev | Delete 14 unrelated stale branches |
| "check prs" → merged PR found | Cleanup for that merged PR only | General repo hygiene on unrelated branches |
| Cleanup finds stuck rebase on merged branch | Abort stale rebase, continue cleanup | Fix unrelated stashes found during cleanup |

## Rebase/Merge State Detection

The `branch-cleanup` subtask checks for stuck rebase, merge, cherry-pick, and revert states before proceeding with branch operations. For merged branches, stale rebase states are aborted. For unmerged branches, the agent HALTs and reports the stuck state.

See `cleanup/branch-cleanup.md` Step 0 for the complete detection and resolution procedure.

## Submodule Dev-Restore

The `branch-cleanup` subtask restores the submodule to the `dev` branch after all branch deletions are complete. This prevents the submodule from being left on a detached HEAD, which causes conflicts and lost work. Submodule git operations are dispatched to a sub-agent — the main agent never performs git operations on submodules inline.

See `cleanup/branch-cleanup.md` Step 5.5 for the complete submodule dev-restore procedure (sub-agent dispatch).

## Procedure

### Step 1: Verify PR Merge and Run Gates

**Route to:** `cleanup/verify-merge`

Verifies PR merge via GitHub API, runs SC-verification gate, phase-completion gate, and rebase pending PRs.

### Step 2: Hierarchical Issue Closure

**Route to:** `cleanup/issue-closure`

Collects all referenced issues from PR body, classifies each (plan/spec/other), closes hierarchically, and runs transitive graph reconciliation.

### Step 3: Branch Cleanup and Sync

**Route to:** `cleanup/branch-cleanup`

Switches to dev, syncs with remote, removes feature worktree, deletes merged branches, verifies clean state.

## Branch Cleanup After Merge — MANDATORY

**⚠️ CRITICAL: Cleanup is NOT Optional**

After EVERY merged PR, cleanup is MANDATORY — no exceptions.

### ✅ ALWAYS DO — IMMEDIATELY After Merge Confirmation

1. Switch to dev and sync: `git checkout dev && git pull origin dev`
2. Verify dev sync: `git log --oneline -5` must show the merge commit
3. Delete local feature branch: `git branch -d <branch-name>`
4. Delete remote branch: `git push origin --delete <branch-name>`
5. Verify cleanup: `git branch -vv`
6. Prune remote references: `git fetch --prune && git remote prune origin`

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

1. List all PRs (open and merged) using `github_list_pull_requests`
2. For each merged PR with local branch still existing → activate full cleanup
3. For each open PR → report PR number, title, and status
4. If only open PRs exist → report and HALT

### Safety Checks Before Deletion

| Check | Purpose | Method |
| -- | -- | -- |
| Branch merged | Prevent deleting unmerged work | `git branch --merged dev` |
| PR status | Confirm merge (not just closed) | GitHub API |
| Not current | Prevent deleting active branch | `git branch --show-current` |
| Not protected | Block main/master deletion | Hardcoded exclusion |
| Clean working tree | Ensure no uncommitted changes | `git status --porcelain` |

**If ANY check fails → SKIP that branch with warning.**

## Sub-Issue Closure Enforcement (CRITICAL)

**⚠️ CRITICAL: Sub-issues are closed by the cleanup task via API, NOT by platform autoclose.**

GitHub autoclose is inert for this repo (PRs merge to `dev`, not `main`). The cleanup task is the SOLE closure mechanism.

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

**Parent issues MUST be closed after ALL child issues are verified complete.** Leaving a parent plan issue open after all sub-issues are closed and verified is a process gap that must be treated as a bug requiring a fix.

Example:
```
Plan #50 (parent)
├── Task #51: Phase 1 → closed, verified complete → OK
├── Task #52: Phase 2 → closed, verified complete → OK
└── ALL children closed → Close #50 with verification comment
```

### Step 2.8: Parent Plan Closure After Sub-Issues

After closing sub-issues (Step 2), check whether the parent plan issue should be closed:

1. **Identify the parent plan issue:**
   - Use `github_issue_read(method="get_sub_issues")` on the plan to list all sub-issues
   - If the current closure context came from a PR body referencing a plan, use that plan issue number

2. **Verify ALL sub-issues are closed with legitimate completion evidence:**
   - Each sub-issue must have `state == "closed"` and `state_reason == "completed"` (not `"not_planned"` or `"duplicate"` without merged PR evidence)
   - Closed sub-issues with `state_reason == "completed"` must have merged PR evidence (verified via `github_pull_request_read` or `github_search_pull_requests`)
   - If any sub-issue has `state_reason == "not_planned"` without explicit developer justification → flag for review, do NOT auto-close parent

3. **If ALL sub-issues are legitimately closed:**
   - Close the parent plan issue with `github_issue_write(method="update", state="closed", state_reason="completed")`
   - Post a verification comment documenting per-sub-issue evidence:
     ```
     All sub-issues verified complete. Closing parent plan.

     Sub-issue closure evidence:
     - #<N1>: Merged PR #<P1> — <brief description>
     - #<N2>: Verified already implemented via autoclose — <brief description>
     - ...

     Parent plan closure is legitimate because all child issues are verified complete.
     ```

4. **If ANY sub-issue is NOT closed or NOT legitimately completed:**
   - Do NOT close the parent plan
   - Report in cleanup output: "Parent plan #<plan_number> remains open — sub-issue #<open_num> is not yet complete"

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
| Local dev synced | `git log --oneline -1 dev` equals remote | Hashes match exactly | VERIFICATION-GAP → re-pull |
| Sub-issues closed | `github_issue_read(method=get_sub_issues, ...)` | All state=closed | VERIFICATION-GAP → close or investigate |

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `cleanup/verify-merge` | PR merge verification, SC gate, phase gate | ≈750 |
| `cleanup/issue-closure` | Hierarchical issue closure, graph reconciliation | ≈800 |
| `cleanup/branch-cleanup` | Dev sync, worktree removal, branch deletion, submodule dev-restore (sub-agent dispatch) | ≈900 |

## Context Required

- Related skills: `issue-operations`, `conflict-resolution`
- Related tasks: `rebase-pending`, `check-pr`