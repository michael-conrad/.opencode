# Task: check-pr

## ⚠️ Enforcement Gate

**This task is MANDATORY when the user says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)". The agent MUST NOT respond with a raw PR listing without routing through this task's phases. Bypassing this gate to list PRs directly is a CRITICAL GUIDELINE VIOLATION — see `000-critical-rules.md` §"Listing Merged PRs Without Invoking Cleanup".**

## Purpose

Execute a 6-phase serial chain to scan for merged PRs, verify each merge, clean up branches, close linked issues, reconcile submodules, and park the repo in a clean final state.

## Entry Criteria

- User says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)"
- OR cleanup task invoked with merged PR detection enabled

## Exit Criteria

- All merged PRs identified and verified
- Merged branches deleted (local and remote)
- Linked issues closed depth-first
- Submodules restored to dev tip
- Working tree clean, repo parked on appropriate branch

## Phase 1: Scan for Merged PRs

- [ ] Build repo list from session-init values plus filesystem glob scan: `ls -d .git/ */.git/ */.git/`
- [ ] For each repo, query merged PRs via the platform-appropriate API (use `github.platform` from session-init: `github` → `github_list_pull_requests` filtered by `merged_at`, `gitbucket` → `gitbucket-api list-pull-requests` filtered by `merged`, `local` → no PRs exist, skip)
- [ ] Report all merged PRs found with PR number, title, branch, and merged_at timestamp
- [ ] If no merged PRs found: report and HALT

## Phase 2: Verify Each Merge

- [ ] For each merged PR, confirm merge state via the platform-appropriate API (use `github.platform` from session-init: `github` → `github_pull_request_read(method=get)` check `merged_at`, `gitbucket` → `gitbucket-api get-pull-request` check `merged`, `local` → N/A)
- [ ] Verify the merge commit exists in local dev history: `git log --oneline dev | grep <merge_sha>`
- [ ] Report PASS/FAIL per PR with evidence artifact

## Phase 3: Clean Up Branches

- [ ] Switch to dev and sync: `git checkout dev && git pull origin dev --ff-only`
- [ ] For each merged branch, verify content exists on dev via `git diff --stat origin/dev...<branch>` — produce content comparison table
- [ ] Delete local merged branch: `git branch -d <branch>`
- [ ] Delete remote branch: `git push origin --delete <branch>`
- [ ] Preserve hash-permanence tags — do NOT delete
- [ ] Delete checkpoint tags only: `git tag -d <parent>/checkpoint/*` and `git push origin --delete <parent>/checkpoint/*`
- [ ] Prune remote references: `git fetch --prune && git remote prune origin`

## Phase 4: Close Linked Issues

- [ ] Search open issues: for each merged PR, query the platform's issue tracker for open issues referencing the PR number or commit SHAs (via PR body, comments, commit messages, or linked PR references)
- [ ] Check sub-issues, siblings, parents, and cross-repo issues for closure eligibility
- [ ] Close depth-first: sub-repos first, children before parents
- [ ] Close silently — no comment churn unless substantively necessary

## Phase 5: Submodule Reconciliation

- [ ] Detect submodules via filesystem glob scan: `ls -d .git/ */.git/ */.git/`
- [ ] For each submodule with a feature branch, clean up the merged branch
- [ ] Restore submodules to dev tip via `submodule-dev-restore` sub-agent task()
- [ ] Do NOT create dependency-sync PRs — leave submodule pointers dirty

## Phase 6: Final State

- [ ] Branch-aware parking per current branch type:
  - On `feature/*`, `fix/*`, `spec/*` → switch to dev tip
  - Already on dev → pull latest, stay on dev
  - Already on main → pull latest, stay on main
  - On non-standard branch → pull latest on current branch, do NOT switch
- [ ] Leave submodule pointers dirty — no corrective action
- [ ] Verify clean working tree: `git status --porcelain` must be empty
- [ ] Report final state summary and HALT
