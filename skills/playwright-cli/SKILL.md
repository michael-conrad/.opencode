---
name: playwright-cli
description: "Load before any browser automation — navigating pages, filling forms, capturing snapshots, verifying web UIs, scraping rendered content, or recording browser traces. Use when a web interaction must be observed rather than assumed; close managed browser sessions when done. Also load during web research when a JS-heavy page comes back as shell HTML from search/fetch tooling — render it and observe what the page actually shows — or when web content must be verified interactively."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# playwright-cli — browser automation

**Provisioning.** The CLI is vendored per-project at `<project-root>/.tools/node/`
(gitignored; a fresh checkout has none) — invoke it PATH-prefixed:
`PATH=<project-root>/.tools/node/bin:$PATH playwright-cli …`. Full setup
runbook: [references/install.md](references/install.md).

## Browser-session defaults

The default launch for interactive web
surfaces is one pairing — Microsoft Edge channel plus the durable saved
profile: `--browser msedge --persistent --profile ~/.cache/ms-playwright/daemon/ud-bl-persist --headed`.
Stated defaults, not per-session judgment: the pairing passes
bot-wall/browser-security checks and preserves saved logins across
sessions. Headless or throwaway-profile launches are explicit **non-default
fallbacks** for clean, API-shape checks only — not research defaults.
**Per-site exception:** msedge is the default, not a per-site mandate — where
a particular site demonstrably works better under a different browser, that
browser serves that site. The exception is site-scoped and
observation-bound: it is a named deviation backed by an observed result,
never an improvised alternate channel and never a wholesale channel
downgrade; every site without such an observation keeps the default.
Provisioning, the default launch recipe, and the login-once flow (planting
saved logins in the profile): Read [the provisioning runbook](references/install.md).

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
