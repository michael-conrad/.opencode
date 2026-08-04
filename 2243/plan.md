---
plan_schema_version: 1
issue: 2243
title: "Add dependency-injector mandate to Python coding standards"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr]
---

# Plan — Add dependency-injector mandate to Python coding standards

Issue: https://github.com/michael-conrad/.opencode/issues/2243

## Goal

Add a mandatory "Dependency Injection" section to the Python coding standards, routing it through the guidelines index. The mandate standardizes dependency wiring across Python projects on `dependency-injector`, with an explicit carveout for `.opencode/` infrastructure tools.

## Architecture

Documentation-only change across 1 repo:

- `.opencode/guidelines/080-code-standards.md` — new "Dependency Injection" section (SC-1) containing the `.opencode/` carveout (SC-3)
- `.opencode/guidelines/INDEX.md` — DI trigger patterns added to the `080-code-standards.md` row (SC-2)

## Files

| File | Action | Repo | SC |
|------|--------|------|----|
| `.opencode/guidelines/080-code-standards.md` | Modify — add DI section | michael-conrad/.opencode | SC-1, SC-3 |
| `.opencode/guidelines/INDEX.md` | Modify — add trigger patterns | michael-conrad/.opencode | SC-2 |

## Dispatch

Skills: `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`.

## Blast Radius

MINIMAL — documentation-only change affecting 2 files in a single repo. All changes are additive (new section, new trigger-pattern row) with zero modification to existing content. No code, interface, or state transitions.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 1 | Guideline updates (080-code-standards.md, INDEX.md) | C1, C2 | SC-1, SC-2, SC-3 | None | Items 1, 2, 3 | test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. Phase 1 completes: SC-1, SC-2, SC-3 pass verification
- [ ] C2. No circular dependencies in the phase DAG
- [ ] C3. Behavioral evidence for SC-1 produced via `opencode run`
- [ ] C4. Structural evidence for SC-2, SC-3 produced
- [ ] C5. Every SC maps to exactly one item

---

# Pre-Implementation Steps

- [ ] 0. **Coherence gate.** Verify the spec at `.opencode/.issues/2243/spec.md` (body in `remote.md`) is coherent: all 3 SCs present, evidence types recorded, no superseding/overlapping open spec for the DI mandate. Check for newer `[SPEC]`/`[SPEC-FIX]` issues that may supersede or overlap this scope. If overlap found, halt and report.
- [ ] 1. **Baseline check.** Verify trunk-tip and clean working state before any modification. Dispatch pre-work from `git-workflow-branch` so the parent repo and `.opencode/` submodule are on `$DEFAULT_BRANCH`, zero pending changes, at remote tracking tip, and submodule pointer matches committed SHA.

---

# Phase 1 — Guideline updates (080-code-standards.md, INDEX.md)

Concern: C1, C2. Files: `.opencode/guidelines/080-code-standards.md`, `.opencode/guidelines/INDEX.md`. SCs: SC-1, SC-2, SC-3. Dependencies: None. Repo: michael-conrad/.opencode.

Entry condition: Baseline check passed. Exit condition: Items 1, 2, 3 all PASS.

**Cost frame:** Verifying the DI mandate through a behavioral test costs minutes of `opencode run` execution. Skipping it means agents keep reinventing per-project wiring — the behavioral defect (mandate not followed) ships to production and costs 1000× more to fix across every Python project adopting these standards.

## Code Path Coverage

- `.opencode/guidelines/080-code-standards.md` — locate "Libraries & Packages" section (before "Print Statements & Output"); insert new "Dependency Injection" section after it
- `.opencode/guidelines/INDEX.md` — locate `080-code-standards.md` row; append DI trigger patterns

## Cross-Cutting SCs

- SC-1 and SC-3 share concern C1 — SC-3 is contained within SC-1 (the carveout is documented inside the DI section, not as a separate deliverable)
- Submodule workflow: Phase 1 files live in the `.opencode/` submodule — requires a separate PR to michael-conrad/.opencode

## Interface Boundaries

- `.opencode/guidelines/080-code-standards.md` ↔ `.opencode/guidelines/INDEX.md` (C1 ↔ C2): COMPATIBLE — INDEX.md routes agents to the DI section via trigger patterns; new section must match existing formatting/tone/structure
- DI section placement within `080-code-standards.md` (C1): COMPATIBLE — inserted after "Libraries & Packages", before "Print Statements & Output"; no existing-content modification

## State Transitions

- None. All SCs are documentation/static-content changes. No code paths, databases, or runtime state affected.

## Step-by-step

