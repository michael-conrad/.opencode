---
name: gb-cli
description: "Load before any command or code that contacts GitBucket — using the gb CLI, GitBucket API calls, or anything needing GitBucket credentials for issues, pull requests, releases, or repository operations. Also load when authoring or running test-harness scenarios, scripts, or automation that will invoke gb or GitBucket endpoints at runtime, and when any GitBucket operation fails or behaves unexpectedly. Authentication is built into gb; never hand-roll GitBucket API code or hunt for credentials. One load does not carry across operation classes: before your first GitBucket contact in a new class (issues ↔ pull requests ↔ API passthrough), load this card again — even though it is already in context."
license: MIT
provenance: AI-authored, .opencode#2490; .opencode#2564; .opencode#2589; .opencode#2547; .opencode#2382; closing-keyword contract, .opencode#2658
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; .opencode#2564; .opencode#2589; .opencode#2547; .opencode#2382; closing-keyword contract, .opencode#2658 -->

# gb-cli — GitBucket operations

1. **Auth first.** Verify gb authentication before operations; credentials are
   the CLI's job — no bespoke auth code, no credential hunting.
2. **Prefer native commands.** Issues, PRs, labels, milestones, releases have
   gb subcommands; `gb api` is the passthrough for gaps. Pass content-bearing
   arguments from files — the preferred pattern is
   `--long-option="$(cat file.md)"` (e.g. `gb issue comment 12
   --body="$(cat msg.md)"`, `gb pr create --body="$(cat body.md)"`); `gb api`
   JSON payloads go via `--input <file|->`.
3. **Construct carefully, inspect output.** Verify command shape; inspect real
   output rather than assuming success. `gb <cmd> --help` before guessing.
   Before every gb contact, run the class check —
   - last gb class contacted: issues / PRs / API / none
   - class of the command about to run
   - different class → load this card again first (one load does not carry
     across classes).
4. **Platform awareness.** GitBucket API differs from GitHub's — consult the
   gb help, not GitHub assumptions, when behavior surprises. Known gaps:
   plain-issue state mutation is absent from GitBucket's GitHub-compatible
   API (`PATCH .../issues/{n}` → 404). PR state mutation is conditional:
   the raw `PATCH .../pulls/{n}` endpoint accepts `state`, but `gb pr close`
   fails with HTTP 404 on GitBucket in every condition observed
   (.opencode#2382, pinned by reproduction: head branch deleted, base branch
   deleted, both deleted, and even with branches intact). Close a PR with
   `gb pr edit <N> --state closed --web` instead — the `--web` fallback
   prompts for the GitBucket password on a terminal; `gb pr edit` without
   `--web` reports "REST PR edit is unavailable" on GitBucket.
   The merge itself is a human gate — the agent merges nothing; read the
   human-merge-gate statements in this deck's PR card and its instruction
   floor. Closing a pull request is not merging
   it: the raw `PATCH .../pulls/{n}` endpoint with `state: closed` closes
   the PR without merging and produces no closing-keyword closure of the
   linked issues. GitBucket's issue API reports `state` but not
   `closed_at`.
5. **Non-interactive issue state changes.** Close/reopen an issue in scripts
   via the comments route's `action` parameter:
   `gb api -X POST repos/{owner}/{repo}/issues/{number}/comments?action=close --input <file|->`
   (`?action=reopen` to reopen). The JSON body must be
   non-empty (e.g. `{"body":"closing"}`); token auth; each change writes the
   same system comment the web UI button writes. Never implement this with
   session cookies or account passwords.
6. **Failures are information.** Diagnose from stderr; never retry blind.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
