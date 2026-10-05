<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->
---
name: multimodal-dispatch
description: Load when routing work to models by content modality — vision tasks, image or screen inspection, or when probing Ollama/local model capabilities to pick the right model for a task. Also load when a sub-agent's task clearly needs a capability the current model lacks.
license: MIT
provenance: AI-authored, .opencode#2490
---

# multimodal-dispatch

1. **Classify the modality** first: text reasoning, code, vision/screen
   inspection, audio. The modality chooses the model — not habit.
2. **Probe capabilities** when the target model's abilities are unknown
   (`ollama-probe` / live check) rather than assuming.
3. **Dispatch with context.** Sub-agents get the scoped goal and the material
   they need — clean-room, no orchestrator narration.
4. **Report provenance** of model-routed results (which model produced what)
   when outcomes feed decisions.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
