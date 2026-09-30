---
plan_schema_version: "1.0"
issue: 2477
title: "import-remote task card mirror-file schema alignment with local-issues"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase-1: test-driven-development (pre-regression, red, green, post-regression), verification-before-completion (pre-regression-verify, verify), orchestrator (commit-inline)
  - phase-2: test-driven-development (pre-regression, red, green, post-regression), verification-before-completion (pre-regression-verify, verify), orchestrator (commit-inline)
  - phase-3: test-driven-development (pre-regression, red, green, post-regression), verification-before-completion (pre-regression-verify, verify), orchestrator (commit-inline)
---

# Implementation Plan — #2477 — import-remote Task Card Mirror-File Schema Alignment

**Issue:** .opencode/.issues/2477/spec.md

**Goal:** Rewrite the `issue-operations-sync` `import-remote` task card so its mirror-file contract, Step 4 completeness gate, and Step 7 counter instructions match the `local-issues` tool's verified schema (`YAML_FILES = (issue.yaml, comments.yaml, links.yaml)`, `MARKDOWN_FILES = (spec.md)`, `_next_number` fail-fast digit-parse semantics).

**Architecture:** Documentation-layer correction of one task card, executed as three sequential single-SC TDD cycles on the same file. The tool's schema constants and `_next_number` semantics are the single ground truth (read-only reference); the card is the corrected consumer. Three phases in strict 1:1 SC↔item↔phase mapping, daisy-chained — each phase's commit is the precondition for the next phase's RED. Post-implementation: audit, Z3 check, structural checks, pre-PR gate, regression check, review-prep, PR creation (stacked, single branch), completion summary.

**Files:**
- `.opencode/skills/issue-operations-sync/tasks/import-remote.md` (target — all three phases)
- `.opencode/tools/local-issues` (read-only ground truth — MUST NOT be modified)

**Blast Radius:** Single-file, documentation-only rewrite. Sections touched: Steps (mirror-file enumeration, Step 4 completeness gate, Step 6 comment import, Step 7 counter write), Exit Criteria, Edge Cases, Live-Verification evidence table. No runtime code paths affected; dispatcher `issue-operations-sync/SKILL.md` unchanged. Sibling task cards with legacy references are excluded per spec Not-Included.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | schema-accuracy-item-1 | legacy-filename-purge | SC-1 | — | 3-9 | task-card (3-8) + direct (9) |
| 2 | completeness-gate-item-2 | schema-enumeration | SC-2 | 1 | 10-16 | task-card (10-15) + direct (16) |
| 3 | counter-validation-item-3 | counter-write-validation | SC-3 | 2 | 17-23 + 24-31 post | task-card (17-22, 24, 26-31) + direct (23, 25) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Pre-implementation steps

- [ ] 1. (**direct**) Coherence gate — dispatch-free gate executed in orchestrator context via the approved spec: confirm the spec at `.opencode/.issues/2477/spec.md` is fresh, labels authoritative locally (`approved-for-for_pr` in local `issue.yaml`), and no superseding open issue exists (spec-creation coherence criteria).
  - Scope: before any phase starts
  - SC reference: none (gate)
- [ ] 2. (**direct**) Baseline check — confirm feature branch exists and is checked out; confirm the target file exists at `.opencode/skills/issue-operations-sync/tasks/import-remote.md`; confirm ground-truth constants in `.opencode/tools/local-issues` are unchanged (read-only check of YAML_FILES / MARKDOWN_FILES / _next_number).
  - SC reference: none (gate)

## Enforcement Gate

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Exit Criteria

- [ ] C1. `import-remote.md` contains zero legacy mirror-filename references — card-wide grep returns 0 (SC-1)
- [ ] C2. Step 4 completeness gate enumerates the actual schema file set and recognizes already-migrated directories (SC-2)
- [ ] C3. Step 7 specifies the named counter-write validation procedure as the sole documented mechanism, citing `_next_number` semantics (SC-3)
- [ ] C4. All three SC item commits daisy-chained; pre-PR gate shows all SC verdicts PASS; audit verdict clean; PR created stacked on single branch

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.