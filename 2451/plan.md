---
plan_schema_version: 1
issue: 2451
title: "One-dispatch-one-step gate — prohibit combined dispatches for discrete steps"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase: 1
    skills: [test-driven-development (red, green, post-regression), verification-before-completion (verify)]
  - phase: 2
    skills: [test-driven-development (red, green, post-regression), verification-before-completion (verify)]
  - phase: 3
    skills: [test-driven-development (red, green, post-regression), verification-before-completion (verify)]
---

# Implementation Plan — One-dispatch-one-step gate (.opencode#2451)

**Issue:** `.opencode/.issues/2451/spec.md`

## Goal

Implement the developer-approved six-part package: canonical pattern p-dis-007 "One-Dispatch-One-Step Gate" in 257, a Tier 1 dispatch-level bright-line in 091, a critical-rules-034 dispatch-level extension in 022, the §15/§6a loophole closure in tests-v2/AGENTS.md, a §6a two-SC behavioral scenario (artifact-generation run + separate clean-room semantic evaluation), and a content-verification placement scenario.

## Architecture

Structural rule text in three guidelines (257 canonical, 091 Tier 1 bright-line, 022 extension), loophole closure in the behavioral test framework guide, enforcement via the §6a two-SC behavioral pattern (session.yaml as PRIMARY evaluation source, semantic-only clean-room judgment, no static gates) plus a content-verification scenario. Architecture B direct execution preserved; the gate constrains task() dispatch cardinality only.

## Files

- `.opencode/guidelines/257-procedural-discipline-reference.md`
- `.opencode/guidelines/091-incremental-build.md`
- `.opencode/guidelines/022-orchestrator-context-discipline.md`
- `.opencode/tests-v2/AGENTS.md`
- `.opencode/tests-v2/behaviors/` (new artifact-generation scenario + clean-room evaluation dispatch)
- `.opencode/tests-v2/` content-verification suite (new placement scenario)

## Dispatch

- Phase 1: task-card (RED/GREEN/post-regression/verify) + direct (commits) — steps 5-24
- Phase 2: task-card (RED/GREEN/post-regression/verify) + direct (commits, push) — steps 25-35
- Phase 3: task-card (RED/GREEN/post-regression/verify) + direct (commits) — steps 36-40
- Post-implementation: task-card (audit, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary) + direct (z3-check) — steps 41-48

## Blast Radius

- Affected: 257, 091, 022 (rule-text additions; existing content preserved — extension, not replacement), tests-v2/AGENTS.md (§6a, §15 wording), new test scenarios under `.opencode/tests-v2/`.
- Unaffected: other skills' DISPATCH_GATE sections; dispatch-mode marking (direct vs task-card); the canonical dispatch string mechanism; plugin/hook enforcement layer.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|---|---|---|---|---|---|---|
| 1 | Rule-text authoring | Canonical pattern, bright-lines, loophole closure | SC-1, SC-2, SC-3, SC-4 | none | 5-24 | task-card (RED/GREEN/verify) + direct (commit) |
| 2 | Behavioral scenario | Artifact-generation run + clean-room semantic evaluation | SC-5, SC-6 | Phase 1 (committed + pushed, fresh-fetch containment) | 25-35 | task-card (RED/GREEN/verify) + direct (commit, push) |
| 3 | Content-verification scenario | Rule-text placement assertions | SC-7 | Phase 1 (items 1-3) | 36-40 | task-card (RED/GREEN/verify) + direct (commit) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- C1: 257 contains p-dis-007 with all §11 add-pattern procedure artifacts and the no-matter-the-reasoning clause (SC-1).
- C2: 091 carries the dispatch-level bright-line with no-exceptions clause and a Read-link to 257 p-dis-007 (SC-2).
- C3: 022 critical-rules-034 covers all dispatch-level combined shapes with preserved sub-agent-internal coverage and a Read-link (SC-3).
- C4: tests-v2/AGENTS.md §15 carries the cannot-combine clarification and §6a the separate-dispatch sentence (SC-4).
- C5: The behavioral artifact-generation session exists with exported session.yaml; RED is the preserved observed evidence (SC-5).
- C6: The separate clean-room evaluation verdict is recorded with criterion + session.yaml as sole inputs (SC-6).
- C7: The content-verification placement scenario passes via the enforcement suite (SC-7).

## Pre-Implementation Steps

