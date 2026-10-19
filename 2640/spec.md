## Summary

When the primary session performs image work — taking screenshots, reading PDFs via their page images, analyzing image files — the image data enters the primary session's context. Image payloads are token-heavy; the session saturates quickly and enters a compaction loop that repeats because the image data appears to be retained across compactions (developer-observed, 2026-10-19).

The fix is a routing rule, not a platform change: any task that would ingest image data into the primary session's context is dispatched to a sub-agent when possible, and the primary works from the sub-agent's textual report. The change surface is one deck skill card — `multimodal-dispatch` — amended in its description (the router) and its body (the dispatch mandate). No new agent card: the developer decided the change is "only a skill card change" (2026-10-19), with the deck's existing sub-agents as dispatch targets.

## Developer statements (provenance)

Traceability sources — all from the 2026-10-19 session unless noted:

- D1: "the agent needs to prefer the use of general or specific sub-agents when doing any type of image work"
- D2 (observed failure): "the main session quickly saturates and ends up in a compaction loop as it seems the image data is kept across compactions"
- D3: "this should include things like screen shots, pdf reading via images, etc."
- D4: "do we need to setup an agent card so that auto routing works for any image work?" — resolved by D6: no agent card.
- D5 (hypothesis, not established): "Could it be an issue with remote caching kicking in causing the image data to be re-sent every turn, even after compaction?"
- D6: "for the main use case where the agent is taking screen shots, extracting images from PDFs, etc, these all should be handled by a sub-agent when possible. only a skill card change is warranted based on this."

## Root Cause

The deck's `multimodal-dispatch` card directs native-first image work: "Prefer the invoking model's own multimodal capability — dispatch vision work to a subagent only for context separation or bulk work, not because a 'vision specialist' exists." Nothing in the deck makes screenshot capture, PDF page-image extraction, or image-file reads dispatch-mandatory, so the primary ingests the image data itself. The card's context-separation exception exists but is optional, and no deck rule treats image bytes as a dispatch trigger. The card previously governed a now-retired `vision-specialist` agent; the native-first rule and the caller-agnostic rubric date from that retirement (.opencode#2567), before this failure mode was observed.

## Classification

