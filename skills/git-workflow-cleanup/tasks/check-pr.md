# Task: check-pr

## ⚠️ Enforcement Gate

**This task is MANDATORY when the user says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)". The agent MUST NOT respond with a raw PR listing without routing through this task's phases. Bypassing this gate to list PRs directly is a CRITICAL GUIDELINE VIOLATION — Load [Listing Merged PRs Without Invoking Cleanup](guidelines/000-critical-rules.md).**

## Purpose

Execute a 6-phase serial chain to scan for merged PRs, verify each merge, close linked issues, clean up branches (submodules before parent), reconcile submodules, and park the repo in a clean final state.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

## Entry Criteria

- User says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)"
- OR cleanup task invoked with merged PR detection enabled

## Exit Criteria

- All merged PRs identified and verified
- Linked issues closed depth-first (sub-repos first, then parent)
- Submodule branches cleaned up (trunk switch, branch delete, tag delete, prune)
- Parent branches cleaned up (trunk switch, branch delete, checkpoint-tag delete, prune)
- All repos iterated depth-first with branch-aware parking
- Working tree clean, repo parked on appropriate branch

## Phase 1: Scan for Merged PRs

- [ ] Build repo list from session-init values plus filesystem glob scan: `ls -d .git/ */.git/ */.git/`
- [ ] For each repo, query merged PRs via the platform-appropriate API (use `github.platform` from session-init: `github` → `github_list_pull_requests` filtered by `merged_at`, `gitbucket` → `gb pr list` filtered by `merged`, `local` → no PRs exist, skip)
- [ ] Report all merged PRs found with PR number, title, branch, and merged_at timestamp
- [ ] If no merged PRs found: report and HALT

## Phase 2: Verify Each Merge — Full Mergeability Diagnosis

For each merged PR, perform a full mergeability diagnosis using the 6-field check (SC-1 through SC-5). This replaces the simple `state`/`merged`-only check with the same mergeability logic used in `pr-creation/create-pr.md` Step 7.2.

**Data Sources:**

| Field | Source | Purpose |
|-------|--------|---------|
| `mergeable` | PR API response | Mergeability status (`true`, `false`, or `null`) |
| `base.sha` | PR API response | Base branch SHA at PR creation time |
| `updated_at` | PR API response | Last update timestamp |
| `created_at` | PR API response | Creation timestamp |
| `state` | PR API response | PR state (`open`, `closed`) |
| `merged` | PR API response | Whether PR was already merged |
| `merge_commit_sha` | PR API response | Merge commit SHA for git log verification |

### Step 2.1: Read Mergeability Fields

- [ ] For each merged PR, read all 7 fields via the platform-appropriate API (use `github.platform` from session-init: `github` → `github_pull_request_read(method=get, pullNumber=<N>)` for `mergeable`, `base.sha`, `updated_at`, `created_at`, `state`, `merged`, `merge_commit_sha`; `gitbucket` → `gb pr view <N>` for equivalent fields; `local` → N/A)

### Step 2.2: Diagnose `mergeable` Status

- [ ] If `mergeable` is `null` (mergeability computation not yet complete):
  - **Stale base check:** Compare `base.sha` against the current remote base tip (`git rev-parse origin/<target>`). If they differ, the base has advanced since PR creation — proceed to Step 2.3.
  - **Conflict check:** If `base.sha` matches remote base tip but `mergeable` is still `null`, the PR may have a conflict that GitHub hasn't computed yet — proceed to Step 2.4.
  - **Pending computation:** If neither stale base nor conflict is confirmed, the mergeability computation is still pending — proceed to Step 2.4.
- [ ] If `mergeable` is `false`: Report that the PR has a merge conflict. Include the conflicting files from `git diff origin/<target>...HEAD --name-only --diff-filter=U`.
- [ ] If `mergeable` is `true`: Confirm mergeability and proceed.

### Step 2.3: Rebase on Stale Base

