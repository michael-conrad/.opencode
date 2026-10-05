<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Creates a pull request using `gb pr create` with title, body, and head/base branches, then verifies the result with `gb pr view`. PR merge is strictly prohibited.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The current branch has unpushed commits or is ahead of the base branch
- The base branch (e.g., `main`) is known
- The PR title and body are provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

1. Run `gb auth status` to verify the authenticated session. If it fails, return BLOCKED with the authentication failure reason.
2. Verify the current branch is ready: run `git status` and `git log` to confirm the branch has the intended commits.
   - Branch creation, commit, and push operations belong to the `git-workflow` skill — do not duplicate them here. Read [the git-workflow skill](.opencode/skills/git-workflow/SKILL.md).
3. Create the pull request using `gb pr create`:
   - `gb pr create -t "<title>" -b "<body>" --head <current-branch> -B <base-branch> -R <owner/repo>`
   - Use `--detect-existing` to avoid creating a duplicate PR if one already exists for the branch.
   - If the PR body is long, write it to a temp file and use `--body-file <path>` if supported.
   - Verify the exact flag surface with `gb pr create --help` before running (flags may differ between versions).
4. Capture the PR number and URL from the command output.
5. Verify the created PR by running `gb pr view <pr-number> -R <owner/repo>`.
   - Confirm the title and state (`OPEN`) match the provided values.
   - If verification fails, return BLOCKED with the mismatch details.
6. **CRITICAL VIOLATION — Do NOT merge the PR.** Read [the critical-rules-merge prohibition](.opencode/guidelines/000-critical-rules.md). Merging is a human-only operation. The agent MUST NOT call `gb pr merge` or any equivalent merge operation.
7. Write the PR summary (number, URL, title, state) to the artifact path.

## Exit Criteria

- The PR has been created and verified via `gb pr view`
- The PR has NOT been merged
- The PR summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<PR number, URL, title, state>"
artifact_path: "<path to PR summary>"
blocker_reason: "<reason if BLOCKED>"
```
