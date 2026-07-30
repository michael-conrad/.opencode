<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists workflow runs with structured filters, views run details and logs, and performs lifecycle actions (rerun, watch, cancel) using `gh run` commands.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The action type (list, view, rerun, watch, cancel) and any filter parameters (branch, workflow, status, event) are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. List workflow runs with filters:
   - `gh run list --repo <owner/repo> --branch <branch> --workflow <workflow-name> --status <queued|in_progress|completed|success|failure|cancelled> --event <push|pull_request|workflow_dispatch> --limit <N> --json databaseId,displayTitle,status,conclusion,headBranch,createdAt,updatedAt,url`
   - If the list is empty, return DONE with `finding_summary: "No workflow runs found matching filters"`.
   - Parse the JSON output to identify the target run(s).
2. For the target run, view detailed information:
   - `gh run view <run-id> --repo <owner/repo> --log --json <fields>`
   - Use `--log-failed` to view only failed step logs.
   - Use `--job <job-id>` to view logs for a specific job.
   - Capture the log output to a file at the artifact path for evidence.
3. Perform the requested lifecycle action:
   - **Rerun**: `gh run rerun <run-id> --repo <owner/repo>`
     - Use `--failed` to rerun only failed jobs.
     - Verify the new run appears: `gh run list --repo <owner/repo> --limit 1 --json databaseId,status`.
   - **Watch**: `gh run watch <run-id> --repo <owner/repo>`
     - This polls the run until completion. Set an appropriate timeout.
     - Capture the final status and conclusion from the output.
   - **Cancel**: `gh run cancel <run-id> --repo <owner/repo>`
     - Verify the run status changed to `cancelled`: `gh run view <run-id> --repo <owner/repo> --json status,conclusion`.
4. If the action was `rerun` or `watch`, write the final run status (conclusion, duration, failed jobs) to the artifact path.
5. If the action was `cancel`, write the cancellation confirmation (run ID, previous status, confirmed cancelled status) to the artifact path.

## Exit Criteria

- The workflow run list has been retrieved with the correct filters
- The requested lifecycle action (rerun/watch/cancel) has been executed
- The action result has been verified via `gh run view` or `gh run list`
- The CI/CD summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<action, run ID, workflow name, status/conclusion>"
artifact_path: "<path to CI/CD summary>"
blocker_reason: "<reason if BLOCKED>"
```
