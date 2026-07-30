<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Creates a pull request using `gh pr create` with title, body, labels, and reviewers, then verifies the result with `gh pr view`. PR merge is strictly prohibited.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The current branch has unpushed commits or is ahead of the base branch
- The base branch (e.g., `main`, `master`) is known
- The PR title, body, labels, and reviewers are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. Run `gh repo sync` to ensure the local repository is up to date with the remote.
   - If the sync fails (network error, auth failure), return BLOCKED with the failure reason.
2. Create the pull request using `gh pr create`:
   - `gh pr create --title "<title>" --body "<body>" --base <base-branch> --head <current-branch>`
   - Add `--label "<label1>,<label2>"` if labels are provided.
   - Add `--reviewer "<user1>,<user2>"` if reviewers are provided.
   - If the PR body is long, write it to a temp file and use `--body-file <path>` instead.
3. Capture the PR URL from the command output. The URL is printed to stdout on success.
4. Verify the created PR by running `gh pr view <pr-number> --json title,state,url,labels,reviewers`.
   - Confirm the title, state (`OPEN`), labels, and reviewers match the provided values.
   - If verification fails, return BLOCKED with the mismatch details.
5. **CRITICAL — Do NOT merge the PR.** Read [the critical-rules-merge prohibition](.opencode/guidelines/000-critical-rules.md). Merging is a human-only operation. The agent MUST NOT call `gh pr merge` or any equivalent merge operation.
6. Write the PR summary (number, URL, title, state, labels, reviewers) to the artifact path.

## Exit Criteria

- The PR has been created and verified via `gh pr view`
- The PR has NOT been merged
- The PR summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<PR number, URL, title, state, labels, reviewers>"
artifact_path: "<path to PR summary>"
blocker_reason: "<reason if BLOCKED>"
```
