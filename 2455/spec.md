---
issue: 2455
title: "[SPEC] Orchestrator-direct plan execution — task() only at plan-marked dispatch points"
labels: [SPEC]
created: 2026-09-18
---

# SPEC — Orchestrator-Direct Plan Execution Default

## Problem

Executing-plans Architecture B (022-orchestrator-context-discipline) states plans execute directly in the orchestrator's own context, with `task()` dispatch ONLY where a plan step explicitly marks dispatch. In practice (observed 2026-09-18, batch .opencode#2452/2451/2450/2447/2446), agents default to dispatching EVERY plan step to sub-agents — including steps the plan marks `direct` — treating task() as the default execution angle. This produced: (a) massive sub-agent overhead with no isolation benefit, (b) orchestrator-context discipline violations, (c) the observed "you murdered yourself" dispatch of a verify step that then hit the harness pre-flight incorrectly.

The defect is the same class as the §17 R-18 excessive-deliberation remediation requirement: a deviation from the canonical execution model must be treated as a defect that gets fixed in the deck, not merely corrected ad hoc in the session.

## Success Criteria

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/guidelines/091-incremental-build.md` carries a bright-line rule as the SINGLE canonical rule site: the default execution angle for plan/workflow steps is orchestrator-direct; `task()` is used ONLY where the plan/workflow step explicitly marks dispatch (`task-card`); any deviation is a defect requiring deck remediation (SC revision or guideline fix folded into the active feature branch), per the §17 R-18 remediation pattern. 022-orchestrator-context-discipline.md remains the Architecture B reference document but carries NO duplicate of this rule — it Read-links to 091, consistent with skill-card-description-standards.md §"Canonical Dispatch-Vocabulary Table" which forbids directive-layer dispatch definitions outside the designated canonical site. | string | `grep` on `.opencode/guidelines/091-incremental-build.md` for the bright-line text (default orchestrator-direct, task() only at `task-card`-marked steps, deviation = deck remediation per §17 R-18); verify 022 contains no duplicate rule text and carries a Read-link to 091 for this rule. |
| SC-2 | `.opencode/skills/executing-plans/SKILL.md` and `.opencode/skills/git-workflow/SKILL.md` each carry the same rule (verbatim in semantics) as 091, each with a `Read [Text](path)` link to `.opencode/guidelines/091-incremental-build.md` as the canonical rule site (no "see" citations). | string | `grep` both SKILL.md files for the rule semantics and for `Read [`-pattern links targeting `091-incremental-build.md`; `grep -c "see.*091"` style scan confirms no "see"-citation form is used. |
| SC-3 | A behavioral scenario at `.opencode/tests-v2/behaviors/2455-sc3-mixed-mode-plan-execution.sh` demonstrates an agent executing a mixed-mode plan — a plan fixture at `.opencode/tests-v2/behaviors/fixtures/plans/2455-mixed-mode-plan.md` containing at least 2 steps explicitly marked `direct` and at least 1 step marked `task-card` (per the per-step plan dispatch mode defined in skill-card-description-standards.md "Canonical Dispatch-Vocabulary Table") — with the `direct` steps executed in the agent's own context (no `task()` calls for them) and `task()` used only at the `task-card`-marked step. | behavioral | Run the scenario via `bash .opencode/tests-v2/behaviors/2455-sc3-mixed-mode-plan-execution.sh` (which invokes `behavior_run` from `.opencode/tests-v2/behaviors/helpers.sh`); a clean-room sub-agent evaluates the exported session.yaml, asserting with the stderr-based helpers (`assert_stderr_pattern_present` for the task-card dispatch string; `assert_stderr_pattern_absent_all_models` for `task()` calls covering direct steps) that no `task()` call occurred for any `direct` step and exactly the `task-card`-marked step was dispatched. |
| SC-4 | A behavioral scenario at `.opencode/tests-v2/behaviors/2455-sc4-deviation-deck-remediation.sh` demonstrates the remediation duty: an agent that combined steps (deviation) must produce a deck fix — a revision to the enforcement artifact carrying the violated rule (091, executing-plans/SKILL.md, or a tests-v2 scenario) committed to its active feature branch per the §17 R-18 pattern — rather than only correcting ad hoc in the session. | behavioral | Run the scenario via `bash .opencode/tests-v2/behaviors/2455-sc4-deviation-deck-remediation.sh`; a clean-room sub-agent evaluates the exported session.yaml, asserting (via `assert_stderr_pattern_present` on deck-file edit/commit evidence) that the agent edited at least one enforcement artifact named above and committed the fix to its feature branch — not merely described the intended fix in stdout prose. |

## Edge Cases

1. Agent combines steps partially (executes some direct steps in-context but still dispatches one) — SC-3 assertion fails on any single `task()` call targeting a `direct` step; partial compliance is FAIL, not partial credit.
2. Agent skips `task()` at a step the plan marks `task-card` — SC-3 assertion fails on the missing dispatch string; the rule requires dispatch ONLY at marked steps, and marked steps MUST be dispatched.
3. Behavioral run harness failure (model timeout, lock contention, pre-flight gate failure) — per tests-v2/AGENTS.md §10, timeout is diagnosed, never assumed to be model unavailability; a run that cannot execute yields FAIL for that SC, never a structural substitute.
4. Agent performs the deck fix as prose-only recommendation (no file edit/commit) — SC-4 fails; prose recall is not behavioral evidence.

## Not Included

- Re-litigating Architecture B's dispatch-vocabulary table (canonical in `.opencode/reference/skill-card-description-standards.md` §"Canonical Dispatch-Vocabulary Table (Single Source of Truth)" — content-verified 2026-09-19: the section defines the dispatch vocabulary once, including the TDT Dispatch closed set (`orchestrator`, `task-card`, `task-card blind`) and the per-step plan dispatch mode (`direct` default, `task-card` marked), and mandates directive-layer files reference the table rather than restate definitions).
- Retroactive audits of past sessions.

## Approach

Add the bright-line to the always-loaded guideline (091) as Tier 1 — the single canonical rule site — Read-linked from 022, mirror in executing-plans + git-workflow SKILL.md text, add two behavioral scenarios to tests-v2 (`2455-sc3-mixed-mode-plan-execution.sh`, `2455-sc4-deviation-deck-remediation.sh`) with the mixed-mode plan fixture.

## Documentation Sources

| Claim | Source | Verification |
|-------|--------|--------------|
| Dispatch-vocabulary table is canonical in skill-card-description-standards.md | `.opencode/reference/skill-card-description-standards.md` §"Canonical Dispatch-Vocabulary Table (Single Source of Truth)" (§191–206) | Content-level verification 2026-09-19: section confirmed present and defining the dispatch vocabulary once (TDT Dispatch closed set; per-step plan dispatch mode with `direct` default and `task-card` marked); directive files MUST NOT carry duplicated or contradictory dispatch definitions. |
| §17 R-18 remediation pattern | `.opencode/tests-v2/AGENTS.md` §17 | Tool-call verified (7 grep matches, prior audit). |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-19 | Initial spec | spec-audit-preparation | Developer (issue 2455) |
| 2026-09-19 | Revision: SC-2 names `.opencode/skills/git-workflow/SKILL.md` + `.opencode/skills/executing-plans/SKILL.md`; SC-3/SC-4 name scenario files, plan fixture, and stderr assertion helpers; SC-1 commits to 091 as the single canonical rule site (resolving the 091-vs-022 either/or; 022 Read-links to 091); added 4th Verification Method column; added Edge Cases section; defined "mixed-mode plan" fixture and "deck fix" assertion target; content-verified dispatch-vocabulary table claim and added Documentation Sources section | spec-audit verdict DRAFT — 7 holistic FAILs (implementability, internal consistency, completeness, testability, provenance); remediation per verdict.yaml bidirectional_findings | Developer revision request 2026-09-19 (spec-audit remediation) |
