---
plan_schema_version: "1.0"
issue: 2437
title: "Reclassify pr-creation workflow routing metadata to canonical dispatch vocabulary"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
dispatch:
  - phase: 1
    steps:
      - "test-driven-development: pre-regression"
      - "verification-before-completion: pre-regression-verify"
      - "test-driven-development: red"
      - "test-driven-development: green"
      - "test-driven-development: post-regression"
      - "verification-before-completion: verify"
      - "(orchestrator): commit-inline"
  - phase: post-implementation
    steps:
      - "audit: verification-audit"
      - "(orchestrator): z3-check"
      - "finishing-a-development-branch: structural-checks"
      - "verification-before-completion: pre-pr-gate"
      - "test-driven-development: regression-check"
      - "git-workflow-pr: review-prep"
      - "git-workflow-pr: create-pr"
      - "completion-core: exec-summary"
---

# Implementation Plan — #2437 — Reclassify pr-creation Workflow Routing Metadata

Issue: https://github.com/michael-conrad/.opencode/issues/2437
- **Issue:** .opencode/.issues/2437/spec.md

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

**Goal:** Remove the contradictory `Execution mode: sub-agent dispatch` marker from the `git-workflow-pr` skill card's `pr-creation` workflow step and re-classify the affected skill-card and task-card routing text to the canonical dispatch-vocabulary table.

**Architecture:** Direct text edits to three agent-facing files, resolving the internal contradiction by editing the contradictory markers (not adding overriding clauses). Classification vocabulary comes solely from the canonical dispatch-vocabulary table in `.opencode/reference/skill-card-description-standards.md`. PR pipeline gates (squash-per-issue, human-only merge, Step 9 reconciliation) are untouched invariants.

**Files:**
- `.opencode/skills/git-workflow-pr/SKILL.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/skills/git-workflow/SKILL.md`

**Blast Radius:** Routing-metadata text only — no runtime/code changes to enforcement plugins or hooks. Downstream consumers: orchestrators loading the git-workflow / git-workflow-pr cards and following pr-creation step routing.

---

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | pr-creation routing-metadata reclassification | Fix contradictory sub-agent-dispatch markers with canonical classification | SC-1, SC-2, SC-3, SC-4, SC-5 | — | 3-30 | task-card (3-8, 10-13, 15-18, 20-23, 25-28, 30) + direct (1-2, 9, 14, 19, 24, 29) |

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**direct**).** Confirm the spec's SC list (SC-1 through SC-5), evidence types, and item decomposition match this plan's phase mapping; confirm no spec revision occurred since plan creation.
  - Re-read the verification ledger at `.opencode/.issues/2437/artifacts/plan-input-verification.md` — not the sources
  - If mismatch: halt, report, and re-enter via spec revision
