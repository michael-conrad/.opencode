---
plan_schema_version: "1.0"
issue: 2489
title: "Holistic submodule pointer discipline: remove pre-commit stale-pointer gate, consolidate tag canon, repair dead references"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 6
dispatch:
  - "phase-1: test-driven-development (red, green, phase-4), verification-before-completion (verify), orchestrator commit-inline, issue-operations (comment CM-2)"
  - "phase-2: test-driven-development (red, green, phase-4), verification-before-completion (verify), orchestrator commit-inline, issue-operations (comment CM-1 policy record)"
  - "phase-3: test-driven-development (red, green, phase-4), verification-before-completion (verify), orchestrator commit-inline"
  - "phase-4: test-driven-development (red, green, phase-4), verification-before-completion (verify), orchestrator commit-inline"
  - "phase-5: test-driven-development (red, green, phase-4), verification-before-completion (verify), orchestrator commit-inline"
  - "phase-6: test-driven-development (red, green, phase-4), verification-before-completion (verify), orchestrator commit-inline, audit, finishing-a-development-branch (checklist), git-workflow-pr (review-prep, create), completion-core (completion), orchestrator z3-check"
---

# Implementation Plan — #2489 — Holistic Submodule Pointer Discipline Fix

> **Full spec and artifacts:** [`.opencode/.issues/2489/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2489) — the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2489/` — spec.md, plan.md, phase plan files, dependency contracts, artifacts

**Issue:** .opencode/.issues/2489/spec.md

**Goal:** Remove the pre-commit hook Gate 2 stale-pointer check and its SKIP hatch, consolidate all tag rules into the single canonical section, repoint all 15 dead references, correct the six tag-format sites, add a standing reference-integrity enforcement check, retire the dependent tests with a ceremony-test policy, and record the issue-graph handover.

**Architecture:** Six phases in dependency order. Phase 1 removes the hook gate (root-cause fix) and records the CM-2 issue-graph handover. Phase 2 retires the five dependent tests and records the CM-1 ceremony-test policy. Phase 3 rewrites the advisory text. Phase 4 builds the reference-integrity check BEFORE the repairs it validates. Phase 5 executes the reference repairs against the fixed Dead-Reference → Live-Target Mapping. Phase 6 closes the loop (integrity check passes on the repaired repo) and corrects the six tag-format sites, then runs all post-implementation gates.

**Files (folders):**
- `.opencode/hooks/` — pre-commit hook Gate 2 + SKIP hatch removal
- `.opencode/tests-v2/` — five dependent test retirements, runner index cleanup, ceremony policy record, new behavioral tests
- `.opencode/skills/git-workflow-branch/` — advisory text rewrite, tag-format corrections, reference repairs, canonical tag section
- `.opencode/skills/git-workflow/`, `.opencode/skills/git-workflow-cleanup/`, `.opencode/commands/`, `.opencode/guidelines/` — reference repairs
- `.opencode/tools/` — new reference-integrity enforcement check

## Blast Radius (from blast-radius.yaml)

- **Component A — hook removal:** `.opencode/hooks/pre-commit` (Gate 2: SKIP hatch, stale-pointer loop, BLOCK message deleted; Gate 1 kept); five dependent tests retire; `pre-commit-pointer-check.md` advisory updated; #2258 superseded.
- **Component B — reference drift:** 15 dead Read-link sites (6 → SKILL.md §Tag Convention, 7 AGENTS.md-section refs, 2 pre-work.md refs) repointed to live targets.
- **Component C — tag format:** six phrase-anchored sites (4 primary defect + 2 consequential same-cluster) carry the suffixed form; `trunk-push-provenance.md` trunk-push tagging step excluded (already suffixed).
- **Explicitly not affected:** hooks/pre-push Gate 2, enforcement-gate Steps 0/0.5/0.75 content, create-pr.md release pointer check, trunk-tip-verification.md, session-enforcement.ts installer code.
- **Ripple effects:** skip-habituation path disappears; #2431 "SKIP semantics unchanged" assumption invalidated (CM-2 handover); installed hook copies refresh at next session start (verify installer overwrite, do not hand-edit).

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Hook gate removal | Commit-time authority transfer | SC-1, SC-2, CM-2 | — | 5-15 | direct (9, 13) + task-card (rest) |
| 2 | Dependent test retirement + ceremony policy | Test integrity + policy record | SC-3, SC-4, CM-1 | 1 | 16-25 | direct (19, 23) + task-card (rest) |
| 3 | Advisory text rewrite | Agent-facing text consistency | SC-5, SC-6 | 1 | 26-34 | direct (29, 33) + task-card (rest) |
| 4 | Reference-integrity check build | Recurrence-guard tool exists | SC-12 | 2 | 35-39 | direct (38) + task-card (rest) |
| 5 | Reference repair | Dead references repointed | SC-8, SC-9, SC-10 | 4 | 40-52 | direct (43, 47, 51) + task-card (rest) |
| 6 | Integrity verification + tag-format correction | Repair loop closure + format fix + post-implementation | SC-13, SC-11 | 5 | 53-67 | direct (58, 61) + task-card (rest) |

## Pre-Implementation Steps (once per plan)

- [ ] 1. **Coherence gate (**direct**).** Confirm the spec SC table (13 SCs) matches structure.yaml phase mappings and dependency-contract.yaml preconditions; confirm sc-summary.yaml is stale (8 SCs) and is NOT used as a source. **→ all SCs**
- [ ] 2. **Baseline check (**direct**).** Verify parent repo and `.opencode` submodule are on trunk tip with zero pending changes; record baseline grep counts for the dead-target patterns (SKILL.md §Tag Convention, AGENTS.md sections, unsuffixed tag format) so RED deltas are measurable. **→ all SCs**
- [ ] 3. **Pre-regression (**task-card**).** Run regression test patterns before RED phase per test-driven-development phase-0 task. **→ all SCs**
- [ ] 4. **Pre-regression-verify (**task-card**).** Verify pre-regression results per verification-before-completion verify task. **→ all SCs**

## Phase Files

- Phase 1 — Hook gate removal: `plan-01-hook-gate-removal.md`
- Phase 2 — Dependent test retirement + ceremony policy: `plan-02-test-retirement-policy.md`
- Phase 3 — Advisory text rewrite: `plan-03-advisory-rewrite.md`
- Phase 4 — Reference-integrity check build: `plan-04-integrity-check.md`
- Phase 5 — Reference repair: `plan-05-reference-repair.md`
- Phase 6 — Integrity verification + tag-format correction (includes post-implementation): `plan-06-verification-tag-format.md`

## Exit Criteria

- [ ] C1. Pre-commit hook contains no Gate 2 stale-pointer check, no `SKIP_STALE_POINTER_CHECK` hatch, and Gate 1 still blocks trunk commits (SC-1, SC-2)
- [ ] C2. The five dependent gate tests are deleted and tests-v2 lists no orphaned runners (SC-3, SC-4)
- [ ] C3. Advisory text is free of stale-pointer/SKIP wording and references the PR-time freshness gates (SC-5, SC-6)
- [ ] C4. All six Tag-Rule Inventory entries are present in the canonical section (SC-7)
- [ ] C5. Zero dead references remain and every repaired link uses inline Read form (SC-8, SC-9, SC-10)
- [ ] C6. All six Tag-Format Site Inventory sites carry the suffixed form (SC-11)
- [ ] C7. The reference-integrity check fails on a deliberate broken probe and passes on the repaired repo (SC-12, SC-13)
- [ ] C8. CM-1 policy record and CM-2 issue-graph annotations are in place and verified
- [ ] C9. Post-implementation gates pass: audit, Z3 check, structural checks, pre-PR gate, regression check, review-prep, PR created, completion summary

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
