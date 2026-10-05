<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Manages GitBucket milestones using `gb milestone` commands: list, view, create, edit, and delete. Milestones are a gb-specific workflow with no gh-cli equivalent.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The target repository (`owner/repo`) is known
- The milestone operation (list, view, create, edit, delete) and parameters are provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

1. **List existing milestones** — Run `gb milestone list -R <owner/repo>`.
   - If the list is empty, note it in findings.
   - Write the full milestone list to the artifact path for reference.
2. **Create a milestone** (if requested) — Run `gb milestone create <title> -R <owner/repo>`.
   - Add any supported flags for due date or description; verify the exact flag surface with `gb milestone create --help` before running.
   - If the milestone already exists, `gb` will print an error. Check for this and return BLOCKED with the conflict message.
   - Verify creation by running `gb milestone list -R <owner/repo>` and confirming the new milestone appears.
3. **View a milestone** (if requested) — Run `gb milestone view <number> -R <owner/repo>`.
4. **Edit a milestone** (if requested) — Run `gb milestone edit <number> -R <owner/repo>` with the appropriate flags.
   - Only include flags for fields that are being changed. Omit unchanged fields.
   - If the milestone does not exist, `gb` will print an error. Return BLOCKED with the not-found message.
   - Verify the edit by running `gb milestone view <number> -R <owner/repo>`.
5. **Delete a milestone** (if requested) — Run `gb milestone delete <number> -R <owner/repo>`.
   - **Do NOT delete milestones without explicit instruction.** Read [the critical-rules-052 prohibition](.opencode/guidelines/000-critical-rules.md) — deletion requires spec + authorization.
   - Verify deletion by running `gb milestone list -R <owner/repo>` and confirming the milestone no longer appears.
6. Write the milestone management summary (operations performed, milestone states before/after) to the artifact path.

## Exit Criteria

- All requested milestone operations have been executed
- Each operation has been verified (create confirmed, edit confirmed, delete confirmed)
- The milestone management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operations performed, milestone count, current state>"
artifact_path: "<path to milestone management summary>"
blocker_reason: "<reason if BLOCKED>"
```
