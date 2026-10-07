---
name: research
description: "Load when information is needed beyond current context — web research on tools, APIs, models, or practices; codebase or document investigation; verifying a claim against live sources; gathering evidence for root-cause analysis. Dispatches scoped research sub-agents while conversation continues; findings carry source URLs and explicit gap reporting. Never answer factual questions from training data without a live check."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #582 yaml-contract-format convention -->

# research — information discovery

1. **Check the catalogue first.** `.issues/research-cards/` may already hold a
   confident answer (confidence ≥ 0.7, current) — reuse it before dispatching.
2. **Dispatch scoped sub-agents** for web/heavy research: one clear question
   per dispatch, primary sources preferred, snippets never trusted without
   fetching the page.
3. **Every finding carries its source** (URL, date) and an honest confidence
   level. Gaps are stated, not papered over.
4. **Live verification.** Facts about the world, tools, or APIs are checked
   against current sources in this session — training data is a liability.
5. **Record back.** Write or update a research card so the next session
   inherits the finding instead of re-paying for it.

**Agent-to-agent format:** structured data one agent creates for another — or
ingests from another — defaults to YAML, marked by the bare `(YAML)` token at
each reference; tool I/O, CLI output, and external configuration keep their
native format; chat prose carries no token.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
