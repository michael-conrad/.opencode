---
plan_schema_version: "1.0"
issue: 2249
title: "Generalize the dependency-injection mandate to a generic multi-language DI approach"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 7
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr]
---

# Implementation Plan — #2249 — Generalize the dependency-injection mandate to a generic multi-language DI approach

Issue: https://github.com/michael-conrad/.opencode/issues/2249

## Goal

Add a generic "Dependency Injection (generic mandate)" section to the coding standards that states the enforceable rule "use a DI approach, not framework X," provides a curated per-language framework table in three advisory tiers, gives selection guidance driven by code analysis and spec requirements, and explicitly excludes HTML/CSS. Route the section through the guidelines index and verify agent behavior with a Two-SC behavioral enforcement test.

## Architecture

Documentation-plus-test change across 1 repo (`.opencode`), sequenced after #2243 merges:

- `.opencode/guidelines/080-code-standards.md` — new "Dependency Injection (generic mandate)" section after "Libraries & Packages" and before "Print Statements & Output", containing the generic principle (SC-1), the curated three-tier framework table (SC-2), selection guidance (SC-3), and the HTML/CSS exclusion (SC-4). This is a superset of #2243's Python-specific mandate — Python remains in the "Clear standard" tier with `dependency-injector`.
- `.opencode/guidelines/INDEX.md` — DI trigger patterns added to the `080-code-standards.md` row (SC-5).
- `.opencode/tests-v2/behaviors/` — a new behavioral enforcement test (Two-SC pattern) that dispatches a real-domain prompt via `opencode run` producing `session.yaml` (SC-6), and a clean-room sub-agent evaluation of that artifact confirming DI-mandate compliance (SC-7).

## Files

| File | Action | Repo | SC |
|------|--------|------|----|
| `.opencode/guidelines/080-code-standards.md` | Modify — add generic DI section | michael-conrad/.opencode | SC-1, SC-2, SC-3, SC-4 |
| `.opencode/guidelines/INDEX.md` | Modify — add DI trigger patterns | michael-conrad/.opencode | SC-5 |
| `.opencode/tests-v2/behaviors/` | Add — behavioral enforcement test | michael-conrad/.opencode | SC-6, SC-7 |

## Dispatch

Skills: `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`.

## Blast Radius

MINIMAL — documentation-plus-test change affecting 3 file groups in a single repo. All guideline changes are additive (new section, new trigger-pattern row) with zero modification to existing content. The behavioral test is a new artifact-only generator under `tests-v2/behaviors/`. No code, interface, or state transitions.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 1 | Generic DI principle section | CONCERN-1 | SC-1 | None | Steps 1.1-1.4 | test-driven-development, verification-before-completion |
| 2 | Curated three-tier framework table | CONCERN-2 | SC-2 | 1 | Steps 2.1-2.4 | test-driven-development, verification-before-completion |
| 3 | Selection guidance | CONCERN-3 | SC-3 | 1, 2 | Steps 3.1-3.4 | test-driven-development, verification-before-completion |
| 4 | HTML/CSS exclusion | CONCERN-4 | SC-4 | 1 | Steps 4.1-4.4 | test-driven-development, verification-before-completion |
| 5 | INDEX.md DI trigger patterns | CONCERN-5 | SC-5 | 4 | Steps 5.1-5.4 | test-driven-development, verification-before-completion |
| 6 | Behavioral test artifact generation | CONCERN-6 | SC-6 | 5 | Steps 6.1-6.4 | test-driven-development, verification-before-completion |
| 7 | Clean-room session.yaml evaluation | CONCERN-7 | SC-7 | 6 | Steps 7.1-7.4 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Phase Procedure Sections

Each phase executes one per-SC RED → GREEN → verify → COMMIT daisy-chain. Each SC maps to exactly one phase; no SC's triplet is split across phases.

### Phase 1 — Generic DI principle section (SC-1, CONCERN-1)

