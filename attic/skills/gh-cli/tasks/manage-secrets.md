<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists, sets, and deletes repository or organization secrets and variables using `gh secret` and `gh variable` commands for CI/CD configuration management.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) or organization is known
- The operation type (list, set, delete) and scope (repo, org) are provided in the task context
- For set operations, the secret/variable name and value are provided
- `gh` CLI must be installed and on PATH

## Procedure

1. Determine the scope and list existing secrets:
   - Repository secrets: `gh secret list --repo <owner/repo> --json name,updatedAt,visibility`
   - Organization secrets: `gh secret list --org <org> --json name,updatedAt,visibility`
   - If the list is empty, note it in the findings.
2. Perform the requested secret operation:
   - **Set a secret**:
     - Repository: `gh secret set <name> --repo <owner/repo> --body "<value>"`
     - Organization: `gh secret set <name> --org <org> --visibility <all|private|selected> --repos "<repo1>,<repo2>"`
     - If the value is long, write it to a temp file and use `--body-file <path>`.
     - Verify the secret was set: `gh secret list --repo <owner/repo> --json name` and confirm the name appears.
   - **Delete a secret**:
     - Repository: `gh secret delete <name> --repo <owner/repo>`
     - Organization: `gh secret delete <name> --org <org>`
     - Verify the secret was deleted: `gh secret list --repo <owner/repo> --json name` and confirm the name no longer appears.
3. Perform the requested variable operation (if applicable):
   - **List variables**:
     - Repository: `gh variable list --repo <owner/repo> --json name,value,updatedAt`
     - Organization: `gh variable list --org <org> --json name,value,updatedAt`
   - **Set a variable**:
     - Repository: `gh variable set <name> --repo <owner/repo> --body "<value>"`
     - Organization: `gh variable set <name> --org <org> --visibility <all|private|selected> --repos "<repo1>,<repo2>"`
     - Verify the variable was set: `gh variable list --repo <owner/repo> --json name` and confirm the name appears.
   - **Delete a variable**:
     - Repository: `gh variable delete <name> --repo <owner/repo>`
     - Organization: `gh variable delete <name> --org <org>`
     - Verify the variable was deleted: `gh variable list --repo <owner/repo> --json name` and confirm the name no longer appears.
4. Write the secrets/variables management summary (scope, operations performed, names, verification results) to the artifact path.

## Exit Criteria

- All requested secret and variable operations have been executed
- Each operation has been verified (set confirmed, delete confirmed)
- The management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<scope, operations performed, secret/variable names>"
artifact_path: "<path to management summary>"
blocker_reason: "<reason if BLOCKED>"
```
