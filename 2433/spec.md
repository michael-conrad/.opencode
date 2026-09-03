# [SPEC] Remediate Orchestrator Dispatch Discipline

> **Full spec and artifacts: [`.opencode/.issues/2433/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2433/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2433/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | Two incompatible orchestrator architectures coexist in the `.opencode` directive layer: Architecture A ("orchestrator is a pure router — it never executes task steps inline") and Architecture B ("orchestrator loads the skill card, executes workflow steps directly, and dispatches task cards via `task()` only where the workflow marks it"). A model reading all directives averages them: it dispatches MORE, including whole cards and whole plans — the exact forwarding the target model prohibits. The observed malfunction (whole SKILL.md and whole plans forwarded to leaf sub-agents that cannot call `task()`) is this averaging made visible. |
| 2 | **Root Cause / Motivation** | The directive layer was written across sessions under two different mental models and never reconciled. `prompts/default.txt` carries BOTH architectures verbatim; `022-orchestrator-context-discipline.md` is written entirely in the pure-router model (A) and arms a HALT-on-inline enforcement machine that would fire on the target model's legitimate direct execution; 3 skill cards mark TDT rows `inline` while their Invocation sections route the same tasks to `task()`; 45 cards carry a blanket "each step dispatched to a sub-agent unless marked inline" clause (measured: 45 files carry the clause head; 44 carry the verbatim single-line tail — `executing-plans` carries the wrapped-tail variant) readable as "dispatch everything"; `executing-plans` routes even read-plan to a sub-agent so no directive anywhere says the orchestrator executes plan steps directly; plans have no pre-flight guard (cards have `ORCHESTRATOR_ONLY_SKILL_CARD`, plans have nothing); and open plan #1210 introduces a third dispatch vocabulary ("orchestrator routes to general (blind)"). |
| 3 | **Approach Chosen** | Adopt Architecture B as the single architecture and re-point every layer at it: rewrite the system prompt routing-boundary language, rewrite `022` (re-pointing the HALT machinery from inline-work to whole-card/whole-plan forwarding), retain the `000-critical-rules` whole-card prohibition, rewrite `executing-plans` so the orchestrator reads the plan and executes steps directly, normalize TDT vocabulary to a closed set (`orchestrator`, `task-card`, `task-card blind`), add a plan pre-flight guard (`ORCHESTRATOR_ONLY_PLAN`), add a per-step dispatch-mode field to the canonical plan format, and single-source the vocabulary in one canonical reference table. Additionally, absorb the dispatch-concern scope of related open tickets (serial pipeline, contract schema, skildeck linter gates) and record supersession of cross-cutting format tickets — see §12. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Keep Architecture A (pure router) and fix only the contradictions — discarded: the whole-card prohibition in `000-critical-rules` and the pre-flight guard in all 51 cards already encode B; the guard converts forwarding into a stall rather than a correction, so A is already unenforceable without contradicting Tier 1 text. (b) Add a third-layer mediation doc explaining when each architecture applies — discarded: adding prose on top of contradictory prose deepens the averaging problem; the deck needs fewer vocabularies, not more. (c) Mechanical detection of forwarding in `session-enforcement.ts` as the primary fix — discarded: detection-at-runtime is a backstop, not a directive; agents need the correct pattern stated before the violation fires. Mechanical detection remains in scope as a phase-2 additive backstop. (d) Leave related dispatch-concern tickets open to be fixed independently — discarded: their dispatch semantics predate and contradict the Architecture-B correction; absorbing them here prevents a second vocabulary fork. |
| 5 | **Key Design Decisions** | (a) The word "inline" is RETIRED from the dispatch vocabulary — it currently means both "orchestrator does directly" (pejorative, in `022`) and "a sanctioned execution mode" (TDT rows); the closed set uses `orchestrator` for sanctioned direct execution. Tradeoff: all 45 blanket-clause cards and 3 contradictory cards need bulk edits, and old TDT values fail the validator after migration. (b) HALT-on-inline machinery is re-pointed, not deleted — the halt behavior is preserved but its trigger condition becomes whole-card/whole-plan forwarding. Tradeoff: any behavioral test asserting the old trigger must be updated in the same GREEN. (c) `task()` dispatch strings are the ONLY sanctioned routing surface — a `task()` string whose target is a SKILL.md path is a whole-card forwarding invitation and fails the grep gate. Tradeoff: card authors lose the ability to delegate "just read this card" — they must route through task cards. (d) Plan steps default to `direct` (orchestrator executes in own context); sub-agent dispatch is opt-in per step. Tradeoff: existing plans without explicit modes remain readable, new plans must carry explicit modes. (e) Related open tickets with direct or cross-cutting dispatch concerns are absorbed into or superseded by this spec rather than remediated in parallel — where an absorbed design contradicts Architecture B, the closed TDT vocabulary, or the `direct|task-card` plan-step schema, this spec's design wins (§12). Tradeoff: absorbed tickets await a separate orchestrator dispatch for marking/closing. |
| 6 | **User Intent / Original Prompt** | Original developer prompt (essence): the observed malfunction is an agent incorrectly dispatching skill cards (not task cards) and whole plans to sub-agents; the target pattern is skill cards' workflows executed directly by the orchestrator with `task()` only at the marked points, and plans loaded and executed step-by-step by the orchestrator; the correction is holistic across `.opencode/` — reconcile conflicting and missing dispatch directives rather than patching a single file. Triggered via the brainstorming → spec-creation handoff (`handoff.yaml`, 3 exploration turns, 7 preliminary artifacts). |

## 2. Not Included

- **`session-enforcement.ts` mechanical forwarding detection** — additive backstop (detect whole-card/whole-plan content in `task()` prompts) is deferred to a follow-up; this spec fixes the directive layer that tells agents the correct pattern. Rationale: directive text is the primary correction surface; mechanical detection without corrected directives would halt correct target-model behavior.
- **Content changes to open spec #1208 / plan #1210 bodies** — their non-dispatch work proceeds; this spec records the coordination decision and supersedes only their dispatch-semantics vocabulary (§12). Rationale: mutating another open issue's body from inside this spec would fork tracking; marking/closing absorbed tickets is a separate orchestrator dispatch.
- **`.opencode/scripts/`, `.opencode/tests/` Python tooling, `node_modules/`, `.venv/`, `.node/`** — no dispatch directives live there.
- **Retiring or redesigning the `skill()` / `task()` tool contracts** — the tool surface is unchanged; only the directive text and guard semantics change.
- **Sub-agent result contract envelope changes** — `{status, finding_summary, artifact_path, blocker_reason}` stays as-is; the enforcement-gated contract schema (SC-10a/10b/10c) extends the payload carried alongside it, not the envelope.
- **`.opencode/AGENTS.md` non-dispatch content** — only its dispatch directives (the "Universal Skill Dispatch Gate" section header and any dispatch-directive prose using the retired vocabulary) change, under R-8/SC-8 coverage; all other AGENTS.md content is out of scope. This bullet documents that AGENTS.md dispatch-directive edits ARE in scope via R-8/SC-8 (blast-radius lists the file as directly affected; the coverage decision lives here and in SC-8 rather than in a dedicated SC).
- **Tickets excluded from absorption (verified no dispatch concern):** 698, 699, 700, 701, 702, 703, 704, 705, 872, 1013, 1189, 1212 — none of these carries a dispatch-table, contract-schema, or serial-pipeline routing concern; their scopes remain with their own issues.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The system prompt (`prompts/default.txt`) Sub-Agent Routing Boundary and Pre-Response Gate state Architecture B: the orchestrator executes skill workflow steps directly in its own context and dispatches a task card via `task()` only where the workflow marks dispatch; the prose "The orchestrator routes. It does not do." and the "hand off to executing-plans via sub-agent" forwarding language are absent. | behavioral | `opencode run` probe (skill-trigger prompt) via `bash .opencode/tests-v2/with-test-home`; assert stderr shows orchestrator executing workflow steps itself (own-context file reads) and no SKILL.md content inside any `task()` prompt | `.opencode/prompts/default.txt` (Sub-Agent Routing Boundary, Pre-Response Gate sections) |
| SC-2 | `022-orchestrator-context-discipline.md` no longer defines the orchestrator as a pure router and no longer HALTs on orchestrator inline work; its halt machinery fires on whole-card/whole-plan forwarding instead; `000-critical-rules.md` retains the whole-card dispatch prohibition (critical-rules-XXX) and its Infrastructure-Failure Carve-out and routing-bypass classifications reference forwarding-based violations. | behavioral | `opencode run` probe: orchestrator performing sanctioned direct workflow execution is not halted; orchestrator forwarding a whole card is halted; verified via tests-v2 behavioral scenario | `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/guidelines/000-critical-rules.md` (whole-card prohibition, Infrastructure-Failure Carve-out sections) |
| SC-3 | `executing-plans` routes plan execution to the orchestrator: it reads the plan file directly, executes steps step-by-step in its own context, and dispatches a step's task card via `task()` only where that step marks dispatch; the read-plan/dispatch-phase routing that sends the whole plan or whole workflow to a sub-agent is absent. | behavioral | `opencode run` probe (approved-plan prompt): assert plan steps executed with orchestrator-own tool calls and `task()` only at step-marked points; no whole-plan body inside any `task()` prompt | `.opencode/skills/executing-plans/SKILL.md`, `tasks/read-plan.md`, `tasks/dispatch-phase.md` |
| SC-4 | No SKILL.md in the deck contains a `task()` dispatch string whose target is a SKILL.md path or that forwards card content; all 51 SKILL.md retain the `ORCHESTRATOR_ONLY_SKILL_CARD` pre-flight guard. | behavioral | tests-v2 behavioral scenario (skill-trigger probe asserting no card content in `task()` prompt) plus the grep gate as precondition check inside the scenario | `.opencode/skills/*/SKILL.md` (Invocation/Dispatch sections), `.opencode/reference/skill-card-schema.md` |
| SC-5 | A plan pre-flight guard exists: a leaf sub-agent receiving a whole plan body rejects with `ORCHESTRATOR_ONLY_PLAN` and halts, analogous to the card guard; the guard definition is written into the canonical standards docs. | behavioral | tests-v2 behavioral negative probe: dispatch a sub-agent with a whole plan body; assert `BLOCKED` with reason `ORCHESTRATOR_ONLY_PLAN` | `.opencode/reference/task-card-structure-standards.md`, `.opencode/skills/skill-creator/` validation tooling |
| SC-6 | TDT Dispatch column values across all SKILL.md use only the closed set {`orchestrator`, `task-card`, `task-card blind`}; the TDT/Invocation contradictions in the audit, brainstorming, and spec-creation cards are resolved; the blanket "each step must be dispatched to a sub-agent unless marked inline" clause is rewritten in every card carrying it (45 files measured). | behavioral | tests-v2 behavioral probe (skill dispatch routes per closed-set row) with the closed-set grep gate as scenario precondition; validator rejects old values (`inline`, `sub-task`, `blind sub-task`) after migration | `.opencode/skills/*/SKILL.md` (TDT sections), `.opencode/reference/skill-card-description-standards.md` |
| SC-7 | The canonical plan format defines a per-step dispatch mode (`direct` or `task-card`, default `direct`); the writing-plans producer templates emit it; a plan-format check verifies every plan step carries an explicit mode. | behavioral | tests-v2 behavioral probe: a plan produced by the updated writing-plans flow is executed per its per-step modes; validator output inspected in-scenario | `.opencode/skills/writing-plans/SKILL.md` + producer task templates, plan-format section |
| SC-8 | A single canonical dispatch-vocabulary table exists in the reference layer; every directive-layer file (system prompt, `022`, `000-critical-rules`, both standards reference cards, and `.opencode/AGENTS.md`'s Universal Skill Dispatch Gate section) references it via Read-link instead of restating definitions; `.opencode/AGENTS.md`'s dispatch directives use the canonical table (retired-vocabulary header prose is rewritten); the system prompt carries no duplicated or contradictory dispatch definitions. | behavioral | tests-v2 behavioral probe: skill-trigger and plan-trigger probes both route per the canonical table; directive files (including `.opencode/AGENTS.md`) inspected in-scenario for Read-link presence and absent duplicate definitions | `.opencode/reference/skill-card-description-standards.md`, `.opencode/prompts/default.txt`, `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/AGENTS.md` (Universal Skill Dispatch Gate section) |
| SC-9a | The orchestrator serial pipeline routes every pipeline dispatch through Architecture-B semantics: the serial pipeline (spec → plan → implement → verify, including the SC coherence gate and its remediation re-dispatch) uses the closed TDT vocabulary and per-step plan dispatch modes as its sole routing sources, with no divide-and-conquer forwarding rows. | behavioral | tests-v2 behavioral serial-pipeline probe: routes per dispatch mode and TDT row; no whole-card/whole-plan forwarding in any `task()` prompt | `.opencode/.issues/open/909-*/spec.md`, `.opencode/.issues/open/912-*/spec.md` |
| SC-9b | The adversarial-audit dispatch-table routing exception dispatches by `auditor_type` to an adversarial model without forwarding card content; no pipeline step routes the adversarial-audit step through the generic dispatch pattern. | behavioral | tests-v2 behavioral adversarial-audit probe: asserts `auditor_type`-based routing and no card content in any `task()` prompt | `.opencode/skills/audit/SKILL.md` (TDT/Invocation), `.opencode/.issues/open/1019-*/spec.md` |
| SC-9c | The cross-validate consensus step derives a deterministic PASS/FAIL verdict from standardized verifier verdicts without re-dispatching whole cards. | behavioral | tests-v2 behavioral consensus probe: asserts deterministic verdict from conflicting verifier outputs | `.opencode/.issues/open/936-*/spec.md` |
| SC-10a | Skill task files declare per-skill `contract.yaml` ownership and emit the standardized enforcement-gated hand-off contract schema with required fields {`gate_result`, `verifier_identity`, `artifact_hash`}; no parallel contract vocabularies remain in the deck. | behavioral | tests-v2 behavioral probe: a pipeline step produces a schema-conformant `contract.yaml` carrying the required fields under declared per-skill ownership; parallel contract vocabularies inspected absent in-scenario | `.opencode/skills/` task files (contract ownership), `.opencode/.issues/open/955-*/spec.md`, `.opencode/.issues/open/1222-*/spec.md` |
| SC-10b | The standardized contract schema carries frugal size limits (bounded field set, no free-form growth) and the skill task-file inventory classification. | behavioral | tests-v2 behavioral probe: a produced contract carries the inventory classification; the linter rejects an oversized contract in-scenario | `.opencode/.issues/open/954-*/spec.md`, `.opencode/skills/` task files |
| SC-10c | The solve tool consumes the standardized contract YAML as its state input. | behavioral | tests-v2 behavioral probe: the solve tool is exercised against standardized contract state in-scenario | `.opencode/tools/solve/`, `.opencode/.issues/open/1198-*/spec.md` |
| SC-11a | skildeck provides a dispatch-table linter gate that rejects TDT Dispatch values outside the closed set {`orchestrator`, `task-card`, `task-card blind`}, running additively alongside existing skildeck validators. | behavioral | validator output inspected in-scenario via negative probe: an old TDT value (`inline`, `sub-task`, `blind sub-task`) fails the linter | `.opencode/tools/skildeck/`, `.opencode/.issues/open/1213-*/spec.md` |
| SC-11b | skildeck provides a dispatch-string linter gate that rejects `task()` dispatch strings whose target is a SKILL.md path (whole-card forwarding invitation), running additively alongside existing skildeck validators. | behavioral | validator output inspected in-scenario via negative probe: a SKILL.md-path-targeting dispatch string fails the linter | `.opencode/tools/skildeck/`, `.opencode/.issues/open/1213-*/spec.md` |
| SC-11c | skildeck provides a contract-schema linter gate that rejects `contract.yaml` files missing required schema fields, running additively alongside existing skildeck validators. | behavioral | validator output inspected in-scenario via negative probe: a schema-missing contract fails the linter | `.opencode/tools/skildeck/`, `.opencode/.issues/open/1213-*/spec.md` |

**SC granularity note:** SC-9, SC-10, and SC-11 absorbed multi-ticket scope and are decomposed into per-concern atomic sub-SCs (SC-9a/9b/9c from #909/#912, #1019, #936; SC-10a/10b/10c from #1222/#955, #954, #1198; SC-11a/11b/11c from #1213's three linter gates) — decomposition is additive; every original assertion is preserved in exactly one sub-SC. SC-2, SC-4, and SC-6 are borderline compound (they each touch multiple files) but each enforces a single routing concern (halt-machinery re-pointing, whole-card prohibition, closed-set vocabulary) and stays whole.

## 4. Requirements

R-1. The system prompt SHALL instruct the orchestrator to execute skill workflow steps directly in its own context, dispatching a task card via `task()` only where the workflow marks dispatch.

R-2. The directive layer (`022-orchestrator-context-discipline.md`, `000-critical-rules.md`) SHALL prohibit whole-card and whole-plan forwarding as the halt-triggering violation, and SHALL NOT prohibit sanctioned direct execution of workflow steps by the orchestrator.

R-3. The `executing-plans` skill SHALL define plan execution as: the orchestrator reads the plan file directly, executes steps step-by-step in its own context, and dispatches a step's task card via `task()` only where that step marks dispatch.

R-4. The deck SHALL contain no `task()` dispatch string whose target is a SKILL.md path (whole-card forwarding invitation), and all SKILL.md files SHALL retain their pre-flight guard.

R-5. A plan pre-flight guard SHALL reject a whole plan body arriving at a leaf sub-agent with `ORCHESTRATOR_ONLY_PLAN`, and its definition SHALL live in the canonical standards docs.

R-6. TDT Dispatch column values SHALL use the closed vocabulary {`orchestrator`, `task-card`, `task-card blind`}; the ambiguous terms `inline`, `sub-task`, and `blind sub-task` SHALL be retired from TDTs, and TDT rows SHALL agree with their card's Invocation section.

R-7. The canonical plan format SHALL carry a per-step dispatch mode (`direct` or `task-card`, default `direct`), and the plan-format check SHALL verify every step carries an explicit mode.

R-8. The dispatch vocabulary SHALL be single-sourced in one canonical reference table, referenced via Read-link by every directive-layer file — including `.opencode/AGENTS.md`'s dispatch directives — with no duplicated or contradictory definitions in the system prompt.

R-9a. The orchestrator serial pipeline SHALL route all pipeline dispatches exclusively through the closed TDT vocabulary and per-step plan dispatch modes, with no divide-and-conquer forwarding rows; the SC coherence gate and its remediation re-dispatch SHALL follow the same routing sources.

R-9b. The adversarial-audit dispatch-table routing exception SHALL dispatch by `auditor_type` to an adversarial model without forwarding card content, and SHALL NOT route the adversarial-audit step through the generic dispatch pattern.

R-9c. The cross-validate consensus step SHALL derive a deterministic PASS/FAIL verdict from standardized verifier verdicts and SHALL NOT re-dispatch whole cards.

R-10a. Skill task files SHALL declare `contract.yaml` ownership and emit the standardized enforcement-gated hand-off contract schema with required fields {`gate_result`, `verifier_identity`, `artifact_hash`}; no parallel contract vocabularies SHALL remain in the deck.

R-10b. The standardized contract schema SHALL carry frugal size limits (bounded field set, no free-form growth) and the skill task-file inventory classification.

R-10c. The solve tool SHALL consume the standardized contract YAML as its state input.

R-11a. skildeck SHALL provide a linter gate that rejects closed-set TDT vocabulary violations, additively alongside existing validators.

R-11b. skildeck SHALL provide a linter gate that rejects `task()` dispatch strings targeting SKILL.md paths, additively alongside existing validators.

R-11c. skildeck SHALL provide a linter gate that rejects contract-schema violations, additively alongside existing validators.

## 5. Items

### Item 1 (SC-1): Rewrite system prompt dispatch directives

- RED: Behavioral scenario prompts a skill trigger; assert stderr currently shows whole-card forwarding or router-model dispatch (expected FAIL before change).
- GREEN: Rewrite `prompts/default.txt` Sub-Agent Routing Boundary and Pre-Response Gate to Architecture B; remove Architecture-A forwarding prose.
- verify: Run the scenario; assert orchestrator executes workflow steps in own context, `task()` only at marked points, no card content in prompts.
- commit: `prompts/default.txt` + scenario in one commit.

### Item 2 (SC-2): Re-point directive-layer HALT machinery

- RED: Behavioral scenario asserting `022` still HALTs on sanctioned direct execution (expected FAIL — the old rule fires).
- GREEN: Rewrite `022` (pure-router framing, inline-work HALT rows) to forwarding-based triggers; align `000-critical-rules` carve-out and routing-bypass classifications; retain the whole-card prohibition.
- verify: Behavioral probes — direct execution not halted, whole-card forwarding halted.
- commit: `guidelines/022-*.md` + `guidelines/000-critical-rules.md` + scenario.

### Item 3 (SC-3): Rewrite executing-plans plan-execution architecture

- RED: Behavioral scenario with an approved plan; assert stderr currently shows whole-plan/workflow dispatch to a sub-agent (expected FAIL before change).
- GREEN: Rewrite `executing-plans/SKILL.md`, `tasks/read-plan.md`, `tasks/dispatch-phase.md`: orchestrator reads the plan and executes steps directly; step-scoped `task()` dispatch only where the plan marks it.
- verify: Scenario asserts orchestrator-own plan-step execution with marked-point dispatch only.
- commit: executing-plans skill files + scenario.

### Item 4 (SC-4): Eliminate whole-card forwarding across the deck

- RED: Grep gate finds SKILL.md-path-targeting `task()` strings; behavioral probe shows card content inside `task()` prompts (expected FAIL).
- GREEN: Fix offending dispatch strings across affected cards; verify guard retention in all 51 cards.
- verify: Grep gate returns zero offending strings; behavioral probe asserts no card content in prompts.
- commit: deck edits + validator gate.

### Item 5 (SC-5): Add plan pre-flight guard

- RED: Negative behavioral probe: sub-agent receiving a whole plan body does not reject (expected FAIL).
- GREEN: Define `ORCHESTRATOR_ONLY_PLAN` guard in `task-card-structure-standards.md` (and skill-creator validation); wire the guard semantics into the sub-agent entry pattern.
- verify: Negative probe asserts `BLOCKED` with reason `ORCHESTRATOR_ONLY_PLAN`.
- commit: standards docs + validation tooling + probe.

### Item 6 (SC-6): Normalize TDT vocabulary to the closed set

- RED: Closed-set validator over all TDTs fails (old values present; 3 contradictory cards detected).
- GREEN: Migrate TDT Dispatch values to {`orchestrator`, `task-card`, `task-card blind`} across the deck; resolve audit/brainstorming/spec-creation TDT-vs-Invocation contradictions; rewrite the blanket clause in all 45 carrying cards.
- verify: Validator passes; behavioral probe routes per closed-set rows.
- commit: deck-wide TDT edits + validator rule.

### Item 7 (SC-7): Add per-step dispatch mode to plan format

- RED: Plan-format check on a produced plan fails (no explicit per-step modes).
- GREEN: Extend the canonical plan format in writing-plans producer templates with the dispatch-mode field (default `direct`); add the format check.
- verify: Produced plan carries per-step modes; behavioral probe executes per modes.
- commit: writing-plans templates + format check.

### Item 8 (SC-8): Single-source the dispatch vocabulary

- RED: Directive-layer files inspected; duplicate/contradictory definitions found, no canonical table (expected FAIL).
- GREEN: Write the canonical vocabulary table into the reference layer; convert directive-layer restatements to Read-links; rewrite `.opencode/AGENTS.md`'s dispatch directives (Universal Skill Dispatch Gate section) onto the canonical table; strip duplicated definitions from the system prompt.
- verify: Behavioral probes (skill + plan triggers) route per the canonical table; directive files including AGENTS.md show Read-link references and no duplicates.
- commit: reference card + directive-layer Read-link edits (including AGENTS.md).

### Item 9a (SC-9a): Re-point serial-pipeline routing to Architecture B

- RED: Behavioral scenario drives a serial-pipeline segment; assert stderr currently shows divide-and-conquer routing or whole-card/whole-plan forwarding in the pipeline's routing table (expected FAIL before change).
- GREEN: Re-point the serial-pipeline routing (absorbing #909's 14-step table and #912's coherence-gate remediation routing) onto the closed TDT vocabulary and per-step plan dispatch modes; remove divide-and-conquer forwarding rows.
- verify: Behavioral probe — pipeline routes per dispatch mode/TDT row with no forwarding.
- commit: routing edits + scenario.

### Item 9b (SC-9b): Route adversarial-audit by auditor_type

- RED: Behavioral scenario drives the adversarial-audit pipeline step; assert stderr currently shows non-`auditor_type` routing through the generic dispatch pattern (expected FAIL before change).
- GREEN: Add the adversarial-audit routing exception (absorbing #1019): dispatch by `auditor_type` to an adversarial model, never by forwarding card content.
- verify: Behavioral probe asserts `auditor_type`-based routing with no card content in prompts.
- commit: dispatch-table routing edit + scenario.

### Item 9c (SC-9c): Derive consensus verdict deterministically

- RED: Behavioral scenario drives the cross-validate consensus step with conflicting verifier outputs; assert the verdict is re-dispatch-based or non-deterministic (expected FAIL before change).
- GREEN: Derive the consensus verdict deterministically from standardized verifier verdicts (absorbing #936); no whole-card re-dispatch.
- verify: Consensus probe asserts deterministic verdict from conflicting verifier outputs.
- commit: consensus-step edit + scenario.

### Item 10a (SC-10a): Standardize contract schema fields + per-skill ownership

- RED: Behavioral scenario runs a pipeline step and inspects its contract artifact; assert no standardized `contract.yaml` with {`gate_result`, `verifier_identity`, `artifact_hash`} and no per-skill ownership declaration (expected FAIL).
- GREEN: Define per-skill `contract.yaml` ownership (absorbing #955, superseded content per #1222) and the standardized schema fields (absorbing #1222) as the required field set; retire parallel contract vocabularies.
- verify: Produced contract conforms to schema with required fields under declared ownership; parallel vocabularies absent.
- commit: schema docs + task-file contract edits + scenario.

### Item 10b (SC-10b): Add frugal contract size limits + inventory classification

- RED: Behavioral scenario inspects produced contracts; assert no bounded field set and no task-file inventory classification (expected FAIL).
- GREEN: Add frugal size limits (bounded field set, no free-form growth) and the skill task-file inventory classification (absorbing #954) to the standardized schema.
- verify: Produced contract carries the inventory classification; the linter rejects an oversized contract in-scenario.
- commit: schema size-bound docs + inventory classification + linter binding + scenario.

### Item 10c (SC-10c): Wire solve tool to standardized contract state

- RED: Behavioral scenario exercises the solve tool against pipeline state; assert it does not consume the standardized contract YAML (expected FAIL).
- GREEN: Wire the solve tool's state input to the standardized contract YAML (absorbing #1198).
- verify: Solve tool consumes standardized contract state in-scenario.
- commit: solve wiring + scenario.

### Item 11a (SC-11a): Add skildeck closed-set TDT vocabulary gate

- RED: Negative probe against skildeck with an old TDT value passes without rejection (expected FAIL).
- GREEN: Add the closed-set TDT vocabulary linter rule to skildeck (merging #1213's dispatch-table linter workstream), additive to existing validators.
- verify: Old TDT value fails the linter; existing validators unaffected.
- commit: skildeck linter rule + probe.

### Item 11b (SC-11b): Add skildeck whole-card dispatch-string gate

- RED: Negative probe against skildeck with a SKILL.md-path-targeting `task()` string passes without rejection (expected FAIL).
- GREEN: Add the SKILL.md-path dispatch-string linter rule to skildeck, additive to existing validators.
- verify: Offending dispatch string fails the linter; existing validators unaffected.
- commit: skildeck linter rule + probe.

### Item 11c (SC-11c): Add skildeck contract-schema gate

- RED: Negative probe against skildeck with a schema-missing contract passes without rejection (expected FAIL).
- GREEN: Add the contract-schema linter rule to skildeck, additive to existing validators.
- verify: Schema-missing contract fails the linter; existing validators unaffected.
- commit: skildeck linter rule + probe.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Absorbed/superseded open specs (909, 912, 954, 955, 1198, 1222, 1019, 1208, 1209, 1210, 1211, 1213, 936, 706 — `.opencode/.issues/open/`) | Dispatch-semantics supersession recorded in §12; those tickets are marked/closed by a separate orchestrator dispatch; non-dispatch workstreams in #1208/#1209/#1211 remain with their owners until closure | pending |
| tests-v2 behavioral harness (`.opencode/tests-v2/with-test-home`, scenario framework) | All SC verification runs through it; existing dispatch-behavior scenarios updated with each GREEN | satisfied |
| Local model availability (qwen3.8:27b-256k-gguf4, verified working) | Behavioral evidence requires real-model `opencode run` cycles; timeout discipline per tests-v2/AGENTS.md (≥600s) | satisfied |
| skildeck validators (`.opencode/tools/skildeck`) | New validator rules (closed-set TDT vocabulary SC-11a, whole-card grep gate SC-11b, plan-step modes SC-7, contract-schema linter SC-11c) land additively | satisfied |
| Skill card pre-flight guards (all 51 SKILL.md) | Retained verbatim; the card-side backstop is unchanged | satisfied |
| Solve tool (`.opencode/tools/solve`) + standardized contract schema (absorbed #1198/#1222) | The solve tool consumes the standardized contract YAML as state input; schema fields land before Item 10c's wiring | pending |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |
| R-4 | SC-4 | Item 4 |
| R-5 | SC-5 | Item 5 |
| R-6 | SC-6 | Item 6 |
| R-7 | SC-7 | Item 7 |
| R-8 | SC-8 | Item 8 |
| R-9a | SC-9a | Item 9a |
| R-9b | SC-9b | Item 9b |
| R-9c | SC-9c | Item 9c |
| R-10a | SC-10a | Item 10a |
| R-10b | SC-10b | Item 10b |
| R-10c | SC-10c | Item 10c |
| R-11a | SC-11a | Item 11a |
| R-11b | SC-11b | Item 11b |
| R-11c | SC-11c | Item 11c |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| System prompt routing language | config | `.opencode/prompts/default.txt` (Sub-Agent Routing Boundary, Pre-Response Gate) | grep read this session: Architecture-A prose at "The orchestrator routes. It does not do." + Architecture-B procedure at Pre-Response Gate step 2.5 |
| Orchestrator context discipline guideline | guideline | `.opencode/guidelines/022-orchestrator-context-discipline.md` | grep read this session: "pure router", "Orchestrator inline work detected → HALT" rows confirmed |
| Critical rules whole-card prohibition | guideline | `.opencode/guidelines/000-critical-rules.md` (critical-rules-XXX sections) | read this session (Tier 1 instruction load): whole-card dispatch prohibition + pre-flight guard backstop present |
| Executing-plans routing | skill card | `.opencode/skills/executing-plans/SKILL.md` | grep read this session: read-plan/dispatch-phase route to sub-agents; blanket clause present (wrapped-tail variant) |
| Card contradictions | skill cards | `.opencode/skills/audit/SKILL.md`, `brainstorming/SKILL.md`, `spec-creation/SKILL.md` | grep read this session: TDT rows marked `inline` vs Invocation `task()` routing confirmed |
| Blanket clause prevalence | deck survey | `.opencode/skills/*/SKILL.md` | grep measured this session (counting pattern: `grep -rl` per file, clause head "must be dispatched to a sub-agent via `task()`"): 45 files carry the blanket clause, one occurrence each; of these, 44 carry the verbatim single-line tail "unless explicitly marked as inline" and the 45th (`executing-plans/SKILL.md`) wraps the tail onto the following line as "explicitly marked as inline/orchestrator" |
| AGENTS.md dispatch directives | guideline | `.opencode/AGENTS.md` (Universal Skill Dispatch Gate section) | grep read this session: line 21 header "Professional agents dispatch skills. Amateurs inline." uses the retired "inline" pejorative vocabulary; blast-radius artifact lists the file as directly affected |
| Plan pre-flight guard absence | deck survey | `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/prompts/` | grep count this session: 0 occurrences of `ORCHESTRATOR_ONLY_PLAN` |
| Third dispatch vocabulary | open plan | `.opencode/.issues/1214/plan.md` (dispatch-type gate rows) | grep read this session: "orchestrator routes to general"/"orchestrator inline" vocabulary confirmed; path verified to exist this session |
| Preliminary analysis artifacts | analysis | `.opencode/.issues/2433/artifacts/` (canonical copy: blast-radius, concern-map, code-paths, cross-cutting, interface-compat, state-analysis, testability + handoff.yaml; preliminary origin: `tmp/dispatch-remediation/artifacts/preliminary/`) | read this session (7 artifacts + handoff.yaml); copied to the canonical `.opencode/.issues/2433/artifacts/` directory at revision time |
| Absorbed spec bodies (909, 912, 954, 955, 1198, 1222, 1019, 936) | spec | `.opencode/.issues/open/{909,912,954,955,1198,1222,1019,936}-*/spec.md` | verified this session: all absorption-set directories present under `.opencode/.issues/open/` with `spec.md` |
| Cross-cutting superseded spec bodies (1208, 1209, 1210, 1211, 1213, 706) | spec | `.opencode/.issues/open/{1208,1209,1210,1211,1213,706}-*/spec.md` | verified this session: directories present under `.opencode/.issues/open/` with `spec.md` |
| skildeck tooling | tool | `.opencode/tools/skildeck/` | verified this session: directory present |
| Solve tool | tool | `.opencode/tools/solve/` | verified this session: directory present |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the skill-trigger behavioral probe costs minutes of model execution time — the defect (whole-card forwarding) is caught at the earliest gate and the fix costs one bounded re-run. Skipping means the averaging defect ships in the system prompt loaded into every future session, and every skill invocation thereafter inherits it — the death spiral starts at the highest-leverage file in the deck.
- SC-2: Running the direct-execution and forwarding probes costs minutes. Skipping means the HALT machinery keeps firing on correct behavior and never fires on the defect — the orchestrator learns that following the rules is punished, which trains the averaging behavior this spec exists to remove.
- SC-3: Running the approved-plan probe costs minutes. Skipping means plans continue to be wholesale-forwarded to leaf sub-agents that stall, fabricate completion, or return partial work as complete — the defect surfaces as silent pipeline corruption discovered days later in review.
- SC-4: The grep gate costs seconds and the behavioral probe costs minutes. Skipping means 284 dispatch strings keep inviting whole-card forwarding, and the guard converts each into a stall-retry loop instead of a correction — every affected skill invocation pays the cost.
- SC-5: Running the negative probe (whole plan to a sub-agent) costs minutes. Skipping means plans remain the only unguarded artifact class — the one path where forwarding produces silent malfunction instead of a BLOCKED contract.
- SC-6: The closed-set validator costs seconds per commit; the routing probe costs minutes. Skipping means three vocabularies persist and every new card flips a coin between them — each new card added under the old vocabulary extends the migration debt.
- SC-7: Producing a plan with per-step modes and running the format check costs minutes. Skipping means the plan layer stays prose-ambiguous and Item 3's behavioral fix degrades back to wholesale forwarding on the next hand-written plan.
- SC-8: Reading the canonical table and running both trigger probes costs minutes. Skipping means the vocabulary re-fragments at the next session that edits a directive file — the dedup is the only item that keeps the other sixteen from regressing.
- SC-9a: Running the serial-pipeline probe costs minutes. Skipping means the absorbed #909/#912 divide-and-conquer routing keeps averaging with Architecture B — the same averaging defect this spec removes re-enters through the serial pipeline and every absorbed ticket's unimplemented scope.
- SC-9b: Running the adversarial-audit routing probe costs minutes. Skipping means the dual-auditor workflow stays bypassed through the generic dispatch pattern — adversarial audits run under the wrong model class and the misrouting is caught only downstream at the verifier-identity gate.
- SC-9c: Running the consensus probe costs minutes. Skipping means cross-validate keeps re-dispatching whole cards on conflicting verifier outputs — consensus stays non-deterministic and the enforcement gate inherits coin-flip verdicts.
- SC-10a: Producing a schema-conformant contract and inspecting ownership costs minutes. Skipping means hand-off artifacts stay free-form — gate results without verifier identity or artifact hash cannot be cross-validated, and parallel contract vocabularies keep fork the payload schema.
- SC-10b: Running the oversized-contract negative linter probe costs seconds. Skipping means contracts grow without bound and the inventory classification never lands — frugality stays a convention instead of a gate.
- SC-10c: Exercising the solve tool against contract state costs minutes. Skipping means the solve tool wires against a moving schema — Z3 verification runs against state whose shape can change between runs.
- SC-11a: Running the closed-set negative probe costs seconds. Skipping means the closed set is a convention, not a gate — the next card author reintroduces a retired vocabulary value with no mechanical rejection.
- SC-11b: Running the SKILL.md-path negative probe costs seconds. Skipping means whole-card forwarding invitations persist in dispatch strings with no mechanical rejection.
- SC-11c: Running the schema-missing-contract negative probe costs seconds. Skipping means the contract schema is a convention, not a gate — schema-missing contracts flow into the solve tool undetected.

## 11. Edge Cases

- **Condition:** A directive-layer edit is behaviorally correct but a behavioral test cannot execute (model unavailable, harness failure). **Expected behavior:** the SC verdict is FAIL — structural or string substitutes are EVIDENCE_TYPE_MISMATCH; remediation-first protocol applies. **Resolution:** retry with the verified model; escalate only after exhaustive remediation.
- **Condition:** An existing in-flight plan (#1210) uses the retired third vocabulary. **Expected behavior:** the plan remains readable (old vocabulary is not erroring for old plans); new plans carry explicit closed-set modes; a coordination comment on #1210 records supersession of its dispatch-semantics rows. **Resolution:** no rewrite of the in-flight plan body is required for its validity — only new plans must conform.
- **Condition:** A skill card legitimately needs orchestrator-only steps mixed with dispatched steps. **Expected behavior:** the TDT row marked `orchestrator` expresses it; the Invocation section agrees; the closed set has a value for exactly this case. **Resolution:** contradiction resolution is per-card, verified by the TDT-vs-Invocation consistency check inside the Item 6 validator.
- **Condition:** A sub-agent receives a step-scoped prompt (not a whole plan) that references the plan. **Expected behavior:** no guard fires — step-scoped prompts and task cards are the sanctioned carriers; only a whole plan body trips `ORCHESTRATOR_ONLY_PLAN`. **Resolution:** the guard definition in the standards docs specifies the trip condition (plan document body in the dispatch prompt).
- **Condition:** The 51-card pre-flight guard retention check and the whole-card grep gate disagree (guard present, but a `task()` string still targets a SKILL.md path). **Expected behavior:** the SC fails on the grep gate — guard presence alone is insufficient; both checks must pass. **Resolution:** the Item 4 validator requires both conditions.
- **Condition:** Concurrent edits to the same deck files by open specs #1208/#1210 and this remediation. **Expected behavior:** sequencing is decided at coordination time (recorded in the #1210 comment before implementation); no silent merge of dispatch semantics. **Resolution:** this spec's vocabulary supersedes; the other issue re-bases its format work onto the closed set.
- **Condition:** An absorbed issue's design contradicts this spec's target architecture (e.g., #909's divide-and-conquer dispatch table vs Architecture B). **Expected behavior:** this spec's design wins — Architecture B, the closed TDT vocabulary {`orchestrator`, `task-card`, `task-card blind`}, and the `direct|task-card` plan-step schema are authoritative; the conflicting absorbed content is recorded as superseded in §12. **Resolution:** no dual-vocabulary period — implementation follows only this spec's dispatch semantics; absorbed tickets are marked/closed by a separate orchestrator dispatch.
- **Condition:** The blanket-clause rewrite (SC-6) and the wrapped-tail variant in `executing-plans/SKILL.md` (SC-3's file set) overlap on the same file. **Expected behavior:** both edits land on the same file without conflict — SC-3 rewrites the card's routing architecture and SC-6 rewrites its Task Discipline clause; the item ordering runs SC-3 before SC-6 so the clause rewrite lands on the already-corrected card. **Resolution:** the enforcement gate re-runs either SC if a later GREEN regresses an earlier one (Recovery edge case).
- **State boundary:** the `.opencode` submodule pointer must ride alongside the next real parent-repo change; pointer-only pushes are blocked by pre-push hooks. **Expected behavior:** all spec implementation commits land in the submodule; pointer updates follow parent-repo discipline. **Resolution:** no migration needed (state analysis artifact confirms no DB/session schema impact).
- **Recovery:** if a behavioral GREEN regresses a previously passing SC (e.g., Item 6 vocabulary edits break Item 1 probe assertions), the affected earlier SC re-runs before the pipeline advances; the enforcement gate is all-or-nothing.

## 12. Superseded and Absorbed Issues

All 14 tickets below were verified (by the orchestrator, against the local `.opencode/.issues/open/` spec bodies) to carry direct or cross-cutting dispatch concerns. **They are NOT closed from this task** — they await marking/closing by a separate orchestrator dispatch. This section records the absorption mapping and conflict resolution.

**Conflict rule:** where an absorbed spec's design contradicts this spec's target architecture (Architecture B: orchestrator executes skill-card workflows and plan steps directly, `task()` only at marked points; closed TDT vocabulary {`orchestrator`, `task-card`, `task-card blind`}; plan-step dispatch mode `direct|task-card`), **this spec's design wins** and the absorbed issue's conflicting content is superseded as noted.

### 12.1 Direct — absorbed scope merged into this spec

| Issue | Disposition | Scope outcome |
|-------|-------------|---------------|
| #909 | absorbed-scope-merged | Orchestrator serial pipeline's 14-step dispatch routing table (replacing divide-and-conquer) is redefined by this spec's Architecture-B dispatch semantics — carried by SC-9a/R-9a/Item 9a; its router-model routing rows are superseded. |
| #912 | absorbed-scope-merged | SC coherence gate + remediation routing (Phase 2 of the 909 cluster) proceeds under this spec's routing vocabulary — carried by SC-9a/R-9a/Item 9a; remediation re-dispatch follows the per-step plan dispatch modes. |
| #954 | absorbed-scope-merged | Frugal contract size limits + skill task-file inventory classification fold into the standardized contract schema — carried by SC-10b/R-10b/Item 10b. |
| #955 | absorbed-scope-merged | Per-skill `contract.yaml` ownership folds into SC-10a/R-10a/Item 10a; its content was already mostly superseded by #1222, which this spec absorbs. |
| #1198 | absorbed-scope-merged | Solve-tool state wiring of the standardized contract YAML is carried by SC-10c/R-10c/Item 10c; the solve tool consumes the schema defined in Item 10a. |
| #1222 | absorbed-scope-merged | Enforcement-gated hand-off contract schema {`gate_result`, `verifier_identity`, `artifact_hash`} absorbed into SC-10a/R-10a/Item 10a verbatim as the required field set. |
| #1019 | absorbed-scope-merged | Dispatch-table routing exception for adversarial-audit absorbed into SC-9b/R-9b/Item 9b — routing dispatches by `auditor_type` to an adversarial model, never by forwarding card content. |

### 12.2 Cross-cutting format — superseded

| Issue | Disposition | Scope outcome |
|-------|-------------|---------------|
| #1208 | superseded | Skillcard routing overhaul parent: this spec's deck normalization + validator work covers and supersedes its dispatch-relevant workstreams (TDT overhaul → SC-6, dispatch-table linter → SC-11a/SC-11b); non-dispatch workstreams (e.g., submodule-sync task) remain with #1208 until closed. |
| #1209 | superseded | Workstream A YAML frontmatter cleanup: subsumed by this spec's deck normalization (closed TDT vocabulary SC-6 + canonical table SC-8); residual non-dispatch frontmatter work remains with #1209 until closed. |
| #1210 | superseded | Workstream B trigger dispatch tables: superseded by the closed-vocabulary migration (SC-6); its third dispatch vocabulary ("orchestrator routes to general (blind)") is retired. |
| #1211 | superseded | Workstream C procedure checklist-ification: subsumed by this spec's deck normalization (SC-4/SC-6); checklists carry closed-set dispatch strings. |
| #1213 | superseded | Workstream E skildeck dispatch-table + contract-schema linter: merges with this spec's validator gates — the dispatch-table gates are carried by SC-11a/R-11a and SC-11b/R-11b (Items 11a/11b), the contract-schema gate by SC-11c/R-11c (Item 11c). |
| #936 | superseded | Deterministic consensus gate: orchestrator routing in cross-validate is absorbed into SC-9c/R-9c/Item 9c; consensus derives deterministically from standardized verifier verdicts. |
| #706 | superseded | Phase-level plans with TDD as mandate: the TDD mandate is preserved, but the canonical plan-step dispatch schema is defined by this spec (R-7/SC-7, extended by SC-10a/10b/10c); plan-format conflicts resolve in this spec's favor. |

### 12.3 Excluded — verified no dispatch concern (not absorbed)

698, 699, 700, 701, 702, 703, 704, 705, 872, 1013, 1189, 1212.

## 13. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-03 | Added §12 (Superseded and Absorbed Issues) with the 14-ticket absorption mapping; added SC-9/SC-10/SC-11, R-9/R-10/R-11, and Items 9–11; updated Intent (field 3/4/5 additions), Not Included (excluded-ticket list, body-mutation clarification, contract envelope clarification), Dependencies (absorbed-set row, solve-tool row), Traceability, Documentation Sources, Cost Frame, and Edge Cases (Architecture-B conflict rule) | Developer directive — absorb/supersede all related open tickets with direct or cross-cutting dispatch concerns into this spec; prior tickets conflicting with the dispatch corrections are resolved via supersession (closing handled by separate orchestrator dispatch) | Developer (test) |
| 2026-09-03 | Validation-FAIL revision (first validate→revise iteration, Tier 1): added preamble field 6 (User Intent / Original Prompt); decomposed SC-9 → SC-9a/SC-9b/SC-9c, SC-10 → SC-10a/SC-10b/SC-10c, and SC-11 → SC-11a/SC-11b/SC-11c into per-concern atomic sub-SCs — each with its own R row (R-9a..R-9c, R-10a..R-10c, R-11a..R-11c), its own Item with RED/GREEN cycle (Items 9a..9c, 10a..10c, 11a..11c), its own cost-frame row, and §7 traceability rows (SC set now 17; SC-1..SC-8 unchanged; decomposition is additive, no assertion removed); fixed Documentation Sources citation path (`.issues/1214/plan.md` → `.opencode/.issues/1214/plan.md`) and replaced the unverified blanket-clause count with measured numbers (45 clause-carrying files, 44 verbatim single-line tails, counting pattern stated); extended R-8/SC-8 to cover `.opencode/AGENTS.md` dispatch directives and documented the coverage decision in Not Included; copied the 8 preliminary artifacts to the canonical `.opencode/.issues/2433/artifacts/` and updated the artifacts Documentation-Sources row; updated sc-summary.yaml (sc_count 17); regenerated the remote exec-summary issue body; no linked plan exists at `.opencode/.issues/2433/plan.md`, so plan regeneration is not applicable | spec-creation validate findings: F1 completeness (preamble field 6 missing), F2 compound-sc (SC-9/SC-10/SC-11 absorbed multi-ticket scope), F3 provenance (citation path + blanket-clause count mismatch); validator warnings: sc-summary drift, AGENTS.md blast-radius coverage, artifact placement | Developer (test) — spec-creation validate→revise pipeline iteration |