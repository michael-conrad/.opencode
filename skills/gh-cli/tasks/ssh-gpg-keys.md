<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Lists, adds, and deletes SSH and GPG keys on the GitHub account using `gh ssh-key` and `gh gpg-key` commands for credential management.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The operation type (list, add, delete) and key type (ssh, gpg) are provided in the task context
- For add operations: the public key file path or key content string is provided
- For delete operations: the key ID is provided
- `gh` CLI must be installed and on PATH

## Procedure

1. If the operation is `list` for SSH keys:
   - `gh ssh-key list --json id,key,title,createdAt,updatedAt`
   - Parse the JSON output and note key fields (id, title, fingerprint).
   - If the list is empty, return DONE with `finding_summary: "No SSH keys found"`.
2. If the operation is `add` for SSH keys:
   - `gh ssh-key add <key-file-path> --title "<title>"`
   - If the key content is provided as a string, write it to a temp file first, then add from the file.
   - Verify the key was added: `gh ssh-key list --json title,createdAt` and confirm the new title appears.
3. If the operation is `delete` for SSH keys:
   - `gh ssh-key delete <key-id>`
   - Verify the key was deleted: `gh ssh-key list --json id` and confirm the key ID no longer appears.
4. If the operation is `list` for GPG keys:
   - `gh gpg-key list --json id,key_id,email,createdAt,expiresAt`
   - Parse the JSON output and note key fields (key_id, email, expiration).
   - If the list is empty, return DONE with `finding_summary: "No GPG keys found"`.
5. If the operation is `add` for GPG keys:
   - `gh gpg-key add <key-file-path>`
   - If the key content is provided as a string, write it to a temp file first, then add from the file.
   - Verify the key was added: `gh gpg-key list --json key_id,email` and confirm the new key appears.
6. If the operation is `delete` for GPG keys:
   - `gh gpg-key delete <key-id>`
   - Verify the key was deleted: `gh gpg-key list --json id` and confirm the key ID no longer appears.
7. Write the key management summary (key type, operation, key IDs/titles, verification results) to the artifact path.

## Exit Criteria

- The requested key operation (list/add/delete) has been executed for the correct key type (SSH/GPG)
- Each operation has been verified (add confirmed, delete confirmed)
- The key management summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<key type, operation, key IDs/titles>"
artifact_path: "<path to key management summary>"
blocker_reason: "<reason if BLOCKED>"
```
