<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Manages GitBucket repository labels using `gb label` commands: list existing labels, create new labels with color, view, edit existing labels, and delete labels. Each operation is verified after execution.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The label operation (list, view, create, edit, delete) and parameters are provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

1. **List existing labels** — Run `gb label list -R <owner/repo>`.
   - If the list is empty, note it in findings.
   - Write the full label list to the artifact path for reference.
2. **Create a label** (if requested) — Run `gb label create <name> --color <hex-color> -R <owner/repo>`.
   - The color must be a 6-character hex string with the `#` prefix (e.g., `#ff0000`).
   - If the label already exists, `gb` will print an error. Check for this and return BLOCKED with the conflict message.
   - Verify creation by running `gb label list -R <owner/repo>` and confirming the new label appears.
3. **View a label** (if requested) — Run `gb label view <name> -R <owner/repo>`.
4. **Edit a label** (if requested) — Run `gb label edit <name> -R <owner/repo>` with the appropriate flags.
   - Only include flags for fields that are being changed. Omit unchanged fields.
   - If the label does not exist, `gb` will print an error. Return BLOCKED with the not-found message.
   - Verify the edit by running `gb label view <name> -R <owner/repo>`.
5. **Delete a label** (if requested) — Run `gb label delete <name> --yes -R <owner/repo>`.
   - The `--yes` flag is required to skip the confirmation prompt.
   - **Do NOT delete labels without explicit instruction.** Read [the critical-rules-052 prohibition](.opencode/guidelines/000-critical-rules.md) — deletion requires spec + authorization.
   - Verify deletion by running `gb label list -R <owner/repo>` and confirming the label no longer appears.
6. **Document the post-creation label limitation:** Post-creation label mutation on GitBucket issues is limited. Labels must be added at issue creation time; mutation after creation requires the `gb api` passthrough on `/repos/{owner}/{repo}/issues/{number}/labels`. Note this limitation in the findings.
7. Write the label management summary (operations performed, label states before/after) to the artifact path.

## Exit Criteria

- All requested label operations have been executed
- Each operation has been verified (create confirmed, edit confirmed, delete confirmed)
- The post-creation label limitation has been documented
- The label management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operations performed, label count, current state>"
artifact_path: "<path to label management summary>"
blocker_reason: "<reason if BLOCKED>"
```
