<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Provides exactly 3 end-to-end workflow examples using `gb` CLI commands, adapted from the gh-cli reference and validated against the local test GitBucket instance. Each workflow is a complete multi-step procedure covering a real-world GitBucket scenario. These workflows are reference examples — the agent executes the relevant individual task cards (create-pr, triage-issues, manage-milestones) for actual work, not this file.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The workflow to execute (1, 2, or 3) is provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

### Workflow 1: Complete PR Creation Flow

1. **Verify authentication** — Run `gb auth status` to confirm the authenticated session.
2. **Create feature branch** — Run `git checkout -b feature/<description>` to create and switch to a new feature branch.
   - Branch creation, commit, and push operations belong to the `git-workflow` skill — do not duplicate them here.
3. **Make changes** — Implement the required changes (code, tests, documentation) on the feature branch.
4. **Commit and push** — Stage changes with `git add`, commit with `git commit -m "<message>"`, and push with `git push -u origin feature/<description>`.
5. **Create PR** — Run `gb pr create -t "<title>" -b "<body>" --head feature/<description> -B <base-branch> -R <owner/repo>`.
   - Capture the PR number and URL from the command output.
6. **View PR status** — Run `gb pr view <pr-number> -R <owner/repo>` to confirm the PR is open.
   - If the PR is not in `OPEN` state, return BLOCKED with the state mismatch.
7. **CRITICAL VIOLATION — Do NOT merge the PR.** Read [the critical-rules-merge prohibition](.opencode/guidelines/000-critical-rules.md). Merging is a human-only operation.
8. Write the workflow summary (branch name, PR number, PR URL, PR state) to the artifact path.

### Workflow 2: Issue Triage

1. **List open issues** — Run `gb issue list -R <owner/repo> --state open`.
   - If the list is empty, return DONE with `finding_summary: "No open issues found"`.
2. **View specific issue** — Run `gb issue view <number> -R <owner/repo> --comments`.
   - Read the full issue body and all comments to gather context.
3. **Add label** — Run `gb issue edit <number> -R <owner/repo>` with the label flags.
   - Note the post-creation label mutation limitation: labels may need the `gb api` passthrough on `/repos/{owner}/{repo}/issues/{number}/labels`.
   - Verify by running `gb issue view <number> -R <owner/repo>`.
4. **Comment on issue** — Run `gb issue comment <number> -b "<comment body>" -R <owner/repo>`.
   - Verify the comment was posted by running `gb issue view <number> -R <owner/repo> --comments` and checking the last comment.
5. **Create PR from issue** — After branch creation via the `git-workflow` skill, create the PR with `gb pr create -t "<title>" -b "Closes #<number>" --head <branch> -B <base-branch> -R <owner/repo>`.
   - Capture the PR URL from the command output.
6. Write the triage workflow summary (issue number, actions taken, branch name, PR URL) to the artifact path.

### Workflow 3: Milestone Management

1. **List existing milestones** — Run `gb milestone list -R <owner/repo>`.
2. **Create a milestone** — Run `gb milestone create "<title>" -R <owner/repo>`.
   - Capture the milestone number from the output.
   - Verify creation by running `gb milestone list -R <owner/repo>`.
3. **Link an issue to the milestone** — Run `gb issue edit <number> -R <owner/repo>` with the milestone flag (or `gb api` passthrough if no dedicated flag exists).
   - Verify by running `gb issue view <number> -R <owner/repo>`.
4. **View milestone progress** — Run `gb milestone view <number> -R <owner/repo>` to confirm the linked issue appears.
5. Write the milestone workflow summary (milestone number, title, linked issues) to the artifact path.

## Exit Criteria

- The requested workflow has been executed through all its steps
- Each step has been verified (PR confirmed, issue edited confirmed, milestone confirmed)
- The workflow summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<workflow number, key results (PR URL, issue state, milestone state)>"
artifact_path: "<path to workflow summary>"
blocker_reason: "<reason if BLOCKED>"
```