- [ ] 1. Coherence gate (**direct**)
  - Verify spec and plan are coherent: SC list matches the six-part design; no SC spans multiple parts; phase DAG has no circular dependencies.
  - Confirm all four rule-text host files exist and contain their expected anchors (257 §11, 091 "Batching items", 022 critical-rules-034, tests-v2/AGENTS.md §6a and §15).
- [ ] 2. Baseline check (**direct**)
  - Confirm repository state: feature branch active, submodules synced, zero pending unrelated changes.
  - Record the observed RED baseline reference: session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6`, 22 combined "Two sequential tasks" dispatches — preserved, not fabricated.
- [ ] 3. Pre-regression (**task-card**) — `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Run regression test patterns before RED phase.
- [ ] 4. Pre-regression verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify pre-regression results.

# Phase 1 — Rule-text authoring (guidelines + tests-v2 AGENTS.md)

<!-- PHASE-1-BODY -->

## Phase Metadata

- **Concern:** Author the three rule texts and the loophole closure — each is the minimum change that makes its RED assertion pass.
- **Files:** `.opencode/guidelines/257-procedural-discipline-reference.md`, `.opencode/guidelines/091-incremental-build.md`, `.opencode/guidelines/022-orchestrator-context-discipline.md`, `.opencode/tests-v2/AGENTS.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** none (first phase)
- **Entry condition:** pre-implementation steps 1-4 complete; trunk-tip state verified.
- **Exit condition:** items 1-4 committed; all four rule texts verifiable by grep-class assertions.

## Code Path Coverage

- 257 §11 "Adding New Patterns" procedure → catalog row, selection matrix entry, canonical formula, co-application with 250/255, auto-detection trigger, version tracking, research basis (SC-1).
- 091 "Batching items" anti-pattern section → dispatch-level extension (SC-2).
- 022 critical-rules-034 rule block → dispatch-level extension with preserved sub-agent-internal coverage (SC-3).
- tests-v2/AGENTS.md §6a and §15 sections → loophole-closure sentences (SC-4).

## Cross-Cutting SCs

- The no-matter-the-reasoning clause appears in SC-1, SC-2, and SC-3 texts; the Read-link mandate (never "see" citations) governs SC-2 and SC-3.
- "Discrete step" definition (task-card plan step or workflow-marked sub-task dispatch) anchors all three rule texts (R-10).

## Interface Boundaries

- 257 is the sole canonical pattern home; 091 and 022 Read-link it and never redefine it.
- Architecture B (direct execution in orchestrator context) remains sanctioned — the gate constrains task() dispatch cardinality only.
- Other skills' DISPATCH_GATE sections are untouched.

## State Transitions

- Guideline files move from "no dispatch-cardinality rule" to "bright-line present at the dispatch decision moment" (091 is always loaded).
- tests-v2/AGENTS.md §15 economy wording moves from ambiguous (combinable reading) to explicitly cannot-combine; §6a gains the separate-dispatch sentence.

## Step-by-Step

### Item 1 (SC-1) — p-dis-007 canonical pattern in 257

- [ ] 5. RED — write the failing content assertion (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC-1
  - The assertion checks 257 for pattern p-dis-007, its §11 procedure artifacts, and the no-matter-the-reasoning clause — it FAILS today because the pattern is absent.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-red-*`
