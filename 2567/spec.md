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
`ollama-cloud/qwen3.5:397b-cloud`, so the defect is the reference form. Audit
re-verification 2026-10-11 confirms the `-cloud` form is still absent from
the catalog and finds the backing model retired from the ollama registry as
of 2026-09-25 (`ollama show qwen3.5:397b-cloud` returns a retirement error) —
reinforcing the unpin/removal rationale; the remediation is unaffected either
way. Research card
`research-cards/glm-5.3-flash-agent-card-settings.md` (opencode-config store,
2026-10-09, confidence 0.85) verified the GLM-5.3-Flash settings from the
Z.ai OpenAPI schema, Z.ai guides, HF model card, `generation_config.json`,
`chat_template.jinja`, models.dev, and opencode source
(`provider-options.ts` normalizes `reasoningEffort` → `reasoning_effort`).

Revision evidence 2026-10-11: the first SC-5 behavioral run and two
diagnostic probes stalled identically on the rebuilt card — subagent session
created, zero/few parts, flat event stream, idle GPU, held connection, task
stuck `running`; an unmodified card (`math-ops`) completed cleanly. Root
cause isolated by direct API probes: Ollama's `/v1` endpoint returns a
deterministic HTTP 500 for `reasoning_effort: max` on
`qwen3.8:27b-256k-gguf4` (chat-template crash), while `low`, `none`, plain,
and `temperature`/`top_p`-only requests pass; opencode's subagent path
hangs silently on the provider 500 instead of surfacing an error.
Full analysis: `research/sc5-stall-root-cause.md`; clean-room evaluation
verdict on record (`evaluation-1791737526.yaml`).

## Approved Design

Developer decisions this session: adopt the card-shape split ("item d") —
retire `vision-agent` and move its analysis rubric into the
`multimodal-dispatch` skill for native-vision use; keep `visual-design-agent`
as a card that does not specify a model but pins the adjustments agent cards
support to match desired behavior; remediate the stale model/agent doc claims
in the same pass.

Revision decision (developer direction 2026-10-11, after the SC-5 behavioral
stall and its root-cause analysis — see
`research/sc5-stall-root-cause.md`): a model-less card must not pin
provider-specific reasoning-effort literals. `reasoningEffort: max` is the
GLM-5.3-Flash vendor recommendation but crashes other providers — observed:
deterministic HTTP 500 from Ollama's `/v1` endpoint on the default test
model's chat template, which opencode's subagent path then hangs on silently.
The portable profile pins only what both providers accept (`temperature:
1.0`, `top_p: 0.95`, verified live against the Ollama `/v1` endpoint and the
Z.ai schema); intent differentiation comes from the prompt rubric and the
invoking session's own configuration, consistent with the unpinning
principle.

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
   subagent only for context separation or bulk work — and link the
   reference file.
4. Edit `agents/visual-design-agent.md`: frontmatter drops `model:`,
   `top_k:`, `options:` (presence_penalty/repetition_penalty — unsupported
   for this model), and `reasoningEffort` (provider-specific literal;
   crashes non-GLM providers — see Approved Design revision); sets
   `temperature: 1.0`, `top_p: 0.95`; keeps `mode: subagent` and the
   permission block; the prompt body's profile paragraph attributes intent
   differentiation to the prompt rubric and the invoking session's
   configuration.
5. Edit `README.md` and `docs/model-dependency.md`: remove or correct the
   model/agent claims that no longer match the live deck — auditor agent
   cards (`agents/auditor-*.md`), `tests-v2/qualification/qualified-auditor-pool.sh`,
   `tools/resolve-models`, `dispatch-table.yaml`, the "hard-wired
   to Ollama / no alternate provider" claim, and the "`ollama/:cloud` and
   `ollama-cloud/` resolve to the same namespace" claim. A full README
   rewrite is out of scope; only model/agent claims ride this pass.

## Success Criteria

### SC-1 — vision-agent retired without dangling references (structural)

`agents/vision-agent.md` does not exist in the deck, and a case-insensitive
search of the live deck tree (skills/, agents/, prompts/, plugins/, floor.md,
routing.md, README.md, docs/) for `vision-agent` returns no matches outside
`attic/`.

Evidence: structural — filesystem existence check plus repo grep.

### SC-2 — visual-design-agent profile is portable and GLM-aligned (structural)

`agents/visual-design-agent.md` contains: no `model:` key in frontmatter; no
`options:` key in frontmatter; no `reasoningEffort` key in frontmatter;
`temperature: 1.0`; `top_p: 0.95`; no occurrence of
`top_k`, `presence_penalty`, `repetition_penalty`, or `reasoningEffort`
anywhere in the file; `mode: subagent` and the existing permission block
unchanged; and a prompt body that attributes intent differentiation to the
prompt rubric and the invoking session's configuration rather than to
card-pinned sampling or effort knobs.

