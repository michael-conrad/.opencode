---
plan_schema_version: "1.0"
issue: 2256
title: "Plan skill card remediation: split canon, tool invocations, plan/solve scope, plan-fidelity basis, writing-plans consistency"
dispatch:
  - test-driven-development
---

# Plan — Issue #2256

**Issue:** [.opencode#2256](https://github.com/michael-conrad/.opencode/issues/2256)

## Goal

Resolve the six defect clusters in the plan skill card set (`plan`, `solve`, `writing-plans`, `audit` plan-fidelity roles) and the plan-structure reference documents: split plan-structure authority, runtime-broken `solve`/`plan` tool invocations, plan/solve scope collision, phantom clean-room plan-fidelity basis, and writing-plans internal inconsistencies. Each success criterion maps one-to-one to a prescriptive resolution.

## Architecture

The plan is a documentation/skill-card remediation. All changes are confined to agent-facing markdown under `.opencode/`. No `src/` code changes, no `tools/solve` or `tools/plan` CLI changes, no new runtime features. The plan is organized into six phases driven by the dependency DAG: P0 (analytical artifacts) is foundational; P1 (plan-structure authority) precedes P5 (plan-fidelity); P4 (tool invocations) precedes P6 (writing-plans consistency).

## Files

- `.opencode/reference/plan-structure-standards.md`
- `.opencode/skills/writing-plans/reference/plan-artifact-format.md` (deleted)
- `.opencode/skills/writing-plans/SKILL.md`
- `.opencode/skills/writing-plans/tasks/create.md`
- `.opencode/skills/writing-plans/tasks/research.md`
- `.opencode/skills/writing-plans/tasks/completion.md`
- `.opencode/skills/writing-plans/tasks/handoff.md`
- `.opencode/skills/writing-plans/contracts/*-output.yaml`
- `.opencode/skills/plan/SKILL.md`
- `.opencode/skills/solve/SKILL.md`
- `.opencode/skills/audit/tasks/plan-fidelity-{evaluator,arbiter,investigator,validator}.md`
- `.opencode/.issues/2256/artifacts/*` (analytical artifacts)

## Dispatch

All per-item RED/GREEN steps dispatch the `test-driven-development` skill via the canonical string `execute red task from test-driven-development` / `execute green task from test-driven-development`. Verification dispatches `verification-before-completion`. Post-implementation gates dispatch `audit`, `finishing-a-development-branch`, `git-workflow-pr`, and `completion-core` per the implementation-workflow reference card.

## Blast Radius

The blast radius is confined to the plan skill card set and its reference documents. Affected impact zones: plan-structure authority consumers (`writing-plans/tasks/create.md`, plan-fidelity tasks), tool-invocation consumers (`writing-plans/tasks/research.md`), skill-description routers (`plan/SKILL.md`, `solve/SKILL.md`), plan-fidelity audit chain (`audit/tasks/plan-fidelity-*.md`), and writing-plans internal consistency (`writing-plans/SKILL.md`, `tasks/*.md`, `contracts/*-output.yaml`). No runtime code, tool CLI, or production data is affected.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 1 | Analytical artifacts generation | Generate the seven analytical artifacts retroactively | SC-19 | — | 1–25 | test-driven-development |
| 2 | Plan-structure authority consolidation | Resolve the split plan-structure canon | SC-1a, SC-1b, SC-1c, SC-2, SC-3 | Phase 1 | 26–50 | test-driven-development |
| 3 | Plan/solve scope and ownership | Resolve the plan/solve scope collision and state/fallback ownership | SC-8, SC-9 | Phase 1 | 51–70 | test-driven-development |
| 4 | Tool invocation remediation | Fix the runtime-broken solve/plan tool invocations and add the BLOCK gate | SC-4, SC-5, SC-6, SC-7 | Phase 1 | 71–90 | test-driven-development |
| 5 | Plan-fidelity audit model | Adopt the single-plan evaluation model and remove the phantom basis | SC-10a, SC-10b | Phase 1, Phase 2 | 91–110 | test-driven-development |
| 6 | Writing-plans internal consistency | Fix the writing-plans internal inconsistencies | SC-11, SC-12, SC-13, SC-14, SC-15, SC-16a, SC-16b, SC-16c, SC-16d, SC-17, SC-18 | Phase 1, Phase 4 | 111–160 | test-driven-development |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. All 25 success criteria (SC-1a through SC-19) pass with 100% clean PASS.
- [ ] C2. `plan-artifact-format.md` is absent from the codebase (SC-1a).
- [ ] C3. `reference/plan-structure-standards.md` is the single canonical plan-structure authority referenced by `create.md` and plan-fidelity tasks (SC-1b).
- [ ] C4. `writing-plans/SKILL.md` File Structure no longer lists `plan-artifact-format.md` (SC-1c).
- [ ] C5. No plan frontmatter declares `dispatch:` (SC-2).
- [ ] C6. `plan_schema_version` is a quoted string in `plan-structure-standards.md` (SC-3).
- [ ] C7. The `solve model` invocation passes `--query True`, not `sat` (SC-4).
- [ ] C8. The `solve check` invocation passes `--state-path {issues_prefix}/{N}/artifacts/state.yaml`, not `state-analysis.yaml` (SC-5).
- [ ] C9. The `plan plan` invocation uses `--problem`, not `--contract-path`/`--output` (SC-6).
- [ ] C10. `research.md` BLOCKs with `INCOMPLETE_SPEC` on incomplete spec before tool invocation (SC-7).
- [ ] C11. `plan/SKILL.md` and `solve/SKILL.md` descriptions no longer share the colliding scope language (SC-8).
- [ ] C12. The `state` task is owned by `plan` and the `fallback` task is owned by `solve` (SC-9).
- [ ] C13. Plan-fidelity tasks use a single-plan (plan-vs-spec) evaluation model (SC-10a).
- [ ] C14. Plan-fidelity tasks have no `plan-fidelity.md` reference (SC-10b).
- [ ] C15. `writing-plans/SKILL.md` declares task count 9 (SC-11).
- [ ] C16. `writing-plans/SKILL.md` and `tasks/create.md` use per-item TDD cycle terminology, not "per-task cycle" (SC-12).
- [ ] C17. `writing-plans/tasks/create.md` body has no JSON/YAML code blocks (SC-13).
- [ ] C18. All 9 output contract templates include `blocker_reason` (SC-14).
- [ ] C19. `verify-plan-pipeline` is wired between `validate` PASS and `completion` (SC-15).
- [ ] C20. Completion appends the lifecycle event to the `completion-core` manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` (SC-16a).
- [ ] C21. Completion reports the executive summary in chat in the completion-core format (`**Summary:**`, `**Outcome:**`, URL ALWAYS LAST) (SC-16b).
- [ ] C22. Completion does not append lifecycle events to `plan.md` or `spec.md` (SC-16c).
- [ ] C23. Completion does not post lifecycle events as human-facing issue comments (SC-16d).
- [ ] C24. `research.md` reads `sc-summary.yaml` from `{issues_prefix}/{N}/sc-summary.yaml` (SC-17).
- [ ] C25. `handoff.md` references the `apply-label` approval-gate task (SC-18).
- [ ] C26. All seven analytical artifacts exist at `.opencode/.issues/2256/artifacts/` (SC-19).

---

# Pre-Implementation

- [ ] 1. **Coherence gate.** Verify the spec is coherent: all 25 SCs are atomic, each maps to exactly one item, and the phase DAG has no circular dependencies. Confirm the structure artifact's phase ordering matches the dependency contract. (**inline**)
  - Verify SC-to-item mapping is one-to-one.
  - Verify the phase DAG (P0→P1/P3/P4/P5/P6, P1→P5, P4→P6) is acyclic.
  - Confirm the post-#2254 dependency: issue #2254 MUST be implemented before dependent SCs (SC-8/9/10a/10b/15/16/17) are verified.
- [ ] 2. **Baseline check.** Verify the current on-disk state matches the spec's documented sources before any modification. (**inline**)
  - Confirm `plan-artifact-format.md` exists at `.opencode/skills/writing-plans/reference/`.
  - Confirm `plan-structure-standards.md` exists at `.opencode/reference/` and declares `dispatch:` and integer `plan_schema_version`.
  - Confirm `research.md` Steps 10-12 contain the broken invocations.
  - Confirm `plan/SKILL.md` and `solve/SKILL.md` share the colliding scope language.
  - Confirm `writing-plans/SKILL.md` declares task count 7 and `verify-plan-pipeline` is unwired.
  - Confirm the 7 analytical artifacts are absent from `.opencode/.issues/2256/artifacts/`.

---

# Phase 1 — Analytical artifacts generation

**Concern:** Generate the seven analytical artifacts retroactively so the artifact cross-reference check can run (SC-19).

**Files:** `.opencode/.issues/2256/artifacts/*`

**SCs:** SC-19

**Dependencies:** None

**Entry condition:** Coherence gate and baseline check passed.

**Exit condition:** All seven analytical artifacts exist at `.opencode/.issues/2256/artifacts/`.

**Code Path Coverage:** The analytical artifacts are generated from the plan skill deck: blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment.

**Cross-Cutting SCs:** SC-19 is foundational — every other phase's verification depends on the analytical baseline it produces.

**Interface Boundaries:** The artifacts are consumed by the artifact cross-reference check and by downstream phase verification.

**State Transitions:** From artifact-absent to artifact-present at `.opencode/.issues/2256/artifacts/`.

**Cost frame:** Generating the seven analytical artifacts costs one artifact-generation pass over the plan skill deck. Skipping leaves the artifact cross-reference check unable to run, so plan-fidelity and validate steps evaluate against a missing analytical baseline.

## Step-by-step

- [ ] 3. **Pre-regression.** Run regression test patterns before the RED phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-*`.
- [ ] 4. **Pre-regression verify.** Verify the pre-regression results. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-verify-*`.

### Item 25 (SC-19): Generate the analytical artifacts retroactively

- [ ] 5. **RED.** Write a failing enforcement test asserting the seven analytical artifact files exist at `.opencode/.issues/2256/artifacts/`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, and testability-assessment files exist.
  - The test FAILs because the artifacts are currently absent.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 6. **GREEN.** Generate the seven analytical artifacts and store them at `.opencode/.issues/2256/artifacts/`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Generate blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, and testability-assessment from the current plan skill deck.
  - No scope creep — only the minimum change needed to make the RED test pass.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 7. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 8. **Verify.** Verify the implementation against SC-19. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify all seven analytical artifact files exist at `.opencode/.issues/2256/artifacts/`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 9. **Commit.** Stage and commit the artifacts. (**inline**)
  - Run `git add .opencode/.issues/2256/artifacts/* && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.
  - No co-author trailers during implementation commits.

**Phase completion block:** Verify SC-19 passes — all seven analytical artifact files exist at `.opencode/.issues/2256/artifacts/`.

**Concern transition:** The analytical baseline is established; proceed to the plan-structure authority consolidation, plan/solve scope, tool invocation remediation, plan-fidelity, and writing-plans consistency phases.

---

# Phase 2 — Plan-structure authority consolidation

**Concern:** Resolve the split plan-structure authority to `plan-structure-standards.md` as the single canonical authority, remove the `dispatch` field, and string `plan_schema_version` (SC-1a, SC-1b, SC-1c, SC-2, SC-3).

**Files:** `.opencode/reference/plan-structure-standards.md`, `.opencode/skills/writing-plans/reference/plan-artifact-format.md` (deleted), `.opencode/skills/writing-plans/SKILL.md`, `.opencode/skills/writing-plans/tasks/create.md`

**SCs:** SC-1a, SC-1b, SC-1c, SC-2, SC-3

**Dependencies:** Phase 1

**Entry condition:** Phase 1 complete — analytical artifacts exist.

**Exit condition:** `plan-structure-standards.md` is the single canonical authority; `plan-artifact-format.md` is deleted; `dispatch` field removed; `plan_schema_version` is a string.

**Code Path Coverage:** The plan-structure authority is consumed by `writing-plans/tasks/create.md` and the plan-fidelity tasks.

**Cross-Cutting SCs:** SC-1b establishes the single authority that P5 (plan-fidelity) reads.

**Interface Boundaries:** `plan-structure-standards.md` is the canonical plan-structure authority; `plan-artifact-format.md` is deleted outright with no reconciliation.

**State Transitions:** From split authority (two reference docs) to single authority (`plan-structure-standards.md`).

**Cost frame:** Consolidating the plan-structure authority costs one read of both reference docs and updating consumer references. Skipping leaves the split authority in place, so consumers read a competing spec that fails downstream audits.

## Step-by-step

- [ ] 10. **Pre-regression.** Run regression test patterns before the RED phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-*`.
- [ ] 11. **Pre-regression verify.** Verify the pre-regression results. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-verify-*`.

### Item 1 (SC-1a): Delete plan-artifact-format.md

- [ ] 12. **RED.** Write a failing enforcement test asserting `plan-artifact-format.md` is absent from the codebase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the file is absent.
  - The test FAILs because the file is currently present.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 13. **GREEN.** Delete `skills/writing-plans/reference/plan-artifact-format.md`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Delete the file outright; no reconciliation or repointing is performed.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 14. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 15. **Verify.** Verify the implementation against SC-1a. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify `plan-artifact-format.md` is absent from the codebase.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 16. **Commit.** Stage and commit the deletion. (**inline**)
  - Run `git add skills/writing-plans/reference/plan-artifact-format.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 2 (SC-1b): Establish plan-structure-standards.md as the single authority

- [ ] 17. **RED.** Write a failing enforcement test asserting `plan-structure-standards.md` is referenced by `create.md` and plan-fidelity tasks as the sole authority. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the single-authority reference.
  - The test FAILs on the current split authority.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 18. **GREEN.** Update consumers to reference `reference/plan-structure-standards.md` as the single canonical authority. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Update `writing-plans/tasks/create.md` and the plan-fidelity tasks to reference `reference/plan-structure-standards.md` as the sole authority.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 19. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 20. **Verify.** Verify the implementation against SC-1b. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify `plan-structure-standards.md` is referenced by `create.md` and the plan-fidelity tasks.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 21. **Commit.** Stage and commit the consumer updates. (**inline**)
  - Run `git add reference/plan-structure-standards.md skills/writing-plans/tasks/create.md skills/audit/tasks/plan-fidelity-*.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 3 (SC-1c): Remove plan-artifact-format.md from SKILL.md File Structure

- [ ] 22. **RED.** Write a failing enforcement test asserting `writing-plans/SKILL.md` File Structure no longer lists `plan-artifact-format.md`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the File Structure listing is absent.
  - The test FAILs on the current listing.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 23. **GREEN.** Remove `plan-artifact-format.md` from the `writing-plans/SKILL.md` File Structure listing. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove the dangling File Structure listing pointing at the deleted file.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 24. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 25. **Verify.** Verify the implementation against SC-1c. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify `writing-plans/SKILL.md` File Structure no longer lists `plan-artifact-format.md`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 26. **Commit.** Stage and commit the SKILL.md update. (**inline**)
  - Run `git add skills/writing-plans/SKILL.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 4 (SC-2): Remove the dispatch field from plan frontmatter

- [ ] 27. **RED.** Write a failing enforcement test asserting no plan frontmatter declares `dispatch:`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the `dispatch:` field is absent from plan frontmatter.
  - The test FAILs on the current `plan-structure-standards.md`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 28. **GREEN.** Remove the `dispatch: [<skill-names>]` field from the plan frontmatter. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove the `dispatch:` field from the plan frontmatter in `reference/plan-structure-standards.md`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 29. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 30. **Verify.** Verify the implementation against SC-2. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify no plan frontmatter declares `dispatch:`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 31. **Commit.** Stage and commit the frontmatter update. (**inline**)
  - Run `git add reference/plan-structure-standards.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 5 (SC-3): String plan_schema_version

- [ ] 32. **RED.** Write a failing enforcement test asserting `plan_schema_version` is a string. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts `plan_schema_version` is a quoted string.
  - The test FAILs on the current integer `1`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 33. **GREEN.** Change the `plan_schema_version` value in the plan frontmatter of `reference/plan-structure-standards.md` from the integer form to the quoted-string form. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Change `plan_schema_version: 1` to `plan_schema_version: "1.0"`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 34. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 35. **Verify.** Verify the implementation against SC-3. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify `plan_schema_version` is a quoted string.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 36. **Commit.** Stage and commit the frontmatter update. (**inline**)
  - Run `git add reference/plan-structure-standards.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify SC-1a, SC-1b, SC-1c, SC-2, SC-3 all pass — `plan-artifact-format.md` deleted, `plan-structure-standards.md` is the single authority, `dispatch` field removed, `plan_schema_version` is a string.

**Concern transition:** The plan-structure authority is consolidated; proceed to the plan-fidelity audit model phase (which reads the single authority).

---

# Phase 3 — Plan/solve scope and ownership

**Concern:** Resolve the plan/solve scope collision and clarify state/fallback ownership (SC-8, SC-9).

**Files:** `.opencode/skills/plan/SKILL.md`, `.opencode/skills/solve/SKILL.md`

**SCs:** SC-8, SC-9

**Dependencies:** Phase 1

**Entry condition:** Phase 1 complete — analytical artifacts exist.

**Exit condition:** `plan/SKILL.md` and `solve/SKILL.md` descriptions are mutually exclusive; `state` is owned by `plan` and `fallback` is owned by `solve`.

**Code Path Coverage:** The skill descriptions are consumed by the agent-intent dispatch router.

**Cross-Cutting SCs:** SC-8/9 depend on the post-#2254 role-card state; #2256 does not duplicate #2254's role-card work.

**Interface Boundaries:** `plan` and `solve` skill descriptions must be mutually exclusive in scope.

**State Transitions:** From shared scope language to mutually exclusive descriptions.

**Cost frame:** Resolving the scope collision costs one read of both descriptions. Skipping means agents misroute between plan and solve, selecting the wrong skill for the wrong task.

## Step-by-step

- [ ] 37. **Pre-regression.** Run regression test patterns before the RED phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-*`.
- [ ] 38. **Pre-regression verify.** Verify the pre-regression results. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-verify-*`.

### Item 10 (SC-8): Resolve plan/solve scope collision in skill descriptions

- [ ] 39. **RED.** Write a failing behavioral enforcement test asserting `plan` and `solve` descriptions no longer share the colliding scope language. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that could route to plan or solve and asserts the agent dispatches exactly one skill.
  - The test FAILs on the current shared scope language.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 40. **GREEN.** Rewrite `plan/SKILL.md` and `solve/SKILL.md` descriptions to be mutually exclusive. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Narrow the `plan` description to plan-artifact generation and the `solve` description to constraint solving.
  - Remove the shared scope language `validating workflow constraints, verifying state against contracts, proving theorems, or checking dependency ordering`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 41. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 42. **Verify.** Verify the implementation against SC-8. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that the agent dispatches exactly one skill (no shared scope language).
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 43. **Commit.** Stage and commit the description updates. (**inline**)
  - Run `git add skills/plan/SKILL.md skills/solve/SKILL.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 11 (SC-9): Clarify state/fallback ownership between plan and solve

- [ ] 44. **RED.** Write a failing behavioral enforcement test asserting the `state` task is owned by `plan` and the `fallback` task is owned by `solve`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers a state/fallback operation and asserts the single owning skill dispatches the task.
  - The test FAILs on the current overlap.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 45. **GREEN.** Clarify state/fallback ownership so `state` is owned by `plan` and `fallback` is owned by `solve`, with neither skill claiming the other's task. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Update `plan/SKILL.md` to own the `state` task and `solve/SKILL.md` to own the `fallback` task.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 46. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 47. **Verify.** Verify the implementation against SC-9. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that the single owning skill dispatches the task (not both skills).
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 48. **Commit.** Stage and commit the ownership updates. (**inline**)
  - Run `git add skills/plan/SKILL.md skills/solve/SKILL.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify SC-8 and SC-9 pass — descriptions mutually exclusive, `state` owned by `plan`, `fallback` owned by `solve`.

**Concern transition:** The plan/solve scope and ownership are resolved; proceed to the tool invocation remediation phase.

---

# Phase 4 — Tool invocation remediation

**Concern:** Fix the three runtime-broken `solve`/`plan` tool invocations in the research step and add a BLOCK-on-incomplete-spec gate (SC-4, SC-5, SC-6, SC-7).

**Files:** `.opencode/skills/writing-plans/tasks/research.md`

**SCs:** SC-4, SC-5, SC-6, SC-7

**Dependencies:** Phase 1

**Entry condition:** Phase 1 complete — analytical artifacts exist.

**Exit condition:** The `solve model`, `solve check`, and `plan plan` invocations use corrected CLI arguments; the BLOCK-on-incomplete-spec gate is in place before Z3/planner invocation.

**Code Path Coverage:** The research step's Z3/planner invocations are the runtime-broken code paths.

**Cross-Cutting SCs:** SC-4/5/6/7 and SC-17 (P6) all edit `research.md`; P6 MUST run after P4.

**Interface Boundaries:** The `solve` and `plan` CLI interfaces MUST remain unchanged (R-20).

**State Transitions:** From broken tool invocations to corrected invocations with a BLOCK gate.

**Cost frame:** Fixing the tool invocations costs one behavioral test run each. Skipping means every research step passes `sat` as a query, reads an analytical artifact instead of a state file, or never runs the plan tool — shipping unusable dependency contracts.

## Step-by-step

- [ ] 49. **Pre-regression.** Run regression test patterns before the RED phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-*`.
- [ ] 50. **Pre-regression verify.** Verify the pre-regression results. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-verify-*`.

### Item 6 (SC-4): Fix the solve model invocation in research.md

- [ ] 51. **RED.** Write a failing behavioral enforcement test asserting research.md Step 10 passes a valid Z3 boolean query expression, not `sat`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers research.md Step 10 and asserts stderr shows the solve model invocation passes `--query True` (evaluating to a `z3.BoolRef`), not the literal `sat`.
  - The test FAILs on the current invocation.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 52. **GREEN.** Fix the `solve model` invocation in `writing-plans/tasks/research.md` Step 10 so its `--query` argument is a valid Z3 boolean expression (evaluating to a `z3.BoolRef`) instead of the literal `sat`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Change the `--query` argument to `--query True`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 53. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 54. **Verify.** Verify the implementation against SC-4. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows the solve model invocation passes `--query True`, not `sat`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 55. **Commit.** Stage and commit the research.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/research.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 7 (SC-5): Fix the solve check invocation in research.md

- [ ] 56. **RED.** Write a failing behavioral enforcement test asserting solve check uses a real solve state file, not `state-analysis.yaml`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers research.md Step 11 and asserts stderr shows the solve check invocation binds `--state-path` to the real solve state file `{issues_prefix}/{N}/artifacts/state.yaml`, not the `state-analysis.yaml` analytical artifact.
  - The test FAILs on the current invocation.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 57. **GREEN.** Fix the `solve check` invocation in `writing-plans/tasks/research.md` Step 11 so its `--state-path` argument points at a real solve state file instead of the `state-analysis.yaml` analytical artifact. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Change the `--state-path` argument to `{issues_prefix}/{N}/artifacts/state.yaml`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 58. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 59. **Verify.** Verify the implementation against SC-5. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows the solve check invocation binds `--state-path` to the real solve state file.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 60. **Commit.** Stage and commit the research.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/research.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 8 (SC-6): Fix the plan plan invocation in research.md

- [ ] 61. **RED.** Write a failing behavioral enforcement test asserting plan plan uses the `--problem` flag, not `--contract-path`/`--output`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers research.md Step 12 and asserts stderr shows the plan plan invocation uses the `--problem` flag bound to `{issues_prefix}/{N}/artifacts/plan-problem.yaml`, not `--contract-path`/`--output`.
  - The test FAILs on the current invocation.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 62. **GREEN.** Fix the `plan plan` invocation in `writing-plans/tasks/research.md` Step 12 so it uses the `--problem` flag (bound to a YAML problem file) instead of `--contract-path`/`--output`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Change the invocation to use `--problem {issues_prefix}/{N}/artifacts/plan-problem.yaml`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 63. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 64. **Verify.** Verify the implementation against SC-6. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows the plan plan invocation uses the `--problem` flag.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 65. **Commit.** Stage and commit the research.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/research.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 9 (SC-7): Add BLOCK-on-incomplete-spec gate to research.md

- [ ] 66. **RED.** Write a failing behavioral enforcement test asserting research.md BLOCKs on incomplete spec before tool invocation. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt with an incomplete spec and asserts stderr shows research.md BLOCKs with `INCOMPLETE_SPEC` rather than invoking tools.
  - The test FAILs on the current absence of the gate.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 67. **GREEN.** Add a BLOCK-on-incomplete-spec gate with diagnose→remediate→escalate before the Z3/planner invocations. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Add the gate returning BLOCKED with reason `INCOMPLETE_SPEC` when the analysis summary, sc-summary, or dependency contract is missing.
  - The gate follows diagnose→remediate→escalate.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 68. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 69. **Verify.** Verify the implementation against SC-7. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows research.md BLOCKs with `INCOMPLETE_SPEC` on incomplete spec.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 70. **Commit.** Stage and commit the research.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/research.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify SC-4, SC-5, SC-6, SC-7 all pass — corrected tool invocations and BLOCK gate in place.

**Concern transition:** The tool invocations are remediated; proceed to the writing-plans internal consistency phase (which edits the same research.md file for SC-17).

---

# Phase 5 — Plan-fidelity audit model

**Concern:** Adopt the single-plan evaluation model and remove the phantom clean-room basis and the `plan-fidelity.md` reference (SC-10a, SC-10b).

**Files:** `.opencode/skills/audit/tasks/plan-fidelity-{evaluator,arbiter,investigator,validator}.md`

**SCs:** SC-10a, SC-10b

**Dependencies:** Phase 1, Phase 2

**Entry condition:** Phase 1 and Phase 2 complete — analytical artifacts exist and `plan-structure-standards.md` is the single authority.

**Exit condition:** Plan-fidelity tasks use a single-plan (plan-vs-spec) evaluation model with no clean-room reference and no `plan-fidelity.md` reference.

**Code Path Coverage:** The plan-fidelity audit chain (evaluator, arbiter, investigator, validator) is the affected code path.

**Cross-Cutting SCs:** SC-10a/10b build on the post-#2254 role-card state; #2256 does not duplicate #2254's role-card work.

**Interface Boundaries:** Plan-fidelity reads `plan-structure-standards.md` as the single canonical authority.

**State Transitions:** From phantom clean-room basis to single-plan (plan-vs-spec) evaluation model.

**Cost frame:** Adopting the single-plan model costs one grep of the plan-fidelity chain. Skipping means the audit evaluates against a phantom plan that does not exist, producing arbitrary verdicts.

## Step-by-step

- [ ] 71. **Pre-regression.** Run regression test patterns before the RED phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-*`.
- [ ] 72. **Pre-regression verify.** Verify the pre-regression results. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-verify-*`.

### Item 12 (SC-10a): Adopt single-plan model in plan-fidelity

- [ ] 73. **RED.** Write a failing behavioral enforcement test asserting plan-fidelity tasks use a single-plan model with no clean-room references. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers a plan-fidelity audit and asserts stderr shows the audit evaluates plan-vs-spec (no clean-room reference).
  - The test FAILs on the current phantom basis.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 74. **GREEN.** Adopt a single-plan evaluation model (plan-vs-spec) in evaluator/arbiter/investigator/validator. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove the phantom clean-room comparison basis from the plan-fidelity tasks.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 75. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 76. **Verify.** Verify the implementation against SC-10a. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows the audit evaluates plan-vs-spec (no clean-room reference).
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 77. **Commit.** Stage and commit the plan-fidelity task updates. (**inline**)
  - Run `git add skills/audit/tasks/plan-fidelity-{evaluator,arbiter,investigator,validator}.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 13 (SC-10b): Remove plan-fidelity.md reference

- [ ] 78. **RED.** Write a failing behavioral enforcement test asserting plan-fidelity tasks have no `plan-fidelity.md` reference. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers a plan-fidelity audit and asserts stderr shows no dispatch to `plan-fidelity.md`.
  - The test FAILs on the current reference.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 79. **GREEN.** Remove the reference to the non-existent `plan-fidelity.md` main task file. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove the residual `plan-fidelity.md` reference without redoing #2254's role-card naming work.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 80. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 81. **Verify.** Verify the implementation against SC-10b. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows no dispatch to `plan-fidelity.md`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 82. **Commit.** Stage and commit the plan-fidelity task updates. (**inline**)
  - Run `git add skills/audit/tasks/plan-fidelity-{evaluator,arbiter,investigator,validator}.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify SC-10a and SC-10b pass — single-plan model adopted, no `plan-fidelity.md` reference.

**Concern transition:** The plan-fidelity audit model is corrected; proceed to the writing-plans internal consistency phase.

---

# Phase 6 — Writing-plans internal consistency

**Concern:** Fix the writing-plans internal inconsistencies: task count, cycle terminology, YAML blocks, contract symmetry, verify-plan-pipeline wiring, completion lifecycle, sc-summary path, auth gating (SC-11 through SC-18).

**Files:** `.opencode/skills/writing-plans/SKILL.md`, `.opencode/skills/writing-plans/tasks/create.md`, `.opencode/skills/writing-plans/tasks/completion.md`, `.opencode/skills/writing-plans/tasks/handoff.md`, `.opencode/skills/writing-plans/tasks/research.md`, `.opencode/skills/writing-plans/contracts/*-output.yaml`

**SCs:** SC-11, SC-12, SC-13, SC-14, SC-15, SC-16a, SC-16b, SC-16c, SC-16d, SC-17, SC-18

**Dependencies:** Phase 1, Phase 4

**Entry condition:** Phase 1 and Phase 4 complete — analytical artifacts exist and research.md tool invocations are corrected.

**Exit condition:** All writing-plans internal inconsistencies are resolved.

**Code Path Coverage:** The writing-plans skill files (SKILL.md, tasks, contracts) are the affected code paths.

**Cross-Cutting SCs:** SC-17 edits `research.md` (also edited by P4); SC-11/12/15 edit `writing-plans/SKILL.md` sequentially.

**Interface Boundaries:** The `completion-core` lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` is the authoritative lifecycle channel.

**State Transitions:** From inconsistent writing-plans skill files to internally consistent files.

**Cost frame:** Fixing the writing-plans inconsistencies costs one edit per item. Skipping leaves asymmetric contracts, an unwired task, a dangling reference, and a wrong sc-summary path that compound across every plan produced.

## Step-by-step

- [ ] 83. **Pre-regression.** Run regression test patterns before the RED phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-*`.
- [ ] 84. **Pre-regression verify.** Verify the pre-regression results. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-regression-verify-*`.

### Item 14 (SC-11): Fix writing-plans task count claim

- [ ] 85. **RED.** Write a failing enforcement test asserting SKILL.md task count is 9. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the task count matches the 9 task files.
  - The test FAILs on the current `7`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 86. **GREEN.** Update `writing-plans/SKILL.md` task count to 9. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Change the declared task count to 9.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 87. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 88. **Verify.** Verify the implementation against SC-11. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify SKILL.md task count matches the 9 task files.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 89. **Commit.** Stage and commit the SKILL.md update. (**inline**)
  - Run `git add skills/writing-plans/SKILL.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 15 (SC-12): Fix writing-plans cycle terminology

- [ ] 90. **RED.** Write a failing enforcement test asserting SKILL.md and create.md use per-item TDD cycle terminology, not "per-task cycle". (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the per-item cycle terminology (RED/GREEN/REFACTOR/COMMIT) is used.
  - The test FAILs on the current per-task/per-item mismatch.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 91. **GREEN.** Normalize cycle terminology in `writing-plans/SKILL.md` and `tasks/create.md` to the per-item TDD cycle (RED/GREEN/REFACTOR/COMMIT), removing "per-task cycle". (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Replace "per-task cycle" with the per-item TDD cycle terminology.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 92. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 93. **Verify.** Verify the implementation against SC-12. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify SKILL.md and create.md use per-item cycle terminology and do not use "per-task cycle".
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 94. **Commit.** Stage and commit the terminology updates. (**inline**)
  - Run `git add skills/writing-plans/SKILL.md skills/writing-plans/tasks/create.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 16 (SC-13): Remove YAML code block from create.md

- [ ] 95. **RED.** Write a failing enforcement test asserting create.md body has no JSON/YAML code blocks. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the Result Contract section has no YAML code block.
  - The test FAILs on the current Result Contract YAML block.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 96. **GREEN.** Remove the YAML code block from `writing-plans/tasks/create.md` body. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove the Result Contract YAML code block.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 97. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 98. **Verify.** Verify the implementation against SC-13. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify create.md body has no JSON/YAML code blocks.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 99. **Commit.** Stage and commit the create.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/create.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 17 (SC-14): Add blocker_reason to output contract templates

- [ ] 100. **RED.** Write a failing enforcement test asserting all 9 output contract templates include `blocker_reason`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts all 9 output contract templates include `blocker_reason`.
  - The test FAILs on the current absence.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 101. **GREEN.** Add `blocker_reason` to `writing-plans/contracts/*-output.yaml` templates. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Add the `blocker_reason` field to all 9 output contract templates.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 102. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 103. **Verify.** Verify the implementation against SC-14. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify all 9 output contract templates include `blocker_reason`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 104. **Commit.** Stage and commit the contract template updates. (**inline**)
  - Run `git add skills/writing-plans/contracts/*-output.yaml && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 18 (SC-15): Wire verify-plan-pipeline into the workflow

- [ ] 105. **RED.** Write a failing behavioral enforcement test asserting verify-plan-pipeline appears in the workflow sequence between validate PASS and completion. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that runs the writing-plans workflow and asserts stderr shows verify-plan-pipeline dispatched between validate PASS and completion.
  - The test FAILs on the current unwired state.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 106. **GREEN.** Wire `verify-plan-pipeline` into the `writing-plans/SKILL.md` Workflows sequence immediately following `validate` PASS and before `completion`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Add `verify-plan-pipeline` to the Workflows sequence between `validate` PASS and `completion`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 107. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 108. **Verify.** Verify the implementation against SC-15. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows verify-plan-pipeline dispatched between validate PASS and completion.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 109. **Commit.** Stage and commit the SKILL.md update. (**inline**)
  - Run `git add skills/writing-plans/SKILL.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 19 (SC-16a): Route completion lifecycle event to the completion-core manifest

- [ ] 110. **RED.** Write a failing behavioral enforcement test asserting completion.md appends the lifecycle event to the `completion-core` manifest. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers the completion task and asserts stderr shows the lifecycle event appended to `{project_root}/tmp/{issue-N}/lifecycle.yaml`.
  - The test FAILs on the current issue-body/plan-file mismatch.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 111. **GREEN.** Normalize `writing-plans/tasks/completion.md` to append the lifecycle event to the `completion-core` lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` (metadata, append-only). (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Route the lifecycle event to the completion-core manifest.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 112. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 113. **Verify.** Verify the implementation against SC-16a. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows the lifecycle event appended to `{project_root}/tmp/{issue-N}/lifecycle.yaml`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 114. **Commit.** Stage and commit the completion.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/completion.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 20 (SC-16b): Report executive summary in chat

- [ ] 115. **RED.** Write a failing behavioral enforcement test asserting completion.md reports the executive summary in chat in the completion-core format. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers the completion task and asserts stderr shows the executive summary reported in chat contains the `**Summary:**` section with 1-2 sentences describing the impact and stakeholder value, the `**Outcome:**` section stating what changed for stakeholders, and the URL as the last line.
  - The test FAILs on the current absence.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 116. **GREEN.** Add the executive summary report to chat in `writing-plans/tasks/completion.md` in the completion-core format (`**Summary:**`, `**Outcome:**`, URL ALWAYS LAST). (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Add the `**Summary:**` section (1-2 sentences on impact and stakeholder value), the `**Outcome:**` section (what changed for stakeholders), and the URL as the last line.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 117. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 118. **Verify.** Verify the implementation against SC-16b. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows the `**Summary:**` section, the `**Outcome:**` section, and the URL as the last line.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 119. **Commit.** Stage and commit the completion.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/completion.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 21 (SC-16c): Do not append lifecycle events to plan.md or spec.md

- [ ] 120. **RED.** Write a failing behavioral enforcement test asserting completion.md does not append lifecycle events to `plan.md` or `spec.md`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers the completion task and asserts stderr shows no lifecycle append to plan.md/spec.md.
  - The test FAILs on the current issue-body/plan-file append.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 121. **GREEN.** Remove lifecycle-event appends to `plan.md`/`spec.md` in `writing-plans/tasks/completion.md`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove lifecycle-event appends to plan.md/spec.md.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 122. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 123. **Verify.** Verify the implementation against SC-16c. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows no lifecycle append to plan.md/spec.md.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 124. **Commit.** Stage and commit the completion.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/completion.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 22 (SC-16d): Do not post lifecycle events as human-facing issue comments

- [ ] 125. **RED.** Write a failing behavioral enforcement test asserting completion.md does not post lifecycle events as issue comments. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers the completion task and asserts stderr shows no lifecycle event posted as an issue comment.
  - The test FAILs on the current comment posting.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 126. **GREEN.** Remove lifecycle-event posting as human-facing issue comments (non-substantive per the substantive-comment gate) in `writing-plans/tasks/completion.md`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Remove lifecycle-event posting as issue comments.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 127. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 128. **Verify.** Verify the implementation against SC-16d. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows no lifecycle event posted as an issue comment.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 129. **Commit.** Stage and commit the completion.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/completion.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 23 (SC-17): Fix sc-summary.yaml path resolution

- [ ] 130. **RED.** Write a failing behavioral enforcement test asserting research.md sc-summary.yaml path matches the spec-creation write path. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers research.md and asserts stderr shows sc-summary.yaml read from `{issues_prefix}/{N}/sc-summary.yaml` (the post-#2254 spec-creation write path `{project_root}/{path}/.issues/{issue_number}/sc-summary.yaml`).
  - The test FAILs on the current mismatch.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 131. **GREEN.** Fix the sc-summary.yaml path in `writing-plans/tasks/research.md`. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Change the sc-summary.yaml read path to `{issues_prefix}/{N}/sc-summary.yaml`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 132. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 133. **Verify.** Verify the implementation against SC-17. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows sc-summary.yaml read from `{issues_prefix}/{N}/sc-summary.yaml`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 134. **Commit.** Stage and commit the research.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/research.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

### Item 24 (SC-18): Fix auth gating in handoff.md

- [ ] 135. **RED.** Write a failing behavioral enforcement test asserting handoff.md references the `apply-label` approval-gate task. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test dispatches a real-domain prompt that triggers the handoff task and asserts stderr shows dispatch to the `apply-label` approval-gate task (not verify-authorization).
  - The test FAILs on the current `verify-authorization`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-red-*`.
- [ ] 136. **GREEN.** Repoint `writing-plans/tasks/handoff.md` to the `apply-label` approval-gate task. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Change the reference from `verify-authorization` to `apply-label`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-green-*`.
- [ ] 137. **Post-regression.** Run regression test patterns after the GREEN phase. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-post-regression-*`.
- [ ] 138. **Verify.** Verify the implementation against SC-18. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify via `opencode run` that stderr shows dispatch to the `apply-label` approval-gate task.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-verify-*`.
- [ ] 139. **Commit.** Stage and commit the handoff.md update. (**inline**)
  - Run `git add skills/writing-plans/tasks/handoff.md && git commit -m "<message>"`.
  - The test and its implementation are committed as one atomic slice.

**Phase completion block:** Verify SC-11 through SC-18 all pass — task count 9, per-item cycle terminology, no YAML blocks, `blocker_reason` in contracts, verify-plan-pipeline wired, completion lifecycle routed to the manifest, sc-summary path fixed, auth gating repointed.

**Concern transition:** The writing-plans internal inconsistencies are resolved; proceed to post-implementation gates.

---

# Post-Implementation

- [ ] 140. **Structural checks.** Run the finishing checklist (lint, typecheck, etc.). (**sub-agent**)
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-structural-checks-*`.
- [ ] 141. **Z3 check.** Run the Z3 constraint solver verification. (**inline**)
  - Run `.opencode/tools/solve check --state-path ... --contract-path ...`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-z3-check-*`.
- [ ] 142. **Audit.** Run the adversarial audit of the deliverable. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`.
  - Follow with validator, evaluator, arbiter in sequence.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-audit-*`.
- [ ] 143. **Cross-validate.** Cross-validate the verification results. (**sub-agent**)
  - Dispatch the cross-validation task to reconcile verification verdicts.
- [ ] 144. **Pre-PR gate.** Verify all SC verdicts before PR creation. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Reads all SC verdicts; BLOCKs if any FAIL.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-pre-pr-gate-*`.
- [ ] 145. **Regression check.** Run the final regression check before PR. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2256}/artifacts/pipeline-regression-check-*`.
- [ ] 146. **Review prep.** Prepare the PR review context. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.
- [ ] 147. **Create PR.** Create the pull request. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`.
- [ ] 148. **Completion.** Generate the completion executive summary. (**sub-agent**)
  - Dispatch `task(..., prompt: "execute completion task from completion-core")`.

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-16T21:34:00Z | plan_created | Plan file created at `.opencode/.issues/2256/plan.md` with 6 phases |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