- [ ] If `base.sha` differs from the current remote base tip:
  ```bash
  git fetch origin <target>
  git rebase origin/<target>
  ```
- [ ] After rebase, force-push the updated branch:
  ```bash
  git push --force-with-lease origin HEAD:<branch_name>
  ```

### Step 2.4: Trigger Mergeability Computation

- [ ] If `updated_at` equals `created_at` (PR has never been updated since creation), the mergeability computation may not have triggered. Trigger it by:
  1. **Comment method:** Add a comment to the PR via `github_add_issue_comment` with a no-op message (e.g., "Triggering mergeability check").
  2. **No-op push method (fallback):** If commenting is insufficient, push a no-op change: `git commit --allow-empty -m "trigger mergeability" && git push origin HEAD:<branch_name>`.
- [ ] After triggering, wait 15 seconds and re-read the PR's `mergeable` field via `github_pull_request_read(method=get, pullNumber=<N>)`. If still `null`, report that mergeability computation is pending.

### Step 2.5: Report Mergeability Diagnosis

- [ ] **Never report "PR is open" as terminal status.** Always include mergeability diagnosis in the output:
  ```
  **Mergeability Diagnosis:**
  - State: open|closed
  - Merged: true|false
  - Mergeable: true|false|null
  - Base SHA match: yes|no (rebased if stale)
  - Computation triggered: yes|no (if updated_at == created_at)
  - Action required: <none|rebase needed|conflict resolution|wait for computation>
  ```
- [ ] Verify the merge commit exists in local trunk history: `git log --oneline "$DEFAULT_BRANCH" | grep "$merge_commit_sha"`
- [ ] Report PASS/FAIL per PR with evidence artifact

## Phase 3: Close Linked Issues

- [ ] Search open issues: for each merged PR, query the platform's issue tracker for open issues referencing the PR number or commit SHAs (via PR body, comments, commit messages, or linked PR references)
- [ ] Check sub-issues, siblings, parents, and cross-repo issues for closure eligibility
- [ ] Close depth-first: sub-repos first, children before parents, cross-repo
- [ ] Close silently — no comment churn unless substantively necessary

## Phase 4: Submodule Branch Cleanup

- [ ] Detect submodules via filesystem glob scan: `ls -d .git/ */.git/ */.git/`
- [ ] For each submodule with a feature branch, clean up the merged branch
- [ ] Restore submodules to trunk tip via sub-agent task()
- [ ] Do NOT create dependency-sync PRs — leave submodule pointers dirty

## Phase 5: Parent Branch Cleanup

- [ ] Switch to trunk and sync: `git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH" --ff-only`
- [ ] For each merged branch, verify content exists on trunk via `git diff --stat origin/"$DEFAULT_BRANCH"...<branch>` — produce content comparison table
- [ ] Delete local merged branch: `git branch -d <branch>`
- [ ] Delete remote branch: `git push origin --delete <branch>`
- [ ] Preserve hash-permanence tags — do NOT delete
- [ ] Delete checkpoint tags only: `git tag -d <parent>/checkpoint/*` and `git push origin --delete <parent>/checkpoint/*`
- [ ] Prune remote references: `git fetch --prune && git remote prune origin`

## Phase 6: Depth-First Final State

- [ ] Iterate ALL discovered repos depth-first: submodule tips, then parent tip
- [ ] Branch-aware parking per current branch type:
  - On `feature/*`, `fix/*`, `spec/*` → switch to trunk tip
  - Already on $DEFAULT_BRANCH → pull latest, stay on $DEFAULT_BRANCH
  - Already on trunk → pull latest, stay on trunk
  - On non-standard branch → pull latest on current branch, do NOT switch
- [ ] Submodule pointers in the parent repo are dirty by design. They are restored during the next pre-work cycle. Do NOT commit, reset, or otherwise correct them.
- [ ] Verify clean working tree: `git status --porcelain` must be empty
- [ ] Report final state summary and HALT
