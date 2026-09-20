---
issue: 2455
title: "[SPEC] Orchestrator-direct plan execution — task() only at plan-marked dispatch points"
labels: [SPEC]
created: 2026-09-18
---

# SPEC — Orchestrator-Direct Plan Execution Default

## Intent and Executive Summary

1. **Problem Statement:** Agents executing plans default to dispatching EVERY plan step to sub-agents via `task()` — including steps the plan marks `direct` — instead of executing `direct` steps in the orchestrator's own context as Architecture B mandates.
2. **Root Cause / Motivation:** No bright-line rule exists in the always-loaded guideline layer (091) making orchestrator-direct execution the default and `task()` a plan-marked exception; skill cards and 022 lack a single canonical rule site. The deviation must be fixed in the deck per the §17 R-18 remediation pattern, not corrected ad hoc per session. Observed 2026-09-18 (batch .opencode#2452/2451/2450/2447/2446): massive sub-agent overhead with no isolation benefit, orchestrator-context discipline violations, and the observed "you murdered yourself" dispatch of a verify step that then hit the harness pre-flight incorrectly.
3. **Approach Chosen:** Add the bright-line to `.opencode/guidelines/091-incremental-build.md` as the single canonical rule site (Tier 1, always loaded); 022 Read-links to 091; mirror the rule semantics in `executing-plans/SKILL.md` and `git-workflow/SKILL.md` via Read-link framing; add two behavioral scenarios to tests-v2 with a mixed-mode plan fixture.
4. **Alternatives Considered & Why Discarded:** (a) Placing the rule in 022 only — discarded because 022 is Tier 2, on-demand loaded, so the rule would not be present at the dispatch decision moment; 091 is Tier 1 and always loaded. (b) Duplicating the full dispatch-vocabulary table in each SKILL.md — discarded because the canonical dispatch-vocabulary table (skill-card-description-standards.md) forbids directive-layer files carrying duplicated dispatch definitions; mirrors must reference, not restate. (c) Creating new stderr-grep assertion helpers in helpers.sh — discarded because tests-v2/AGENTS.md §2 (Evaluation Source: session.yaml is PRIMARY, §78/§125) forbids stderr-grep assertion helpers for behavioral SC evaluation; session.yaml inspection is the sanctioned mechanism.
5. **Key Design Decisions:** (a) 091 is the SINGLE canonical rule site; 022 and both SKILL.md files Read-link to it — tradeoff: one extra Read-link hop for directive files versus eliminating duplicate-rule drift. (b) SKILL.md mirrors carry rule SEMANTICS (default orchestrator-direct, task() only at `task-card`-marked steps) plus a Read-link to 091 — tradeoff: brief local restatement of the rule sentence for always-visible routing versus strict single-copy text; the mirrors do NOT restate dispatch vocabulary definitions, so they coexist with the canonical-table no-duplicate mandate. (c) Behavioral evaluation uses the sanctioned harness contract: `behavior_run` artifact generation + clean-room sub-agent inspection of the exported `session.yaml` (via `.opencode/tools/session-to-timeline`) — tradeoff: two-SC generation/evaluation split versus a single conflated SC, resolved in favor of the split per tests-v2/AGENTS.md evaluation-paradigm rules.
6. **User Intent / Original Prompt:** Developer revision request 2026-09-19: "spec re-audit verdict DRAFT with 7 holistic FAILs — must reach 100% clean pass" — remediate per re-audit verdict.yaml bidirectional_findings (original spec trigger: observed 2026-09-18 batch defect where agents dispatched every plan step to sub-agents).

## Problem

Executing-plans Architecture B (022-orchestrator-context-discipline) states plans execute directly in the orchestrator's own context, with `task()` dispatch ONLY where a plan step explicitly marks dispatch. In practice (observed 2026-09-18, batch .opencode#2452/2451/2450/2447/2446), agents default to dispatching EVERY plan step to sub-agents — including steps the plan marks `direct` — treating task() as the default execution angle. This produced: (a) massive sub-agent overhead with no isolation benefit, (b) orchestrator-context discipline violations, (c) the observed "you murdered yourself" dispatch of a verify step that then hit the harness pre-flight incorrectly.

The defect is the same class as the §17 R-18 excessive-deliberation remediation requirement: a deviation from the canonical execution model must be treated as a defect that gets fixed in the deck, not merely corrected ad hoc in the session.

## Not Included

- **Re-litigating Architecture B's dispatch-vocabulary table** — the table is canonical in `.opencode/reference/skill-card-description-standards.md` §"Canonical Dispatch-Vocabulary Table (Single Source of Truth)"; this spec only references it, per its no-duplicate mandate for directive-layer files.
- **Retroactive audits of past sessions** — the fix is prospective deck enforcement; auditing historical sessions adds no forward protection.

## Requirements

R-1. `.opencode/guidelines/091-incremental-build.md` SHALL carry the orchestrator-direct bright-line rule as the single canonical rule site, and no other file SHALL carry a duplicate directive-layer dispatch-definition of the rule.
R-2. `executing-plans/SKILL.md` and `git-workflow/SKILL.md` SHALL each carry the rule semantics with a `Read [Text](path)` link to 091, and SHALL NOT use "see"-citation form.
R-3. The deck SHALL include a behavioral scenario demonstrating mixed-mode plan execution matching the plan's per-step dispatch modes.
R-4. The deck SHALL include a behavioral scenario demonstrating that a step-combining deviation produces a committed deck fix, not an ad hoc session correction.

## Success Criteria

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/guidelines/091-incremental-build.md` carries a bright-line rule as the SINGLE canonical rule site: the default execution angle for plan/workflow steps is orchestrator-direct; `task()` is used ONLY where the plan/workflow step explicitly marks dispatch (`task-card`); any deviation is a defect requiring deck remediation (SC revision or guideline fix folded into the active feature branch), per the §17 R-18 remediation pattern. 022-orchestrator-context-discipline.md remains the Architecture B reference document but carries NO duplicate of this rule — it Read-links to 091, consistent with skill-card-description-standards.md §"Canonical Dispatch-Vocabulary Table" which forbids directive-layer dispatch definitions outside the designated canonical site. | string | `grep` on `.opencode/guidelines/091-incremental-build.md` for the bright-line text (default orchestrator-direct, task() only at `task-card`-marked steps, deviation = deck remediation per §17 R-18); verify 022 contains no duplicate rule text and carries a Read-link to 091 for this rule. |
| SC-2 | `.opencode/skills/executing-plans/SKILL.md` and `.opencode/skills/git-workflow/SKILL.md` each carry the rule SEMANTICS (default orchestrator-direct; `task()` only at `task-card`-marked steps; deviation = deck remediation) as a rule STATEMENT, each with a `Read [Text](path)` link to `.opencode/guidelines/091-incremental-build.md` as the canonical rule site (no "see" citations). The mirrors carry the rule sentence only — they do NOT restate the dispatch-vocabulary table or its definitions (`orchestrator`, `task-card`, `task-card blind`, per-step `direct`/`task-card` modes), which remain canonical in skill-card-description-standards.md; a rule statement referencing the canonical site coexists with (does not violate) the canonical-table no-duplicate mandate. | string | `grep` both SKILL.md files for the rule semantics and for `Read [`-pattern links targeting `091-incremental-build.md`; `grep -c "see.*091"` style scan confirms no "see"-citation form; `grep` confirms neither SKILL.md redefines the dispatch vocabulary terms (no `direct`/`task-card` mode definitions beyond the rule sentence). |
| SC-3 | A behavioral scenario at `.opencode/tests-v2/behaviors/2455-sc3-mixed-mode-plan-execution.sh` is an artifact-only generator: it runs a clean-room agent against a mixed-mode plan fixture at `.opencode/tests-v2/behaviors/fixtures/plans/2455-mixed-mode-plan.md` (at least 2 steps marked `direct`, at least 1 step marked `task-card`, per plan-artifact-format.md §4.2 per-step dispatch mode) via `behavior_run`, producing the mandatory artifact set (`session.yaml`, `manifest.yaml`, `stdout.log`, `stderr.log`, `exit_code`) and exiting 0. A separate clean-room evaluation step inspects the exported `session.yaml` (via `.opencode/tools/session-to-timeline`) and judges that the agent executed `direct` steps in its own context (no `task()` calls targeting them) and dispatched `task()` only at the `task-card`-marked step. | behavioral | Step 1 (generation): run `bash .opencode/tests-v2/behaviors/2455-sc3-mixed-mode-plan-execution.sh` — PASS requires exit 0 and a non-empty `session.yaml` in the artifact directory. Step 2 (evaluation): dispatch a clean-room sub-agent that reads `session.yaml`/`timeline.yaml` from the artifact directory and returns PASS/FAIL on: zero `task()` tool-call events for any `direct` step, and exactly one `task()` dispatch event matching the `task-card`-marked step's dispatch string. No stderr/stdout grep assertion helpers are used (forbidden per tests-v2/AGENTS.md §2). |
| SC-4 | A behavioral scenario at `.opencode/tests-v2/behaviors/2455-sc4-deviation-deck-remediation.sh` is an artifact-only generator: it runs a clean-room agent given a step-combining deviation scenario via `behavior_run`, producing the mandatory artifact set and exiting 0. A separate clean-room evaluation step inspects the exported `session.yaml` (via `.opencode/tools/session-to-timeline`) and judges that the agent EDITED at least one enforcement artifact carrying the violated rule (091, executing-plans/SKILL.md, or a tests-v2 scenario) and COMMITTED the fix to its active feature branch per the §17 R-18 pattern — rather than only correcting ad hoc or describing the intended fix in prose. | behavioral | Step 1 (generation): run `bash .opencode/tests-v2/behaviors/2455-sc4-deviation-deck-remediation.sh` — PASS requires exit 0 and a non-empty `session.yaml`. Step 2 (evaluation): dispatch a clean-room sub-agent that reads `session.yaml`/`timeline.yaml` from the artifact directory and returns PASS/FAIL on: presence of file-edit tool-call events (`edit`/`write`) targeting at least one named enforcement artifact AND `git commit`/`git push` command events in the session — prose-only remediation (no edit/commit events) is FAIL. No stderr/stdout grep assertion helpers are used (forbidden per tests-v2/AGENTS.md §2). |

## Items

### Item 1 (SC-1): Add bright-line rule to 091; Read-link from 022

- RED: `grep` for the bright-line text in 091 fails (rule absent); `grep` on 022 shows no Read-link to 091 for this rule.
- GREEN: Add the bright-line paragraph to 091 (default orchestrator-direct; `task()` only at `task-card`-marked steps; deviation = deck remediation per §17 R-18); add `Read [Text](path)` link from 022 to 091.
- verify: grep both files per SC-1 Verification Method.
- commit: guideline changes on the active feature branch.

### Item 2 (SC-2): Mirror rule semantics in both SKILL.md files

- RED: `grep` shows neither SKILL.md carries the rule semantics nor a Read-link to 091.
- GREEN: Add rule-semantics sentence + `Read [Text](path)` link to 091 in both SKILL.md files, without restating dispatch vocabulary definitions.
- verify: grep both files per SC-2 Verification Method.
- commit: skill card changes on the active feature branch.

### Item 3 (SC-3): Mixed-mode plan execution behavioral scenario

- RED: Scenario file and plan fixture absent (`ls` fails).
- GREEN: Create `.opencode/tests-v2/behaviors/2455-sc3-mixed-mode-plan-execution.sh` (artifact-only generator calling `behavior_run`, exit 0) and the mixed-mode plan fixture with ≥2 `direct` steps and ≥1 `task-card` step; define the clean-room evaluation step inspecting `session.yaml` via `session-to-timeline`.
- verify: run the generator (exit 0, non-empty session.yaml), then clean-room evaluation per SC-3 Verification Method.
- commit: scenario + fixture on the active feature branch; commit AND push before the behavioral run per tests-v2/AGENTS.md §4.

### Item 4 (SC-4): Deviation→deck-remediation behavioral scenario

- RED: Scenario file absent (`ls` fails).
- GREEN: Create `.opencode/tests-v2/behaviors/2455-sc4-deviation-deck-remediation.sh` (artifact-only generator calling `behavior_run`, exit 0) with a deviation prompt; define the clean-room evaluation step judging edit+commit evidence in `session.yaml` via `session-to-timeline`.
- verify: run the generator (exit 0, non-empty session.yaml), then clean-room evaluation per SC-4 Verification Method.
- commit: scenario on the active feature branch; commit AND push before the behavioral run per tests-v2/AGENTS.md §4.

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/behaviors/helpers.sh` `behavior_run` (line 798) | Scenario scripts call `behavior_run` for artifact generation | Satisfied (live-verified: function present) |
| `.opencode/tools/session-to-timeline` | Evaluation steps process exported `session.yaml` into a tool-call timeline | Satisfied (registered agent tool) |
| `.opencode/tests-v2/AGENTS.md` §2 (session.yaml PRIMARY; §78/§125 forbidden-helpers list), §9 prompt-construction mandate, §4 commit+push pre-run gate | Scenarios and evaluation steps MUST follow this harness contract | Satisfied (read and followed in this spec) |
| `.opencode/reference/skill-card-description-standards.md` §"Canonical Dispatch-Vocabulary Table (Single Source of Truth)" | Rule wording MUST NOT duplicate dispatch vocabulary definitions | Satisfied (content-verified 2026-09-19) |
| `.opencode/skills/writing-plans/reference/plan-artifact-format.md` §4.2 | Mixed-mode fixture MUST use the per-step dispatch mode (`direct`/`task-card`) | Satisfied (live-read 2026-09-19; see Documentation Sources) |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 2 |
| R-4 | SC-4 | Phase 2 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Canonical dispatch-vocabulary table | doc | `.opencode/reference/skill-card-description-standards.md` §"Canonical Dispatch-Vocabulary Table (Single Source of Truth)" | Content-level verification 2026-09-19: section defines the dispatch vocabulary once (TDT Dispatch closed set; per-step plan dispatch mode with `direct` default and `task-card` marked); directive files MUST NOT carry duplicated or contradictory dispatch definitions. |
| Per-step dispatch mode definition | doc | `.opencode/skills/writing-plans/reference/plan-artifact-format.md` §4.2 "Dispatch Indicators and Per-Step Dispatch Mode" | Live-read 2026-09-19. Quote: "Every step MUST use one of two dispatch indicators, each carrying the step's explicit **dispatch mode** (`direct` or `task-card`, default `direct`)" (line 162). Claim confirmed. |
| §17 R-18 remediation pattern | doc | `.opencode/tests-v2/AGENTS.md` §17 | Tool-call verified (7 grep matches, prior audit; re-confirmed this revision via AGENTS.md read). |
| Harness evaluation contract | doc | `.opencode/tests-v2/AGENTS.md` §2 ("Evaluation Source: session.yaml is PRIMARY"; forbidden-helpers list at §78/§125); `behavior_run` at `.opencode/tests-v2/behaviors/helpers.sh:798` | Live-verified 2026-09-19: grep of helpers.sh for `assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models` returned 0 matches; helpers.sh read confirms `behavior_run()` exists and exports `session.yaml`; AGENTS.md §2 read confirms session.yaml is the PRIMARY evaluation source and stderr-grep assertion helpers are FORBIDDEN for behavioral SC evaluation. |
| Timeline evaluation tool | code | `.opencode/tools/session-to-timeline` | Verified present in session-init Agent Tools registry and referenced by helpers.sh `behavior_run` (helpers.sh:1144-1146). |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

- **SC-1:** Reading 091 and grepping for the bright-line costs minutes — the rule is present at the dispatch decision moment every session. Skipping costs every future session — agents keep dispatching `direct` steps to sub-agents, re-creating the 2026-09-18 batch defect with each plan execution.
- **SC-2:** Grepping two SKILL.md files costs minutes — skill-card readers see the rule where they route. Skipping costs silent rule divergence — the skill cards keep pointing agents at dispatch-first execution with no canonical backstop.
- **SC-3:** Building and running the mixed-mode scenario costs one `behavior_run` cycle plus one clean-room evaluation pass — the harness contract (generation/evaluation split, session.yaml evidence) is validated against the real rule. Skipping costs undetected regression — a deck edit that silently breaks mixed-mode execution ships with zero behavioral evidence, and the defect resurfaces only after another batch of wasted sub-agent dispatches.
- **SC-4:** Building and running the deviation scenario costs one `behavior_run` cycle plus one clean-room evaluation pass — the §17 R-18 remediation duty is proven to fire, not assumed. Skipping costs the exact failure class this spec exists to kill — agents that deviate and self-correct ad hoc leave the violated rule unrepaired, so every subsequent session inherits the same defect.

## Edge Cases

1. Agent combines steps partially (executes some direct steps in-context but still dispatches one) — SC-3 clean-room evaluation fails on any single `task()` call targeting a `direct` step; partial compliance is FAIL, not partial credit.
2. Agent skips `task()` at a step the plan marks `task-card` — SC-3 clean-room evaluation fails on the missing dispatch event; the rule requires dispatch ONLY at marked steps, and marked steps MUST be dispatched.
3. Behavioral run harness failure (model timeout, lock contention, pre-flight gate failure) — per tests-v2/AGENTS.md §10, timeout is diagnosed (including inspecting the exported session.yaml evidence), never assumed to be model unavailability; a run that cannot execute yields FAIL for that SC, never a structural substitute.
4. Agent performs the deck fix as prose-only recommendation (no file edit/commit events in session.yaml) — SC-4 clean-room evaluation fails; prose recall is not behavioral evidence.
5. `session.yaml` export contains `source_db: MISSING` — hard FAIL per tests-v2/AGENTS.md §2; no stderr/stdout substitute; recovery is verifying clean-room separation (dedicated test home, `TEST_HOME=<path>` on stderr), never data fabrication.

## Approach

Add the bright-line to the always-loaded guideline (091) as Tier 1 — the single canonical rule site — Read-linked from 022, mirror the rule semantics in executing-plans + git-workflow SKILL.md text (rule statement + Read-link, no dispatch-vocabulary restatement), add two behavioral scenarios to tests-v2 (`2455-sc3-mixed-mode-plan-execution.sh`, `2455-sc4-deviation-deck-remediation.sh`) with the mixed-mode plan fixture, evaluated per the harness contract: `behavior_run` artifact generation + clean-room sub-agent inspection of the exported `session.yaml` via `.opencode/tools/session-to-timeline`.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-19 | Initial spec | spec-audit-preparation | Developer (issue 2455) |
| 2026-09-19 | Revision 1: SC-2 names `.opencode/skills/git-workflow/SKILL.md` + `.opencode/skills/executing-plans/SKILL.md`; SC-3/SC-4 name scenario files, plan fixture, and stderr assertion helpers; SC-1 commits to 091 as the single canonical rule site (resolving the 091-vs-022 either/or; 022 Read-links to 091); added 4th Verification Method column; added Edge Cases section; defined "mixed-mode plan" fixture and "deck fix" assertion target; content-verified dispatch-vocabulary table claim and added Documentation Sources section | spec-audit verdict DRAFT — 7 holistic FAILs (implementability, internal consistency, completeness, testability, provenance); remediation per verdict.yaml bidirectional_findings | Developer revision request 2026-09-19 (spec-audit remediation) |
| 2026-09-19 | Revision 2: (1) SC-3/SC-4 verification methods rewritten from nonexistent/forbidden stderr assertion helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models` — live grep 0 matches in helpers.sh; forbidden by tests-v2/AGENTS.md §2/§78/§125) to the sanctioned harness contract: `behavior_run` artifact generation (exit 0 + non-empty session.yaml) + clean-room sub-agent inspection of exported `session.yaml` via `.opencode/tools/session-to-timeline`; behavioral intent NOT weakened — zero-task()-for-direct-steps and edit+commit deck-fix assertions preserved, now asserted on session.yaml tool-call events. (2) SC-2 disambiguated: mirrors carry rule SEMANTICS as a rule statement + Read-link, do NOT restate dispatch-vocabulary definitions — resolves contradiction with canonical-table no-duplicate mandate. (3) Added required sections per spec-structure-standards.md: Intent and Executive Summary preamble (6 fields), Requirements (RFC 2119), Items (per-SC TDD), Dependencies, Traceability, Enforcement Gate, Cost Frame (per-SC action/skipping cost per dark-prose-007). (4) Live-verified plan-artifact-format.md §4.2 (read; quote recorded in Documentation Sources — claim confirmed). (5) Documentation Sources rebuilt to Source/Type/Location/Verification columns with only live-verified claims. | Re-audit verdict DRAFT — 7 holistic FAILs (Implementability, Internal Consistency, Completeness, Testability, Provenance, Feasibility); remediation per reaudit-1 verdict.yaml bidirectional_findings | Developer revision request 2026-09-19 (spec re-audit remediation) |
