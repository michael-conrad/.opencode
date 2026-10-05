<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Provide exactly 3 end-to-end workflow examples using `gh` CLI commands. Each workflow is a complete multi-step procedure covering a real-world GitHub scenario. These workflows are reference examples — the agent executes the relevant individual task cards (create-pr, triage-issues, do-release) for actual work, not this file.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The workflow to execute (1, 2, or 3) is provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

### Workflow 1: Complete PR Creation Flow

1. **Update main branch** — Run `gh repo sync <owner/repo> --branch main` to sync the local main branch with the remote.
   - If the sync fails (network error, auth failure), return BLOCKED with the failure reason.
2. **Create feature branch** — Run `git checkout -b feature/<description>` to create and switch to a new feature branch.
3. **Make changes** — Implement the required changes (code, tests, documentation) on the feature branch.
4. **Commit and push** — Stage changes with `git add`, commit with `git commit -m "<message>"`, and push with `git push -u origin feature/<description>`.
5. **Create PR** — Run `gh pr create --title "<title>" --body "<body>" --base main --head feature/<description> --label "<label1>,<label2>" --reviewer "<user1>,<user2>"`.
   - Capture the PR URL from the command output.
6. **View PR status** — Run `gh pr view <pr-number> --json title,state,url,labels,reviewers,mergeable` to confirm the PR is open and check mergeability.
   - If the PR is not in `OPEN` state, return BLOCKED with the state mismatch.
7. **CRITICAL — Do NOT merge the PR.** Read [the critical-rules-merge prohibition](.opencode/guidelines/000-critical-rules.md). Merging is a human-only operation.
8. Write the workflow summary (branch name, PR number, PR URL, PR state, labels, reviewers) to the artifact path.

### Workflow 2: Issue Triage

1. **List open issues** — Run `gh issue list --repo <owner/repo> --state open --limit 20 --json number,title,state,labels,assignees,updatedAt`.
   - If the list is empty, return DONE with `finding_summary: "No open issues found"`.
2. **View specific issue** — Run `gh issue view <number> --repo <owner/repo> --json title,body,state,labels,assignees,comments,createdAt,updatedAt`.
   - Read the full issue body and all comments to gather context.
3. **Add label and assign** — Run `gh issue edit <number> --repo <owner/repo> --add-label "<label>" --add-assignee "<user>"`.
   - Verify by running `gh issue view <number> --repo <owner/repo> --json labels,assignees`.
4. **Comment on issue** — Run `gh issue comment <number> --repo <owner/repo> --body "<comment body>"`.
   - Verify the comment was posted by running `gh issue view <number> --repo <owner/repo> --json comments` and checking the last comment.
5. **Create branch from issue** — Run `gh issue develop <number> --repo <owner/repo> --branch-name <branch-name> --checkout`.
   - If `gh issue develop` is not available (older `gh` version), fall back to `git checkout -b <branch-name>`.
6. **Create PR from issue** — Run `gh issue develop <number> --repo <owner/repo> --make-pr` or create the PR manually with `gh pr create --title "<title>" --body "Closes #<number>" --base main`.
   - Capture the PR URL from the command output.
7. Write the triage workflow summary (issue number, actions taken, branch name, PR URL) to the artifact path.

### Workflow 3: Release Management

1. **Create release tag** — Run `git tag -a v<version> -m "Release v<version>"` to create an annotated tag.
   - Push the tag with `git push origin v<version>`.
   - Verify the tag exists remotely with `git ls-remote --tags origin v<version>`.
2. **Create release with notes** — Run `gh release create v<version> --repo <owner/repo> --title "v<version>" --notes "<release notes>"`.
   - If the release notes are long, write them to a temp file and use `--notes-file <path>`.
   - Use `--prerelease` if the release is a pre-release, or `--latest` to mark as the latest release.
   - Capture the release URL from the command output.
3. **Upload assets** — Run `gh release upload v<version> --repo <owner/repo> <asset1> <asset2>` for each asset file.
   - Verify the upload by running `gh release view v<version> --repo <owner/repo> --json assets` and confirming the asset names appear.
4. **View release in browser** — Run `gh release view v<version> --repo <owner/repo> --web` to open the release page.
   - Capture the release URL from the output or construct it as `https://github.com/<owner>/<repo>/releases/tag/v<version>`.
5. Write the release management summary (tag, version, release URL, asset list) to the artifact path.

## Exit Criteria

- The requested workflow has been executed through all its steps
- Each step has been verified (PR confirmed, issue edited confirmed, release upload confirmed)
- The workflow summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<workflow number, key results (PR URL, issue state, release URL)>"
artifact_path: "<path to workflow summary>"
blocker_reason: "<reason if BLOCKED>"
```
