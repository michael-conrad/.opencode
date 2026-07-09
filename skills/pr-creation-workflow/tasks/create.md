# Task: create — Execute PR Creation

## Purpose

Create a pull request from the current feature branch. Verifies authorization scope, reads VbC table artifacts, and dispatches to `git-workflow --task create-pr` for the actual PR creation.

## Entry Criteria

- [ ] Authorization scope >= `for_pr` (halt_at: pr_created)
- [ ] Feature branch exists and has commits
- [ ] VbC table artifact exists at `{project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md` (if applicable)
- [ ] All SCs verified PASS (pre-pr-gate passed)

## Steps

### Step 1: Verify Authorization Scope

Confirm `halt_at >= pr_created` and `authorization_scope` includes PR creation. If scope is insufficient, return BLOCKED.

### Step 2: Read VbC Table Artifact

If a VbC table artifact exists at `{project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md`, read it for inclusion in the PR body. If no artifact exists, proceed without it.

### Step 3: Dispatch to git-workflow create-pr

Dispatch to `git-workflow --task create-pr` with context:
- `issue_number`
- `authorization_scope`
- `halt_at`
- `github.owner`
- `github.repo`

The `git-workflow create-pr` task handles:
- PR body composition (including VbC table if available)
- `github_create_pull_request` API call
- PR URL extraction from API response `html_url`
- PR URL posting to issue comments

### Step 4: Return Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "PR created at {pr_url}"
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pr-creation-{timestamp}.yaml"
blocker_reason: null | "reason if blocked"
pr_url: "https://github.com/{owner}/{repo}/pull/{number}"
```

## Exit Criteria

- [ ] PR created on GitHub
- [ ] PR URL extracted from API response (never constructed from template)
- [ ] PR URL posted as issue comment
- [ ] Result contract returned with pr_url

## Cross-References

- `git-workflow/tasks/pr-creation/create-pr.md` — PR body composition and API call
- `implementation-pipeline/SKILL.md` — Pipeline step that dispatches here
