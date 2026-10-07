# PLAN: Contract Format Standardization — YAML for All LLM-Consumed Content (.opencode#582)

Every item traces to an SC in `.opencode/.issues/582/spec.md` (the authoritative
spec). Branch: `feature/582-yaml-contract-format` in the `.opencode` repo,
created before the first card edit with the trunk tip verified fresh. This is a
single-PR change boundary (spec Change Control): all items ship on that one
branch, squashed to one commit per the stacked-PR mandate.

## Deck-governance record (admission gate — skill-creator)

The card edits below pass the admission gate as follows:

1. **Observed failure** — the 2026-05 audit (spec Problem section) found the
   pre-replacement deck instructing JSON contract formats; the live deck's
   reorganization left the codified YAML rule homeless (survives only in
   `attic/guidelines/080-code-standards.md`). Agents default to JSON in
   agent-to-agent exchanges (training-data bias; JSON ~11–18pp worse for LLM
   comprehension of nested data — improvingagents.com 2025, cited in spec).
2. **Consumer** — agents reading the exchange-governing cards at the moment
   structured data crosses an agent boundary (dispatch composition, result
   hand-back).
3. **Mechanism** — card text plus the bare `(YAML)` token at each reference.
   Predicate classification: **intent-decidable — scripts FORBIDDEN**; the
   spec's Change Control explicitly prohibits scripts, lint rules, new tests,
   and tooling. Drift control is definition quality + the one-word token form +
   the verify reviewer.
4. **Domain match** — evidence is from this deck's own audit plus the cited
   LLM-comprehension benchmark domain (agent prompt/data formats).
