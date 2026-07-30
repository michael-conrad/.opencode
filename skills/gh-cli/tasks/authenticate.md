<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Verifies `gh` CLI authentication status and establishes authenticated sessions when missing, including optional configuration of host and protocol settings.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh` CLI must be installed and on PATH
- The target host (e.g., `github.com` or GitHub Enterprise URL) must be known
- The project root must be set

## Procedure

1. Run `gh auth status` to check current authentication state.
   - If the command exits 0 (authenticated), note the logged-in account and host, then proceed to Step 4.
   - If the command exits non-zero (not authenticated), proceed to Step 2.
2. Run `gh auth login` with the appropriate flags:
   - For `github.com`: `gh auth login --web` (interactive browser flow) or `gh auth login --with-token < token.txt` (non-interactive).
   - For GitHub Enterprise Server: `gh auth login --hostname <hostname> --web`.
   - If a token file is available at a known path, use `--with-token` for non-interactive setup.
3. Verify authentication by running `gh auth status` again. If it exits non-zero, return BLOCKED with the failure reason.
4. If the target host or git protocol requires non-default configuration, run `gh config set` as needed:
   - `gh config set git_protocol ssh --host <host>` to prefer SSH over HTTPS.
   - `gh config set editor <editor>` to set the default editor.
   - Verify each config change with `gh config get <key> --host <host>`.
5. Write the authentication summary (account, host, protocol, config keys set) to the artifact path.

## Exit Criteria

- `gh auth status` exits 0 for the target host
- All required config keys have been verified
- The authentication summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<authenticated account, host, and config keys set>"
artifact_path: "<path to authentication summary>"
blocker_reason: "<reason if BLOCKED>"
```