- [ ] 2. **Baseline check (**direct**).** Verify clean starting state in the `.opencode` submodule.
  - `git -C .opencode status --porcelain` returns empty
  - `git -C .opencode status` shows the feature branch is based on current trunk tip
  - Feature branch exists (create via git-workflow pre-work if not — requires `for_implementation`+ scope, which this plan's `for_pr` authorization covers)

## Phase 1 — pr-creation routing-metadata reclassification

**Concern:** Fix the contradictory sub-agent-dispatch markers in the pr-creation routing metadata with canonical dispatch-vocabulary classifications.

**Files:**
- `.opencode/skills/git-workflow-pr/SKILL.md` (items 1, 2)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` (items 3, 4)
- `.opencode/skills/git-workflow/SKILL.md` (item 5)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None (single-phase plan)

**Entry Conditions:**
- Spec `.opencode/.issues/2437/spec.md` is approved (`approved-for-pr` label present locally)
- Pre-implementation steps 1-2 passed
- Canonical dispatch-vocabulary table read from `.opencode/reference/skill-card-description-standards.md` before any edit

**Exit Conditions:**
- All five SCs verified PASS with correct evidence types
- All five item commits present on the feature branch

### Code Path Coverage

- Routing metadata only: `pr-creation` workflow step body in the git-workflow-pr skill card; step-group routing prose and sub-task dispatch listing in `tasks/pr-creation.md`; "Create a PR" workflow entry in the git-workflow skill card. No enforcement-plugin or hook code paths are touched.

### Cross-Cutting SCs

- R-6 (no overriding clauses) governs every edit in items 1-5 — resolution is by editing the contradictory markers directly.
- R-7 (preserve and append bylines) applies to all three edited files across all items.

### Interface Boundaries

- The canonical dispatch-vocabulary table in `.opencode/reference/skill-card-description-standards.md` is the sole classification vocabulary source — no ad-hoc vocabulary is introduced in the edited files.
- PR pipeline gates (squash-per-issue, human-only merge, Step 9 reconciliation) are untouched invariants.

### State Transitions

- Reclassification is a one-time text edit; no runtime state machine is affected. PR pipeline states (`for_pr`, `approved-for-pr`) are unchanged.

### Step-by-step

Per-task cycle steps are daisy-chained: item N's commit is precondition for item N+1's RED. Each RED→GREEN→verify→commit tuple covers exactly one SC.

**Pre-phase (per implementation-workflow reference card):**

- [ ] 3. **pre-regression (**task-card**).** Run regression test patterns before RED phase via `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Pre-clean previous-run artifacts for this step and later steps (`rm -f {project_root}/tmp/2437/artifacts/pipeline-pre-regression-*` and subsequent step prefixes)
  - Regression suite: existing tests-v2 enforcement scenarios touching git-workflow-pr routing
  - Coverage: confirms no pre-existing failures before the change begins
- [ ] 4. **pre-regression-verify (**task-card**).** Verify pre-regression results via `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Evidence artifact recorded at `{project_root}/tmp/2437/artifacts/pipeline-pre-regression-verify-*`
  - FAIL blocks the phase; remediation-first applies

**Item 1 — SC-1 (behavioral): remove the sub-agent-dispatch marker from the pr-creation workflow step.**

- [ ] 5. **RED (**task-card**).** Write a tests-v2 behavioral enforcement scenario via `task(..., prompt: "execute red task from test-driven-development")`.
  - The scenario asserts the orchestrator does NOT dispatch the git-workflow-pr skill card's pr-creation routing content to a sub-agent, using content-verification assertions on stderr agent actions (`with-test-home opencode run`)
  - RED condition: the scenario FAILS because the `Execution mode: sub-agent dispatch` marker and its `task()` prompt still exist on the `pr-creation` step in `.opencode/skills/git-workflow-pr/SKILL.md`
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-red-*`
- [ ] 6. **GREEN (**task-card**).** Remove the contradictory marker via `task(..., prompt: "execute green task from test-driven-development")`.
  - Minimum change: remove the `Execution mode: sub-agent dispatch` text and its `task()` prompt from the `pr-creation` workflow step in `.opencode/skills/git-workflow-pr/SKILL.md` — no overriding clause is added (R-6)
  - Preserve and append bylines per R-7
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-green-*`
- [ ] 7. **post-regression (**task-card**).** Run regression test patterns after GREEN via `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Behavioral scenario now PASSES; no unrelated scenario regressed
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-post-regression-*`
- [ ] 8. **verify (**task-card**).** Verify implementation against SC-1 via `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verdict must be behavioral evidence (stderr agent actions) — a structural substitute is EVIDENCE_TYPE_MISMATCH and FAILs
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-verify-*`
- [ ] 9. **commit-inline (**direct**).** Orchestrator stages and commits the change directly (no sub-agent dispatch).
  - `git -C .opencode add skills/git-workflow-pr/SKILL.md && git -C .opencode commit -m "reclassify: remove sub-agent-dispatch marker from pr-creation workflow step (SC-1)"`
  - Test and implementation committed as one atomic slice; no co-author trailers during implementation commits

**Item 2 — SC-2 (string): add the task-card classification to the pr-creation workflow step.**

- [ ] 10. **RED (**task-card**).** Content check via `task(..., prompt: "execute red task from test-driven-development")`.
  - RED condition: grep finds no `task-card` classification and no citation of the canonical dispatch-vocabulary table on the `pr-creation` step in `.opencode/skills/git-workflow-pr/SKILL.md`
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-red-*`
- [ ] 11. **GREEN (**task-card**).** Add the classification via `task(..., prompt: "execute green task from test-driven-development")`.
  - Mark the `pr-creation` step with the `task-card` classification citing the canonical dispatch-vocabulary table in `.opencode/reference/skill-card-description-standards.md`, consistent with the Mandatory Task Discipline clause
  - Preserve and append bylines per R-7
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-green-*`
- [ ] 12. **post-regression (**task-card**).** Run regression patterns via `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - SC-1's behavioral scenario still PASSES (marker not reintroduced); grep confirms `task-card` + table citation present and no contradictory marker text remains
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-post-regression-*`
- [ ] 13. **verify (**task-card**).** Verify against SC-2 via `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-verify-*`
- [ ] 14. **commit-inline (**direct**).** `git -C .opencode add skills/git-workflow-pr/SKILL.md && git -C .opencode commit -m "reclassify: add task-card classification with canonical table citation to pr-creation step (SC-2)"`

**Item 3 — SC-3 (semantic): classify step routing in the pr-creation task card.**

- [ ] 15. **RED (**task-card**).** Content check via `task(..., prompt: "execute red task from test-driven-development")`.
  - RED condition: `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` has only ambiguous "Route to" prose with no explicit per-step dispatch classification
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-red-*`
- [ ] 16. **GREEN (**task-card**).** Add classifications via `task(..., prompt: "execute green task from test-driven-development")`.
  - State orchestrator-direct classification for each procedure step group: Steps 0-1 orchestrator-direct; Steps 2-4 orchestrator-direct; Steps 5-7 orchestrator-direct, per the canonical dispatch-vocabulary table
  - Preserve and append bylines per R-7
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-green-*`
- [ ] 17. **post-regression (**task-card**).** Run regression patterns via `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-post-regression-*`
- [ ] 18. **verify (**task-card**).** Verify against SC-3 via `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Semantic evidence: clean-room sub-agent reads the task card and confirms each of the three step groups carries exactly one stated classification
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-verify-*`
- [ ] 19. **commit-inline (**direct**).** `git -C .opencode add skills/git-workflow-pr/tasks/pr-creation.md && git -C .opencode commit -m "reclassify: state orchestrator-direct classification per step group in pr-creation task card (SC-3)"`

**Item 4 — SC-4 (semantic): classify nested sub-task routing in the pr-creation task card.**

- [ ] 20. **RED (**task-card**).** Content check via `task(..., prompt: "execute red task from test-driven-development")`.
  - RED condition: `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` lists none of `pr-creation/enforcement-gate.md`, `pr-creation/squash-push.md`, `pr-creation/create-pr.md` as `task-card` dispatch points
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-red-*`
- [ ] 21. **GREEN (**task-card**).** Add sub-task classifications via `task(..., prompt: "execute green task from test-driven-development")`.
  - Classify each nested `pr-creation/*.md` sub-task card (`enforcement-gate.md`, `squash-push.md`, `create-pr.md`) as a `task-card` dispatch point in `tasks/pr-creation.md`
  - Preserve and append bylines per R-7
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-green-*`
- [ ] 22. **post-regression (**task-card**).** Run regression patterns via `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-post-regression-*`
- [ ] 23. **verify (**task-card**).** Verify against SC-4 via `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Semantic evidence: clean-room sub-agent read confirms each of the three sub-task files is listed as a `task-card` dispatch point
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-verify-*`
- [ ] 24. **commit-inline (**direct**).** `git -C .opencode add skills/git-workflow-pr/tasks/pr-creation.md && git -C .opencode commit -m "reclassify: mark nested pr-creation sub-task cards as task-card dispatch points (SC-4)"`

**Item 5 — SC-5 (string): sync the parent git-workflow skill card.**

- [ ] 25. **RED (**task-card**).** Content check via `task(..., prompt: "execute red task from test-driven-development")`.
  - RED condition: grep finds the old sub-agent-dispatch prompt still present in `.opencode/skills/git-workflow/SKILL.md`'s "Create a PR" workflow entry
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-red-*`
- [ ] 26. **GREEN (**task-card**).** Align the entry via `task(..., prompt: "execute green task from test-driven-development")`.
  - Align the "Create a PR" entry's prompt/execution mode with the `task-card` classification vocabulary used in items 2-4, citing the canonical dispatch-vocabulary table
  - Preserve and append bylines per R-7
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-green-*`
- [ ] 27. **post-regression (**task-card**).** Run regression patterns via `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Grep confirms the old prompt is gone and `task-card` classification is present in the entry
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-post-regression-*`
- [ ] 28. **verify (**task-card**).** Verify against SC-5 via `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-verify-*`
- [ ] 29. **commit-inline (**direct**).** `git -C .opencode add skills/git-workflow/SKILL.md && git -C .opencode commit -m "reclassify: align git-workflow Create-a-PR entry with task-card classification vocabulary (SC-5)"`

#### Phase 1 Completion Block (VbC)

- [ ] 30. **VbC (**task-card**).** Verify all phase-1 SC verdicts via `task(..., prompt: "execute verify task from verification-before-completion")`.
  - SC-1 PASS (behavioral evidence), SC-2 PASS (grep), SC-3 PASS (semantic clean-room read), SC-4 PASS (semantic clean-room read), SC-5 PASS (grep)
  - Evidence artifacts enumerated at `{project_root}/tmp/2437/artifacts/`
  - Any FAIL triggers the self-remediation protocol before proceeding

**Concern transition:** Leaving routing-metadata reclassification — entering post-implementation verification and PR delivery. Post-implementation depends on every item commit landing.

**Cost frame:** Running the behavioral enforcement scenario for SC-1 costs minutes of execution time — the dispatch-decision defect is caught at the pre-commit gate where the fix costs the same bounded delay. The grep checks for SC-2 and SC-5 cost seconds; the clean-room semantic reads for SC-3 and SC-4 cost minutes of sub-agent execution. Skipping the behavioral gate costs a death spiral: a structural or string PASS lets the orchestrator keep dispatching skill-card routing content to sub-agents — the critical-rules category error resurfaces on every PR run at 1000× the fix cost; skipping the semantic reads costs days-to-weeks of defect-discovery latency each time an orchestrator mis-routes a step mid-PR. Correctness is the only metric.

## Post-Implementation

Executed once after all phase-1 items commit. Each step pre-cleans its own artifact prefix before running.

- [ ] 31. **audit (**task-card**).** Adversarial audit of the deliverable via `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read `audit/tasks/verification-audit-investigator.md` first")` — followed by validator, evaluator, arbiter in sequence.
  - Audits spec fidelity, plan coherence, evidence-type match for every SC
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-audit-*`
- [ ] 32. **z3-check (**direct**).** Orchestrator runs `.opencode/tools/solve check --state-path <state> --contract-path <contract>` directly — no sub-agent dispatch.
  - Validates the phase dependency contract and state transitions
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-z3-check-*`
- [ ] 33. **structural-checks (**task-card**).** Run the finishing checklist via `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.
  - Lint and content-verification checks on the three edited agent-facing files
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-structural-checks-*`
- [ ] 34. **pre-pr-gate (**task-card**).** Verify all SC verdicts via `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL.
  - DONE_WITH_CONCERNS coerces to FAIL; EVIDENCE_TYPE_MISMATCH FAILs
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-pre-pr-gate-*`
- [ ] 35. **regression-check (**task-card**).** Final regression check via `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Pre-clean: `rm -f {project_root}/tmp/2437/artifacts/pipeline-regression-check-*`
- [ ] 36. **review-prep (**task-card**).** Prepare PR review context via `task(..., prompt: "execute review-prep from git-workflow-pr. Read `git-workflow-pr/tasks/review-prep.md` first")`.
  - Note: review-prep remains a task-card dispatch; this plan reclassifies only the `pr-creation` step (spec Not-Included boundary)
- [ ] 37. **create-pr (**task-card**).** Create the pull request via `task(..., prompt: "execute create task from git-workflow-pr")`.
  - Squash to exactly one commit per issue at PR creation; stacked PR targeting the trunk; PR requires the existing `for_pr` authorization scope
  - No co-author trailers fabricated at squash beyond attribution rules; HALT after PR creation — human-only merge
- [ ] 38. **exec-summary (**task-card**).** Generate the completion executive summary via `task(..., prompt: "execute completion task from completion-core")`.
  - Exactly one `plan_created` lifecycle event with `plan_file` and `phase_count` recorded per the lifecycle convention

---

## Exit Criteria

- [ ] C1. The `git-workflow-pr` skill card's `pr-creation` workflow step contains no `Execution mode: sub-agent dispatch` text (SC-1, behavioral evidence)
- [ ] C2. The `pr-creation` workflow step states the `task-card` classification with a citation of the canonical dispatch-vocabulary table (SC-2, grep)
- [ ] C3. `tasks/pr-creation.md` states exactly one orchestrator-direct classification for each of the three step groups — Steps 0-1, 2-4, 5-7 (SC-3, semantic)
- [ ] C4. `tasks/pr-creation.md` lists `enforcement-gate.md`, `squash-push.md`, and `create-pr.md` as `task-card` dispatch points (SC-4, semantic)
- [ ] C5. The `git-workflow` skill card's "Create a PR" entry contains the `task-card` vocabulary and no old sub-agent-dispatch prompt text (SC-5, grep)
- [ ] C6. All five SC verdicts are PASS with evidence types matching their declared types; every item's test and change committed as one atomic slice on the feature branch

---

## lifecycle_events

| timestamp | event | plan_file | phase_count |
|-----------|-------|-----------|-------------|
| 2026-09-20T13:50:00-04:00 | plan_created | `.opencode/.issues/2437/plan.md` | 1 |

---

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
