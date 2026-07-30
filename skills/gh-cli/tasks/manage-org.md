<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Views organization profile and member lists, and manages repositories under an organization using `gh org` and `gh repo` commands.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The organization name is known
- The operation type (view, list-members, repo-list, repo-create) is provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. View the organization profile:
   - `gh org view <org> --json name,login,description,email,location,createdAt,totalRepos,totalMembers,url`
   - Parse the JSON output and note key fields (name, member count, repo count, URL).
   - If the organization does not exist or the agent lacks access, return BLOCKED with the failure reason.
2. List organization members:
   - `gh org list-members <org> --json login,name,role --limit <N>`
   - Use `--role <admin|member>` to filter by role.
   - If the list is empty, note it in the findings.
3. List repositories under the organization:
   - `gh repo list <org> --json name,description,visibility,language,updatedAt,forkCount,stargazerCount --limit <N>`
   - Use `--fork` to include forks, `--source` to exclude forks, `--language <lang>` to filter by language.
   - If the list is empty, note it in the findings.
4. Create a new repository under the organization (if requested):
   - `gh repo create <org>/<name> --<public|private|internal> --description "<description>" --homepage "<url>" --add-readme --license <template> --gitignore <template>`
   - Capture the repository URL from the output.
   - Verify the repository exists: `gh repo view <org>/<name> --json name,visibility,url`.
5. Write the organization management summary (org name, member count, repo count, any created repo details) to the artifact path.

## Exit Criteria

- The organization profile has been viewed
- Members and repositories have been listed (if requested)
- Any new repository has been created and verified
- The management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<org name, member count, repo count, created repo details>"
artifact_path: "<path to management summary>"
blocker_reason: "<reason if BLOCKED>"
```
