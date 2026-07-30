<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Creates, lists, views, edits, and deletes GitHub Gists with configurable visibility using `gh gist` commands.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The operation type (create, list, view, edit, delete) is provided in the task context
- For create: the file path(s) and visibility (public/secret) are provided
- For edit: the gist ID and new content file path are provided
- For delete: the gist ID is provided
- `gh` CLI must be installed and on PATH

## Procedure

1. If the operation is `create`:
   - `gh gist create <file1> <file2> --<public|secret> --desc "<description>"`
   - Use `--web` to open the gist in the browser after creation.
   - Capture the gist URL from the command output.
   - Verify the gist was created: `gh gist view <gist-id> --json id,description,files,visibility,url`.
2. If the operation is `list`:
   - `gh gist list --limit <N> --json id,description,files,visibility,updatedAt,url`
   - Use `--public` to list only public gists, `--secret` to list only secret gists.
   - If the list is empty, return DONE with `finding_summary: "No gists found"`.
   - Parse the JSON output and note key fields (id, description, file count, visibility).
3. If the operation is `view`:
   - `gh gist view <gist-id> --json id,description,files,visibility,createdAt,updatedAt,owner,url`
   - Read the file content from the `files` field in the JSON output.
   - If the gist does not exist or access is denied, return BLOCKED with the failure reason.
4. If the operation is `edit`:
   - `gh gist edit <gist-id> <new-file-path> --add <additional-file> --desc "<new description>"`
   - Verify the edit: `gh gist view <gist-id> --json files,description` and confirm the changes.
5. If the operation is `delete`:
   - `gh gist delete <gist-id>`
   - Verify the gist was deleted: `gh gist list --limit 1 --json id` and confirm the gist ID no longer appears.
   - If the gist does not exist or the agent lacks permission, return BLOCKED with the failure reason.
6. Write the gist management summary (operation, gist ID, description, file count, visibility, URL) to the artifact path.

## Exit Criteria

- The requested gist operation (create/list/view/edit/delete) has been executed
- Each operation has been verified (create confirmed, edit confirmed, delete confirmed)
- The management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operation, gist ID, description, file count, visibility>"
artifact_path: "<path to management summary>"
blocker_reason: "<reason if BLOCKED>"
```