- **Pattern**: context-economics defect — image payloads retained in primary-session context across compactions
- **Substrate**: deck card directive (the `multimodal-dispatch` native-first rule and its description's trigger coverage)
- **Risk**: session-level — compaction loops waste cycles, degrade reasoning quality, and can truncate long sessions (observed, D2)

## Evidence

Deck-state facts, all verified against the live tree 2026-10-19:

- `.opencode/skills/multimodal-dispatch/SKILL.md` — rule 2 carries the native-first directive quoted under Root Cause; the description claims "vision tasks, image or screen inspection" but names no screenshot or PDF triggers, and the body carries no image-ingestion dispatch mandate.
- `.opencode/skills/multimodal-dispatch/references/vision-critique.md` — already caller-agnostic; its "Image-as-file-path mechanics" section documents that subagents receive file paths and must read the images themselves. The dispatch pattern this spec mandates is already mechanically supported; the rubric travels with the dispatch unchanged.
- Subagent inventory (verified across `.opencode/agents/` and `.opencode/agent/`): `visual-design-agent` (production), `email-ops`, `math-ops`, `notebook-ops`, plus the platform `general` agent. No dedicated image-inspection agent card exists as of 2026-10-19 — consistent with the developer's decision (D6) that none is needed.
- Observed failure D2 (developer, 2026-10-19): the primary session saturates during image work and enters a compaction loop; image data appears retained across compactions. Mechanism unverified: the remote-caching hypothesis (D5) has not been tested — a research dispatch for it was cancelled before executing. No criterion in this spec depends on the mechanism.
- GLM-5.3-Flash sampling envelope: research card `glm-5.3-flash-agent-card-settings` (confidence 0.85, sources verified 2026-10-09) — vendor-recommended temperature 1.0 / top_p 0.95; sampling knobs are orthogonal to context retention, so no parameter change is part of this fix.

## Approach

- The card description front-loads the image-work classes it governs (images, screenshots, PDF reading via page images, image analysis) so platform intent-matching loads the card for any image-work task.
- The card body's native-first rule gains a deliberate exception for image ingestion: a task that would ingest image data into the primary session's context is dispatched to a sub-agent when possible; the primary receives the sub-agent's textual analysis and works from that text, not from the image. Rule 2's closing cross-reference to `references/vision-critique.md` — the card's only live link to the rubric — is preserved and re-anchored to the dispatch mandate.
- Dispatch routing by work class: visual design and artifact production → the existing `visual-design-agent` subagent; image inspection, analysis, transcription, and QA → a general-purpose subagent.
- Escape ("when possible," developer-stated): when dispatch is not viable — the image data is already in the primary session with no file-path representation available to hand off, or no sub-agent can take the work — the primary analyzes natively and does not compound the ingestion: on either path it never ingests the same image material twice (no re-reads, re-captures, or re-extractions of material it already holds).
- The edit is developer-directed (2026-10-19), so the skill-creator admission gate's proposal-time evidence hunt does not re-run; the card standards still bind the written text: lean body, added detail one level deep in `references/` (the vision-critique rubric is already there and caller-agnostic), description-as-router discipline, root-agnostic prose, and predicate classification — the dispatch mandate is intent-decidable (judgment decides "when possible"), and no scripted enforcement is specified.

## Requirements

- R-1. The `multimodal-dispatch` card description SHALL name the image-work classes it governs — images, screenshots, PDF reading via page images, image analysis — so that intent matching loads the card for any image-work task.
- R-2. The card body SHALL mandate that a task which would ingest image data into the primary session's context — screenshot capture, PDF page-image extraction, image-file reading, image analysis, and similar — be dispatched to a sub-agent when possible, and SHALL state that the primary thereafter works from the sub-agent's textual report rather than from the image data.
- R-3. The card body SHALL name the dispatch targets by work class: visual design and artifact production → the `visual-design-agent` subagent; image inspection, analysis, transcription, and QA → a general-purpose subagent.
- R-4. The card body SHALL state the escape: when dispatch is not possible, the primary agent may work natively; and the card SHALL state that the primary never ingests the same image material twice — after dispatching, the primary works from the sub-agent's textual report; under the escape, the primary works from the image data it already holds without new captures, extractions, or re-reads of that material.
- R-5. The amendment touches exactly two surfaces, each in a stated way: the native-first rule (rule 2) gains the image-ingestion exception of R-2 while preserving its closing cross-reference to `references/vision-critique.md` — the card's only live link to the rubric; and the description's trigger sentence gains the image-work classes of R-1 while its non-image clauses survive. Every other pre-change rule and trigger — modality classification, capability probing, dispatch-with-context (clean-room, no orchestrator narration), provenance reporting, the agent-to-agent format note — SHALL survive. The body SHALL stay lean, placing any added detail one level deep in `references/`.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | The card description names images, screenshots, PDF reading via page images, and image analysis (R-1). | structural | Read the card's frontmatter; assert all four trigger classes appear in `description`. |
| SC-2 | The card body mandates dispatch of image-ingestion work (screenshot capture, PDF page-image extraction, image-file reading, image analysis) and states the primary works from the sub-agent's textual report (R-2). | structural | Read the card body; assert the mandate names each ingestion class and the text-report rule. |
| SC-3 | The card body routes dispatch targets by work class (R-3). | structural | Read the card body; assert `visual-design-agent` is named for production work and a general-purpose subagent for inspection, analysis, transcription, and QA. |
| SC-4 | The card body states the when-possible escape and the no-compounding rule covering both the dispatch path and the escape path (R-4). | structural | Read the card body; assert the escape statement and the never-ingests-the-same-material-twice rule stated for both paths. |
| SC-5 | Every pre-change card rule and description clause survives the amendment except the two amended surfaces — rule 2's native-first directive (which gains the R-2 exception and keeps its vision-critique cross-reference) and the description's trigger sentence (which gains the R-1 image classes and keeps its non-image clauses) — and explanatory or example detail introduced by the amendment lives in the card's `references/`, not in the card body (R-5). | structural | Diff the amended card against the pre-change card (trunk state): the diff's removed or rewritten lines are confined to rule 2's native-first directive and the description's trigger sentence; clause-level comparison of the two descriptions shows every pre-change non-image clause (modality-routing frame, capability probing, sub-agent capability gap) present in the amended description; the amended card retains the `references/vision-critique.md` link; modality classification, capability probing, dispatch-with-context, provenance reporting, and the agent-to-agent format note survive in the body; new body lines are confined to the dispatch mandate, target routing, and escape statements; any further added content sits in `references/` files. |
| SC-6 | In a live opencode run given an image-work task, the primary session ingests no image data: no primary-session reads of image files, no primary-session screenshot capture, and zero image attachments in primary-session messages. | behavioral | tests-v2 behavioral scenario; assert from the session store (tool-call events and message parts) that the primary performed no image ingestion. |
| SC-7 | In the same run, the image reading or capture is performed by a dispatched sub-agent (receiving file paths where the material already exists on disk), and the primary's final answer reflects the sub-agent's textual report. | behavioral | Same scenario; assert the task-dispatch event carries a file path rather than image data, the sub-agent's session shows the image work, and the primary's answer is consistent with the sub-agent's report. |
| SC-8 | In a run where the image material enters the primary session as a user attachment with no file-path representation available, the primary performs no new image ingestion of that material beyond the initial attachment — no re-reads, re-captures, or re-extractions — whether it analyzes natively or dispatches after establishing a path representation. | behavioral | tests-v2 behavioral scenario with an image attached in the opening prompt; assert from the session store that no image-ingestion tool call or image-bearing message part appears in the primary session after the initial attachment. |

The structural criteria are content checks run against the amended file. The behavioral criteria run under the tests-v2 harness; the behavioral-testing card governs the instrument at implementation time.

## Impact

- **Consumers**: every session performing image work — browser screenshots (`playwright-cli` workflows), desktop captures, PDF inspection, image-file analysis; and the card's existing consumers (modality classification, capability probing, provenance reporting).
- **Blast radius**: one card's description and body, plus at most added detail in the card's `references/`. The card is a submodule file; the submodule pointer rides with a real parent-repo change per submodule pointer discipline.
- **Risk**: trivial image glances now pay dispatch latency; the "when possible" escape keeps native analysis available where dispatch cannot serve. Against the observed failure mode — a session lost to a compaction loop — that overhead is the cheaper cost.

## Out of scope

1. New agent cards — the developer decided against one (2026-10-19); existing sub-agents are the dispatch targets.
2. Edits to `references/vision-critique.md` — the rubric is already caller-agnostic and travels with the dispatch unchanged.
3. Platform-level mitigations (plugin hooks that strip image parts from messages, config knobs) — a mechanism-dependent surface; the compaction/caching mechanism is not established. Separate ticket if pursued.
4. Establishing the retention mechanism (the remote-caching hypothesis) — recorded as open; no criterion in this spec depends on it.
5. Sampling-parameter changes (temperature, top_p) — moot with no new agent card, and orthogonal to context retention (the GLM-5.3-Flash vendor envelope is temperature 1.0 / top_p 0.95; research card `glm-5.3-flash-agent-card-settings`, confidence 0.85, sources verified 2026-10-09).
6. Amendments to adjacent cards (`playwright-cli`, tests-v2 screenshot workflows) — the developer scoped the change to the `multimodal-dispatch` card; adjacent cards route through their own triggers.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
