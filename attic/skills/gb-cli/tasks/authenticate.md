<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Verifies `gb` CLI authentication status and establishes authenticated sessions when missing, including version pinning and configuration of host and protocol settings.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb` CLI must be installed and on PATH
- The target host (e.g., `https://gitbucket.example.com` or a base URL) must be known
- The project root must be set

## Procedure

1. Run `gb --version` to verify the CLI is installed and reports version `>= 0.6.1`.
   - If the command is not found, return BLOCKED with `reason: TOOL_MISSING`.
   - If the version is below `0.6.1`, return BLOCKED with the reported version as the blocker reason. Read [the version pinning requirement](.opencode/AGENTS.md).
2. Run `gb auth status -H <host>` to check current authentication state for the target host.
   - If the command exits 0 (authenticated), note the logged-in account and host, then proceed to Step 5.
   - If the command exits non-zero (not authenticated), proceed to Step 3.
3. Run `gb auth login -H <host> -t <token> --protocol <http|https>` to authenticate non-interactively.
   - Obtain the token from the task context, environment, or a secrets source — never fabricate or guess a token.
4. Verify authentication by running `gb auth status -H <host>` again. If it exits non-zero, return BLOCKED with the failure reason.
5. If the target host or protocol requires non-default configuration, run `gb config set <key> <value>` as needed:
   - Verify each config change with `gb config get <key>`.
   - Read [the config commands reference](.opencode/AGENTS.md) for supported config keys.
6. Write the authentication summary (account, host, protocol, version, config keys set) to the artifact path.

## Exit Criteria

- `gb --version` reports `>= 0.6.1`
- `gb auth status -H <host>` exits 0 for the target host
- All required config keys have been verified
- The authentication summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<authenticated account, host, protocol, version, config keys set>"
artifact_path: "<path to authentication summary>"
blocker_reason: "<reason if BLOCKED>"
```
