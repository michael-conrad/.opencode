<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists open pull requests, inspects their diffs, checks out the branch locally, and submits comment-based review feedback using `gb pr` commands. GitBucket has no formal review-approval API — review is performed via `gb pr diff` + `gb pr comment`.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The review action (comment-based feedback) and target PR number are provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

1. List open pull requests using `gb pr list -R <owner/repo> --state open`.
   - Use `--label <label>` to filter by label if supported.
   - If the list is empty, return DONE with `finding_summary: "No open pull requests found"`.
2. For the target PR, view the full diff using `gb pr diff <number> -R <owner/repo>`.
   - Read the diff output carefully to understand the changes.
   - Read the PR body via `gb pr view <number> -R <owner/repo>` and all existing PR comments via `gb pr comment <number> -R <owner/repo>` to avoid duplicating feedback.
   - If the PR body or comments contain critical context (scope, intent, blockers), note it in the findings.
3. Check out the PR branch locally for deeper inspection if needed:
   - `gb pr checkout <number> -R <owner/repo>`
   - Run local verification (lint, tests, build) as appropriate for the project.
   - After inspection, switch back to the original branch: `git checkout <original-branch>`.
4. Submit comment-based review feedback using `gb pr comment <number> -b "<feedback body>" -R <owner/repo>`.
   - GitBucket has no formal review-approval command (`gb pr review` does not exist); document this limitation in the findings.
   - If the feedback body is long, write it to a temp file and use `--body-file <path>` if supported.
5. Verify the comment was submitted by running `gb pr comment <number> -R <owner/repo>` and checking the latest comment.
6. **CRITICAL VIOLATION — Do NOT merge the PR.** Read [the critical-rules-merge prohibition](.opencode/guidelines/000-critical-rules.md). Merging is a human-only operation. The agent MUST NOT call `gb pr merge` or any equivalent merge operation.
7. Write the review summary (PR number, feedback action, key findings, verification result) to the artifact path.

## Exit Criteria

- The PR diff has been inspected
- The comment-based review has been submitted and verified
- The PR has NOT been merged
- The review summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<PR number, review feedback, key findings>"
artifact_path: "<path to review summary>"
blocker_reason: "<reason if BLOCKED>"
```