- [ ] 6. GREEN — add p-dis-007 "One-Dispatch-One-Step Gate" to 257 (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC-1
  - Must be true: 257 contains the pattern per its §11 add-pattern procedure — catalog row, selection matrix entry, canonical formula, co-application with 250/255, auto-detection trigger, version tracking, research basis. Bright-line: one dispatch = one discrete step; enumerated violation shapes (two task cards, run+verify, multi-SC verification, Task A/Task B shapes, "combined effectiveness run"); structural, not reasoning-classification. No other card carries the canonical definition.
- [ ] 7. Post-regression (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC-1
- [ ] 8. Verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC-1 — grep-class check over 257 for the pattern ID, §11 artifacts, and the clause; verdict recorded.
- [ ] 9. Commit (**direct**)
  - SC: SC-1 — `git add .opencode/guidelines/257-procedural-discipline-reference.md <test artifact> && git commit` — guideline pattern addition (257 only).

### Item 2 (SC-2) — 091 Tier 1 dispatch-level bright-line

Depends on item 1 (the Read-link target must exist).

- [ ] 10. RED (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC-2
  - The assertion checks 091's "Batching items" anti-pattern for dispatch-level language and a Read-link to p-dis-007 — it FAILS today.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-red-*`
- [ ] 11. GREEN (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC-2
  - Must be true: 091 extends "Batching items" into an explicit dispatch-level rule with the no-exceptions clause, plus a `Read [Text](path)` link to 257 p-dis-007 — never "see" citations. Tier 1 rationale recorded (091 always loaded at the dispatch decision moment).
- [ ] 12. Post-regression (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC-2
- [ ] 13. Verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC-2 — grep 091 for the extension, the no-exceptions clause, and the Read-link; assert absence of "see"-style citations to the pattern.
- [ ] 14. Commit (**direct**)
  - SC: SC-2 — guideline bright-line change committed.

### Item 3 (SC-3) — 022 critical-rules-034 dispatch-level extension

Depends on item 1 (the Read-link target must exist).

- [ ] 15. RED (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC-3
  - The assertion checks critical-rules-034 for dispatch-level shapes (run+verify in one task(), cross-SC verification runs, Task A/Task B packing) — it FAILS today.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-red-*`
- [ ] 16. GREEN (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC-3
  - Must be true: 022 extends critical-rules-034 to cover ALL combined-dispatch shapes at the dispatch level with the no-matter-the-reasoning clause and a Read-link to 257 p-dis-007; the existing sub-agent-internal coverage is preserved, not replaced.
- [ ] 17. Post-regression (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC-3
- [ ] 18. Verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC-3 — grep 022 for the shapes, the clause, and the Read-link; consistency read against the pre-extension 034 text (extension, not replacement).
- [ ] 19. Commit (**direct**)
  - SC: SC-3 — guideline rule extension committed.

### Item 4 (SC-4) — tests-v2/AGENTS.md §15 + §6a loophole closure

- [ ] 20. RED (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC-4
  - The assertion checks §15 for the cannot-combine clarification and §6a for the separate-dispatch sentence — it FAILS today.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-red-*`
- [ ] 21. GREEN (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC-4
  - Must be true: §15 clarifies that "one run per SC-RED need and one run per SC-GREEN need" CANNOT be satisfied by combining two SCs' needs into one run — a combined run violates the mandate; §6a states explicitly that the clean-room evaluation is a SEPARATE dispatch from the artifact-generation run.
- [ ] 22. Post-regression (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC-4
- [ ] 23. Verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC-4 — grep §15 and §6a for both additions.
- [ ] 24. Commit (**direct**)
  - SC: SC-4 — tests framework guide change committed.

## Phase Completion Block

- All four items report PASS; SC-1..SC-4 verdicts verified and recorded.
- Daisy chain holds: item 1 committed before items 2-3 RED; item 4 independent of 2-3 but sequenced last.

## Concern Transition

Phase 1 rule text must be committed AND pushed (fresh-fetch remote containment) before the Phase 2 behavioral run — per the behavioral harness pre-flight gate.

**Cost frame:** Verifying each rule-text addition costs one grep-class content check — seconds, bounded. Skipping costs the gate its definition and visibility: with no p-dis-007 in 257, no bright-line in always-loaded 091, no 034 extension in 022, and the §15 loophole intact, every combined dispatch repeats the observed unattributable-diagnosis cost — the 100×–1000× DDL tier, with the ~44h SC-09 re-dispatch loop as the recorded precedent. Correctness is the only metric.

# Phase 2 — Behavioral scenario (artifact-generation run + clean-room evaluation)

<!-- PHASE-2-BODY -->

## Phase Metadata

- **Concern:** Produce runtime behavioral evidence via the §6a two-SC pattern — an artifact-generation run whose session.yaml a SEPARATE clean-room dispatch then evaluates semantically.
- **Files:** `.opencode/tests-v2/behaviors/` (new artifact-generation scenario; new clean-room evaluation dispatch); exported `session.yaml` (run artifact).
- **SCs:** SC-5, SC-6
- **Dependencies:** Phase 1 committed and pushed; fresh `git fetch` verifying the effective commit is contained in a remote ref (behavioral harness pre-flight gate hard-FAILs otherwise).
- **Entry condition:** Phase 1 exit condition met; remote containment verified.
- **Exit condition:** session.yaml exported and preserved; clean-room verdict recorded with criterion + session.yaml as sole inputs.

## Code Path Coverage

- New behavioral scenario script in `.opencode/tests-v2/behaviors/` invoking `bash .opencode/tests-v2/with-test-home opencode run '<multi-step-plan prompt>'` with a >=600s timeout (SC-5).
- New clean-room evaluation dispatch whose sole inputs are the semantic criterion and the session.yaml from SC-5 (SC-6).

## Cross-Cutting SCs

- R-7 (no static gates) and R-8 (observed RED preserved, not fabricated) govern both items.
- tests-v2/AGENTS.md §2: session.yaml is the PRIMARY evaluation source; stderr/stdout assertion helpers are prohibited.

## Interface Boundaries

- The clean-room evaluation is a SEPARATE dispatch from the artifact-generation run — never merged, never collapsed.
- The evaluator receives only the criterion and session.yaml — no marker lists, no expected phrases, no static gates.

## State Transitions

- RED state: observed evidence on record — 22 combined "Two sequential tasks" dispatches in production session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` (issue 2432); documented, not re-run or fabricated.
- GREEN state: the post-rule artifact-generation session shows one dispatch per discrete step; the clean-room evaluator judges this semantically.

## Step-by-Step

### Item 5 (SC-5) — behavioral artifact-generation scenario (§6a SC-N)

Depends on items 1-4 (rule text effective in the evaluated session).

- [ ] 25. RED — document the observed baseline (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC-5
  - RED is observed, not fabricated: the scenario cites the preserved evidence record (22 combined dispatches in `ses_f5aa152f7ffeeEzOm66Lr2Gbs6`, issue 2432). No RED run is manufactured. If neither the live session nor the preserved record is accessible, report BLOCKED rather than fabricating evidence.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-red-*`
- [ ] 26. GREEN — add the behavioral scenario script (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC-5
  - Must be true: a scenario in `.opencode/tests-v2/behaviors/` runs a real-model `opencode run` against a multi-step-plan prompt via `with-test-home` (>=600s timeout), producing the artifact-generation session whose session.yaml is the evaluation input.
- [ ] 27. Commit (**direct**)
  - SC: SC-5 — test script plus fixtures committed.
- [ ] 28. Push (**direct**)
  - SC: SC-5 — behavioral variant ordering: push the commit to its remote branch, then fresh `git fetch` and verify the effective commit is contained in a remote ref — required BEFORE the behavioral run.
- [ ] 29. Post-regression (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC-5
- [ ] 30. Verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC-5 — session.yaml exported and preserved per the behavioral harness export procedure; no structural substitution; run evidence preserved under `./tmp/behavioral-evidence-*` naming where applicable.

### Item 6 (SC-6) — clean-room semantic evaluation (§6a SC-N+1)

Depends on items 1-4 and item 5 (session.yaml must exist).

- [ ] 31. RED (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC-6
  - The observed baseline session evaluated under the semantic criterion FAILS — 22 combined dispatches mean not every discrete step received its own dispatch. Documented from the preserved record; not fabricated.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-red-*`
- [ ] 32. GREEN (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC-6
  - Must be true: a SEPARATE clean-room evaluation dispatch — distinct from item 5's artifact-generation run — receives only the semantic criterion (every discrete step received its own dispatch) and the session.yaml, and judges SEMANTICALLY. No marker lists, no expected phrases, no static gates (R-7). GREEN = the post-rule session shows one dispatch per discrete step.
- [ ] 33. Post-regression (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC-6
- [ ] 34. Verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC-6 — verdict recorded per the §6a result-contract format; evaluator input audit confirms criterion + session.yaml only.
- [ ] 35. Commit (**direct**)
  - SC: SC-6 — evaluation script/prompt fixture committed.

## Phase Completion Block

- SC-5 and SC-6 verdicts verified and recorded with behavioral evidence type; no structural substitution anywhere in the phase.

## Concern Transition

The behavioral evidence is complete; Phase 3 adds the regression gate that keeps the three rule texts in place.

**Cost frame:** Running the artifact-generation scenario costs minutes of real-model execution — a bounded delay; RED is already observed on record, so no RED-run cost is added. Skipping costs the package its only runtime evidence — a structural PASS with zero evidence the dispatch behavior changed. Running the separate clean-room evaluation costs one bounded dispatch; collapsing it into item 5's run (which §6a forbids) or replacing it with marker gates costs the semantic verdict itself — the escape hatch the developer directive prohibits. Correctness is the only metric.

# Phase 3 — Content-verification scenario (rule-text placement)

<!-- PHASE-3-BODY -->

## Phase Metadata

- **Concern:** Lock the three rule texts in place with a content-verification regression scenario.
- **Files:** `.opencode/tests-v2/` content-verification suite (new placement scenario).
- **SCs:** SC-7
- **Dependencies:** Phase 1 items 1-3 (the rule texts must exist for placement assertions to pass).
- **Entry condition:** items 1-3 committed.
- **Exit condition:** scenario PASS via `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>`.

## Code Path Coverage

- New content-verification scenario asserting: 257 contains p-dis-007; 091 contains the dispatch-level bright-line; 022 contains the critical-rules-034 dispatch-level extension; task cards contain NO multi-step dispatch template text.

## Cross-Cutting SCs

- None — single-SC phase.

## Interface Boundaries

- The scenario asserts placement only; it does not duplicate or redefine any rule text.

## State Transitions

- Rule texts move from unenforced placement to regression-guarded placement — future edits that move or delete them fail the suite.

## Step-by-Step

### Item 7 (SC-7) — content-verification scenario for rule-text placement

Depends on items 1-3.

- [ ] 36. RED (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC-7
  - The placement scenario run before items 1-3 FAILS — the rule texts are absent. Documented as the pre-change state; the scenario file is authored here and its assertions validated against the now-present texts in GREEN.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-red-*`
- [ ] 37. GREEN (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC-7
  - Must be true: the content-verification scenario asserts 257 contains p-dis-007, 091 contains the bright-line, 022 contains the 034 extension, and task cards contain NO multi-step dispatch template text; the scenario PASSES via `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>`.
- [ ] 38. Post-regression (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC-7
- [ ] 39. Verify (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC-7 — scenario PASS via the content-verification suite; no structural substitution.
- [ ] 40. Commit (**direct**)
  - SC: SC-7 — content-verification scenario committed.

## Phase Completion Block

- SC-7 verdict verified; all seven SCs now pass — the enforcement gate is satisfied at item level.

## Concern Transition

All SCs pass; post-implementation gates (audit, structural checks, pre-PR gate, review-prep, PR creation) proceed.

**Cost frame:** Running the content-verification scenario costs seconds via the existing suite. Skipping costs the regression gate: future edits could silently move or delete the three rule texts with nothing failing — the defect re-enters through the same unguarded door the package just closed. Correctness is the only metric.

# Post-Implementation

<!-- POST-IMPLEMENTATION-BODY -->

- [ ] 41. Audit (**task-card**) — `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Adversarial audit of the deliverable against all seven SCs; clean-room evaluation input audit included.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-audit-*`
- [ ] 42. Z3 check (**direct**)
  - Orchestrator runs `.opencode/tools/solve check --state-path <state> --contract-path <contract>` directly — no sub-agent dispatch.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-z3-check-*`
- [ ] 43. Structural checks (**task-card**) — `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Run the finishing checklist (lint, typecheck, markdown format checks on modified guideline files).
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-structural-checks-*`
- [ ] 44. Pre-PR gate (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - Read all SC verdicts; BLOCK if any FAIL. DONE_WITH_CONCERNS coerces to FAIL. EVIDENCE_TYPE_MISMATCH is a hard FAIL.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-pre-pr-gate-*`
- [ ] 45. Regression check (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Final regression check before PR, including the new content-verification scenario.
  - Pre-clean: `rm -f ./tmp/2451/artifacts/pipeline-regression-check-*`
- [ ] 46. Review prep (**task-card**) — `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 47. Create PR (**task-card**) — `task(..., prompt: "execute create task from git-workflow-pr")`
  - Stacked PR — one branch, commits squashed to exactly one per issue at PR creation. PR creation only; merging is human-only.
- [ ] 48. Completion summary (**task-card**) — `task(..., prompt: "execute completion task from completion-core")`
  - Generate the completion executive summary; report once; HALT.

<!-- PRE-FLIGHT-GUARD -->

## Pre-Flight Guard

> **ORCHESTRATOR_ONLY_PLAN** — This artifact is an implementation plan (orchestrator-level routing metadata).
>
> **Guard (execute before consuming any plan step):**
>
> ```text
> IF task tool (task) is NOT present in this agent's toolset:
>     RETURN BLOCKED
>     reason: ORCHESTRATOR_ONLY_PLAN
>     detail: "Plans contain orchestrator-level routing (dispatch indicators, phase gates, per-step modes). A sub-agent cannot dispatch task() or hold phase-level state."
> ELSE:
>     PROCEED — consumer is the orchestrator; plan steps may execute.
> ```
>
> This guard is mechanical (action-not-perception): presence of the `task` tool is the probe; it does not infer role from prompts. Reason code table: `ORCHESTRATOR_ONLY_PLAN` (this artifact), `ORCHESTRATOR_ONLY_SKILL_CARD` (skill cards).
