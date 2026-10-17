<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2382 (R-1 reproduction transcript) -->

# R-1 Reproduction — `gb pr close` 404 condition, pinned 2026-10-17

Environment: tests-v2 harness self-contained GitBucket container
(`tests-v2-gitbucket`, provisioned per tests-v2/AGENTS.md §12 via
`__ensure_gitbucket` in `tests-v2/docker/docker-harness.sh`; GitBucket WAR
current latest release; port 32789; admin `root`, token-minted). Scratch
repository `root/test-repo`. Non-production; no production repository was
touched. `gb pr edit --help` confirms `--state <open|closed>` and `--web`
("Allow GitBucket web UI fallback when REST PR edit is unavailable") exist.

Method: git pushes over HTTP with token auth; PRs created with
`gb pr create`; branch deletion via `git push origin --delete`; the `--web`
fallback is interactive (prompts for the GitBucket password), so it was
driven under a Python `pty` session feeding the password.

## Per-condition results

| Case | PR | Condition | `gb pr close <N>` | `gb pr edit <N> --state closed --web` |
|---|---|---|---|---|
| A | #1 (head `feature-a`) | head deleted | `Error: API error (404): {"message":"Not Found"}`, exit 1 | `✓ Updated pull request #1: PR-A` — closed (verified absent from open list) |
| B | #4 (base `base-b`) | base deleted | `Error: API error (404)`, exit 1 | `✓ Updated pull request #4` — closed |
| C | #5 (base `base-c`, head `feature-e`) | both deleted | `Error: API error (404)`, exit 1 | `✓ Updated pull request #5` — closed (verified `state: closed` via `gb api`) |
| control | #3 (base `main`, head `feature-c`) | **branches intact** | `Error: API error (404)`, exit 1 — PR stayed OPEN | (not needed) |
| control | #2 (branches intact) | branches intact | — | REST path without `--web`: `Error: REST PR edit is unavailable on this GitBucket instance. Re-run with --web…` |

## Findings (the pinned condition set)

1. **`gb pr close` returns HTTP 404 on GitBucket in every condition tested —
   including the intact-branches control.** The 404 is not gated on deleted
   branches; deleted head/base/both and intact branches all produced the
   same `API error (404)`. The command is unusable on this GitBucket,
   unconditionally as observed.
2. **`gb pr edit <N> --state closed --web` succeeded in all deleted-branch
   conditions** (head-only, base-only, both) and closed each PR. It prompts
   for the GitBucket password on a terminal — non-TTY invocation fails with
   `Error: Prompt error: IO error: not a terminal`.
3. **`gb pr edit <N> --state closed` without `--web` fails with "REST PR
   edit is unavailable on this GitBucket instance"** even with branches
   intact — the CLI's own REST path self-reports unavailability.
4. **Raw `PATCH /api/v3/repos/{o}/{r}/pulls/{n}` with `{"state":"closed"}`
   returned 200 and did change the PR state** (PR #2 closed by direct
   PATCH) — the §4 claim "`PATCH .../pulls/{n}` accepts `state`" is true at
   the raw API level; the defect is in `gb pr close`'s route, not the
   PATCH endpoint.

Caveat wording for the card follows finding 1's condition: the 404 fires
regardless of branch state; recovery is `gb pr edit <N> --state closed
--web` (interactive password prompt; requires a terminal).

---
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