Evidence: structural — file inspection.

### SC-2b — the pinned options are provider-portable (behavioral, subsumed in SC-5)

The behavioral run in SC-5 doubles as the portability check: `temperature:
1.0` and `top_p: 0.95` must be accepted by the default test model's provider
(no parameter rejection). Direct-API evidence on record (2026-10-11): the
Ollama `/v1` endpoint accepts both values. No separate criterion — SC-5's
completion covers it.

### SC-3 — vision rubric reachable from the dispatch skill (structural)

`skills/multimodal-dispatch/references/vision-critique.md` exists and carries
the rubric's load-bearing content: resolution-adequacy assessment (do not
guess at illegible detail; state what could not be verified),
look-before-concluding workflow, evidence-anchored critique (region,
coordinates, or exact text), facts-vs-recommendations separation, and explicit
confidence statementing. The reference is caller-agnostic — written for use by
the primary agent reading images natively and by any subagent — and states
the image-as-file-path mechanics (subagents receive images only as paths they
read themselves) and the capability-probe commands (`ollama show <model>`,
`opencode models`). `skills/multimodal-dispatch/SKILL.md` contains a
native-first rule referencing that file.

Evidence: structural — file inspection.

### SC-4 — doc claims match the live deck (structural)

`README.md` and `docs/model-dependency.md` contain none of: `auditor-`,
`qualified-auditor-pool`, `resolve-models`, `dispatch-table.yaml`; neither
states that the deck is hard-wired to Ollama as its only provider, nor that
`ollama/:cloud` and `ollama-cloud/` resolve to the same namespace.

Evidence: structural — grep plus read of the changed sections.

### SC-5 — unpinned design card dispatches and runs (behavioral)

A tests-v2 harness scenario dispatches `visual-design-agent` from a live
opencode session. The run completes: the subagent resolves to the invoking
primary's model (no model-resolution failure) and the pinned options are
accepted by the provider (no parameter rejection). The execution evidence
includes the subagent's effective model identity.

Evidence: behavioral — harness artifact generation via
`bash .opencode/tests-v2/behaviors/<scenario>.sh` from the project root,
producing `session.yaml` per the harness contract.

### SC-6 — clean-room evaluation of the dispatch run (behavioral)

A clean-room evaluator sub-agent receives only the artifact directory and the
SC-5 criteria — no orchestrator context, no expected outcomes — reads
`session.yaml` as the primary source, and returns a verdict record
(`evaluation-<timestamp>.yaml`) finding the dispatch completed with the
subagent's effective model identity recorded and no model-resolution or
parameter-rejection failure.

Evidence: behavioral — clean-room evaluation verdict record per the harness
contract; artifact generation alone is never a PASS.

## Predicate Classification

Fact-decidable at the file and mechanism level for SC-1 through SC-4;
SC-5 and SC-6 are execution facts. No intent-decidable criteria remain
— the design choices (retire vs. keep, the unpinning principle, the portable
profile without provider-specific effort literals) were settled by the
developer across both sessions.

## Constraints

Implementation passes the deck-governance card (`skill-creator`): admission
gate for the new reference file and SKILL.md edit; retirement gate for
`vision-agent` — evidence on record: the developer's usage statement and the
structural obsolescence documented above; the retirement decision is recorded
in the deck-debt ledger per that card. Behavioral verification (SC-5/SC-6)
passes the `behavioral-testing` card's harness gate: tests-v2 only, with the
clean-room evaluation as a separate dispatch.

## Provenance

- Filed from session 2026-10-09 during explore → spec on agent-card model
  references.
- Developer decisions: option D (split by card-shape); "cards that don't
  specify the model but include temperature and other adjustments"; vision
  card usage statement ("never used more than once or twice").
- Revision 2026-10-11 from the developer direction "revise spec to deal with
  the bug, adjust reasoning etc as needed", following the SC-5 stall and
  root-cause analysis; design decision: provider-specific effort literals
  stay out of model-less cards.
- Correction 2026-10-11: an interim revision briefly carried an
  upstream-defect-filing deliverable (SC-7) — authored without authorization,
  filed as anomalyco/opencode#54568, then closed with a withdrawal apology on
  the developer's direction; the deliverable and criterion are struck from
  this spec.
- Research: `research-cards/glm-5.3-flash-agent-card-settings.md`
  (opencode-config store, 2026-10-09, confidence 0.85).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
