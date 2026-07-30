<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists GitHub Projects (classic and Projects v2) and views project details including items, fields, and status using `gh project` commands.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The owner (user or organization) is known
- The operation type (list, view) and any project number are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. List projects for the owner:
   - `gh project list --owner <owner> --limit <N> --json number,title,closed,url,updatedAt`
   - Use `--org <org>` instead of `--owner` for organization projects.
   - If the list is empty, return DONE with `finding_summary: "No projects found for owner: <owner>"`.
   - Parse the JSON output and note key fields (number, title, closed status, URL).
2. For the target project, view detailed information:
   - `gh project view <number> --owner <owner> --json title,number,url,shortDescription,closed,items`
   - Use `--org <org>` for organization projects.
   - The `items` field contains the project items with their status, fields, and content references.
   - Parse the items to extract:
     - Item titles and status field values
     - Linked issue/PR numbers and URLs
     - Custom field values
3. If the project has many items, paginate through results:
   - `gh project view <number> --owner <owner> --json items --limit <N> --page <page>`
   - Combine results across pages for a complete view.
4. Write the project management summary (project number, title, item count, key items with status and linked issues) to the artifact path.

## Exit Criteria

- The project list has been retrieved for the owner
- The target project has been viewed with all items
- Items have been parsed and key fields extracted
- The project management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<project number, title, item count, key items>"
artifact_path: "<path to project management summary>"
blocker_reason: "<reason if BLOCKED>"
```
