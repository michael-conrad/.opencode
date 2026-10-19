---
name: multimodal-dispatch
description: "Load for ANY image work — reading or analyzing image files, screenshots, PDF reading via page images, or image analysis — before any image data enters the primary session. Also load when routing work to models by content modality, when probing Ollama/local model capabilities to pick the right model for a task, or when a sub-agent's task clearly needs a capability the current model lacks."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #582 yaml-contract-format convention; native-first rule + reference link, .opencode#2567; image-work dispatch mandate, .opencode#2640 -->

# multimodal-dispatch

1. **Classify the modality** first: text reasoning, code, vision/screen
   inspection, audio. The modality chooses the model — not habit.
2. **Image ingestion is dispatched.** A task that would ingest image data
   into the primary session's context — screenshot capture, PDF page-image
   extraction, image-file reading, image analysis, and similar — goes to a
   sub-agent when possible; the primary never reads, captures, or extracts
   that image material itself while dispatch is possible, and thereafter
   works from the sub-agent's textual report, not from the image data. Route
   by work class: visual design and artifact production →
   `visual-design-agent`; image inspection, analysis, transcription, and QA →
   a general-purpose subagent. When
   dispatch is not viable — the material already sits in the primary session
   with no file-path representation to hand off, or no sub-agent can take the
   work — the primary analyzes natively and never ingests the same image
   material twice: after dispatch it works from the textual report and never
   re-derives the image content itself (no independent decodes, re-reads, or
   captures to double-check the sub-agent); under the
   escape it works from the data it already holds without new captures,
   extractions, or re-reads. For remaining native vision work, prefer the
   invoking model's own multimodal capability — dispatch for context
   separation or bulk work, not because a "vision specialist" exists. Visual
   critique follows
   [references/vision-critique.md](references/vision-critique.md).
3. **Probe capabilities** when the target model's abilities are unknown
   (`ollama-probe` / live check) rather than assuming.
4. **Dispatch with context.** Sub-agents get the scoped goal and the material
   they need — clean-room, no orchestrator narration.
5. **Report provenance** of model-routed results (which model produced what)
   when outcomes feed decisions.

**Agent-to-agent format:** structured data one agent creates for another — or
ingests from another — defaults to YAML, marked by the bare `(YAML)` token at
each reference; tool I/O, CLI output, and external configuration keep their
native format; chat prose carries no token.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
