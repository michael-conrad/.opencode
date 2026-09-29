---
plan_schema_version: 1
issue: 2471
title: "Deck-wide no-approval-mechanism rule for spec issue body footers"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
dispatch:
  - "phase-1: task-card: test-driven-development (pre-regression: 1, red: 8, post-regression: 10, final regression: 19), verification-before-completion (pre-regression-verify: 2, verify: 11, verify: 13, verify: 18), audit (verification-audit: 15), finishing-a-development-branch (structural-checks: 17), git-workflow-pr (review-prep: 20, create-pr: 21), completion-core (exec-summary: 22); orchestrator-direct: artifact-cleanup (3), branch-check (4), readiness-report (5), coherence-gate (6), baseline-check (7), commit-inline (12), concern-transition (14), z3-check (16)"
---

# Implementation Plan — Issue #2471

- **Issue:** .opencode/.issues/2471/spec.md

## Goal

Make the deck normatively forbid approval-mechanism language in spec issue bodies. All three body-assembly task cards (spec-creation create, issue-operations-core creation, local platform creation) state the footer allowlist with an explicit "no process/tracking indicators" rule, and any stale `Approval Tracking` / `AI: Approved` literals are removed — verified by a string-level enforcement test.

## Architecture

- Single phase, single SC (SC1, evidence type `string`).
- RED: failing string-level enforcement test asserting zero approval-mechanism literals in the three target task cards AND presence of the normative no-indicator rule.
- GREEN: add the footer-allowlist rule to all three task cards; remove any approval-mechanism literals found.
- COMMIT: orchestrator commit-inline — test + changed cards in one atomic commit.

## Files

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation/tasks/create.md` | Add normative no-indicator footer rule to body template (Step 4) |
| `.opencode/skills/issue-operations-core/tasks/creation.md` | Footer mandate (Step 3) and body format (Step 5) — add footer allowlist |
| `.opencode/skills/issue-operations/platforms/local/tasks/creation.md` | Search and clear any approval-tracking literal; add footer allowlist |
| `.opencode/tests-v2/behaviors/` | New string-level enforcement test for SC1 |

## Dispatch

- Phase 1: direct (3-7, 12, 14, 16) + task-card (1-2, 8-11, 13, 15, 17-22)

## Blast Radius

Direct: the three task cards above. Indirect: other platform creation paths (github-mcp, gitbucket-api) may share the body-assembly convention — verified during GREEN, no rule added there (outside SC1 file set). Unaffected: no runtime code; already-created specs #36/#1385 repaired 2026-09-29.

## Admonishment

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|-----------|----------|
| 1 | task-card footer allowlist rule | no approval-mechanism indicators in spec issue bodies | SC1 | — | 1-22 | direct (3-7, 12, 14, 16) + task-card (1-2, 8-11, 13, 15, 17-22) |

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## Pre-Implementation Steps

- [ ] 1. (**task-card**) Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")` — run pre-regression test patterns before RED.

  - Step name: `pre-regression`
