<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists open pull requests, inspects their diffs, checks out the branch locally, and submits a review (approve, comment, or request changes) using `gh pr` commands.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The review action (approve, comment, request-changes) and target PR number are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. List open pull requests using `gh pr list --repo <owner/repo> --state open --json number,title,author,headRefName,baseRefName,createdAt,labels`.
   - Use `--limit <N>` to cap results (default 30).
   - Use `--label "<label>"` to filter by label if provided.
   - If the list is empty, return DONE with `finding_summary: "No open pull requests found"`.
2. For the target PR, view the full diff using `gh pr view <number> --repo <owner/repo> --json title,body,state,additions,deletions,files,reviews,comments --diff`.
   - Read the diff output carefully to understand the changes.
   - Read all existing review comments to avoid duplicating feedback.
   - If the PR body or comments contain critical context (scope, intent, blockers), note it in the findings.
3. Check out the PR branch locally for deeper inspection if needed:
   - `gh pr checkout <number> --repo <owner/repo>`
   - Run local verification (lint, tests, build) as appropriate for the project.
   - After inspection, switch back to the original branch: `git checkout <original-branch>`.
4. Submit a review using `gh pr review <number> --repo <owner/repo>`:
   - For approval: `--approve --body "<approval comment>"`
   - For comments: `--comment --body "<feedback comment>"`
   - For change requests: `--request-changes --body "<change request details>"`
   - If the review body is long, write it to a temp file and use `--body-file <path>`.
5. Verify the review was submitted by running `gh pr view <number> --repo <owner/repo> --json reviews` and checking the latest review matches the submitted action.
6. **CRITICAL — Do NOT merge the PR.** Read [the critical-rules-merge prohibition](.opencode/guidelines/000-critical-rules.md). Merging is a human-only operation. The agent MUST NOT call `gh pr merge` or any equivalent merge operation.
7. Write the review summary (PR number, review action, key findings, verification result) to the artifact path.

## Exit Criteria

- The PR diff has been inspected
- The review has been submitted with the correct action (approve/comment/request-changes)
- The review has been verified via `gh pr view`
- The PR has NOT been merged
- The review summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<PR number, review action, key findings>"
artifact_path: "<path to review summary>"
blocker_reason: "<reason if BLOCKED>"
```
