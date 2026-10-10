---
number: 2567
title: "[SPEC] Agent card updates: unpin models, retire vision-agent, GLM-5.3-Flash-aligned profiles"
state: OPEN
labels: [spec]
---

## Problem Statement

The deck's two agent cards pin `model: ollama-cloud/qwen3.5:397b-cloud` — a
model id that does not resolve in opencode's provider catalog: the listed
cloud id is `ollama-cloud/qwen3.5:397b`; the `-cloud`-suffixed form is the
ollama CLI tag. Because subagent dispatch is intent-matched against card
descriptions, vision-flavored tasks are steered into a card whose model
reference cannot resolve.

The cards' sampling profiles are qwen-era (temperature 0.3–0.8, top_k 20–40,
presence_penalty 1.5–2.0). The session primary, GLM-5.3-Flash, is natively
multimodal — making a vision-specialist subagent redundant — and its
vendor-recommended profile is temperature 1.0 / top_p 0.95 with intent
differentiation via `reasoning_effort` (low/high/max only); penalty
parameters and top_k are absent from its serving schema. The vision card has
also seen negligible use.

## Observed Failure

Session 2026-10-09 evaluation of the deck's agent cards: `opencode models`
lists `ollama-cloud/qwen3.5:397b` but not the cards' pinned
`ollama-cloud/qwen3.5:397b-cloud`; `ollama show qwen3.5:397b-cloud` confirms
the model exists and is vision-capable under the CLI tag, so the defect is the
reference form, not the model. Research card
`research-cards/glm-5.3-flash-agent-card-settings.md` (opencode-config store,
2026-10-09, confidence 0.85) verified the GLM-5.3-Flash settings from the
Z.ai OpenAPI schema, Z.ai guides, HF model card, `generation_config.json`,
`chat_template.jinja`, models.dev, and opencode source
(`provider-options.ts` normalizes `reasoningEffort` → `reasoning_effort`).

## Approved Design

Developer decisions this session: adopt the card-shape split ("item d") —
retire `vision-agent` and move its analysis rubric into the
`multimodal-dispatch` skill for native-vision use; keep `visual-design-agent`
as a card that does not specify a model but pins the adjustments agent cards
support to match desired behavior; remediate the stale model/agent doc claims
in the same pass.

## Deliverables

1. Delete `agents/vision-agent.md`.
2. Add `skills/multimodal-dispatch/references/vision-critique.md` — the
   retired card's analysis rubric, caller-agnostic (usable by the primary
   agent reading images natively and by any subagent), including the
   image-as-file-path mechanics note (subagents receive images only as paths
   they read themselves) and capability-probe commands
   (`ollama show <model>`, `opencode models`).
3. Edit `skills/multimodal-dispatch/SKILL.md`: add a native-first rule —
   prefer the invoking model's own multimodal capability; dispatch to a
   subagent only for context separation or bulk work; probe capability when
   unknown — and link the reference file.
4. Edit `agents/visual-design-agent.md`: frontmatter drops `model:`, `top_k:`,
   and `options:` (presence_penalty/repetition_penalty — unsupported for this
   model); sets `temperature: 1.0`, `top_p: 0.95`, `reasoningEffort: max`
   (vendor recommendation for complex coding work, which design generation
   is); keeps `mode: subagent` and the permission block; revises the prompt
   body's "creative generation profile (higher temperature, broad sampling)"
   paragraph, which would be false under the new profile.
5. Edit `README.md` and `docs/model-dependency.md`: remove or correct the
   model/agent claims that no longer match the live deck — auditor agent
   cards (`agents/auditor-*.md`), `tests-v2/qualification/qualified-auditor-pool.sh`,
   `tools/resolve-models`, `dispatch-table.yaml`, the "hard-wired to Ollama /
   no alternate provider" claim, and the "`ollama/:cloud` and `ollama-cloud/`
   resolve to the same namespace" claim. A full README rewrite is out of
   scope; only model/agent claims ride this pass.

## Success Criteria

### SC-1 — vision-agent retired without dangling references (structural)

`agents/vision-agent.md` does not exist in the deck, and a case-insensitive
search of the live deck tree (skills/, agents/, prompts/, plugins/, floor.md,
routing.md, README.md, docs/) for `vision-agent` returns no matches outside
`attic/`.

Evidence: structural — filesystem existence check plus repo grep.

### SC-2 — visual-design-agent profile matches GLM-5.3-Flash (structural)

`agents/visual-design-agent.md` contains: no `model:` key in frontmatter;
`temperature: 1.0`; `top_p: 0.95`; `reasoningEffort: max`; no occurrence of
`top_k`, `presence_penalty`, or `repetition_penalty` anywhere in the file;
`mode: subagent` and the existing permission block unchanged; and a prompt
body that no longer claims a temperature-differentiated creative profile.

Evidence: structural — file inspection.

### SC-3 — vision rubric reachable from the dispatch skill (structural)

`skills/multimodal-dispatch/references/vision-critique.md` exists and carries
the rubric's load-bearing content: resolution-adequacy assessment (do not
guess at illegible detail; state what could not be verified),
look-before-concluding workflow, evidence-anchored critique (region,
coordinates, or exact text), facts-vs-recommendations separation, and explicit
confidence statementing. `skills/multimodal-dispatch/SKILL.md` contains a
native-first rule referencing that file.

Evidence: structural — file inspection.

### SC-4 — doc claims match the live deck (structural)

`README.md` and `docs/model-dependency.md` contain none of: `auditor-`,
`qualified-auditor-pool`, `resolve-models`, `dispatch-table.yaml`; neither
states that the deck is hard-wired to Ollama as its only provider, nor that
`ollama/:cloud` and `ollama-cloud/` resolve to the same namespace.

Evidence: structural — grep plus read of the changed sections.

### SC-5 — unpinned design card dispatches and runs (behavioral)

Dispatching `visual-design-agent` from a live opencode session completes: the
subagent resolves to the invoking primary's model (no model-resolution
failure) and the pinned options are accepted by the provider (no parameter
rejection). The execution evidence includes the subagent's effective model
identity.

Evidence: behavioral — executed `opencode run` (or tests-v2 harness scenario)
transcript.

## Predicate Classification

Fact-decidable at the file and mechanism level for SC-1 through SC-4;
SC-5 is an execution fact. No intent-decidable criteria remain — the design
choices (retire vs. keep, the unpinning principle, the effort level) were
settled by the developer this session.

## Constraints

Implementation passes the deck-governance card (`skill-creator`): admission
gate for the new reference file and SKILL.md edit; retirement gate for
`vision-agent` — evidence on record: the developer's usage statement and the
structural obsolescence documented above; the retirement decision is recorded
in the deck-debt ledger per that card.

## Provenance

- Filed from session 2026-10-09 during explore → spec on agent-card model
  references.
- Developer decisions: option D (split by card-shape); "cards that don't
  specify the model but include temperature and other adjustments"; vision
  card usage statement ("never used more than once or twice").
- Research: `research-cards/glm-5.3-flash-agent-card-settings.md`
  (opencode-config store, 2026-10-09, confidence 0.85).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
