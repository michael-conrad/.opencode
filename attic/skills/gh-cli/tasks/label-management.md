<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Manage GitHub issue labels using `gh label` commands: list existing labels, create new labels with color and description, edit existing labels, and delete labels. Each operation is verified after execution.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The label operation (list, create, edit, delete) and parameters are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. **List existing labels** — Run `gh label list --repo <owner/repo> --json name,color,description`.
   - Use `--limit <N>` to cap results (default 30, max 100).
   - If the list is empty, note it in findings.
   - Write the full label list to the artifact path for reference.
2. **Create a label** (if requested) — Run `gh label create <name> --repo <owner/repo> --color <hex-color> --description "<description>"`.
   - The color must be a 6-character hex string without the `#` prefix (e.g., `ff0000`).
   - If the label already exists, `gh` will print an error. Check for this and return BLOCKED with the conflict message.
   - Verify creation by running `gh label list --repo <owner/repo> --json name,color,description` and confirming the new label appears with the correct values.
3. **Edit a label** (if requested) — Run `gh label edit <name> --repo <owner/repo> --name <new-name> --color <hex-color> --description "<new-description>"`.
   - Only include flags for fields that are being changed. Omit unchanged fields.
   - If the label does not exist, `gh` will print an error. Return BLOCKED with the not-found message.
   - Verify the edit by running `gh label list --repo <owner/repo> --json name,color,description` and confirming the label reflects the new values.
4. **Delete a label** (if requested) — Run `gh label delete <name> --repo <owner/repo> --yes`.
   - The `--yes` flag is required to skip the confirmation prompt.
   - **Do NOT delete labels without explicit instruction.** Read [the critical-rules-052 prohibition](.opencode/guidelines/000-critical-rules.md) — file deletion (including label deletion) requires spec + authorization.
   - Verify deletion by running `gh label list --repo <owner/repo> --json name` and confirming the label no longer appears.
5. Write the label management summary (operations performed, label states before/after) to the artifact path.

## Exit Criteria

- All requested label operations have been executed
- Each operation has been verified (create confirmed, edit confirmed, delete confirmed)
- The label management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operations performed, label count, current state>"
artifact_path: "<path to label management summary>"
blocker_reason: "<reason if BLOCKED>"
```
