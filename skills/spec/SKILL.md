---
name: spec
description: Load when creating or revising a specification document — success criteria, evidence types, traceability. Also load when a spec needs revision from review findings. Success criteria come from the developer's stated requirements and observed failures only — inventing extra criteria is scope creep. Every criterion is classified behavioral (runtime effect) or structural by its nature, and carries a verification instrument.
license: MIT
provenance: AI-authored, .opencode#2490
---

# spec — specification creation and revision

1. **Extract, don't invent.** Requirements come from the developer's statements
   and the exploration record. If a criterion cannot be traced to a developer
   statement or an observed failure, delete it — that is the scope-creep guard.
2. **Every SC is testable.** State what to check and how: behavioral SCs get a
   runtime verification instrument; structural SCs get a fact-decidable check.
   Evidence types are classified by the change's nature, not by intent.
3. **Write and persist.** `local-issues create` (or update); `spec.md` in the
   issue directory; the issue body mirrors the spec.
4. **Revision discipline.** Findings from review produce targeted revisions;
   superseded criteria are removed, never accumulated. No STATUS fields — the
   spec defines what is required, implemented or not.
5. **Approval is a human gate.** The spec waits for the developer's
   authorization before `plan`.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