- [ ] 1.1. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run the SC-1 behavior scenario via `bash .opencode/tests-v2/with-test-home opencode run`; confirm the clean-room `session.yaml` shows the agent hand-rolling manual wiring (defect present — rule not yet documented).
- [ ] 1.2. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add the generic "Dependency Injection (generic mandate)" section to `.opencode/guidelines/080-code-standards.md` after "Libraries & Packages" and before "Print Statements & Output" stating the generic principle: approach problem solving and unit tests from the point of view of having an available DI approach of some worth, and use it rather than hand-rolling manual wiring where such an approach exists. The enforceable rule SHALL be "use a DI approach," not "use framework X."
- [ ] 1.3. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Two-SC pattern: SC-1a generates `session.yaml`; SC-1b clean-room sub-agent verifies the agent applied the generic DI principle.
- [ ] 1.4. **COMMIT** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md && git commit -m "<message>"`. Commit the guideline section (foundational — SC-2/SC-3/SC-4 depend on it).

### Phase 2 — Curated three-tier framework table (SC-2, CONCERN-2)

- [ ] 2.1. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run the SC-2 behavior scenario via `with-test-home`; confirm the clean-room `session.yaml` shows no tiered per-language guidance applied.
- [ ] 2.2. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add the curated three-tier framework table to the generic DI section: Clear standard (Python `dependency-injector`, C#/.NET built-in M.E.DI, Java Spring / Dagger for GWT-style, Angular/Vue/Svelte built-in), Contested (Kotlin Koin/Hilt, Scala MacWire/Guice/ZIO, Dart/Flutter get_it/provider/Riverpod, TypeScript tsyringe/InversifyJS), Non-idiomatic and guidance-only (Go, Rust, C++, Swift, Ruby, React Context/hooks, Web Components). Explicitly advisory.
- [ ] 2.3. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Two-SC pattern: SC-2a generates `session.yaml`; SC-2b clean-room sub-agent verifies the agent applied the tiered guidance appropriately for a given language.
- [ ] 2.4. **COMMIT** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md && git commit -m "<message>"`. Commit the table.

### Phase 3 — Selection guidance (SC-3, CONCERN-3)

- [ ] 3.1. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run the SC-3 behavior scenario via `with-test-home`; confirm the clean-room `session.yaml` shows arbitrary/fixed-pin framework choice.
- [ ] 3.2. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add selection guidance to the generic DI section: framework choice is driven by code analysis and spec requirements, not a fixed pin; combinations of DI approaches allowed when the framework table documents two or more idiomatic DI options for the same language.
- [ ] 3.3. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Two-SC pattern: SC-3a generates `session.yaml`; SC-3b clean-room sub-agent verifies context-driven selection.
- [ ] 3.4. **COMMIT** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md && git commit -m "<message>"`. Commit the guidance.

### Phase 4 — HTML/CSS exclusion (SC-4, CONCERN-4)

- [ ] 4.1. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run the SC-4 behavior scenario via `with-test-home`; confirm the clean-room `session.yaml` shows the agent attempting DI on markup/styling.
- [ ] 4.2. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add the explicit HTML/CSS exclusion to the generic DI section: markup and styling are not programming languages and DI guidance does not apply.
- [ ] 4.3. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Two-SC pattern: SC-4a generates `session.yaml`; SC-4b clean-room sub-agent verifies no DI attempt on markup/styling.
- [ ] 4.4. **COMMIT** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md && git commit -m "<message>"`. Commit the exclusion.

### Phase 5 — INDEX.md DI trigger patterns (SC-5, CONCERN-5)

- [ ] 5.1. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. `grep` `.opencode/guidelines/INDEX.md` for DI trigger patterns (`dependency injection`, `di`, `inject`, `container`) in the `080-code-standards.md` row; confirm 0 matches.
- [ ] 5.2. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add `dependency injection`, `di`, `inject`, `container` to the `080-code-standards.md` row in `.opencode/guidelines/INDEX.md`, preserving existing trigger patterns.
- [ ] 5.3. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. `grep` `INDEX.md` for the DI trigger patterns returns a match; existing trigger patterns preserved.
- [ ] 5.4. **COMMIT** (**inline**). Orchestrator runs `git add .opencode/guidelines/INDEX.md && git commit -m "<message>"`. Commit the `INDEX.md` row update.

### Phase 6 — Behavioral test artifact generation (SC-6, CONCERN-6)

- [ ] 6.1. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run the SC-6 behavior scenario via `with-test-home` before the rule is documented; confirm the clean-room `session.yaml` shows the agent hand-rolling manual wiring.
- [ ] 6.2. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add a behavioral enforcement test under `.opencode/tests-v2/behaviors/` (Two-SC pattern per `tests-v2/AGENTS.md` §6a) that dispatches a real-domain prompt via `opencode run` requiring the agent to design a solution/unit test where a DI approach exists, producing `session.yaml` artifacts. Real-domain prompts per §11 — not prose-recall.
- [ ] 6.3. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. SC-6a generates `session.yaml` via `opencode run`; confirm a `session.yaml` artifact is produced recording agent tool calls and decisions.
- [ ] 6.4. **COMMIT** (**inline**). Orchestrator runs `git add .opencode/tests-v2/behaviors/ && git commit -m "<message>"`. Commit the rule + test together.

