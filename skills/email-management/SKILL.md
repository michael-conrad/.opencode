---
name: email-management
description: "Load when the session involves email — gmail, inbox, drafts, sending, or mail searches: recognize the intent and dispatch gmail tool work to the email-ops subagent, which holds the gmail tool permissions. Drafting defaults to a dry run, and every outward-facing send requires explicit developer instruction in the session."
license: MIT
provenance: AI-authored, .opencode#2532
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2532 -->

# email-management — search, read, and draft mail in an existing desktop profile

Mail lives in a profile maintained by a desktop mail application; the agent
never creates accounts or profiles — it operates on what already exists,
through a local command-line tool over that profile. All tooling identity,
install steps, and command syntax live one level down in the details cards so
the router surface here survives a tool replacement.

1. **Setup only on real need.** The tool is not preinstalled. Follow
   [references/install.md](references/install.md) when a session actually
   needs mail access — checksum-verified download, runtime verification, and
   profile discovery included — and keep the installed binary for later
   sessions.
2. **Verify the machine first.** Before any mail operation on an unfamiliar
   machine, run the tool's runtime-verification command; its live report
   overrides every written prerequisite. Search and read are read-only; the
   profile is treated as immutable data.
3. **Search before read; trust the returned next command.** Prefer the
   one-shot natural-language search over composing manual filters; every
   result carries the exact command to open the message — use it verbatim.
   The workflow, including threads and attachment extraction, is in
   [references/search-read.md](references/search-read.md).
4. **Draft is dry-run; send is a human decision.** Reply/compose commands
   print what they would send and deliver nothing until explicitly told to.
   A real send requires an explicit developer instruction in the current
   session, and success is verified against the server, never a local
   Sent-folder read. Discipline and the send-verification commands:
   [references/draft-send.md](references/draft-send.md).
5. **Negative results are evidence only when scoped.** When a search finds
   nothing, the tool names the folders it actually searched — quote that
   scope in any "no such mail" conclusion instead of assuming the wrong
   mailbox.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
