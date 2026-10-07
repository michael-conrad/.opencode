---
id: 582
title: "Contract Format Standardization — YAML for All LLM-Consumed Content"
status: DRAFT
author: michael-conrad
created: 2026-05-15
updated: 2026-10-06
license: MIT
provenance: AI-generated
supersedes:
  - .opencode#1420 (closed — YAML mandate rule; #582 is the implementation)
---

# SPEC: Contract Format Standardization — YAML for All LLM-Consumed Content

## Problem

When an agent directly parses or writes structured data for consumption by another agent — result contracts, hand-off state, structured verdicts, evidence artifacts — it must default to YAML, not JSON. The agent, not the format, is the subject of this mandate: models default to JSON in agent-to-agent exchanges because training data is JSON-heavy, and JSON is error-prone when embedded in prompts due to brace/quote escaping.

The original audit (2026-05) found the pre-replacement deck instructing the opposite: ` ```json ` contract templates in task files, prose-embedded JSON output instructions, and "structured JSON verdict" language across SKILL.md files, auditor agent cards, and guidelines. The deck has since been reorganized into single-file skill cards; the pre-replacement deck is preserved unloaded under `attic/` (tag `pre-rip`) pending soak and deletion. That reorganization absorbed the file migration the original spec enumerated — but it also left the codified rule homeless: the YAML Standard now survives only in the preserved attic copy, and nothing in the live deck tells an agent to default to YAML when exchanging structured data with another agent.

This spec re-baselines the mandate onto the current deck: verify live-deck conformance, and put the rule where agents actually encounter it — in the cards, at the artifact references, progressively disclosed.

## Principle

**YAML for everything an LLM reads, parses, or is instructed to generate. JSON only for tool-to-tool file I/O, CLI output, and external tool configuration.**

Operationally: the agent uses YAML, not JSON, as the default communication format for structured data it directly parses or writes for consumption by other agents. The convention is disclosed progressively through the card deck itself: a bare `(YAML)` token, directly associated with each skill-card or detail-card reference to a structured output an agent creates or an input it ingests from another agent. The token's definition lives in the skill cards that govern agent-to-agent exchanges — the cards already in context when structured data crosses an agent boundary — never in the slim pointer surfaces (`floor.md`, `routing.md`, `AGENTS.md`, `prompts/default.txt`). The governing rule text (§YAML Standard for LLM-to-LLM Data Transfers) survives in the preserved governing copy `attic/guidelines/080-code-standards.md`; the live deck no longer carries `guidelines/`.

## Current State (live deck)

- Exactly **1** true ` ```json ` fence: `skills/email-management/references/search-read.md` — documents the mail CLI's JSON output; excluded category (CLI output), not an LLM-output instruction.
- Exactly **1** ` ```jsonc ` fence: `README.md` — `opencode.jsonc` config example; excluded.
- **0** "JSON verdict" / "structured JSON" references in live content.
- **0** prose instructions directing an LLM to produce JSON output in live content.
- **0** `yaml+symbolic` blocks in live content (the construct is attic-only).
- The pre-replacement deck's 21 fenced ` ```json ` sites (task cards, references) are preserved unloaded under `attic/`; the auditor agent cards were removed outright. Migrating attic content is dead work.

## Contract Format Specification

