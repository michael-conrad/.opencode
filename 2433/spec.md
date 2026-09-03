# [SPEC] Remediate Orchestrator Dispatch Discipline

> **Full spec and artifacts: [`.opencode/.issues/2433/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2433/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2433/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | Two incompatible orchestrator architectures coexist in the `.opencode` directive layer: Architecture A ("orchestrator is a pure router — it never executes task steps inline") and Architecture B ("orchestrator loads the skill card, executes workflow steps directly, and dispatches task cards via `task()` only where the workflow marks it"). A model reading all directives averages them: it dispatches MORE, including whole cards and whole plans — the exact forwarding the target model prohibits. The observed malfunction (whole SKILL.md and whole plans forwarded to leaf sub-agents that cannot call `task()`) is this averaging made visible. |
| 2 | **Root Cause / Motivation** | The directive layer was written across sessions under two different mental models and never reconciled. `prompts/default.txt` carries BOTH architectures verbatim; `022-orchestrator-context-discipline.md` is written entirely in the pure-router model (A) and arms a HALT-on-inline enforcement machine that would fire on the target model's legitimate direct execution; 3 skill cards mark TDT rows `inline` while their Invocation sections route the same tasks to `task()`; 44 cards carry a blanket "each step dispatched to a sub-agent unless marked inline" clause readable as "dispatch everything"; `executing-plans` routes even read-plan to a sub-agent so no directive anywhere says the orchestrator executes plan steps directly; plans have no pre-flight guard (cards have `ORCHESTRATOR_ONLY_SKILL_CARD`, plans have nothing); and open plan #1210 introduces a third dispatch vocabulary ("orchestrator routes to general (blind)"). |
| 3 | **Approach Chosen** | Adopt Architecture B as the single architecture and re-point every layer at it: rewrite the system prompt routing-boundary language, rewrite `022` (re-pointing the HALT machinery from inline-work to whole-card/whole-plan forwarding), retain the `000-critical-rules` whole-card prohibition, rewrite `executing-plans` so the orchestrator reads the plan and executes steps directly, normalize TDT vocabulary to a closed set (`orchestrator`, `task-card`, `task-card blind`), add a plan pre-flight guard (`ORCHESTRATOR_ONLY_PLAN`), add a per-step dispatch-mode field to the canonical plan format, and single-source the vocabulary in one canonical reference table. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Keep Architecture A (pure router) and fix only the contradictions — discarded: the whole-card prohibition in `000-critical-rules` and the pre-flight guard in all 51 cards already encode B; the guard converts forwarding into a stall rather than a correction, so A is already unenforceable without contradicting Tier 1 text. (b) Add a third-layer mediation doc explaining when each architecture applies — discarded: adding prose on top of contradictory prose deepens the averaging problem; the deck needs fewer vocabularies, not more. (c) Mechanical detection of forwarding in `session-enforcement.ts` as the primary fix — discarded: detection-at-runtime is a backstop, not a directive; agents need the correct pattern stated before the violation fires. Mechanical detection remains in scope as a phase-2 additive backstop. |
| 5 | **Key Design Decisions** | (a) The word "inline" is RETIRED from the dispatch vocabulary — it currently means both "orchestrator does directly" (pejorative, in `022`) and "a sanctioned execution mode" (TDT rows); the closed set uses `orchestrator` for sanctioned direct execution. Tradeoff: all 44 blanket-clause cards and 3 contradictory cards need bulk edits, and old TDT values fail the validator after migration. (b) HALT-on-inline machinery is re-pointed, not deleted — the halt behavior is preserved but its trigger condition becomes whole-card/whole-plan forwarding. Tradeoff: any behavioral test asserting the old trigger must be updated in the same GREEN. (c) `task()` dispatch strings are the ONLY sanctioned routing surface — a `task()` string whose target is a SKILL.md path is a whole-card forwarding invitation and fails the grep gate. Tradeoff: card authors lose the ability to delegate "just read this card" — they must route through task cards. (d) Plan steps default to `direct` (orchestrator executes in own context); sub-agent dispatch is opt-in per step. Tradeoff: existing plans without explicit modes remain readable, new plans must carry explicit modes. |
| 6 | **User Intent / Original Prompt** | "the spec topic: remediation of orchestrator dispatch discipline in .opencode/ (skill cards executed directly by orchestrator with task() only at marked points; plans executed step-by-step by orchestrator; whole-card and whole-plan forwarding eliminated; vocabulary normalization; dedup of system-prompt injection)." |

## 2. Not Included

- **`session-enforcement.ts` mechanical forwarding detection** — additive backstop (detect whole-card/whole-plan content in `task()` prompts) is deferred to a follow-up; this spec fixes the directive layer that tells agents the correct pattern. Rationale: directive text is the primary correction surface; mechanical detection without corrected directives would halt correct target-model behavior.
- **Content changes to open spec #1208 / plan #1210** — their TDT-format work proceeds; this spec records the coordination decision and supersedes only their dispatch-semantics vocabulary. Rationale: mutating another open issue's body from inside this spec would fork tracking.
- **`.opencode/scripts/`, `.opencode/tests/` Python tooling, `node_modules/`, `.venv/`, `.node/`** — no dispatch directives live there.
- **Retiring or redesigning the `skill()` / `task()` tool contracts** — the tool surface is unchanged; only the directive text and guard semantics change.
- **Sub-agent result contract changes** — `{status, finding_summary, artifact_path, blocker_reason}` stays as-is.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The system prompt (`prompts/default.txt`) Sub-Agent Routing Boundary and Pre-Response Gate state Architecture B: the orchestrator executes skill workflow steps directly in its own context and dispatches a task card via `task()` only where the workflow marks dispatch; the prose "The orchestrator routes. It does not do." and the "hand off to executing-plans via sub-agent" forwarding language are absent. | behavioral | `opencode run` probe (skill-trigger prompt) via `bash .opencode/tests-v2/with-test-home`; assert stderr shows orchestrator executing workflow steps itself (own-context file reads) and no SKILL.md content inside any `task()` prompt | `.opencode/prompts/default.txt` (Sub-Agent Routing Boundary, Pre-Response Gate sections) |
| SC-2 | `022-orchestrator-context-discipline.md` no longer defines the orchestrator as a pure router and no longer HALTs on orchestrator inline work; its halt machinery fires on whole-card/whole-plan forwarding instead; `000-critical-rules.md` retains the whole-card dispatch prohibition (critical-rules-XXX) and its Infrastructure-Failure Carve-out and routing-bypass classifications reference forwarding-based violations. | behavioral | `opencode run` probe: orchestrator performing sanctioned direct workflow execution is not halted; orchestrator forwarding a whole card is halted; verified via tests-v2 behavioral scenario | `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/guidelines/000-critical-rules.md` (whole-card prohibition, Infrastructure-Failure Carve-out sections) |
| SC-3 | `executing-plans` routes plan execution to the orchestrator: it reads the plan file directly, executes steps step-by-step in its own context, and dispatches a step's task card via `task()` only where that step marks dispatch; the read-plan/dispatch-phase routing that sends the whole plan or whole workflow to a sub-agent is absent. | behavioral | `opencode run` probe (approved-plan prompt): assert plan steps executed with orchestrator-own tool calls and `task()` only at step-marked points; no whole-plan body inside any `task()` prompt | `.opencode/skills/executing-plans/SKILL.md`, `tasks/read-plan.md`, `tasks/dispatch-phase.md` |
| SC-4 | No SKILL.md in the deck contains a `task()` dispatch string whose target is a SKILL.md path or that forwards card content; all 51 SKILL.md retain the `ORCHESTRATOR_ONLY_SKILL_CARD` pre-flight guard. | behavioral | tests-v2 behavioral scenario (skill-trigger probe asserting no card content in `task()` prompt) plus the grep gate as precondition check inside the scenario | `.opencode/skills/*/SKILL.md` (Invocation/Dispatch sections), `.opencode/reference/skill-card-schema.md` |
| SC-5 | A plan pre-flight guard exists: a leaf sub-agent receiving a whole plan body rejects with `ORCHESTRATOR_ONLY_PLAN` and halts, analogous to the card guard; the guard definition is written into the canonical standards docs. | behavioral | tests-v2 behavioral negative probe: dispatch a sub-agent with a whole plan body; assert `BLOCKED` with reason `ORCHESTRATOR_ONLY_PLAN` | `.opencode/reference/task-card-structure-standards.md`, `.opencode/skills/skill-creator/` validation tooling |
| SC-6 | TDT Dispatch column values across all SKILL.md use only the closed set {`orchestrator`, `task-card`, `task-card blind`}; the TDT/Invocation contradictions in the audit, brainstorming, and spec-creation cards are resolved; the blanket "each step must be dispatched to a sub-agent unless marked inline" clause is rewritten in every card carrying it. | behavioral | tests-v2 behavioral probe (skill dispatch routes per closed-set row) with the closed-set grep gate as scenario precondition; validator rejects old values (`inline`, `sub-task`, `blind sub-task`) after migration | `.opencode/skills/*/SKILL.md` (TDT sections), `.opencode/reference/skill-card-description-standards.md` |
| SC-7 | The canonical plan format defines a per-step dispatch mode (`direct` or `task-card`, default `direct`); the writing-plans producer templates emit it; a plan-format check verifies every plan step carries an explicit mode. | behavioral | tests-v2 behavioral probe: a plan produced by the updated writing-plans flow is executed per its per-step modes; validator output inspected in-scenario | `.opencode/skills/writing-plans/SKILL.md` + producer task templates, plan-format section |
| SC-8 | A single canonical dispatch-vocabulary table exists in the reference layer; every directive-layer file (system prompt, `022`, `000-critical-rules`, both standards reference cards) references it via Read-link instead of restating definitions; the system prompt carries no duplicated or contradictory dispatch definitions. | behavioral | tests-v2 behavioral probe: skill-trigger and plan-trigger probes both route per the canonical table; directive files inspected in-scenario for Read-link presence and absent duplicate definitions | `.opencode/reference/skill-card-description-standards.md`, `.opencode/prompts/default.txt`, `.opencode/guidelines/022-orchestrator-context-discipline.md` |

## 4. Requirements

R-1. The system prompt SHALL instruct the orchestrator to execute skill workflow steps directly in its own context, dispatching a task card via `task()` only where the workflow marks dispatch.

R-2. The directive layer (`022-orchestrator-context-discipline.md`, `000-critical-rules.md`) SHALL prohibit whole-card and whole-plan forwarding as the halt-triggering violation, and SHALL NOT prohibit sanctioned direct execution of workflow steps by the orchestrator.

R-3. The `executing-plans` skill SHALL define plan execution as: the orchestrator reads the plan file directly, executes steps step-by-step in its own context, and dispatches a step's task card via `task()` only where that step marks dispatch.

R-4. The deck SHALL contain no `task()` dispatch string whose target is a SKILL.md path (whole-card forwarding invitation), and all SKILL.md files SHALL retain their pre-flight guard.

R-5. A plan pre-flight guard SHALL reject a whole plan body arriving at a leaf sub-agent with `ORCHESTRATOR_ONLY_PLAN`, and its definition SHALL live in the canonical standards docs.

R-6. TDT Dispatch column values SHALL use the closed vocabulary {`orchestrator`, `task-card`, `task-card blind`}; the ambiguous terms `inline`, `sub-task`, and `blind sub-task` SHALL be retired from TDTs, and TDT rows SHALL agree with their card's Invocation section.

R-7. The canonical plan format SHALL carry a per-step dispatch mode (`direct` or `task-card`, default `direct`), and the plan-format check SHALL verify every step carries an explicit mode.

R-8. The dispatch vocabulary SHALL be single-sourced in one canonical reference table, referenced via Read-link by every directive-layer file, with no duplicated or contradictory definitions in the system prompt.

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
- GREEN: Migrate TDT Dispatch values to {`orchestrator`, `task-card`, `task-card blind`} across the deck; resolve audit/brainstorming/spec-creation TDT-vs-Invocation contradictions; rewrite the blanket clause in all carrying cards.
- verify: Validator passes; behavioral probe routes per closed-set rows.
- commit: deck-wide TDT edits + validator rule.

### Item 7 (SC-7): Add per-step dispatch mode to plan format

- RED: Plan-format check on a produced plan fails (no explicit per-step modes).
- GREEN: Extend the canonical plan format in writing-plans producer templates with the dispatch-mode field (default `direct`); add the format check.
- verify: Produced plan carries per-step modes; behavioral probe executes per modes.
- commit: writing-plans templates + format check.

### Item 8 (SC-8): Single-source the dispatch vocabulary

- RED: Directive-layer files inspected; duplicate/contradictory definitions found, no canonical table (expected FAIL).
- GREEN: Write the canonical vocabulary table into the reference layer; convert directive-layer restatements to Read-links; strip duplicated definitions from the system prompt.
- verify: Behavioral probes (skill + plan triggers) route per the canonical table; directive files show Read-link references and no duplicates.
- commit: reference card + directive-layer Read-link edits.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Open spec #1208 / plan #1210 (`.opencode/.issues/`) | Overlapping TDT-format work; this spec supersedes their dispatch-semantics vocabulary; coordination comment recorded before implementation begins | pending |
| tests-v2 behavioral harness (`.opencode/tests-v2/with-test-home`, scenario framework) | All SC verification runs through it; existing dispatch-behavior scenarios updated with each GREEN | satisfied |
| Local model availability (qwen3.8:27b-256k-gguf4, verified working) | Behavioral evidence requires real-model `opencode run` cycles; timeout discipline per tests-v2/AGENTS.md (≥600s) | satisfied |
| skildeck validators (`.opencode/tools/skildeck`) | New validator rules (closed-set TDT vocabulary, whole-card grep gate, plan-step modes) land additively | satisfied |
| Skill card pre-flight guards (all 51 SKILL.md) | Retained verbatim; the card-side backstop is unchanged | satisfied |

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

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| System prompt routing language | config | `.opencode/prompts/default.txt` (Sub-Agent Routing Boundary, Pre-Response Gate) | grep read this session: Architecture-A prose at "The orchestrator routes. It does not do." + Architecture-B procedure at Pre-Response Gate step 2.5 |
| Orchestrator context discipline guideline | guideline | `.opencode/guidelines/022-orchestrator-context-discipline.md` | grep read this session: "pure router", "Orchestrator inline work detected → HALT" rows confirmed |
| Critical rules whole-card prohibition | guideline | `.opencode/guidelines/000-critical-rules.md` (critical-rules-XXX sections) | read this session (Tier 1 instruction load): whole-card dispatch prohibition + pre-flight guard backstop present |
| Executing-plans routing | skill card | `.opencode/skills/executing-plans/SKILL.md` | grep read this session: read-plan/dispatch-phase route to sub-agents; blanket clause present |
| Card contradictions | skill cards | `.opencode/skills/audit/SKILL.md`, `brainstorming/SKILL.md`, `spec-creation/SKILL.md` | grep read this session: TDT rows marked `inline` vs Invocation `task()` routing confirmed |
| Blanket clause prevalence | deck survey | `.opencode/skills/*/SKILL.md` | grep count this session: 44 files carry "unless explicitly marked as inline" |
| Plan pre-flight guard absence | deck survey | `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/prompts/` | grep count this session: 0 occurrences of `ORCHESTRATOR_ONLY_PLAN` |
| Third dispatch vocabulary | open plan | `.issues/1214/plan.md` (dispatch-type gate rows) | grep read this session: "orchestrator routes to general"/"orchestrator inline" vocabulary confirmed |
| Preliminary analysis artifacts | analysis | `tmp/dispatch-remediation/artifacts/preliminary/` (blast-radius, concern-map, code-paths, cross-cutting, interface-compat, state-analysis, testability) | read this session (7 artifacts + handoff.yaml) |

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
- SC-8: Reading the canonical table and running both trigger probes costs minutes. Skipping means the vocabulary re-fragments at the next session that edits a directive file — the dedup is the only item that keeps the other seven from regressing.

## 11. Edge Cases

- **Condition:** A directive-layer edit is behaviorally correct but a behavioral test cannot execute (model unavailable, harness failure). **Expected behavior:** the SC verdict is FAIL — structural or string substitutes are EVIDENCE_TYPE_MISMATCH; remediation-first protocol applies. **Resolution:** retry with the verified model; escalate only after exhaustive remediation.
- **Condition:** An existing in-flight plan (#1210) uses the retired third vocabulary. **Expected behavior:** the plan remains readable (old vocabulary is not erroring for old plans); new plans carry explicit closed-set modes; a coordination comment on #1210 records supersession of its dispatch-semantics rows. **Resolution:** no rewrite of the in-flight plan body is required for its validity — only new plans must conform.
- **Condition:** A skill card legitimately needs orchestrator-only steps mixed with dispatched steps. **Expected behavior:** the TDT row marked `orchestrator` expresses it; the Invocation section agrees; the closed set has a value for exactly this case. **Resolution:** contradiction resolution is per-card, verified by the TDT-vs-Invocation consistency check inside the Item 6 validator.
- **Condition:** A sub-agent receives a step-scoped prompt (not a whole plan) that references the plan. **Expected behavior:** no guard fires — step-scoped prompts and task cards are the sanctioned carriers; only a whole plan body trips `ORCHESTRATOR_ONLY_PLAN`. **Resolution:** the guard definition in the standards docs specifies the trip condition (plan document body in the dispatch prompt).
- **Condition:** The 51-card pre-flight guard retention check and the whole-card grep gate disagree (guard present, but a `task()` string still targets a SKILL.md path). **Expected behavior:** the SC fails on the grep gate — guard presence alone is insufficient; both checks must pass. **Resolution:** the Item 4 validator requires both conditions.
- **Condition:** Concurrent edits to the same deck files by open specs #1208/#1210 and this remediation. **Expected behavior:** sequencing is decided at coordination time (recorded in the #1210 comment before implementation); no silent merge of dispatch semantics. **Resolution:** this spec's vocabulary supersedes; the other issue re-bases its format work onto the closed set.
- **State boundary:** the `.opencode` submodule pointer must ride alongside the next real parent-repo change; pointer-only pushes are blocked by pre-push hooks. **Expected behavior:** all spec implementation commits land in the submodule; pointer updates follow parent-repo discipline. **Resolution:** no migration needed (state analysis artifact confirms no DB/session schema impact).
- **Recovery:** if a behavioral GREEN regresses a previously passing SC (e.g., Item 6 vocabulary edits break Item 1 probe assertions), the affected earlier SC re-runs before the pipeline advances; the enforcement gate is all-or-nothing.