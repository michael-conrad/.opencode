---
name: issues
description: "Load when creating, reading, updating, commenting on, linking, or closing any issue — local .issues/ stores, GitHub, or GitBucket. Covers qualified issue names, platform routing via the authenticated CLIs, the local-issues tool, and the comment substantiveness gate: non-substantive progress updates stay in chat and never become issue comments."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# issues — issue operations

1. **Routing.** Local stores go through `.opencode/tools/local-issues` with
   qualified names (`repo#N`); remote operations go through the platform CLI
   (`gh` / `gb`) — authenticated tools, never raw API scripts.
2. **Creation.** Title states the work; body carries the spec/proposal with
   attribution byline. Labels describe pipeline state.
3. **Comment gate.** Post only substantive content — findings, decisions,
   evidence. Progress narration ("working on it", "halfway done") stays in
   chat. Internal audit findings go to chat, never to stakeholder channels.
4. **Relationships.** Link sub-issues to parents; the hierarchy carries the
   authorization cascade and closure order.
5. **Closure.** Issue closure follows delivered work (post-merge cleanup) or
   explicit developer instruction — never closure to tidy up.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
