<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists, inspects, edits, comments on, and optionally closes GitBucket issues using `gb issue` commands for triage workflows.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The triage action (list, view, edit, comment, close) and target issue numbers are provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

1. List issues using `gb issue list -R <owner/repo>` with appropriate filters:
   - `gb issue list -R <owner/repo> --state <open|closed|all>`
   - Use `--label <label>` to filter by label if supported.
   - If the list is empty, return DONE with `finding_summary: "No matching issues found"`.
2. For each issue that requires deeper inspection, run `gb issue view <number> -R <owner/repo> --comments`.
   - Read the full issue body and all comments to gather context.
3. Edit the issue if label or assignee changes are needed:
   - `gb issue edit <number> -R <owner/repo>` with the appropriate flags (e.g., `--title`, `--add-label`).
   - Note: post-creation label mutation on GitBucket uses the `gb api` passthrough on `/repos/{owner}/{repo}/issues/{number}/labels`; document the limitation in the findings.
   - Verify the edit by running `gb issue view <number> -R <owner/repo>`.
4. Post a comment on the issue if required:
   - `gb issue comment <number> -b "<comment body>" -R <owner/repo>`
   - Verify the comment was posted by running `gb issue view <number> -R <owner/repo> --comments` and checking the last comment.
5. Close the issue if explicitly instructed and all criteria are met:
   - `gb issue close <number> -R <owner/repo>`
   - Verify the issue state changed to `CLOSED` via `gb issue view <number> -R <owner/repo>`.
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
