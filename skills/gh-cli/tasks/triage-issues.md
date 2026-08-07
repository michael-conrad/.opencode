<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists, inspects, edits, comments on, and optionally closes GitHub issues using `gh issue` commands for triage workflows.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The triage action (list, view, edit, comment, close) and target issue numbers are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. List issues using `gh issue list` with appropriate filters:
   - `gh issue list --repo <owner/repo> --state <open|closed|all> --label "<label>" --assignee <user>`
   - Use `--limit <N>` to cap results (default 30).
   - Use `--json number,title,state,labels,assignees,updatedAt` for structured output.
   - If the list is empty, return DONE with `finding_summary: "No matching issues found"`.
2. For each issue that requires deeper inspection, run `gh issue view <number> --repo <owner/repo> --json title,body,state,labels,assignees,comments,createdAt,updatedAt`.
   - Read the full issue body and all comments to gather context.
3. Edit the issue if label or assignee changes are needed:
   - `gh issue edit <number> --repo <owner/repo> --add-label "<label>" --remove-label "<label>" --add-assignee "<user>" --remove-assignee "<user>"`
   - Verify the edit by running `gh issue view <number> --repo <owner/repo> --json labels,assignees`.
4. Post a comment on the issue if required:
   - `gh issue comment <number> --repo <owner/repo> --body "<comment body>"`
   - If the comment body is long, write it to a temp file and use `--body-file <path>`.
   - Verify the comment was posted by running `gh issue view <number> --repo <owner/repo> --json comments` and checking the last comment.
5. Close the issue if explicitly instructed and all criteria are met:
   - `gh issue close <number> --repo <owner/repo> --comment "<closing comment>"`
   - Verify the issue state changed to `CLOSED` via `gh issue view <number> --repo <owner/repo> --json state`.
   - **Do NOT close issues without explicit instruction.** Read [the approval-gate rules](.opencode/guidelines/010-approval-gate.md) — issue closure requires authorization.
6. Write the triage summary (issues processed, actions taken, current state) to the artifact path.

## Exit Criteria

- All requested triage actions have been executed
- Each action has been verified (edit verified, comment confirmed, close confirmed)
- The triage summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<issues processed, actions taken, current state per issue>"
artifact_path: "<path to triage summary>"
blocker_reason: "<reason if BLOCKED>"
```
