# [SPEC] Remediate Orchestrator Dispatch Discipline

> **Full spec and artifacts: [`.opencode/.issues/2433/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2433/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2433/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | Two incompatible orchestrator architectures coexist in the `.opencode` directive layer: Architecture A ("orchestrator is a pure router — it never executes task steps inline") and Architecture B ("orchestrator loads the skill card, executes workflow steps directly, and dispatches task cards via `task()` only where the workflow marks it"). A model reading all directives averages them: it dispatches MORE, including whole cards and whole plans — the exact forwarding the target model prohibits. The observed malfunction (whole SKILL.md and whole plans forwarded to leaf sub-agents that cannot call `task()`) is this averaging made visible. |
| 2 | **Root Cause / Motivation** | The directive layer was written across sessions under two different mental models and never reconciled. `prompts/default.txt` carries BOTH architectures verbatim; `022-orchestrator-context-discipline.md` is written entirely in the pure-router model (A) and arms a HALT-on-inline enforcement machine that would fire on the target model's legitimate direct execution; 3 skill cards mark TDT rows `inline` while their Invocation sections route the same tasks to `task()`; 45 cards carry a blanket "each step dispatched to a sub-agent unless marked inline" clause (measured: 45 files carry the clause head; 44 carry the verbatim single-line tail — `executing-plans` carries the wrapped-tail variant) readable as "dispatch everything"; `executing-plans` routes even read-plan to a sub-agent so no directive anywhere says the orchestrator executes plan steps directly; plans have no pre-flight guard (cards have `ORCHESTRATOR_ONLY_SKILL_CARD`, plans have nothing); and plan #1210 introduced a third dispatch vocabulary ("orchestrator routes to general (blind)"). |
| 3 | **Approach Chosen** | Adopt Architecture B as the single architecture and re-point every layer at it: rewrite the system prompt routing-boundary language, rewrite `022` (re-pointing the HALT machinery from inline-work to whole-card/whole-plan forwarding), retain the `000-critical-rules` whole-card prohibition, rewrite `executing-plans` so the orchestrator reads the plan and executes steps directly, normalize TDT vocabulary to a closed set (`orchestrator`, `task-card`, `task-card blind`), add a plan pre-flight guard (`ORCHESTRATOR_ONLY_PLAN`), add a per-step dispatch-mode field to the canonical plan format, and single-source the vocabulary in one canonical reference table. Related open tickets carrying conflicting dispatch semantics are superseded by this spec — see §12. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Keep Architecture A (pure router) and fix only the contradictions — discarded: the whole-card prohibition in `000-critical-rules` and the pre-flight guard in all 51 cards already encode B; the guard converts forwarding into a stall rather than a correction, so A is already unenforceable without contradicting Tier 1 text. (b) Add a third-layer mediation doc explaining when each architecture applies — discarded: adding prose on top of contradictory prose deepens the averaging problem; the deck needs fewer vocabularies, not more. (c) Fix only the three contradictory cards and leave the 45 blanket-clause cards — discarded: the averaging problem is deck-wide; partial migration leaves most whole-card forwarding invitations intact and re-fragments the vocabulary at the next card edit. |
| 5 | **Key Design Decisions** | (a) The word "inline" is RETIRED from the dispatch vocabulary — it currently means both "orchestrator does directly" (pejorative, in `022`) and "a sanctioned execution mode" (TDT rows); the closed set uses `orchestrator` for sanctioned direct execution. Tradeoff: all 45 blanket-clause cards and 3 contradictory cards need bulk edits. (b) HALT-on-inline machinery is re-pointed, not deleted — the halt behavior is preserved but its trigger condition becomes whole-card/whole-plan forwarding. Tradeoff: any behavioral test asserting the old trigger must be updated in the same GREEN. (c) `task()` dispatch strings are the ONLY sanctioned routing surface — a `task()` string whose target is a SKILL.md path is a whole-card forwarding invitation and is prohibited (SC-4). Tradeoff: card authors lose the ability to delegate "just read this card" — they must route through task cards. (d) Plan steps default to `direct` (orchestrator executes in own context); sub-agent dispatch is opt-in per step. Tradeoff: existing plans without explicit modes remain readable, new plans must carry explicit modes. (e) Related open tickets carrying conflicting dispatch semantics are superseded by this spec rather than remediated in parallel — where a superseded design contradicts Architecture B, the closed TDT vocabulary, or the `direct|task-card` plan-step schema, this spec's design wins (§12). |
| 6 | **User Intent / Original Prompt** | Original developer prompt (essence): the observed malfunction is an agent incorrectly dispatching skill cards (not task cards) and whole plans to sub-agents; the target pattern is skill cards' workflows executed directly by the orchestrator with `task()` only at the marked points, and plans loaded and executed step-by-step by the orchestrator; the correction is holistic across `.opencode/` — reconcile conflicting and missing dispatch directives rather than patching a single file. Triggered via the brainstorming → spec-creation handoff (`handoff.yaml`, 3 exploration turns, 7 preliminary artifacts). |

## 2. Not Included

- **Scope is directive text only: guidelines, prompts, AGENTS.md, skill cards, task cards, reference standards markdown, and plan/spec documents.** Nothing more. No code files of any kind; every deliverable is a text artifact.
- **Behavioral test execution must be targeted: one run per SC-RED and SC-GREEN need; no whole-suite invocation mechanism.** There must be NO way for an agent to run all opencode behavioral tests in a single script or invocation — every `opencode run` targets exactly the scenario(s) the current SC's RED test and GREEN test need (R-25/R-26, SC-9).
- **Content changes to other issues' bodies** — superseded tickets are recorded in §12; this spec does not edit other issues' bodies.
- **Sub-agent result contract envelope changes** — `{status, finding_summary, artifact_path, blocker_reason}` stays as-is.
- **`.opencode/AGENTS.md` non-dispatch content** — only its dispatch directives (the "Universal Skill Dispatch Gate" section header and any dispatch-directive prose using the retired vocabulary) change, under R-8/SC-8 coverage; all other AGENTS.md content is out of scope. This bullet documents that AGENTS.md dispatch-directive edits ARE in scope via R-8/SC-8 (blast-radius lists the file as directly affected; the coverage decision lives here and in SC-8 rather than in a dedicated SC).
- **Tickets verified to have no dispatch concern:** 698, 699, 700, 701, 702, 703, 704, 705, 872, 1013, 1189, 1212 — none of these carries a dispatch-table or routing concern; their scopes remain with their own issues.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The system prompt (`prompts/default.txt`) Sub-Agent Routing Boundary and Pre-Response Gate state Architecture B: the orchestrator executes skill workflow steps directly in its own context and dispatches a task card via `task()` only where the workflow marks dispatch; the prose "The orchestrator routes. It does not do." and the "hand off to executing-plans via sub-agent" forwarding language are absent. | behavioral | Behavioral probe via sub-agents dispatched from the working session (no isolated environment, no project writes): skill-trigger prompt; probe asserts orchestrator executing workflow steps itself (own-context file reads) and no SKILL.md content inside any `task()` prompt; direct reading of `prompts/default.txt` | `.opencode/prompts/default.txt` (Sub-Agent Routing Boundary, Pre-Response Gate sections) |
| SC-2 | `022-orchestrator-context-discipline.md` no longer defines the orchestrator as a pure router and no longer HALTs on orchestrator inline work; its halt machinery fires on whole-card/whole-plan forwarding instead; `000-critical-rules.md` retains the whole-card dispatch prohibition (critical-rules-XXX) and its Infrastructure-Failure Carve-out and routing-bypass classifications reference forwarding-based violations. | behavioral | Behavioral probe via sub-agents dispatched from the working session: orchestrator performing sanctioned direct workflow execution is not halted; orchestrator forwarding a whole card is halted; direct reading of both guideline files | `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/guidelines/000-critical-rules.md` (whole-card prohibition, Infrastructure-Failure Carve-out sections) |
| SC-3 | `executing-plans` routes plan execution to the orchestrator: it reads the plan file directly, executes steps step-by-step in its own context, and dispatches a step's task card via `task()` only where that step marks dispatch; the read-plan/dispatch-phase routing that sends the whole plan or whole workflow to a sub-agent is absent. | behavioral | Behavioral probe via sub-agents dispatched from the working session: approved-plan prompt; probe asserts plan steps executed with orchestrator-own tool calls and `task()` only at step-marked points; no whole-plan body inside any `task()` prompt; direct reading of the skill files | `.opencode/skills/executing-plans/SKILL.md`, `tasks/read-plan.md`, `tasks/dispatch-phase.md` |
| SC-4 | No SKILL.md in the deck contains a `task()` dispatch string whose target is a SKILL.md path or that forwards card content; all 51 SKILL.md retain the `ORCHESTRATOR_ONLY_SKILL_CARD` pre-flight guard. | behavioral | Behavioral probe via sub-agents dispatched from the working session: skill-trigger probe asserting no card content in `task()` prompt; direct reading of every SKILL.md Invocation/Dispatch section and guard line | `.opencode/skills/*/SKILL.md` (Invocation/Dispatch sections), `.opencode/reference/skill-card-schema.md` |
| SC-5 | A plan pre-flight guard exists: a leaf sub-agent receiving a whole plan body rejects with `ORCHESTRATOR_ONLY_PLAN` and halts, analogous to the card guard; the guard definition is written into the canonical standards docs. | behavioral | Behavioral negative probe via sub-agents dispatched from the working session: dispatch a sub-agent with a whole plan body; assert `BLOCKED` with reason `ORCHESTRATOR_ONLY_PLAN`; direct reading of the standards doc carrying the guard definition | `.opencode/reference/task-card-structure-standards.md` |
| SC-6 | TDT Dispatch column values across all SKILL.md use only the closed set {`orchestrator`, `task-card`, `task-card blind`}; the TDT/Invocation contradictions in the audit, brainstorming, and spec-creation cards are resolved; the blanket "each step must be dispatched to a sub-agent unless marked inline" clause is rewritten in every card carrying it (45 files measured). | behavioral | Behavioral probe via sub-agents dispatched from the working session: skill dispatch routes per closed-set row; direct reading of every SKILL.md TDT and Invocation section confirming closed-set values and TDT-vs-Invocation agreement | `.opencode/skills/*/SKILL.md` (TDT sections), `.opencode/reference/skill-card-description-standards.md` |
| SC-7 | The canonical plan format defines a per-step dispatch mode (`direct` or `task-card`, default `direct`); the writing-plans producer templates emit it; every step of a produced plan carries an explicit mode. | behavioral | Behavioral probe via sub-agents dispatched from the working session: a plan produced by the updated writing-plans flow is executed per its per-step modes; direct reading of the produced plan and the producer templates confirming explicit per-step modes | `.opencode/skills/writing-plans/SKILL.md` + producer task templates, plan-format section |
| SC-8 | A single canonical dispatch-vocabulary table exists in the reference layer; every directive-layer file (system prompt, `022`, `000-critical-rules`, both standards reference cards, and `.opencode/AGENTS.md`'s Universal Skill Dispatch Gate section) references it via Read-link instead of restating definitions; `.opencode/AGENTS.md`'s dispatch directives use the canonical table (retired-vocabulary header prose is rewritten); the system prompt carries no duplicated or contradictory dispatch definitions. | behavioral | Behavioral probes via sub-agents dispatched from the working session: skill-trigger and plan-trigger probes both route per the canonical table; direct reading of the directive files (including `.opencode/AGENTS.md`) confirming Read-link presence and absent duplicate definitions | `.opencode/reference/skill-card-description-standards.md`, `.opencode/prompts/default.txt`, `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/AGENTS.md` (Universal Skill Dispatch Gate section) |
| SC-9 | Behavioral test execution is targeted: an agent instructed to "run the behavioral tests" derives the named scenarios needed for the current SC's RED or GREEN evidence and runs only those — it does NOT enumerate and run all behavioral scenario scripts (`tests-v2/behaviors/*.sh`, 197 model-executing scripts) in one invocation, does NOT loop over all scenarios, and does NOT issue unfiltered model-executing sweeps; the harness docs state the mandate and the guard text is present. | behavioral | Behavioral test: an agent asked to "run the behavioral tests" attempts a whole-suite invocation and is BLOCKED/prohibited by the directive + harness guard (assert no model-executing whole-suite invocation occurs); plus structural read-back of the guard text in `tests-v2/AGENTS.md` | `.opencode/tests-v2/AGENTS.md`, `.opencode/tests-v2/behaviors/` (197 scenario scripts) |

**SC granularity note:** The active SC set is the core dispatch-correction set SC-1..SC-9. SC-2, SC-4, and SC-6 are borderline compound (they each touch multiple files) but each enforces a single routing concern (halt-machinery re-pointing, whole-card prohibition, closed-set vocabulary) and stays whole. SC-9 governs test-execution discipline (targeted model-run scoping) and is orthogonal to the routing concern set — it stays whole as a single prohibition.

## 4. Requirements

R-1. The system prompt SHALL instruct the orchestrator to execute skill workflow steps directly in its own context, dispatching a task card via `task()` only where the workflow marks dispatch.

R-2. The directive layer (`022-orchestrator-context-discipline.md`, `000-critical-rules.md`) SHALL prohibit whole-card and whole-plan forwarding as the halt-triggering violation, and SHALL NOT prohibit sanctioned direct execution of workflow steps by the orchestrator.

R-3. The `executing-plans` skill SHALL define plan execution as: the orchestrator reads the plan file directly, executes steps step-by-step in its own context, and dispatches a step's task card via `task()` only where that step marks dispatch.

R-4. The deck SHALL contain no `task()` dispatch string whose target is a SKILL.md path (whole-card forwarding invitation), and all SKILL.md files SHALL retain their pre-flight guard.

R-5. A plan pre-flight guard SHALL reject a whole plan body arriving at a leaf sub-agent with `ORCHESTRATOR_ONLY_PLAN`, and its definition SHALL live in the canonical standards docs.

R-6. TDT Dispatch column values SHALL use the closed vocabulary {`orchestrator`, `task-card`, `task-card blind`}; the ambiguous terms `inline`, `sub-task`, and `blind sub-task` SHALL be retired from TDTs, and TDT rows SHALL agree with their card's Invocation section.

R-7. The canonical plan format SHALL carry a per-step dispatch mode (`direct` or `task-card`, default `direct`), and the writing-plans producer templates SHALL emit it so every produced plan step carries an explicit mode.

R-8. The dispatch vocabulary SHALL be single-sourced in one canonical reference table, referenced via Read-link by every directive-layer file — including `.opencode/AGENTS.md`'s dispatch directives — with no duplicated or contradictory definitions in the system prompt.

R-25. Agents MUST NOT enumerate and run all behavioral scenario scripts in one invocation. Each `opencode run` MUST target exactly the scenario(s) needed for the current item's RED or GREEN evidence.

R-26. The test framework documentation (`tests-v2/AGENTS.md`) and harness MUST state the targeted-run mandate: whole-suite runs (glob over `behaviors/*.sh`, unfiltered `test-enforcement.sh` sweeps that execute model runs, or any loop over all scenarios) are PROHIBITED; the checklist's per-SC re-run instruction MUST be explicit that it means the named scenarios for the current branch's SCs only.

## 5. Items

### Item 1 (SC-1): Rewrite system prompt dispatch directives

- RED: Behavioral probe prompts a skill trigger; probe currently shows whole-card forwarding or router-model dispatch (expected FAIL before change).
- GREEN: Rewrite `prompts/default.txt` Sub-Agent Routing Boundary and Pre-Response Gate to Architecture B; remove Architecture-A forwarding prose.
- verify: Run the probe; assert orchestrator executes workflow steps in own context, `task()` only at marked points, no card content in prompts.
- commit: `prompts/default.txt` + probe in one commit.

### Item 2 (SC-2): Re-point directive-layer HALT machinery

- RED: Behavioral probe asserting `022` still HALTs on sanctioned direct execution (expected FAIL — the old rule fires).
- GREEN: Rewrite `022` (pure-router framing, inline-work HALT rows) to forwarding-based triggers; align `000-critical-rules` carve-out and routing-bypass classifications; retain the whole-card prohibition.
- verify: Behavioral probes — direct execution not halted, whole-card forwarding halted.
- commit: `guidelines/022-*.md` + `guidelines/000-critical-rules.md` + probe.

### Item 3 (SC-3): Rewrite executing-plans plan-execution architecture

- RED: Behavioral probe with an approved plan; probe currently shows whole-plan/workflow dispatch to a sub-agent (expected FAIL before change).
- GREEN: Rewrite `executing-plans/SKILL.md`, `tasks/read-plan.md`, `tasks/dispatch-phase.md`: orchestrator reads the plan and executes steps directly; step-scoped `task()` dispatch only where the plan marks it.
- verify: Probe asserts orchestrator-own plan-step execution with marked-point dispatch only.
- commit: executing-plans skill files + probe.

### Item 4 (SC-4): Eliminate whole-card forwarding across the deck

- RED: Behavioral probe shows card content inside `task()` prompts (expected FAIL).
- GREEN: Fix offending dispatch strings across affected cards; verify guard retention in all 51 cards by direct reading.
- verify: Behavioral probe asserts no card content in prompts; direct reading of all SKILL.md dispatch strings finds no SKILL.md-path targets.
- commit: deck edits + probe.

### Item 5 (SC-5): Add plan pre-flight guard

- RED: Negative behavioral probe: sub-agent receiving a whole plan body does not reject (expected FAIL).
- GREEN: Define `ORCHESTRATOR_ONLY_PLAN` guard in `task-card-structure-standards.md`; state the guard semantics in the sub-agent entry pattern (task-card directive text).
- verify: Negative probe asserts `BLOCKED` with reason `ORCHESTRATOR_ONLY_PLAN`.
- commit: standards docs + probe.

### Item 6 (SC-6): Normalize TDT vocabulary to the closed set

- RED: Direct reading of all TDTs finds old values present and 3 contradictory cards (expected FAIL).
- GREEN: Migrate TDT Dispatch values to {`orchestrator`, `task-card`, `task-card blind`} across the deck; resolve audit/brainstorming/spec-creation TDT-vs-Invocation contradictions; rewrite the blanket clause in all 45 carrying cards.
- verify: Behavioral probe routes per closed-set rows; direct reading confirms closed-set values and TDT-vs-Invocation agreement.
- commit: deck-wide TDT edits + probe.

### Item 7 (SC-7): Add per-step dispatch mode to plan format

- RED: Direct reading of a produced plan finds no explicit per-step modes (expected FAIL).
- GREEN: Extend the canonical plan format in writing-plans producer templates with the dispatch-mode field (default `direct`).
- verify: Produced plan carries per-step modes (direct reading); behavioral probe executes per modes.
- commit: writing-plans templates + probe.

### Item 8 (SC-8): Single-source the dispatch vocabulary

- RED: Directive-layer files read directly; duplicate/contradictory definitions found, no canonical table (expected FAIL).
- GREEN: Write the canonical vocabulary table into the reference layer; convert directive-layer restatements to Read-links; rewrite `.opencode/AGENTS.md`'s dispatch directives (Universal Skill Dispatch Gate section) onto the canonical table; strip duplicated definitions from the system prompt.
- verify: Behavioral probes (skill + plan triggers) route per the canonical table; direct reading of directive files including AGENTS.md shows Read-link references and no duplicates.
- commit: reference card + directive-layer Read-link edits (including AGENTS.md).

### Item 9 (SC-9): Enforce targeted behavioral-test execution

- RED: Behavioral test prompts an agent to "run the behavioral tests"; probe currently shows (or permits) a whole-suite invocation — a loop/glob over `behaviors/*.sh` or an unfiltered model-executing sweep (expected FAIL before change).
- GREEN: State the targeted-run mandate in `tests-v2/AGENTS.md` and the harness guard: whole-suite runs, directory-enumeration runs, and unfiltered model-executing sweeps are PROHIBITED; the per-SC re-run instruction names only the current branch's SC scenarios; add the harness guard text scoping the prohibition to model-executing invocations (content-verification runners excluded).
- verify: Behavioral test — the agent's whole-suite attempt is BLOCKED/prohibited by the directive + harness guard (assert no model-executing whole-suite invocation occurs); structural read-back of the guard text in `tests-v2/AGENTS.md`.
- commit: `tests-v2/AGENTS.md` + guard text + behavioral test in one commit.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Behavioral probes executed by sub-agents dispatched from the working session (no isolated environment, no project writes) | All SC verification runs through them | satisfied |
| Verified local model availability (qwen3.8:27b-256k-gguf4) | Behavioral probes require real-model execution | satisfied |
| Skill card pre-flight guards (all 51 SKILL.md) | Retained verbatim; the card-side backstop is unchanged | satisfied |
| Superseded tickets (§12) | Their conflicting SCs are superseded by this spec's dispatch-correction SCs (SC-1..SC-8) | recorded |
| tests-v2 harness surface (`tests-v2/AGENTS.md`, `behaviors/` scenario scripts, `test-enforcement.sh`) | SC-9's targeted-run mandate and guard live in the harness docs; the prohibition scopes to model-executing invocations | verified this session (197 scenario scripts; `test-enforcement.sh` is content-verification — no model runs) |

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
| R-25 | SC-9 | Item 9 |
| R-26 | SC-9 | Item 9 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| System prompt routing language | config | `.opencode/prompts/default.txt` (Sub-Agent Routing Boundary, Pre-Response Gate) | read this session: Architecture-A prose at "The orchestrator routes. It does not do." (line 45) + Architecture-B procedure at Pre-Response Gate step 2.5 |
| Orchestrator context discipline guideline | guideline | `.opencode/guidelines/022-orchestrator-context-discipline.md` | read this session: "pure router", "Orchestrator inline work detected → HALT" rows confirmed |
| Critical rules whole-card prohibition | guideline | `.opencode/guidelines/000-critical-rules.md` (critical-rules-XXX sections) | read this session (Tier 1 instruction load): whole-card dispatch prohibition + pre-flight guard backstop present |
| Executing-plans routing | skill card | `.opencode/skills/executing-plans/SKILL.md` | read this session: read-plan/dispatch-phase route to sub-agents; blanket clause present (wrapped-tail variant) |
| Card contradictions | skill cards | `.opencode/skills/audit/SKILL.md`, `brainstorming/SKILL.md`, `spec-creation/SKILL.md` | read this session: TDT rows marked `inline` vs Invocation `task()` routing confirmed |
| Blanket clause prevalence | deck survey | `.opencode/skills/*/SKILL.md` | measured this session (per-file count, clause head "must be dispatched to a sub-agent via `task()`"): 45 files carry the blanket clause, one occurrence each; of these, 44 carry the verbatim single-line tail "unless explicitly marked as inline" and the 45th (`executing-plans/SKILL.md`) wraps the tail onto the following line as "explicitly marked as inline/orchestrator" |
| AGENTS.md dispatch directives | guideline | `.opencode/AGENTS.md` (Universal Skill Dispatch Gate section) | read this session: line 21 header "Professional agents dispatch skills. Amateurs inline." uses the retired "inline" pejorative vocabulary; blast-radius artifact lists the file as directly affected |
| Plan pre-flight guard absence | deck survey | `.opencode/skills/`, `.opencode/guidelines/`, `.opencode/prompts/` | count this session: 0 occurrences of `ORCHESTRATOR_ONLY_PLAN` |
| Third dispatch vocabulary | open plan | `.opencode/.issues/open/1210-spec-workstream-b-trigger-dispatch-tables-all-39-skillmd-files/plan.md` (gate table rows) | read this session: "orchestrator routes to general"/"orchestrator inline" vocabulary confirmed; path verified to exist this session |
| Third dispatch vocabulary (orphan plan artifact) | plan | `.opencode/.issues/1214/plan.md` (16-gate dispatch table rows) | read this session: same third dispatch vocabulary confirmed; orphan directory — no issue.yaml on the local tree, plan artifact only |
| Preliminary analysis artifacts | analysis | `.opencode/.issues/2433/artifacts/` (canonical copy: blast-radius, concern-map, code-paths, cross-cutting, interface-compat, state-analysis, testability + handoff.yaml) | read this session (8 files); blast-radius attribution corrected this revision (quoted sentence lives at `prompts/default.txt:198`, not AGENTS.md) |
| Superseded ticket set (§12) | issue records | local `.opencode/.issues/{706,909,912,936,954,955,1019,1198,1208,1209,1210,1211,1213,1222}` directories | verified this session: directories present; #1214 orphan directory (plan artifact only, no issue.yaml) also present |
| Behavioral test harness surface | test framework | `.opencode/tests-v2/AGENTS.md`, `.opencode/tests-v2/behaviors/*.sh`, `.opencode/tests-v2/test-enforcement.sh` | verified this session: 197 scenario scripts in `behaviors/`; `test-enforcement.sh` is content-verification (no model runs — scenario tags confirm); 0 occurrences of any targeted-run / whole-suite-prohibition guard in `tests-v2/AGENTS.md` |

## 9. Enforcement Gate

> **Enforcement gate:** All 9 success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the skill-trigger behavioral probe costs minutes of model execution time — the defect (whole-card forwarding) is caught at the earliest gate and the fix costs one bounded re-run. Skipping means the averaging defect ships in the system prompt loaded into every future session, and every skill invocation thereafter inherits it — the death spiral starts at the highest-leverage file in the deck.
- SC-2: Running the direct-execution and forwarding probes costs minutes. Skipping means the HALT machinery keeps firing on correct behavior and never fires on the defect — the orchestrator learns that following the rules is punished, which trains the averaging behavior this spec exists to remove.
- SC-3: Running the approved-plan probe costs minutes. Skipping means plans continue to be wholesale-forwarded to leaf sub-agents that stall, fabricate completion, or return partial work as complete — the defect surfaces as silent pipeline corruption discovered days later in review.
- SC-4: Running the dispatch-string behavioral probe costs minutes. Skipping means whole-card forwarding invitations persist across the deck, and the guard converts each affected skill invocation into a stall-retry loop instead of a correction — every affected invocation pays the cost.
- SC-5: Running the negative probe (whole plan to a sub-agent) costs minutes. Skipping means plans remain the only unguarded artifact class — the one path where forwarding produces silent malfunction instead of a BLOCKED contract.
- SC-6: Reading the migrated TDTs and running the routing probe costs minutes. Skipping means three vocabularies persist and every new card flips a coin between them — each new card added under the old vocabulary extends the migration debt.
- SC-7: Producing a plan with per-step modes and running the probe costs minutes. Skipping means the plan layer stays prose-ambiguous and Item 3's behavioral fix degrades back to wholesale forwarding on the next hand-written plan.
- SC-8: Reading the canonical table and running both trigger probes costs minutes. Skipping means the vocabulary re-fragments at the next session that edits a directive file — the dedup is the only item that keeps the other seven from regressing.
- SC-9: Running the targeted-run behavioral test costs minutes. Skipping means an agent facing "run the behavioral tests" can enumerate `behaviors/*.sh` (197 model-executing scripts) and launch a >2000-run runaway — observed this session during branch-finishing, where the runaway burned hours of model execution and masked per-SC evidence. Every unguarded "run the tests" instruction is a latent multi-hour runaway; the targeted-run mandate converts each into one bounded named-scenario run.

## 11. Edge Cases

- **Condition:** A directive-layer edit is behaviorally correct but a behavioral probe cannot execute (model unavailable). **Expected behavior:** the SC verdict is FAIL — structural or string substitutes are EVIDENCE_TYPE_MISMATCH; remediation-first protocol applies. **Resolution:** retry with the verified model; escalate only after exhaustive remediation.
- **Condition:** An existing plan uses the retired third vocabulary. **Expected behavior:** the plan remains readable (old vocabulary is not erroring for old plans); new plans carry explicit closed-set modes. **Resolution:** no rewrite of the existing plan body is required for its validity — only new plans must conform.
- **Condition:** A skill card legitimately needs orchestrator-only steps mixed with dispatched steps. **Expected behavior:** the TDT row marked `orchestrator` expresses it; the Invocation section agrees; the closed set has a value for exactly this case. **Resolution:** contradiction resolution is per-card, verified by the TDT-vs-Invocation direct reading in Item 6.
- **Condition:** A sub-agent receives a step-scoped prompt (not a whole plan) that references the plan. **Expected behavior:** no guard fires — step-scoped prompts and task cards are the sanctioned carriers; only a whole plan body trips `ORCHESTRATOR_ONLY_PLAN`. **Resolution:** the guard definition in the standards docs specifies the trip condition (plan document body in the dispatch prompt).
- **Condition:** A card retains its pre-flight guard but a `task()` string still targets a SKILL.md path. **Expected behavior:** SC-4 fails on the dispatch-string condition — guard presence alone is insufficient; both conditions must pass. **Resolution:** Item 4 verification requires both the behavioral probe and the direct reading.
- **Condition:** A superseded ticket's design contradicts this spec's target architecture. **Expected behavior:** this spec's design wins — Architecture B, the closed TDT vocabulary {`orchestrator`, `task-card`, `task-card blind`}, and the `direct|task-card` plan-step schema are authoritative; the conflict is recorded as superseded in §12. **Resolution:** no dual-vocabulary period — implementation follows only this spec's dispatch semantics.
- **Condition:** The blanket-clause rewrite (SC-6) and the wrapped-tail variant in `executing-plans/SKILL.md` (SC-3's file set) overlap on the same file. **Expected behavior:** both edits land on the same file without conflict — SC-3 rewrites the card's routing architecture and SC-6 rewrites its Task Discipline clause; the item ordering runs SC-3 before SC-6 so the clause rewrite lands on the already-corrected card. **Resolution:** the enforcement gate re-runs either SC if a later GREEN regresses an earlier one (Recovery edge case).
- **State boundary:** the `.opencode` submodule pointer must ride alongside the next real parent-repo change; pointer-only pushes are blocked. **Expected behavior:** all spec implementation commits land in the submodule; pointer updates follow parent-repo discipline. **Resolution:** no migration needed (state analysis artifact confirms no DB/session schema impact).
- **Recovery:** if a behavioral GREEN regresses a previously passing SC (e.g., Item 6 vocabulary edits break Item 1 probe assertions), the affected earlier SC re-runs before the pipeline advances; the enforcement gate is all-or-nothing.
- **Condition:** An agent receives a bare "run the behavioral tests" instruction with no SC context. **Expected behavior:** the correct behavior under SC-9 is to ask or derive which SCs need testing and run only the named scenarios for the current branch's SCs — never a whole-suite invocation. **Resolution:** the mandate in `tests-v2/AGENTS.md` states the derivation rule; the guard BLOCKS the enumeration path.
- **Condition:** CI or umbrella scripts (e.g., `test-enforcement.sh` without scope filters, content-verification runners) execute all scenarios. **Expected behavior:** exempt — the prohibition targets model-executing invocations only; `test-enforcement.sh` is a content-verification runner (no model runs), so an unfiltered run of it is not a model-cost runaway. **Resolution:** the harness guard text scopes the prohibition to model-executing invocations explicitly.

## 12. Superseded Issues

The tickets below are **superseded by #2433** — disposition category: `superseded by #2433`. Their conflicting SCs are superseded by #2433's dispatch-correction SCs (SC-1..SC-8) and test-execution discipline (SC-9). No ticket contents are described beyond this supersession statement.

| Issue | Disposition |
|-------|-------------|
| #909 | superseded by #2433 |
| #912 | superseded by #2433 |
| #936 | superseded by #2433 |
| #954 | superseded by #2433 |
| #955 | superseded by #2433 |
| #1019 | superseded by #2433 |
| #1198 | superseded by #2433 |
| #1208 | superseded by #2433 |
| #1209 | superseded by #2433 |
| #1210 | superseded by #2433 |
| #1211 | superseded by #2433 |
| #1213 | superseded by #2433 |
| #1222 | superseded by #2433 |
| #706 | superseded by #2433 |
| #1214 | superseded by #2433 — orphan directory (plan artifact only, no issue.yaml), carries the same third dispatch vocabulary |

Tickets verified to have no dispatch concern (not superseded): 698, 699, 700, 701, 702, 703, 704, 705, 872, 1013, 1189, 1212.

## 13. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-03 | Added §12 (Superseded and Absorbed Issues) with the related-ticket disposition mapping; added SC-9/SC-10/SC-11, R-9/R-10/R-11, and Items 9–11; updated Intent (field 3/4/5 additions), Not Included (excluded-ticket list, body-mutation clarification, contract envelope clarification), Dependencies, Traceability, Documentation Sources, Cost Frame, and Edge Cases | Developer directive — record dispositions for all related open tickets with direct or cross-cutting dispatch concerns; conflicts resolved via supersession (closing handled by separate orchestrator dispatch) | Developer (test) |
| 2026-09-03 | Validation-FAIL revision (first validate→revise iteration, Tier 1): added preamble field 6 (User Intent / Original Prompt); decomposed SC-9 → SC-9a/SC-9b/SC-9c, SC-10 → SC-10a/SC-10b/SC-10c, and SC-11 → SC-11a/SC-11b/SC-11c into per-concern atomic sub-SCs — each with its own R row, its own Item with RED/GREEN cycle, its own cost-frame row, and §7 traceability rows (SC set then 17; SC-1..SC-8 unchanged); fixed Documentation Sources citation path and replaced the unverified blanket-clause count with measured numbers (45 clause-carrying files, 44 verbatim single-line tails, counting pattern stated); extended R-8/SC-8 to cover `.opencode/AGENTS.md` dispatch directives; copied the 8 preliminary artifacts to the canonical `.opencode/.issues/2433/artifacts/`; updated sc-summary.yaml; regenerated the remote exec-summary issue body; no linked plan exists at `.opencode/.issues/2433/plan.md`, so plan regeneration is not applicable | spec-creation validate findings: F1 completeness (preamble field 6 missing), F2 compound-sc, F3 provenance (citation path + blanket-clause count mismatch); pipeline warnings: sc-summary drift, AGENTS.md blast-radius coverage, artifact placement (all addressed by the next row's revision) | Developer (test) — spec-creation validate→revise pipeline iteration |
| 2026-09-03 | Removed the decomposed sub-SCs (SC-9a/9b/9c, SC-10a/10b/10c, SC-11a/11b/11c) with their R rows, Items, cost-frame rows, and traceability mappings — active SC set is SC-1..SC-8. Rewrote §12 to a single disposition category (superseded by #2433) for all related tickets including #1214. Purged the spec body of every artifact-reference outside the directive-text surface — the spec reads as directive text only, with zero non-directive artifact paths. Replaced pattern-matching structural verification in all SCs and Items with behavioral probes via sub-agents dispatched from the working session (no isolated environment, no project writes) plus direct reading of text artifacts. Added scope statement (§2): directive text only. Fixed W1 (blast-radius artifact attribution: quoted sentence lives at `prompts/default.txt:198`, not AGENTS.md) and W2 (#1210 plan path added to §8; #1214 recorded as superseded in §12). Updated sc-summary.yaml (sc_count 8); regenerated the remote exec-summary issue body; no linked plan exists, so plan regeneration is not applicable | Developer directives (cumulative): (1) the directive-text surface is the only deliverable surface; (2) no SC or reference outside that surface, to prevent agent confusion; (3) references to later-phase work are erroneous; (4) tickets are properly superseded, not honored, and no pattern-matching structural checks may enforce the mandate — pattern-matching checks invite agent workarounds that turn the code into dead weight with extra ceremony, excessive token usage, agent confusion, malfunctions, and deliberation thought loops | Developer (test) |
| 2026-09-03 | Added the targeted behavioral-test execution mandate: new scope bullet in §2 (one run per SC-RED and SC-GREEN need; no whole-suite invocation mechanism); new SC-9 row in the SC table (evidence type behavioral per BEH-EV substrate — the change affects runtime behavior of agents invoking the harness; verification: behavioral test where an agent asked to "run the behavioral tests" attempts a whole-suite invocation and is BLOCKED/prohibited by the directive + harness guard, plus structural read-back of the guard text); new R-25/R-26 after R-8; new Item 9 (SC-9) with RED/GREEN/verify/commit; SC granularity note updated (SC-1..SC-9); Dependencies row for the tests-v2 harness surface; §8 Documentation Sources row (197 scenario scripts measured; `test-enforcement.sh` confirmed content-verification — no model runs); Enforcement Gate count 8 → 9; Cost Frame row for SC-9 (defect-discovery-latency frame — the >2000-run runaway observed during branch-finishing this session); two new §11 Edge Cases (bare "run the behavioral tests" instruction → derive/ask for named scenarios; CI/umbrella + content-verification runners exempt — prohibition scopes to model-executing invocations); §12 supersession sentence updated to include SC-9; traceability rows R-25/R-26 → SC-9 → Item 9. Updated sc-summary.yaml (sc_count 8 → 9, SC-9 with plan_item 9). Stale analytical artifacts deleted per revise procedure. A linked plan now exists at `.opencode/.issues/2433/plan.md` (8 phases, SC-1..SC-8) — it is stale relative to the revised 9-SC spec; plan regeneration follows as a separate orchestrated step per developer dispatch directive (change-control note recorded here; regeneration dispatched by the orchestrator). Remote exec-summary body regenerated (remote michael-conrad/.opencode#2433 — SC count and scope numbers match the revised spec exactly). Issues-data pushed via local-issues sync | Developer-directed revision reason: a mechanism existed whereby an agent could run ALL opencode behavioral tests in a single script/invocation (enumerating `behaviors/`, or unfiltered model-executing sweeps, or a loop over all scenario scripts), causing a >2000-run runaway during branch-finishing; developer mandate: NO way to run all opencode run tests in a single script or invocation — every opencode run is targeted, scoped solely to the current SC's RED and GREEN needs | Developer (test) |