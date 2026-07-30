<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Check overall GitHub status for the authenticated user using `gh status`. Displays a summary of open issues, pull requests, and notifications across repositories. Supports optional `--repo` and `--limit` filters for scoped queries.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- `gh` CLI must be installed and on PATH

## Procedure

1. Run `gh status` to fetch the current status overview.
   - This displays a summary of recent activity: open issues assigned to you, open PRs authored by you, PRs awaiting your review, and notifications.
   - If `--repo <owner/repo>` is provided in the task context, scope the status to that repository.
   - If `--limit <N>` is provided, cap the number of items per section (default is 10, max is 100).
2. Parse the output into structured sections:
   - **Issues**: Open issues assigned to you (number, title, repo, state).
   - **Pull Requests**: Open PRs authored by you (number, title, repo, state, draft status).
   - **Review Requests**: PRs awaiting your review (number, title, repo, author).
   - **Notifications**: Unread notifications (if supported by the output format).
3. If the output is empty or indicates no activity, return DONE with `finding_summary: "No current activity"`.
4. Write the structured status report to the artifact path in YAML format:
   - Include a `timestamp` field with the current UTC datetime.
   - Include per-section item counts.
   - Include the raw `gh status` output as a `raw_output` field for audit purposes.

## Exit Criteria

- The status has been fetched and parsed into structured sections
- The status report has been written to disk with timestamp and raw output

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<issue count, PR count, review request count, notification count>"
artifact_path: "<path to status report>"
blocker_reason: "<reason if BLOCKED>"
```