| Element | Format | Example |
|---|---|---|
| Outer boundary | ` ```yaml ` code fence | ` ```yaml ` |
| Multi-record inside a single fence | `---` separator between records | `---\nstatus: PASS\n---\nstatus: FAIL` |
| Prose contract description | YAML-style, not JSON brace syntax | `status: DONE, evidence: path to file` |
| Agent-exchanged artifact reference in a card | bare `(YAML)` token directly associated with the reference | `a result back (YAML)` |
| Agent re-serialization of tool JSON for another agent | YAML (the hand-off representation; the tool's raw output stays JSON) | convert before hand-off |
| Tool I/O, CLI output, file persistence | JSON (unchanged) | excluded from migration |

## Scope

Live, LLM-consumed, owned content in `.opencode/`: skill cards (`skills/**` — `SKILL.md` and `references/**`), agent-facing harness documentation (`tests-v2/AGENTS.md`), `docs/`, `README.md`, agent cards (`agents/*.md`), and the pointer surfaces (`floor.md`, `routing.md`, `AGENTS.md`, `prompts/`) as scan-only surfaces. The implementing agent discovers affected content per block, not per file.

The token convention and its definition are implemented strictly as skill-card and detail-card adjustments — no scripts, no lint rules, no new tests, no tooling. Card edits go through the deck-governance card (`skill-creator`); this spec defines the requirement, deck governance governs the edit.

### Excluded

- Chat prose and human-facing records — a verdict recorded once in chat or a PR description, correspondence drafts, issue-comment narration: these are not data artifacts exchanged between agents; they carry no token and take no format mandate.
- `attic/` — preserved, unloaded pre-replacement deck (pending soak and deletion)
- `.issues/` and `.opencode/.issues/` — issue metadata stores
- Tool I/O files written to disk by one tool and read by another (capability snapshots, provenance logs, session exports)
- CLI output documentation and examples (including the mail CLI block in `skills/email-management/references/search-read.md`)
- Script `--json` flags for programmatic consumption (`skildeck` suite, test tooling)
- ` ```jsonc ` blocks (config-file examples)
- Behavioral-test fixtures and generated artifacts (`tests-v2/behaviors/fixtures/`, `tmp/`, `test-artifacts/`, `vector_db/`)
- Vendor-generated files (`agents/vision-agent.md`, `agents/visual-design-agent.md` — vendor-card boundary: regenerated by the owning tool, never hand-edited)
- Vendor dependencies (`.node/`, `node_modules/`, `.tools/`)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | Zero ` ```json ` code fences serving as LLM-consumed contract templates in live owned `.opencode/` content. Any block encountered during the sweep is converted to ` ```yaml ` with semantically equivalent content — no fields lost, values changed, or structural information dropped. | `string + semantic` | Fenced scan (`rg -n '^```json'`) over live content (Excluded categories out of scan scope) — expected zero outside excluded categories. If a block is found: migrate, then representative sample comparison — a sub-agent reads original and migrated versions and confirms field-for-field equivalence. |
| SC-2 | Zero prose instructions directing an LLM to produce JSON output in live owned content (e.g., "Return a JSON with fields: status, evidence…" or `Result: { status, files_changed }` templates). | `string + semantic` | Pattern scan plus sampled read-through — a fresh-context sub-agent reads sampled live content and confirms no JSON-output instructions remain. |
| SC-3 | Zero "JSON verdict" or "structured JSON" references in live owned content where the referenced output is LLM-consumed. | `string` | `rg -in 'json verdict\|structured json'` over live content — zero hits. |
| SC-4 | The `(YAML)` token convention is in force across the live deck: every skill-card and detail-card reference to a structured output an agent creates for another agent, or a structured input an agent ingests from another agent, carries the bare `(YAML)` token directly associated with that reference. The token's definition — universe (structured data artifacts exchanged between agents), default (YAML), exceptions (tool I/O, CLI output, external configuration), and boundary (chat prose carries no token) — is stated in the skill card(s) that govern agent-to-agent exchanges. | `string + semantic` | Full read-sweep of `skills/**` (`SKILL.md` + `references/*.md`): every agent-exchanged structured-artifact reference carries the token, directly associated. A fresh-context sub-agent reads sampled cards and confirms the definition is present in the exchange-governing card(s) and that tokens are correctly applied and correctly absent at boundary cases. |
| SC-5 | Boundary integrity: no `(YAML)` token on chat-prose records, tool-I/O or CLI-output references, ` ```jsonc ` examples, or vendor-generated agent cards; the pointer surfaces (`floor.md`, `routing.md`, `AGENTS.md`, `prompts/default.txt`) carry no rule text; the one live ` ```json ` block (`search-read.md`) is byte-identical. | `string` | Read check of the named boundary cases; diff shows no rule text added to the pointer surfaces. |
| SC-6 | Change boundary: the implementation diff contains only skill-card and detail-card text adjustments — no scripts, no lint rules, no new tests, no tooling of any kind. | `structural` | Diff inspection — only `.md` files under `skills/**` (plus the issue store's own records) are modified; no executable or configuration files added or changed. |
| SC-7 | Verification instruments pass post-remediation. | `behavioral` | `bash .opencode/tests-v2/test-enforcement.sh` — zero failures (content-verification runner; no model runs; full run permitted). Behavioral scenarios run only where card text changed, one targeted run per SC's RED/GREEN need per `.opencode#2433`'s targeted-run mandate — whole-suite behavioral enumeration is prohibited — under the harness precondition cycle (commit → push → fetch/verify → run, `tests-v2/AGENTS.md` §4). |
| SC-8 | **Zero-tolerance for lobotomized tests.** No SC may be removed, weakened, deferred, or blocked to evade implementation. Any attempt to bypass an SC (skip, defer, mark as "blocked", weaken evidence type) marks ALL SCs as FAIL. The PR must be immediately rejected and trashed as defective and unusable. | `behavioral` | The `verify` card's single fresh-context reviewer pass confirms every SC in this spec is addressed with its declared evidence. Any missing or weakened SC → ALL SCs FAIL. |
| SC-9 | All SCs must achieve 100% clean PASS. No "PASS with caveats", "functionally equivalent", "PASS with concerns", or any partial-PASS verdict is accepted. A single FAIL on any SC means the entire implementation is rejected. | `behavioral` | Verification produces binary PASS/FAIL per SC. Any FAIL → full rejection. |

## Phases

### Phase 1 — Live-deck residual sweep

Scan live LLM-consumed content (the Scope set) for fenced JSON contract templates, prose JSON-output instructions, and JSON-verdict language. Classify each hit per block: migrate (LLM-consumed contract) vs exclude (tool I/O, CLI output, config example). Migrate where required: fence-type replacement plus structural JSON→YAML conversion — braces and commas become indentation, quoted keys become unquoted, trailing commas removed, array brackets become dash lists — with semantic equivalence preserved. The Current State scan found no live block requiring migration; this sweep exists to catch anything the pattern scan missed, and its findings drive this phase's work.

### Phase 2 — Token convention implementation

1. **Definition text** — state the token convention's definition (universe, default, exceptions, prose boundary) in the skill card(s) that govern agent-to-agent exchanges; exact card selection is an implementation decision under the deck-governance admission gate.
2. **Token application sweep** — read every skill card and detail card; wherever a reference to a structured output created for another agent or a structured input ingested from another agent appears, attach the bare `(YAML)` token directly to that reference. Boundary references (chat prose, tool I/O, CLI output, config examples, vendor cards) stay unmarked.
3. **Strictly text** — no scripts, no lint rules, no new tests, no tooling. The definition's wording is the rule's whole enforcement; drift control is the one-word token form plus review.

### Phase 3 — Verification pass

- `bash .opencode/tests-v2/test-enforcement.sh` — zero failures.
- Behavioral scenarios only where card text changed (targeted runs, precondition cycle).
- Read-check the boundary cases and the pointer surfaces.
- The `verify` card's single fresh-context reviewer pass over all SCs against the diff and executed output; close the issue only when all SCs pass.

## Edge Cases

- **Agent-parsed tool JSON** — when an agent parses a tool's JSON output and re-serializes it for another agent, the hand-off representation is YAML (the token attaches to the hand-off artifact); the tool's raw output stays JSON.
- **Token form** — the bare `(YAML)` token only; no variants ("YAML only", "YAML preferred", prose restatements). Consistency is carried by the definition card as exemplar and by review, not by machinery.
- **Multi-record contract content** — N records in one block use `---` separators inside a single ` ```yaml ` fence, never separate fences per record.
- **Mixed JSON/YAML in a single file** — classify per block: LLM-consumed JSON migrates, tool-I/O JSON stays.
- **` ```jsonc ` blocks** — excluded; they illustrate JSON config files, not LLM contracts.
- **Prose describing a tool's JSON output** — left as-is; documenting a CLI tool is not instructing an LLM to produce JSON.
- **Ambiguous JSON-adjacent prose contracts** — patterns like `Result: { status: DONE, evidence: "..." }` resolve to unambiguous YAML: `status: DONE\nevidence: "..."`.
- **Pointer-surface hits** — a contract template found in `floor.md`, `routing.md`, `AGENTS.md`, or `prompts/` is a deck-governance matter, never an inline edit; the fix routes the content to a skill card, never moves rule text into the pointer surfaces.
- **Vendor-generated agent cards** — regenerate via the owning tool; never hand-edit.

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Agents default to JSON in agent-to-agent structured exchanges (training-data bias) | High | High | The `(YAML)` token sits at every agent-exchanged artifact reference; the definition lives in the cards already in context at exchange time |
| Attic deletion orphans the codified rule | Medium | High | The definition lives in live skill cards before `attic/` ages out |
| Token drift into variants | Medium | Low | One-word form resists mutation; the definition card is the exemplar; the reviewer pass catches divergence |
| Incomplete token application across cards | Medium | Medium | Full read-sweep of `skills/**` plus the verify reviewer; completeness is judgment and the spec states it honestly |
| JSON→YAML conversion loses structural information in an edge case | Low | Medium | SC-1's semantic-equivalence verification applies to any block the sweep migrates |
| Excluded files accidentally modified | Low | Medium | SC-5/SC-6 read and diff checks; the implementor classifies per block before editing |
| Prose-embedded JSON ambiguous with tool-describing JSON | Medium | Low | Per-block reading comprehension — the implementor reads context before converting |
| Enforcement tests expect pre-migration text | Medium | Medium | SC-7 runs the enforcement suite post-remediation; failures indicate missed references |
| SC lobotomization (weakening SCs to pass) | Low | Critical | SC-8 explicitly prohibits this; any attempt marks ALL SCs as FAIL and rejects the PR |

## Change Control

- Single-PR boundary. All phases ship together.
- The core principle (YAML as the default format for structured data exchanged between agents) is frozen. SC-set changes happen only through a developer-directed spec revision — never agent-initiated weakening (SC-8 governs).
- The token convention is implemented strictly as skill-card and detail-card text: no mechanical checks, no bespoke scripting (developer directive, 2026-10-06). Drift and completeness are controlled by definition quality, the one-word token form, and the reviewer pass.
- Deck edits during implementation (definition placement, token application) go through the deck-governance card — the admission gate applies; this spec does not bypass it.
- Post-implementation verification is the `verify` card's single fresh-context reviewer pass against this spec.
- SC-8 and SC-9 are non-waivable. No authorization, scope, or developer instruction can override them.

## References

- `attic/guidelines/080-code-standards.md` §YAML Standard for LLM-to-LLM Data Transfers — the mandate this spec implements (preserved governing copy; the live deck no longer carries `guidelines/`)
- `.opencode#1420` (closed) — issue that codified the YAML mandate rule
- `.opencode#2433` (closed) — dispatch-discipline remediation that reorganized the deck to skill cards and superseded #1208/#1222/#936 (§12); its SC-9 defines the targeted behavioral-run mandate
- `.opencode#1208`, `.opencode#1222`, `.opencode#936` (closed) — former interdependencies; dispositions recorded here, no live dependency remains
- `.opencode#2489` (CM-1) — ceremony-test retirement policy: no new enforcement tests without a defect they alone catch
- `tests-v2/AGENTS.md` — behavioral harness specification (precondition cycle, artifact-only paradigm)
- improvingagents.com (2025) — YAML vs JSON comprehension benchmarks for LLMs

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
