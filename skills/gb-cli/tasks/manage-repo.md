<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Creates, forks, lists, views, clones, and deletes GitBucket repositories using `gb repo` commands. Each operation is verified after execution.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The target repository name and owner are known
- The operation type (create, fork, list, view, clone, delete) and all required parameters are provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

1. Verify the authenticated session with `gb auth status`. If it fails, return BLOCKED with the authentication failure reason.
2. If the operation is `create`:
   - `gb repo create <name> [-g <group>]`
   - Capture the repository URL from the output.
   - Verify the repository exists: `gb repo view <owner>/<name>`.
3. If the operation is `fork`:
   - `gb repo fork <owner/repo>`
   - Note: on some GitBucket instances fork uses a web fallback (browser prompt). If the command does not complete, document the fallback in the findings and return BLOCKED if the operation could not be confirmed.
   - Verify the fork exists: `gb repo view <owner>/<repo>`.
4. If the operation is `list` or `view`:
   - List repositories: `gb repo list [owner]`.
   - View repository details: `gb repo view <owner/repo>`.
5. If the operation is `clone`:
   - `gb repo clone <owner/repo>`
   - Capture the target directory from the output.
6. If the operation is `delete`:
   - `gb repo delete <owner/repo>` with explicit confirmation.
   - **Do NOT delete repositories without explicit instruction.** Read [the critical-rules-052 prohibition](.opencode/guidelines/000-critical-rules.md) — deletion requires spec + authorization.
7. Write the repository management summary (operation, name, URL, changed fields, verification results) to the artifact path.

## Exit Criteria

- The repository operation (create/fork/list/view/clone/delete) has been executed successfully
- Each change has been verified via `gb repo view` or `gb repo list`
- The management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operation, repo name, URL, fields changed>"
artifact_path: "<path to management summary>"
blocker_reason: "<reason if BLOCKED>"
```
