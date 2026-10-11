# Plan — Agent card updates: unpin models, retire vision-agent, GLM-5.3-Flash-aligned profiles (.opencode#2567)

Spec: `.opencode/.issues/2567/spec.md`. Authorization: `approved for plan`
(2026-10-11) — carries the item through the plan stage; `implement` waits for
the developer's authorization per the plan card's stage boundary. Merge is
human-only.

## Reference-currency conformance (authoring time)

Every deck path and dispatch string in this plan was existence-checked against
this repo's live deck copy on 2026-10-11 — all current:

- `.opencode/agents/vision-agent.md`, `.opencode/agents/visual-design-agent.md` — exist
- `.opencode/skills/multimodal-dispatch/SKILL.md` — exists; no `references/` subdir yet
- `.opencode/skills/skill-creator/SKILL.md` — exists (governance gates + ledger mechanics)
- `.opencode/skills/behavioral-testing/SKILL.md` + `references/behavioral-evaluation.md` — exist
- `.opencode/tests-v2/AGENTS.md`, `.opencode/tests-v2/behaviors/template.sh` — exist;
  recent scenario naming convention `{N}-sc{K}-{kebab-slug}.sh` observed
- Deck-debt ledger: `.opencode#2534` ("Deck-debt ledger — cross-deployment
  evidence base", open) — the ledger is the ledger issue's body `## Entries`
  section, appended via the local-issues tool

No remediations were required.

## SC validation (against spec/references/validation-standards.md)

All six criteria PASS. Judgment notes:

- **Traceability.** SC-1..SC-4 each remediate a stated problem/observed
  failure (dead model id, qwen-era profile, redundancy, stale doc claims);
  SC-5/SC-6 verify the approved design's core behavior (an unpinned card
  dispatches). Nothing invented.
- **Testability.** SC-1..SC-4 state closed, checkable conditions; SC-5/SC-6
  name the harness contract instruments.
- **Currently failing, not trivially-true.** Verified 2026-10-11: the card
  exists and pins the dead id; `temperature: 0.8`, `top_k: 40`,
  `options:` penalties present; the reference file is absent; the doc claims
  are present at the lines enumerated in Item 4's RED; no scenario artifact
  exists.
- **SC-5 "invoking primary's model" resolution.** In the seeded test home the
  primary runs the single-sourced `DEFAULT_TEST_MODEL`; the evidence check is
  that the recorded effective subagent model identity equals the primary's
  resolved model (no model-resolution failure), not any specific model name.
  This is the spec's stated intent, not a reinterpretation.
- **No intent-decidable criteria.** Matches the spec's predicate
  classification; no BLOCKED.

## Items

### Item 1 — SC-3 (structural): vision-critique reference + native-first dispatch rule

- **Deliverable:** `skills/multimodal-dispatch/references/vision-critique.md`
  carrying the vision-agent card's analysis rubric, reframed caller-agnostic
  (usable by the primary agent reading images natively and by any subagent).
  Load-bearing content per SC-3: resolution-adequacy assessment (do not guess
  at illegible detail; state what could not be verified), look-before-concluding
  workflow, evidence-anchored critique (region, coordinates, or exact text),
  facts-vs-recommendations separation, explicit confidence statementing, the
  image-as-file-path mechanics note (subagents receive images only as paths
  they read themselves), and the capability-probe commands
  (`ollama show <model>`, `opencode models`). Source material: the body of
  `agents/vision-agent.md` (its "Image resolution and detail", "Core
  workflow", "Task-specific standards", "Output discipline" sections),
  de-carded: drop the card-persona framing; zero root-repo names or absolute
  paths. Also edit `skills/multimodal-dispatch/SKILL.md`: add the native-first
  rule — prefer the invoking model's own multimodal capability; dispatch to a
  subagent only for context separation or bulk work; probe capability when
  unknown — and link the reference file.
- **Governance (admission gate, skill-creator card):** observed failure =
  vision tasks steered into a card whose pinned model id cannot resolve
  (#2567 Observed Failure); consumer = primary agent + any subagent doing
  visual critique; mechanism/trigger = SKILL.md link + description-matched
  load; predicate classification = fact-decidable (file exists, tokens
  present); domain match = n/a (homegrown rubric); root-agnostic = enforced;
  what it replaces = the vision-agent card's rubric (net-zero with Item 2's
  retirement); always-loaded surface = none (nothing enters floor.md).
- **RED:** the reference file does not exist (`test -f` fails);
  `multimodal-dispatch/SKILL.md` carries no native-first rule and no link
  (grep: zero matches).
- **GREEN:** author the reference; add the rule + link.
- **Instrument:** file-existence check; grep of SKILL.md for the rule and the
  link; per-element content checklist against SC-3's enumerated list (each
  element greppable in the reference).

