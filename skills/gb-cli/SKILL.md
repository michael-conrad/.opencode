---
name: gb-cli
description: "Load before any command or code that contacts GitBucket — using the gb CLI, GitBucket API calls, or anything needing GitBucket credentials for issues, pull requests, releases, or repository operations. Also load when authoring or running test-harness scenarios, scripts, or automation that will invoke gb or GitBucket endpoints at runtime, and when any GitBucket operation fails or behaves unexpectedly. Authentication is built into gb; never hand-roll GitBucket API code or hunt for credentials."
license: MIT
provenance: AI-authored, .opencode#2490; .opencode#2564
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; .opencode#2564 -->

# gb-cli — GitBucket operations

1. **Auth first.** Verify gb authentication before operations; credentials are
   the CLI's job — no bespoke auth code, no credential hunting.
2. **Prefer native commands.** Issues, PRs, labels, milestones, releases have
   gb subcommands; `gb api` is the passthrough for gaps.
3. **Construct carefully, inspect output.** Verify command shape; inspect real
   output rather than assuming success. `gb <cmd> --help` before guessing.
4. **Platform awareness.** GitBucket API differs from GitHub's — consult the
   gb help, not GitHub assumptions, when behavior surprises. Known gap
   (#2564): GitBucket implements NO issue state mutation over its
   GitHub-compatible API (`PATCH .../issues/{n}` with `state` → 404), so
   `gb issue close`/`reopen` fall back to an interactive web flow that needs
   a TTY and fails in scripts and harness runs.
5. **Non-interactive state changes.** For closing/reopening an issue without
   a terminal, use the `gitbucket-issue-state` tool (session-cookie web
   route; requires `GB_PASSWORD`/`GB_USER` — GitBucket offers no token-based
   state mutation). Do not re-implement that route with curl anywhere else.
6. **Failures are information.** Diagnose from stderr; never retry blind.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