- [ ] 2. (**task-card**) Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` — verify pre-regression results.

  - Step name: `pre-regression-verify`
- [ ] 3. (**direct**) Apply pre-step artifact cleanup per implementation-workflow §Rule 3 for the phases about to run.

  - Command pattern: `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-regression-*` (and subsequent steps as they execute)
- [ ] 4. (**direct**) Confirm feature branch exists and working tree is on it (per git-workflow pre-work; branch already required by `for_pr` scope).

  - Verify `git status` clean before phase 1 begins
- [ ] 5. (**direct**) Report readiness summary; proceed into Phase 1 without halting (for_pr scope carries through).

  - Scope: authorization cascades through plan execution to PR creation

## Pre-Implementation Verification (once per plan)

- [ ] 6. (**direct**) Coherence gate — verify the plan is faithful to the spec: every SC mapped to at least one phase, no SCs added or dropped, phase DAG acyclic (zero edges).

  - Read this plan's Phase Table; confirm SC1 is covered; confirm the spec has exactly one SC
- [ ] 7. (**direct**) Baseline check — run the existing test suite relevant to the changed cards to establish a green baseline before RED.

  - Command: `rg "Approval Tracking|AI: Approved" .opencode/` confirming current state (expected: no matches in task cards — the deck gap is the missing normative rule)

# Phase 1 — task-card footer allowlist rule

- **Concern:** no approval-mechanism indicators in spec issue bodies
- **Files:** `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/skills/issue-operations-core/tasks/creation.md`, `.opencode/skills/issue-operations/platforms/local/tasks/creation.md`
- **SCs:** SC1
- **Dependencies:** — (DAG has zero edges)
- **Entry condition:** pre-implementation steps complete; baseline recorded
- **Exit condition:** SC1 verified with string evidence; test + card changes committed as one atomic commit

### Code Path Coverage

- spec-creation create body assembly — `.opencode/skills/spec-creation/tasks/create.md` (Step 4 template → remote-body write)
- issue-operations-core exec-summary assembly — `.opencode/skills/issue-operations-core/tasks/creation.md` (Step 3 footer mandate; Step 5 body format)
- local platform creation — `.opencode/skills/issue-operations/platforms/local/tasks/creation.md` (candidate emitter; searched and cleared)
- approval state authority (unchanged) — approval-gate skill + `approved-for-*` labels, local `issue.yaml` canonical

### Cross-Cutting SCs

- SC1 is cross-cutting: spans all three creation-path task cards; body-assembly responsibility is split between spec-creation template and issue-operations-core creation task — the normative rule lands in all three.

### Interface Boundaries

- spec-creation create → issue-operations-core creation body conventions: remote issue body structure (blockquote / sections / footer). Adding the normative exclusion rule breaks no interface; the 5-section exec-summary format and byline footer are preserved with approval-mechanism content excluded.

### State Transitions

- Spec issue body template (deck): unspecified footer content → normative footer allowlist (byline only; no process/tracking indicators)
- Remote issue bodies created after fix: rendered from template with zero approval-mechanism language. No application state, database, or serialized-format transitions.

### Cost frame

Verifying the rule addition across three task cards costs three grep searches and one string-level test run — seconds. Skipping means the deck gap persists and sub-agents can still invent approval-mechanism content; the string-level defect is then discovered only at the next spec-creation run, after full pipeline dispatch — days of rework to re-clean issue bodies.

### Step-by-step

Item SC1-body-template (daisy chain: this is the only item; its commit is the phase exit):

- [ ] 8. (**task-card**) RED — Write a failing string-level enforcement test asserting zero approval-mechanism literals ("Approval Tracking", "AI: Approved") in the three target task cards AND presence of the normative no-indicator rule ("no process/tracking indicators" footer allowlist). Test FAILS before GREEN.

  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - SC: SC1 · Evidence: string
- [ ] 9. (**task-card**) GREEN — Add the normative footer allowlist / no process/tracking-indicator rule to: `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/skills/issue-operations-core/tasks/creation.md`, `.opencode/skills/issue-operations/platforms/local/tasks/creation.md`. Remove any approval-mechanism literals found in those cards.

  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - SC: SC1 · Evidence: string
- [ ] 10. (**task-card**) post-regression — Run regression test patterns after GREEN.

  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC: SC1
- [ ] 11. (**task-card**) verify — Verify implementation against success criteria.

  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC: SC1 · Evidence: string
- [ ] 12. (**direct**) COMMIT — Stage and commit changes: `git add` the enforcement test + the three changed task cards; one atomic commit, no co-author trailers (added at squash time).

  - Dispatch: none — orchestrator commit-inline
  - SC: SC1

## Phase 1 Completion Block

- [ ] 13. (**task-card**) Verify all Phase 1 assertions hold: SC1 verdict PASS with string evidence; test file and all three cards committed in one commit.

  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 14. (**direct**) Concern transition: no further phases — proceed to post-implementation.

## Post-Implementation Steps

- [ ] 15. (**task-card**) Adversarial audit of the deliverable.

  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
- [ ] 16. (**direct**) Run Z3 constraint solver verification.

  - Command: `.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] 17. (**task-card**) Run finishing checklist (lint, typecheck, etc.).

  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
- [ ] 18. (**task-card**) Verify all SC verdicts before PR creation.

  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 19. (**task-card**) Final regression check before PR.

  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 20. (**task-card**) Prepare PR review context.

  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 21. (**task-card**) Create the pull request (stacked; `for_pr` scope authorizes PR creation).

  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
- [ ] 22. (**task-card**) Generate completion executive summary.

  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`

## Exit Criteria

- [ ] C1 — The string-level enforcement test for SC1 exists and passes
- [ ] C2 — All three target task cards contain the normative no-indicator footer allowlist rule
- [ ] C3 — Zero approval-mechanism literals ("Approval Tracking", "AI: Approved") remain in the three task cards
- [ ] C4 — Test + card changes are committed as one atomic slice via commit-inline
- [ ] C5 — All SC verdicts are PASS with string evidence before PR creation

## Lifecycle Events

- 2026-09-29T09:57:00Z (approx; schema-version timestamp on append) — `plan_created` — plan file: `.opencode/.issues/2471/plan.md` — phase count: 1

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
