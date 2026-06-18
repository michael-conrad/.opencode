# Task: check-pr

## ⚠️ Enforcement Gate

**This task is MANDATORY when the user says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)". The agent MUST NOT respond with a raw PR listing without routing through this task's phases. Bypassing this gate to list PRs directly is a CRITICAL GUIDELINE VIOLATION — see `000-critical-rules.md` §"Listing Merged PRs Without Invoking Cleanup".**

## Purpose

Execute a 6-phase serial chain to scan for merged PRs, verify each merge, close linked issues, clean up branches (submodules before parent), reconcile submodules, and park the repo in a clean final state.

## Entry Criteria

- User says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)"
- OR cleanup task invoked with merged PR detection enabled

## Exit Criteria

- All merged PRs identified and verified
- Linked issues closed depth-first (sub-repos first, then parent)
- Submodule branches cleaned up (dev switch, branch delete, tag delete, prune)
- Parent branches cleaned up (dev switch, branch delete, checkpoint-tag delete, prune)
- All repos iterated depth-first with branch-aware parking
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

## Phase 3: Close Linked Issues

**RULE:** Every issue reference MUST be live-verified before closure. Metadata (PR body text, commit messages, artifact content) is NOT evidence of completion — only live API state is. Closing an issue based on PR body text without live-verification IS closing on metadata alone — metadata is not evidence.

**RULE:** An issue that is not 100% completed but appears it should have been MUST be reported to the developer, not closed.

**RULE:** Supersession check searches for issues that the candidate supersedes, NOT issues that supersede the candidate.

### Step 3.1: Extract Issue References from PR Body

- [ ] For each merged PR, read the PR body via `github_pull_request_read(method=get)` and extract ALL `#N` references
- [ ] Do NOT assume `Fixes`/`Closes`/`Implements` prefixes — any `#N` in the body is a candidate
- [ ] Collect into a candidate list per PR

### Step 3.2: Extract Issue References from Commit Messages

- [ ] For each merged PR, read all commits via `github_pull_request_read(method=get_commits)`
- [ ] For each commit, extract ALL `#N` references from the commit message
- [ ] Add to the candidate list

### Step 3.3: Extract Issue References from Verification/Audit Artifacts

- [ ] Search `./tmp/`, `./issues/`, and `./*/.issues/` for verification and audit artifacts (YAML files, log files, evidence files) that map success criteria to issue numbers
- [ ] Extract any issue references found
- [ ] Add to the candidate list

### Step 3.4: Deduplicate Candidate List

- [ ] Merge all candidate lists across all merged PRs
- [ ] Deduplicate by issue number — the result is the full set of issues potentially affected by the merged work

### Step 3.5: Live-Verify Each Candidate Issue

- [ ] For each candidate issue, perform a live API call (`github_issue_read(method=get)`) to read: state, body, all comments, labels, sub-issues, parent issue
- [ ] Determine if the issue is truly completed:
  - Issue body or comments indicate completion AND issue is still open → eligible for closure
  - Issue is not 100% completed but appears it should have been (referenced in merged PR body but still open with no pending work) → **alert the developer**, do NOT close
  - Issue is already closed → skip

### Step 3.6: Cross-Cutting Interdependency Scan

- [ ] For each directly referenced issue, find indirectly related issues:
  - **Sub-issues**: Check each sub-issue's state — sub-issues of a completed parent may also be completable
  - **Siblings**: If the issue is a sub-issue of a parent, check sibling sub-issues — siblings from the same plan may also be completable
  - **Parent**: If the issue is a sub-issue and all siblings are complete, the parent may be closable
  - **Shared concern**: Search for other open issues sharing affected files, symbols, or concern boundaries with the merged PR's changes — these may have been implicitly resolved
- [ ] Add any found indirectly-related issues to the candidate list and live-verify per Step 3.5

### Step 3.7: Supersession Check

- [ ] For each candidate issue that appears completed, check if the issue itself supersedes other issues
- [ ] Check issue body and comments for supersession language (e.g., "Supersedes #N", "Replaces #N")
- [ ] For each superseded issue found, add to the candidate list and live-verify per Step 3.5
- [ ] Do NOT check for issues that supersede the candidate — that is a pre-implementation concern, not a cleanup concern

### Step 3.8: Close Eligible Issues Depth-First

- [ ] Close eligible issues in depth-first order: sub-repos first, then parent repo. Children before parents. Cross-repo issues handled per their repo.
- [ ] Close silently — no comment churn unless substantively necessary

## Phase 4: Submodule Branch Cleanup

- [ ] Detect submodules via filesystem glob scan: `ls -d .git/ */.git/ */.git/`
- [ ] For each submodule with a feature branch, clean up the merged branch
- [ ] Restore submodules to dev tip via `submodule-dev-restore` sub-agent task()
- [ ] Do NOT create dependency-sync PRs — leave submodule pointers dirty

## Phase 5: Parent Branch Cleanup

- [ ] Switch to dev and sync: `git checkout dev && git pull origin dev --ff-only`
- [ ] For each merged branch, verify content exists on dev via `git diff --stat origin/dev...<branch>` — produce content comparison table
- [ ] Delete local merged branch: `git branch -d <branch>`
- [ ] Delete remote branch: `git push origin --delete <branch>`
- [ ] Preserve hash-permanence tags — do NOT delete
- [ ] Delete checkpoint tags only: `git tag -d <parent>/checkpoint/*` and `git push origin --delete <parent>/checkpoint/*`
- [ ] Prune remote references: `git fetch --prune && git remote prune origin`

## Phase 6: Depth-First Final State

- [ ] Iterate ALL discovered repos depth-first: submodule tips, then parent tip
- [ ] Branch-aware parking per current branch type:
  - On `feature/*`, `fix/*`, `spec/*` → switch to dev tip
  - Already on dev → pull latest, stay on dev
  - Already on main → pull latest, stay on main
  - On non-standard branch → pull latest on current branch, do NOT switch
- [ ] Submodule pointers in the parent repo are dirty by design. They are restored during the next pre-work cycle (submodule-tag-prework). Do NOT commit, reset, or otherwise correct them.
- [ ] Verify clean working tree: `git status --porcelain` must be empty
- [ ] Report final state summary and HALT
