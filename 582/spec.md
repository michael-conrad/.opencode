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

This spec re-baselines the mandate onto the current deck: verify live-deck conformance, and give the rule a live, on-demand disclosure home.

## Principle

**YAML for everything an LLM reads, parses, or is instructed to generate. JSON only for tool-to-tool file I/O, CLI output, and external tool configuration.**

Operationally: the agent uses YAML, not JSON, as the default communication format for structured data it directly parses or writes for consumption by other agents. The governing rule text (§YAML Standard for LLM-to-LLM Data Transfers) survives in the preserved governing copy `attic/guidelines/080-code-standards.md`; the live deck no longer carries `guidelines/`. In the current deck, conventions are disclosed via skill cards loaded on demand — never via the slim pointer surfaces (`floor.md`, `routing.md`, `AGENTS.md`, `prompts/default.txt`), which carry no contract content and gain none from this spec.

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
| Agent re-serialization of tool JSON for another agent | YAML (the hand-off representation; the tool's raw output stays JSON) | convert before hand-off |
| Tool I/O, CLI output, file persistence | JSON (unchanged) | excluded from migration |

## Scope

Live, LLM-consumed, owned content in `.opencode/`: skill cards (`skills/**` — `SKILL.md` and `references/**`), agent-facing harness documentation (`tests-v2/AGENTS.md`), `docs/`, `README.md`, agent cards (`agents/*.md`), and the pointer surfaces (`floor.md`, `routing.md`, `AGENTS.md`, `prompts/`). The implementing agent discovers affected content per block, not per file. Card and routing-index edits go through the deck-governance card (`skill-creator`) — this spec defines the requirement; deck governance governs the edit.

### Excluded

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
| SC-4 | The YAML-default communication rule is disclosed in the live deck via a skill card: the agent uses YAML, not JSON, as the default format for structured data it directly parses or writes for consumption by other agents (exceptions: tool I/O, CLI output, external configuration). The rule is discoverable through the routing index; the pointer surfaces carry none of the rule text. | `structural` | Read the live deck: a card carries the rule; `routing.md` routes structured-data-format intent to it (an index entry, not rule text); `skildeck lint` passes on the amended card; `floor.md`, `AGENTS.md`, and `prompts/default.txt` remain slim (diff shows no rule text added). |
| SC-5 | Excluded content remains byte-identical: no modifications outside the migration set, and excluded categories keep their JSON where JSON is correct. | `structural` | Diff check — no changes to `attic/`, `.issues/` stores, vendor-generated agent cards, fixtures, generated artifacts, tool I/O files, or CLI-output documentation; the one live ` ```json ` block (`search-read.md`) is byte-identical. |
| SC-6 | Verification instruments pass post-remediation. | `behavioral` | `bash .opencode/tests-v2/test-enforcement.sh` — zero failures (content-verification runner; no model runs; full run permitted). Behavioral scenarios run only where card text changed, one targeted run per SC's RED/GREEN need per `.opencode#2433`'s targeted-run mandate — whole-suite behavioral enumeration is prohibited — under the harness precondition cycle (commit → push → fetch/verify → run, `tests-v2/AGENTS.md` §4). |
| SC-7 | **Zero-tolerance for lobotomized tests.** No SC may be removed, weakened, deferred, or blocked to evade implementation. Any attempt to bypass an SC (skip, defer, mark as "blocked", weaken evidence type) marks ALL SCs as FAIL. The PR must be immediately rejected and trashed as defective and unusable. | `behavioral` | The `verify` card's single fresh-context reviewer pass confirms every SC in this spec is addressed with its declared evidence. Any missing or weakened SC → ALL SCs FAIL. |
| SC-8 | All SCs must achieve 100% clean PASS. No "PASS with caveats", "functionally equivalent", "PASS with concerns", or any partial-PASS verdict is accepted. A single FAIL on any SC means the entire implementation is rejected. | `behavioral` | Verification produces binary PASS/FAIL per SC. Any FAIL → full rejection. |

## Phases

### Phase 1 — Live-deck residual sweep

Scan live LLM-consumed content (the Scope set) for fenced JSON contract templates, prose JSON-output instructions, and JSON-verdict language. Classify each hit per block: migrate (LLM-consumed contract) vs exclude (tool I/O, CLI output, config example). Migrate where required: fence-type replacement plus structural JSON→YAML conversion — braces and commas become indentation, quoted keys become unquoted, trailing commas removed, array brackets become dash lists — with semantic equivalence preserved. The Current State scan found no live block requiring migration; this sweep exists to catch anything the pattern scan missed, and its findings drive this phase's work.

### Phase 2 — Mandate disclosure via skill card

Amend or create the skill card that carries the YAML-default communication rule (Principle section, operational phrasing), through the deck-governance card: admission gate, predicate classification, deck-debt ledger. Add the routing-index entry that dispatches structured-data-format intent to that card. The card choice is an implementation decision under the admission gate; the requirement is that the rule be live, on-demand discoverable, and absent from the pointer surfaces.

### Phase 3 — Verification pass

- `bash .opencode/tests-v2/test-enforcement.sh` — zero failures.
- Behavioral scenarios only where card text changed (targeted runs, precondition cycle).
- Spot-check the excluded set byte-identical.
- The `verify` card's single fresh-context reviewer pass over all SCs against the diff and executed output; close the issue only when all SCs pass.

## Edge Cases

- **Agent-parsed tool JSON** — when an agent parses a tool's JSON output and re-serializes it for another agent, the hand-off representation is YAML; the tool's raw output stays JSON.
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
| Agents default to JSON in agent-to-agent structured exchanges (training-data bias) | High | High | SC-4 discloses the YAML-default rule via a live skill card the agent loads when exchanging structured data |
| Attic deletion orphans the codified rule | Medium | High | SC-4 moves the rule's live home into the deck before `attic/` ages out |
| JSON→YAML conversion loses structural information in an edge case | Low | Medium | SC-1's semantic-equivalence verification applies to any block the sweep migrates |
| Excluded files accidentally modified | Low | Medium | SC-5 diff check; the implementor classifies per block before editing |
| Prose-embedded JSON ambiguous with tool-describing JSON | Medium | Low | Per-block reading comprehension — the implementor reads context before converting |
| Enforcement tests expect pre-migration text | Medium | Medium | SC-6 runs the enforcement suite post-remediation; failures indicate missed references |
| Multi-record YAML with `---` separators confuses LLM parsing | Low | Low | Same multi-doc pattern as the YAML spec itself; well-established |
| SC lobotomization (weakening SCs to pass) | Low | Critical | SC-7 explicitly prohibits this; any attempt marks ALL SCs as FAIL and rejects the PR |

## Change Control

- Single-PR boundary. All phases ship together.
- The core principle (YAML as the default format for structured data exchanged between agents) is frozen. SC-set changes happen only through a developer-directed spec revision — never agent-initiated weakening (SC-7 governs).
- Deck edits during implementation (card amendment, routing-index entry) go through the deck-governance card — the admission gate applies; this spec does not bypass it.
- Post-implementation verification is the `verify` card's single fresh-context reviewer pass against this spec.
- SC-7 and SC-8 are non-waivable. No authorization, scope, or developer instruction can override them.

## References

- `attic/guidelines/080-code-standards.md` §YAML Standard for LLM-to-LLM Data Transfers — the mandate this spec implements (preserved governing copy; the live deck no longer carries `guidelines/`)
- `.opencode#1420` (closed) — issue that codified the YAML mandate rule
- `.opencode#2433` (closed) — dispatch-discipline remediation that reorganized the deck to skill cards and superseded #1208/#1222/#936 (§12); its SC-9 defines the targeted behavioral-run mandate
- `.opencode#1208`, `.opencode#1222`, `.opencode#936` (closed) — former interdependencies; dispositions recorded here, no live dependency remains
- `.opencode#2489` (CM-1) — ceremony-test retirement policy: no new enforcement tests without a defect they alone catch
- `tests-v2/AGENTS.md` — behavioral harness specification (precondition cycle, artifact-only paradigm)
- improvingagents.com (2025) — YAML vs JSON comprehension benchmarks for LLMs

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
