---
name: gb-cli
description: "Load before any command or code that contacts GitBucket — using the gb CLI, GitBucket API calls, or anything needing GitBucket credentials for issues, pull requests, releases, or repository operations. Authentication is built into gb; never hand-roll GitBucket API code or hunt for credentials. Also load when GitBucket operations fail unexpectedly."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# gb-cli — GitBucket operations

1. **Auth first.** Verify gb authentication before operations; credentials are
   the CLI's job — no bespoke auth code, no credential hunting.
2. **Prefer native commands.** Issues, PRs, labels, milestones, releases have
   gb subcommands; `gb api` is the passthrough for gaps.
3. **Construct carefully, inspect output.** Verify command shape; inspect real
   output rather than assuming success. `gb <cmd> --help` before guessing.
4. **Platform awareness.** GitBucket API differs from GitHub's — consult the
   gb help, not GitHub assumptions, when behavior surprises.
5. **Failures are information.** Diagnose from stderr; never retry blind.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
