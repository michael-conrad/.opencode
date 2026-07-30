<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Creates and forks repositories with configurable visibility, manages issue labels, and edits repository metadata (topics, visibility, description) using `gh repo` and `gh label` commands.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository name and owner/org are known
- The operation type (create, fork, edit, label) and all required parameters are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. If the operation is `create`:
   - `gh repo create <name> --<public|private|internal> --description "<description>" --homepage "<url>" --template <owner/repo> --clone`
   - Use `--push --remote <name>` to push an existing local repo to the new remote.
   - Use `--add-readme` to initialize with a README, `--license <template>` to add a license, `--gitignore <template>` to add a .gitignore.
   - Capture the clone URL from the output.
   - Verify the repository exists: `gh repo view <owner>/<name> --json name,visibility,url`.
2. If the operation is `fork`:
   - `gh repo fork <owner/repo> --clone --fork-name <new-name> --org <org>`
   - Use `--remote` to add the fork as a remote (default: `origin`).
   - Capture the fork URL from the output.
   - Verify the fork exists: `gh repo view <fork-owner>/<repo> --json name,parent,url`.
3. If the operation is `label`:
   - List existing labels: `gh label list --repo <owner/repo> --json name,color,description`.
   - Create a new label: `gh label create <name> --repo <owner/repo> --color <hex-color> --description "<description>"`.
   - Verify the label was created: `gh label list --repo <owner/repo> --json name,color` and confirm the new label appears.
4. If the operation is `edit`:
   - `gh repo edit <owner/repo> --<enable|disable>-<wiki|issues|projects|merge-commit|squash-merge|rebase-merge|discussions>`
   - `gh repo edit <owner/repo> --add-topic "<topic1>" --add-topic "<topic2>" --remove-topic "<topic>"`
   - `gh repo edit <owner/repo> --description "<new description>" --homepage "<new url>" --visibility <public|private|internal>`
   - Verify each change: `gh repo view <owner/repo> --json <changed-fields>` and confirm values match.
5. Write the repository management summary (operation, name, URL, changed fields, verification results) to the artifact path.

## Exit Criteria

- The repository operation (create/fork/label/edit) has been executed successfully
- Each change has been verified via `gh repo view` or `gh label list`
- The management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operation, repo name, URL, fields changed>"
artifact_path: "<path to management summary>"
blocker_reason: "<reason if BLOCKED>"
```