5. **Root-agnostic** — new text contains no root-repo names or absolute paths.
6. **What it replaces** — the homeless rule itself: the YAML Standard currently
   survives only in the preserved attic copy; this admission gives it its live
   home (the spec's stated purpose). Net growth: one definition sentence in
   four cards + one token — the minimum that satisfies SC-4.

## Definition text (identical in all four cards)

> **Agent-to-agent format:** structured data one agent creates for another —
> or ingests from another — defaults to YAML, marked by the bare `(YAML)` token
> at each reference; tool I/O, CLI output, and external configuration keep
> their native format; chat prose carries no token.

Covers universe (agent-to-agent structured data artifacts), default (YAML),
exceptions (tool I/O, CLI output, external configuration), and boundary (chat
prose carries no token) — the four elements SC-4 requires.

## Items

### Item 1 — SC-1: zero live JSON contract fences

- Deliverable: live owned content free of ` ```json ` contract templates; any
  non-excluded hit migrated to ` ```yaml ` with field-for-field equivalence.
- RED (executed 2026-10-06, pre-implementation): `rg -n '^```json'` over the
  live scope (attic/, .issues/, behavioral fixtures, vendor deps, .tools/
  excluded) → exactly one hit:
  `skills/email-management/references/search-read.md:39` — excluded category
  (CLI output documentation), stays byte-identical per SC-5. Zero non-excluded
  fences exist; the deck reorganization already absorbed the migration.
- GREEN: none required. Conditional: any non-excluded block found at
  verification is migrated, then a fresh-context sub-agent compares original
  and migrated versions field-for-field.
- Instrument: the fenced scan; expected zero non-excluded hits.

### Item 2 — SC-2: zero prose JSON-output instructions

- RED (executed): pattern scan
  (`return a json|json with fields|output json|produce json|as json|in json|json object|json format`)
  over floor.md, routing.md, AGENTS.md, prompts/, docs/, skills/,
  tests-v2/AGENTS.md, README.md → zero hits. All 10 JSON mentions in
  tests-v2/AGENTS.md are harness tool I/O (SQLite export, json.dump code,
  opencode.jsonc config) — excluded categories.
- GREEN: none required. Conditional: any hit → rewrite to a YAML-style prose
  contract (`status: DONE`, newline-separated fields).
- Instrument: the pattern scan plus SC-2's declared fresh-context sampled
  read-through at verification.

### Item 3 — SC-3: zero JSON-verdict / structured-JSON references

- RED (executed): `rg -in 'json verdict|structured json'` over the live scope
  → zero hits.
- GREEN: none required.
- Instrument: the rg scan.

### Item 4 — SC-4: the (YAML) token convention in force

- Deliverable: (a) the definition sentence in the exchange-governing cards;
  (b) the bare `(YAML)` token attached at every agent-exchanged
  structured-artifact reference found by the full read-sweep.
- **Card selection (admission-gate decision):** the four cards that explicitly
  govern dispatching agents and receiving their outputs — `implement`
  ("Dispatched work gets a clean-room prompt and a result back"), `verify`
  ("Dispatch one reviewer"), `research` ("Dispatch scoped sub-agents"),
  `multimodal-dispatch` ("Dispatch with context"). Each is guaranteed in
  context at the moment an exchange happens in its flow — the spec's placement
  criterion. `behavioral-testing` also dispatches, but its exchanges are
  harness tool I/O (`session.yaml` — excluded category) and prose judgments;
  it carries no structured-artifact reference and gains no definition.
- **Read-sweep result** (all 31 SKILL.md + all 9 references/*.md read in full):
  exactly one token target — `skills/implement/SKILL.md` item 6, "a result
  back" (the spec's own canonical example). Boundary references verified as
  correctly unmarked: verify's verdict record (chat prose — spec Excluded),
  `session.yaml` (tool I/O), formal contract/state YAML (tool I/O, already
  YAML), gh-cli "jq for JSON" (CLI output), email search-read ```json (CLI
  output), `opencode.jsonc` example (config).
- RED (executed): `rg -n '(YAML)' skills/` → zero hits; definition text → zero
  hits. The convention is absent — RED confirmed.
- GREEN:
  1. `skills/implement/SKILL.md` — item 6 becomes "Dispatched work gets a
     clean-room prompt and a result back (YAML) — no chain theater."; the
     definition sentence appended to item 6.
  2. `skills/verify/SKILL.md` — definition sentence appended to item 1 (the
     reviewer dispatch).
  3. `skills/research/SKILL.md` — definition sentence appended to item 2 (the
     research dispatch).
  4. `skills/multimodal-dispatch/SKILL.md` — definition sentence appended to
     item 3 (dispatch with context).
  5. Each edited card's provenance comment gains `; #582 yaml-contract-format
     convention` (existing precedent: verify's `; #2518 criteria invariance`).
- Instrument: rg for the token and definition text (string), plus SC-4's
  declared fresh-context full read-sweep of `skills/**` at verification.

### Item 5 — SC-5: boundary integrity

- Deliverable: token correctly absent at boundary cases; pointer surfaces
  carry no rule text; the one live ` ```json ` block byte-identical.
- RED: pre-edit state — no token anywhere, pointer surfaces unmodified (the
  absence baseline is the state the check protects).
- GREEN: none beyond item 4's edits; the check asserts the boundary held.
- Instrument: `git diff --name-only` shows zero changes under `floor.md`,
  `routing.md`, `AGENTS.md`, `prompts/`, and
  `skills/email-management/references/search-read.md`; rg confirms `(YAML)`
  appears exactly once in `skills/**` (implement item 6).

### Item 6 — SC-6: change boundary (text only)

- Deliverable: the implementation diff contains only skill-card text
  adjustments — no scripts, no lint rules, no new tests, no tooling.
- Instrument: `git diff --name-only main` in the `.opencode` repo → only the
  four `skills/*/SKILL.md` paths. The issue store's plan/spec records live on
  the `issues-data` branch, outside the feature-branch diff.

### Item 7 — SC-7: verification instruments pass

- Deliverable: `bash .opencode/tests-v2/test-enforcement.sh --tag
  content-verification` — zero failures. The six standalone scripts fully
  determine the runner's failure count: the model scenarios are marked PASS on
  run-completion by construction and cannot fail, so the tag-filtered
  content-verification run is the complete failure surface (no model runs);
  the spec permits but does not require the unfiltered run. Baseline run
  before edits (instruments function; deck already clean), post-edit run for
  GREEN.
- Also mandatory per tests-v2/AGENTS.md §6c: `./.opencode/tools/reference-integrity --scan`
  before committing any agent-facing markdown change.
- Behavioral scenario runs: **none required** — no SC's verification method is
  a behavioral harness run (SC-1..6 are string/structural; SC-7 is the
  content-verification runner; SC-8/9 are the verify reviewer pass), and the
  targeted-run mandate permits scenario runs only per an SC's RED/GREEN need
  (#2433). Judgment recorded here for the reviewer; whole-suite behavioral
  enumeration is prohibited.
- Instrument: the runner's `PASSED/FAILED` totals; reference-integrity exit
  code.

### Item 8 — SC-8 / SC-9: the single fresh-context verify pass

- Deliverable: the verify card's one fresh-context reviewer dispatch over all
  nine SCs against the spec, the diff, and the executed output. Binary
  PASS/FAIL per SC; no SC removed, weakened, deferred, or blocked (SC-8 —
  non-waivable); any FAIL → remediate → one re-review → still FAIL → halt to
  the developer (SC-9's rejection rule).
- Instrument: the verify card process itself; the verdict is recorded once
  (chat / PR description).

## Dependency order

Items 1–3 are completed scans (conditional GREEN only) → item 4 (the edits,
on the feature branch) → items 5–6 (diff checks) → item 7 (suite +
reference-integrity) → item 8 (verify pass) → PR per `git-workflow-pr`.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
