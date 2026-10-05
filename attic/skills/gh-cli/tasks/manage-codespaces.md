<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists, creates, connects to (SSH or VS Code), and deletes GitHub Codespaces using `gh codespace` commands for cloud development environment management.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The operation type (list, create, ssh, code, delete) and any parameters (branch, machine type, idle timeout) are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. List existing codespaces:
   - `gh codespace list --json name,repository,owner,branch,state,createdAt,gitStatus,machine`
   - Use `--repo <owner/repo>` to filter by repository.
   - Use `--org <org>` to list codespaces in an organization (requires org admin).
   - If the list is empty, note it in the findings.
2. If the operation is `create`:
   - `gh codespace create --repo <owner/repo> --branch <branch> --machine <machine-type> --idle-timeout <minutes> --display-name "<name>"`
   - Wait for the codespace to reach `Available` state. Poll with `gh codespace list --repo <owner/repo> --json name,state` until state is `Available` or a timeout is reached.
   - If creation times out, return BLOCKED with `reason: "Codespace creation timed out in state: <state>"`.
   - Capture the codespace name from the output.
3. If the operation is `ssh`:
   - `gh codespace ssh --codespace <name>`
   - This opens an interactive SSH session. For non-interactive use, pass a command: `gh codespace ssh --codespace <name> --command "<command>"`.
   - Capture the command output for the artifact.
4. If the operation is `code`:
   - `gh codespace code --codespace <name>`
   - This opens the codespace in VS Code desktop or web. Note: this is a client-side action; the agent captures the confirmation message.
5. If the operation is `delete`:
   - `gh codespace delete --codespace <name>`
   - Use `--force` to skip confirmation.
   - Verify the codespace no longer appears: `gh codespace list --repo <owner/repo> --json name` and confirm the name is absent.
6. Write the codespace management summary (operation, codespace name, repository, branch, state, machine type) to the artifact path.

## Exit Criteria

- The requested codespace operation (list/create/ssh/code/delete) has been executed
- For create: the codespace reached `Available` state
- For delete: the codespace no longer appears in the list
- The management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operation, codespace name, repo, branch, state>"
artifact_path: "<path to management summary>"
blocker_reason: "<reason if BLOCKED>"
```
