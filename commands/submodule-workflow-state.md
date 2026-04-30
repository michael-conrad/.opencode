---
name: submodule-workflow-state
description: Discover submodule workflow state for PR/merge/cleanup skills. Detects submodules via .gitmodules, resolves remote owner/repo/URL, classifies PR combination, and queries submodule PR/branch/issue state. Consumed by git-workflow cleanup, check-pr, pr-creation-workflow, review-prep, finishing-a-development-branch, and approval-gate skills.
type: sub-agent-command
provenance: AI-generated
compatibility: opencode
---

# Command: submodule-workflow-state

## Purpose

Discover submodule workflow state for PR/merge/cleanup skills. This command provides a unified mechanism for all workflow skills to query submodule PR, branch, and issue state without duplicating detection logic across 6+ skill task files.

## Operating Protocol

1. **Invoked by workflow skills:** This command is invoked by `cleanup/verify-merge`, `cleanup/branch-cleanup`, `cleanup/issue-closure`, `check-pr`, `pr-creation-workflow`, `review-prep`, and `finishing-a-development-branch`
2. **Read-only discovery:** This command NEVER modifies any git or GitHub state
3. **Sub-agent dispatch:** The main agent dispatches this command; it runs as a sub-agent command

## Entry Criteria

- `.gitmodules` exists in the repository, OR the calling skill needs to confirm no submodules exist
- The calling skill needs PR/branch/issue state for submodule repos

## Exit Criteria

- Structured output block containing submodule workflow state
- Per-submodule PR status, branch status, issue status, and combination classification
- If no submodules exist: `submodule_workflow.has_submodules: false`

## Procedure

### Step 1: Detect Submodules

```bash
# Check if .gitmodules exists
test -f .gitmodules && echo "HAS_SUBMODULES" || echo "NO_SUBMODULES"
```

If `NO_SUBMODULES`, return immediately with:

```yaml
submodule_workflow:
  has_submodules: false
  submodules: []
```

If `HAS_SUBMODULES`, proceed to Step 2.

### Step 2: Resolve Submodule Remotes

For each submodule path from `.gitmodules`:

```bash
# Get submodule paths
git config --file .gitmodules --get-regexp path | awk '{print $2}'
```

For each path, resolve the remote:

```bash
cd <submodule-path>
REMOTE_URL=$(git remote get-url origin)
BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
cd <parent-repo-root>
```

Parse `REMOTE_URL` to extract `owner` and `repo`:

- SSH format: `git@github.com:<owner>/<repo>.git` → owner=`<owner>`, repo=`<repo>`
- HTTPS format: `https://github.com/<owner>/<repo>.git` → owner=`<owner>`, repo=`<repo>`
- Strip trailing `.git` from repo name

Also read submodule status:

```bash
git submodule status
```

### Step 3: Classify PR Combination

For each submodule, classify the PR combination by checking if the parent repo and/or submodule repo have open PRs on the current branch pattern.

Determine the current feature branch name in the parent repo:

```bash
PARENT_BRANCH=$(git branch --show-current)
```

For each submodule, search for open PRs:

```python
# Search for PRs in the submodule repo
github_search_pull_requests(
    query=f"head:{branch_pattern} repo:{submodule_owner}/{submodule_repo}"
)
```

Also check for open PRs in the parent repo:

```python
github_search_pull_requests(
    query=f"head:{PARENT_BRANCH} repo:{github.owner}/{github.repo}"
)
```

Classify each submodule's combination:

| Condition | `combination_class` |
|-----------|---------------------|
| Parent has open PR AND submodule has open PR | `main_and_sub` |
| Parent has open PR, submodule has NO open PR | `main_only` |
| Parent has NO open PR, submodule has open PR | `sub_only` |

If no PRs exist in either repo (pre-PR state), default to `main_only` since the parent will create a PR when ready.

### Step 4: Query Submodule PR State

For each submodule with an open PR:

```python
pr = github_pull_request_read(
    method="get",
    owner=submodule_owner,
    repo=submodule_repo,
    pullNumber=pr_number
)
```

Extract:
- `has_pr`: boolean
- `pr_number`: int or null
- `pr_merged`: boolean (check `merged_at` is not None)
- `pr_url`: string (from `html_url`)

### Step 5: Query Submodule Branch State

For each submodule, check if a matching feature branch exists:

```bash
cd <submodule-path>
# Check for a branch matching the parent's feature branch name pattern
git branch --list "*${PARENT_BRANCH}*" 2>/dev/null
# Also check current branch
git branch --show-current
cd <parent-repo-root>
```

Extract:
- `has_matching_branch`: boolean
- `branch_name`: string or null

### Step 6: Query Submodule Issue State

For each submodule, search for related open issues:

```python
issues = github_search_issues(
    query=f"repo:{submodule_owner}/{submodule_repo} is:issue is:open {branch_pattern}"
)
```

Extract:
- `has_related_issue`: boolean
- `issue_number`: int or null
- `issue_open`: boolean
- `issue_url`: string or null

### Step 7: Produce Structured Output

Return the complete submodule workflow state:

```yaml
submodule_workflow:
  has_submodules: true
  parent_branch: "<parent-branch-name>"
  parent_has_pr: true|false
  parent_pr_number: <int>|null
  parent_pr_url: "<url>"|null
  submodules:
    - path: "<submodule-path>"
      owner: "<submodule-owner>"
      repo: "<submodule-repo>"
      combination_class: "main_and_sub"|"main_only"|"sub_only"
      pr_state:
        has_pr: true|false
        pr_number: <int>|null
        pr_merged: true|false
        pr_url: "<url>"|null
      branch_state:
        has_matching_branch: true|false
        branch_name: "<branch-name>"|null
      issue_state:
        has_related_issue: true|false
        issue_number: <int>|null
        issue_open: true|false
        issue_url: "<url>"|null
```

## Consuming Skills

The following skills consume this command's output:

| Skill | Task | What It Consumes |
|-------|------|------------------|
| `git-workflow` | `cleanup/verify-merge` | `pr_state.pr_merged` for `main_and_sub` and `sub_only` combinations |
| `git-workflow` | `cleanup/branch-cleanup` | `branch_state` for submodule branch content verification |
| `git-workflow` | `cleanup/issue-closure` | `issue_state` for routing issue closure to `owner/repo` |
| `git-workflow` | `check-pr` | `pr_state` and `branch_state` for submodule PR cleanup |
| `pr-creation-workflow` | PR body construction | `pr_state.has_pr` and `combination_class` for PR body and routing |
| `git-workflow` | `review-prep` | `branch_state.has_matching_branch` for push verification |
| `finishing-a-development-branch` | `checklist` | All submodule state for additional checklist items |

## CRITICAL: Read-Only Discovery

This command NEVER:
- Creates, updates, or deletes any git or GitHub resource
- Modifies submodule state (checkout, pull, push)
- Creates PRs, issues, or branches
- Performs any write operation

It is a pure discovery/read command that produces structured output for consuming skills to act upon.

## Context Required

- `github.owner`, `github.repo`: From session init (parent repo)
- `github.platform`: From session init (for API routing)
- Branch context: Current branch name (from `git branch --show-current`)
- `.gitmodules` file: For submodule path enumeration