- [ ] 2. **pre-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`. Run regression test patterns before the first RED phase. Confirm the baseline behavioral and structural test suite is green.
- [ ] 3. **Verify pre-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Confirm pre-regression results are clean before proceeding to RED.

### Item 1 — SC-1 (behavioral): DI section in 080-code-standards.md

- [ ] 4. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a behavioral enforcement test that FAILS because the "Dependency Injection" mandate does not yet exist. The test sends a real-domain prompt via `opencode run` and asserts, via stderr, that an agent writing Python code dispatches to and follows the DI mandate in `080-code-standards.md`. RED must fail before GREEN begins.
- [ ] 5. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by adding the "Dependency Injection" section to `.opencode/guidelines/080-code-standards.md` after "Libraries & Packages" and before "Print Statements & Output". The section must cover: what DI is, why it is required, the mandated library (`dependency-injector`), usage patterns, and the `.opencode/` carveout. No scope creep — only the minimum change needed for SC-1.
- [ ] 6. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 7. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-1 against its success criterion. Behavioral evidence: `opencode run` stderr shows the agent following the DI mandate. PASS requires clean behavioral evidence — a non-clean pass (DONE_WITH_CONCERNS) is coerced to FAIL.
- [ ] 8. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md <test files> && git commit -m "<message>"`. Test and implementation committed as one atomic slice. No co-author trailer during implementation commits.

### Item 2 — SC-2 (structural): INDEX.md trigger patterns

- [ ] 9. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a failing structural test asserting `.opencode/guidelines/INDEX.md` contains DI-related trigger patterns (`dependency injection`, `di`, `inject`, `container`) in the `080-code-standards.md` row. Fails because the trigger patterns are not yet present.
- [ ] 10. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by appending the DI-related trigger patterns to the `080-code-standards.md` row in `.opencode/guidelines/INDEX.md`. No scope creep.
- [ ] 11. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 12. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-2: assert the `080-code-standards.md` row in INDEX.md contains the DI trigger patterns. Structural evidence suffices.
- [ ] 13. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/INDEX.md <test files> && git commit -m "<message>"`. Atomic slice.

### Item 3 — SC-3 (structural): carveout within DI section

- [ ] 14. **RED** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a failing structural test asserting the DI section in `.opencode/guidelines/080-code-standards.md` documents the carveout paths (`.opencode/tools/`, `.opencode/scripts/`, `.opencode/skills/*/scripts/`). Fails because the carveout is not yet documented.
- [ ] 15. **GREEN** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Make the RED test PASS by documenting the `.opencode/` infrastructure-tools carveout within the DI section (contained within SC-1's section). No scope creep.
- [ ] 16. **post-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change.
- [ ] 17. **verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-3: assert the carveout paths are documented within the DI section. Structural evidence suffices.
- [ ] 18. **commit-inline** (**inline**). Orchestrator runs `git add .opencode/guidelines/080-code-standards.md <test files> && git commit -m "<message>"`. Atomic slice.

## Phase Completion Block

- [ ] 19. **VbC verification assertions** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Assert SC-1 (behavioral, clean), SC-2 (structural), SC-3 (structural) all PASS. Any FAIL (including EVIDENCE_TYPE_MISMATCH for SC-1's behavioral requirement) halts the phase.

## Concern Transition

Phase 1 delivers the guideline mandate (SC-1), index routing (SC-2), and carveout (SC-3). Plan is complete.

---

# Post-Implementation Steps

- [ ] 20. **audit** (**sub-agent**). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable against the spec.
- [ ] 21. **z3-check** (**inline**). Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...`. Run Z3 constraint solver verification of the phase DAG.
- [ ] 22. **structural-checks** (**sub-agent**). Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run finishing checklist (lint, typecheck, format).
- [ ] 23. **pre-pr-gate** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts. BLOCK if any FAIL. Confirm all SCs pass before PR creation.
- [ ] 24. **regression-check** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR.
- [ ] 25. **review-prep** (**sub-agent**). Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context.
- [ ] 26. **create-pr** (**sub-agent**). Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request for the guideline changes. Include the `.opencode/` submodule pointer update alongside the guideline changes in the same commit if the pointer is dirty.
- [ ] 27. **exec-summary** (**sub-agent**). Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary and append lifecycle event.

---

## Lifecycle Events

| Timestamp | Event | Notes |
|-----------|-------|-------|
| 2026-08-04T18:20:36Z | `plan_created` | Plan created at `.opencode/.issues/2243/plan.md`; 1 phase
| 2026-08-04 | `plan_revised` | Phase 2 (Butter root AGENTS.md, SC-3) removed; SC-4 renumbered to SC-3 |
