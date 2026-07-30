<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Manages `gh` CLI aliases and extensions — sets, lists, and deletes custom aliases, and installs, lists, and removes community extensions.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The operation type (alias, extension) and sub-operation (set/list/delete/install/remove) are provided in the task context
- For alias set: the alias name and expansion command are provided
- For extension install: the extension name or GitHub repository reference is provided
- For delete/remove: the alias name or extension name is provided
- `gh` CLI must be installed and on PATH

## Procedure

1. If the operation is `alias`:
   - **List aliases**: `gh alias list` — parse the output to show alias names and their expansions.
     - If no aliases are configured, return DONE with `finding_summary: "No aliases configured"`.
   - **Set an alias**: `gh alias set <name> "<expansion>"`
     - Use `--clobber` to overwrite an existing alias with the same name.
     - Verify the alias was set: `gh alias list` and confirm the new alias appears with the correct expansion.
   - **Delete an alias**: `gh alias delete <name>`
     - Verify the alias was deleted: `gh alias list` and confirm the name no longer appears.
2. If the operation is `extension`:
   - **List extensions**: `gh extension list --json name,description,version,is_local`
     - If no extensions are installed, return DONE with `finding_summary: "No extensions installed"`.
   - **Install an extension**: `gh extension install <owner/repo>`
     - Use `--force` to upgrade an already-installed extension.
     - Verify the extension was installed: `gh extension list --json name` and confirm the name appears.
   - **Remove an extension**: `gh extension remove <name>`
     - Verify the extension was removed: `gh extension list --json name` and confirm the name no longer appears.
   - **Upgrade all extensions**: `gh extension upgrade --all`
     - Verify the upgrade: `gh extension list --json name,version` and confirm versions are updated.
3. Write the aliases/extensions management summary (operation, names, expansions/versions, verification results) to the artifact path.

## Exit Criteria

- The requested alias or extension operation has been executed
- Each operation has been verified (set confirmed, delete confirmed, install confirmed, remove confirmed)
- The management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<operation type, names, expansions/versions>"
artifact_path: "<path to management summary>"
blocker_reason: "<reason if BLOCKED>"
```
