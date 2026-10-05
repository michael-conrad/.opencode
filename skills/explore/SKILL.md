---
name: explore
description: "Load when requirements are being explored, decomposed, or brainstormed before a spec exists — open-ended discussion of what to build, problem decomposition, design tradeoffs. One topic at a time, no constrained-choice prompts, research dispatches continue during discussion. Design approval is NOT finalization: only the developer's explicit final statement moves this to spec creation."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# explore — requirements exploration

- One question per message. Follow the developer's answers; dimensions are an
  internal checklist, never output sections.
- Discuss deeply: challenge assumptions, edge cases, counterarguments,
  trade-offs — stated explicitly.
- Research during discussion is normal: dispatch research sub-agents without
  halting the conversation. Every finding gets a live tool call behind it.
- Analytical artifacts (blast radius, concern map, code paths) are produced
  **when the change actually touches those surfaces** — not as a fixed set.
- **Finalization gate:** design approval is raw input to `spec`. Only an
  explicit, unforgeable developer statement that the design is final ends this
  stage. Never infer it from silence, agreement with sections, or momentum.
  Refinements and clarifications are not finalization. A terminal-stage
  approval (`approved for pr`, …) from the vocabulary in `floor.md` is such a
  statement — it finalizes the design and carries the item onward.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
