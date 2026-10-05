<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->
---
name: playwright-cli
description: Load before any browser automation — navigating pages, filling forms, capturing snapshots, verifying web UIs, scraping rendered content, or recording browser traces. Use when a web interaction must be observed rather than assumed; close managed browser sessions when done.
license: MIT
provenance: AI-authored, .opencode#2490
---

# playwright-cli — browser automation

1. **Snapshot first.** Capture the page state before acting; navigate by
   observed structure, not by guessed selectors.
2. **Act, then verify.** Each interaction (fill, click, submit) is followed by
   a snapshot or assertion of the resulting state.
3. **Sessions.** Manage browser lifecycle deliberately — reuse a session for
   related steps, close it when done; never leave orphan browsers.
4. **Storage state** (cookies/local storage) is saved and restored for login
   flows instead of re-authenticating per step.
5. **Evidence.** Snapshots and traces are the verification artifacts for
   UI-work claims.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