### Phase 7 — Clean-room session.yaml evaluation (SC-7, CONCERN-7)

- [ ] 7.1. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Run the SC-7 scenario via `with-test-home` before the rule is documented; confirm clean-room evaluation shows no DI-mandate compliance.
- [ ] 7.2. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Add the clean-room sub-agent evaluation: read the `session.yaml` artifact (from SC-6) and verify DI-mandate compliance across at least one Clear-standard and one Contested/Non-idiomatic language, plus the HTML/CSS exclusion.
- [ ] 7.3. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Clean-room sub-agent produces a PASS verdict on `session.yaml` (from SC-6) confirming DI-mandate compliance.
- [ ] 7.4. **COMMIT** (**inline**). Orchestrator runs `git add .opencode/tests-v2/behaviors/ && git commit -m "<message>"`. Commit the rule + test together.

## Exit Criteria

- [ ] C1. Phase 1 completes: SC-1 passes verification
- [ ] C2. Phase 2 completes: SC-2 passes verification
- [ ] C3. Phase 3 completes: SC-3 passes verification
- [ ] C4. Phase 4 completes: SC-4 passes verification
- [ ] C5. Phase 5 completes: SC-5 passes verification
- [ ] C6. Phase 6 completes: SC-6 passes verification
- [ ] C7. Phase 7 completes: SC-7 passes verification
- [ ] C8. No circular dependencies in the phase DAG
- [ ] C9. Behavioral evidence for SC-1, SC-2, SC-3, SC-4, SC-6, SC-7 produced via `opencode run` + clean-room `session.yaml` evaluation
- [ ] C10. Structural evidence for SC-5 produced
- [ ] C11. Every SC maps to exactly one item

---

# Pre-Implementation Steps

- [ ] 0. **Coherence gate.** Verify the spec at `.opencode/.issues/2249/spec.md` is coherent: all 7 SCs present, evidence types recorded, no superseding/overlapping open spec for the generic DI mandate. Check for newer `[SPEC]`/`[SPEC-FIX]` issues that may supersede or overlap this scope. Confirm #2243 (the parent Python-specific mandate) has merged so the generic mandate does not contradict it. If overlap found, halt and report.
- [ ] 1. **Baseline check.** Verify trunk-tip and clean working state before any modification. Dispatch pre-work from `git-workflow-branch` so the parent repo and `.opencode/` submodule are on `$DEFAULT_BRANCH`, zero pending changes, at remote tracking tip, and submodule pointer matches committed SHA.

---

# Post-Implementation Steps

- [ ] 46. **audit** (**sub-agent**). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable against the spec.
- [ ] 47. **z3-check** (**inline**). Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...`. Run Z3 constraint solver verification of the phase DAG.
- [ ] 48. **structural-checks** (**sub-agent**). Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run finishing checklist (lint, typecheck, format).
- [ ] 49. **pre-pr-gate** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts. BLOCK if any FAIL. Confirm all SCs pass before PR creation.
- [ ] 50. **regression-check** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR.
- [ ] 51. **review-prep** (**sub-agent**). Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context.
- [ ] 52. **create-pr** (**sub-agent**). Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request for the guideline and test changes. Include the `.opencode/` submodule pointer update alongside the changes in the same commit if the pointer is dirty.
- [ ] 53. **exec-summary** (**sub-agent**). Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary and append lifecycle event.

---

## Lifecycle Events

| Timestamp | Event | Notes |
|-----------|-------|-------|
| 2026-08-11 | `plan_created` | Plan created at `.opencode/.issues/2249/plan.md`; 7 phases |
| 2026-08-11 | `plan_revised` | Validation FAIL fix: added per-phase procedure sections (Steps 1.1-7.4) with numbered RED/GREEN/verify/COMMIT steps; split CONCERN-6 into CONCERN-6 (artifact generation) and CONCERN-7 (clean-room evaluation) in concern-map.yaml to resolve DUPLICATE_CONCERN and CONCERN_NOT_IN_CONCERN_MAP findings |