### Item 2 — SC-1 (structural): retire vision-agent without dangling references

- **Deliverable:** delete `agents/vision-agent.md`. Zero dangling references
  in the live deck tree.
- **Governance (retirement gate, skill-creator card):** evidence on record —
  developer usage statement ("never used more than once or twice", spec
  Provenance) + structural obsolescence (pinned `ollama-cloud/qwen3.5:397b-cloud`
  absent from opencode's catalog; backing model retired from the ollama
  registry as of 2026-09-25; redundant against the primary's native vision).
  Resurrection path: git history. Record the retirement decision as an entry
  in the deck-debt ledger (`.opencode#2534` body `## Entries`, via the
  local-issues tool), following the entry format already in that body.
- **RED:** the file exists (`test -f` succeeds); a live-tree grep for
  `vision-agent` returns hits (the card itself). 2026-10-11 pre-check: the
  only `vision-agent` mentions in the live tree are this card and the issue
  store — the scoped grep below is expected clean immediately after deletion,
  and any unexpected hit is remediated inside this item.
- **GREEN:** delete the file; scoped grep returns zero matches.
- **Instrument:** file-absence check plus case-insensitive
  `grep -ri vision-agent` over `skills/`, `agents/`, `prompts/`, `plugins/`,
  `floor.md`, `routing.md`, `README.md`, `docs/` (attic excluded per SC-1).

### Item 3 — SC-2 (structural): visual-design-agent profile aligned to GLM-5.3-Flash

- **Deliverable:** rebuild the frontmatter of
  `agents/visual-design-agent.md`: remove `model:`
  (`ollama-cloud/qwen3.5:397b-cloud`), `top_k: 40`, and the `options:` block
  (`presence_penalty: 2.0`, `repetition_penalty: 1.0` — absent from the
  model's serving schema); set `temperature: 1.0` (from 0.8) and `top_p: 0.95`
  (from 1.0); add `reasoningEffort: max` (camelCase — opencode normalizes to
  `reasoning_effort` per the research card; vendor recommendation for complex
  generation work, which design generation is); keep `mode: subagent` and the
  permission block byte-identical; revise the prompt body's
  "creative generation profile (higher temperature, broad sampling)"
  paragraph (current lines 28–32), which is false under the new profile —
  replace with profile-accurate guidance (temperature is capped at 1.0 — no
  "hotter = more creative" headroom; intent differentiation happens via
  `reasoningEffort` and the prompt rubric; the vary-layouts-deliberately
  instruction survives in rubric form).
- **Grounding:** `research-cards/glm-5.3-flash-agent-card-settings.md`
  (opencode-config store, 2026-10-09, confidence 0.85) — Z.ai OpenAPI schema
  (temp default 1.0 range [0,1]; top_p default 0.95; `reasoning_effort` enum
  [max,high,low]; NO penalties/top_k in schema), Z.ai guide recommendations,
  HF `generation_config.json`, opencode `provider-options.ts` normalization.
- **RED:** the current file carries the unresolvable model id, `top_k: 40`,
  the `options:` penalties, `temperature: 0.8`/`top_p: 1.0`, and the
  temperature-profile narrative.
- **GREEN:** the edits above.
- **Instrument:** structural inspection — grep assertions for absence of
  `model:`, `top_k`, `presence_penalty`, `repetition_penalty`, `options:` and
  presence of `temperature: 1.0`, `top_p: 0.95`, `reasoningEffort: max`,
  `mode: subagent`; diff confirms the permission block unchanged.

### Item 4 — SC-4 (structural): doc claims match the live deck

- **Deliverable:** `README.md` and `docs/model-dependency.md` — remove or
  correct only the model/agent claims that no longer match the live deck:
  1. Remove references to artifacts that do not exist (all verified absent
     2026-10-11): `agents/auditor-*.md` rows (agents/ holds email-ops,
     math-ops, visual-design-agent after Item 2), the
     `tests-v2/qualification/qualified-auditor-pool.sh` rows (no
     qualification/ dir), the `tools/resolve-models` mentions (tools/ holds
     only `ollama-probe`), the `skills/audit/` row (absent), and the
     `dispatch-table.yaml` tree line (README L72; file absent).
  2. Correct the "hard-wired to Ollama / no alternate provider" sentence
     (README L34, model-dependency L7): the deck config wires no provider or
     model at all (`opencode.jsonc` carries instructions, prompts, MCP
     servers, permissions only — verified 2026-10-11); provider/model
     selection comes from the invoking opencode config; Ollama remains a live
     dependency only where the deck actually touches it — the default test
     model (`tests-v2/default-model.sh`) and the `ollama-probe` tool.
  3. Correct or remove the "Model name convention … both resolve to the same
     namespace" section (README L64, model-dependency L39–46): `ollama/` and
     `ollama-cloud/` are distinct provider ids in opencode's catalog (local
     server vs cloud hosting), not aliases; rewrite to that fact or drop the
     section.
  4. Preserve the truthful Ollama content: prerequisites rows tied to
     `default-model.sh` / `ollama-probe`, the behavioral-test default-model
     rows, and the `020-go-prohibitions.md` guideline row stay.
  Scope boundary: no full README rewrite — only model/agent claims ride this
  pass.
- **RED:** grep hits at README L34, 38, 41–43, 60–62, 64, 72 and
  model-dependency L7, 13, 16–18, 35–37, 41–46 (enumerated 2026-10-11).
- **GREEN:** as listed above; reword from the live deck, not from memory.
- **Instrument:** the SC-4 grep — zero matches for `auditor-`,
  `qualified-auditor-pool`, `resolve-models`, `dispatch-table.yaml` in both
  files; no exclusivity claim; no same-namespace claim — plus a read of the
  changed sections.

### Item 5 — SC-5 (behavioral): unpinned design-card dispatch completes

- **Deliverable:** harness scenario
  `tests-v2/behaviors/2567-sc5-visual-design-unpinned-dispatch.sh` (copy
  `tests-v2/behaviors/template.sh`; kebab-case `SCENARIO_NAME` matching any
  fixture filename; artifact-only generator — runs `behavior_run`, exits 0,
  never evaluates output) dispatching `visual-design-agent` from a live
  opencode session with a real-domain design-generation task (§11: real-domain
  task, never interview/prose-recall); the run produces `session.yaml` per the
  harness contract, including the subagent's effective model identity.
- **Preconditions:** Items 1–4 committed and pushed — the harness builds the
  test home from the pushed effective commit (§4 ordered precondition cycle:
  commit → push → fetch/verify → run).
- **Execution constraints (behavioral-testing card):** read
  `tests-v2/AGENTS.md` first; supervise the run with the 60-second poll cycle
  (continuous until conclusive — poll tool call → in-chat update → next poll;
  no filtered poll output, no long sleeps); `DEFAULT_TEST_MODEL` single-sourced,
  no model shopping; test-home isolation inviolable — no credential
  passthrough, no config injection (a scenario need isolation cannot meet is
  a spec problem, re-scoped at the spec, never the isolation); no blocking
  action > 60 s mid-run; evaluation dispatches at run boundaries only.
- **RED:** no scenario or artifact exists for this SC; the
  dispatch-with-pinned-dead-model failure is on record in the spec's Observed
  Failure.
- **GREEN:** the run completes; `session.yaml` records the subagent's
  effective model identity equal to the primary's resolved model; no
  model-resolution failure; no parameter rejection (`temperature`/`top_p`/
  `reasoningEffort` accepted by the provider).
- **Instrument:** `bash
  .opencode/tests-v2/behaviors/2567-sc5-visual-design-unpinned-dispatch.sh`
  from the project root; artifacts land under
  `./tmp/behavioral-evidence-<scenario>-<phase>-<model>/` and are preserved
  issue-keyed under `{project_root}/tmp/issue-2567/artifacts/`. Artifact
  generation alone is never a PASS — Item 6 is the verdict.

### Item 6 — SC-6 (behavioral): clean-room evaluation of the dispatch run

- **Deliverable:** dispatch the clean-room evaluator sub-agent per
  `skills/behavioral-testing/references/behavioral-evaluation.md`, receiving
  ONLY the artifact directory and the SC-5 criteria — no orchestrator
  context, no expected outcomes, no cached results; it reads `session.yaml`
  as the primary source, writes `evaluation-<timestamp>.yaml` into the
  artifact directory, and returns the YAML verdict record. Dispatch prompt
  bounds the evaluator's authorization exactly (floor, dispatched sub-agent
  scope).
- **RED:** no evaluation record exists for the Item-5 artifacts.
- **GREEN:** the verdict record finds the dispatch completed with the
  subagent's effective model identity recorded and no model-resolution or
  parameter-rejection failure.
- **Instrument:** the returned verdict record
  (`evaluation-<timestamp>.yaml`); a FAIL verdict routes to remediation and
  one re-run per the harness contract — never reclassification.

## Dependency graph

```
Item 1 (SC-3) → Item 2 (SC-1) → Item 3 (SC-2) → Item 4 (SC-4) → [commit + push] → Item 5 (SC-5) → Item 6 (SC-6)
```

The rubric relocates before its source card retires (no content-loss window);
doc claims are written against the settled deck state; the behavioral run
executes against the pushed effective commit, so it gates on every structural
item; the clean-room evaluation follows the run at a run boundary.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
