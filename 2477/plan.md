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

## Phase 1: schema-accuracy-item-1 (Steps 3-9)

**Concern:** legacy-filename-purge — eliminate every legacy mirror-filename reference in `import-remote.md`. **SCs:** SC-1. **Full phase file:** `plan-01-schema-accuracy-item-1.md` (entry/exit conditions, code path coverage, cost frame).

- [ ] 3. (**task-card**) Pre-regression — dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`, context: run regression test patterns before RED phase, pre-clean `tmp/2477/artifacts/pipeline-pre-regression-*`.
  - SC reference: SC-1
- [ ] 4. (**task-card**) Pre-regression verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")` against pre-regression results, pre-clean `pipeline-pre-regression-verify-*`.
  - SC reference: SC-1
- [ ] 5. (**task-card**) RED — dispatch `task(..., prompt: "execute red task from test-driven-development")`, context: run the SC-1 grep `grep -c 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md`; the test FAILS because legacy names are present (count > 0). Pre-clean `pipeline-red-*`.
  - SC reference: SC-1
- [ ] 6. (**task-card**) GREEN — dispatch `task(..., prompt: "execute green task from test-driven-development")`, context: replace every legacy mirror-filename reference across the card with the actual schema name (`comments.md` → `comments.yaml`; `remote.md`/`state.md` references removed or rewritten), including the Live-Verification evidence table rows (R-1, R-5). What must be true: the card-wide grep returns 0 legacy-name matches. Minimum change only — no Step 7 counter rewrite here (Phase 3), no completeness-gate rewrite here beyond legacy-name removal (Phase 2). Pre-clean `pipeline-green-*`.
  - SC reference: SC-1
- [ ] 7. (**task-card**) Post-regression — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: run regression test patterns after GREEN, pre-clean `pipeline-post-regression-*`.
  - SC reference: SC-1
- [ ] 8. (**task-card**) Verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: verify SC-1 — `grep -c 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md` returns 0, covering every section including the Live-Verification evidence table. Pre-clean `pipeline-verify-*`.
  - SC reference: SC-1
- [ ] 9. (**direct**) Commit-inline — orchestrator runs `git add .opencode/skills/issue-operations-sync/tasks/import-remote.md && git commit -m "fix(sync): purge legacy mirror filenames from import-remote card (SC-1)"` — no sub-agent dispatch.
  - SC reference: SC-1

**SC-1 triplet containment:** RED (step 5), GREEN (step 6), COMMIT (step 9) — all within Phase 1; no cross-phase split.

## Phase 2: completeness-gate-item-2 (Steps 10-16)

**Concern:** schema-enumeration — Step 4 completeness gate enumerates the actual schema file set. **SCs:** SC-2. **Depends on:** Phase 1 (item 1 commit is precondition for item 2's RED). **Full phase file:** `plan-02-completeness-gate-item-2.md`.

- [ ] 10. (**task-card**) Pre-regression — dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`, context: run regression test patterns before RED phase; pre-clean `tmp/2477/artifacts/pipeline-pre-regression-*`.
  - SC reference: SC-2
- [ ] 11. (**task-card**) Pre-regression verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")` against pre-regression results; pre-clean `pipeline-pre-regression-verify-*`.
  - SC reference: SC-2
- [ ] 12. (**task-card**) RED — dispatch `task(..., prompt: "execute red task from test-driven-development")`, context: run the SC-2 positive grep for `issue.yaml`/`comments.yaml`/`links.yaml` anchored at the Step 4 completeness gate block; the test FAILS because the gate references legacy or absent schema (no matches). Pre-clean `pipeline-red-*`.
  - SC reference: SC-2
- [ ] 13. (**task-card**) GREEN — dispatch `task(..., prompt: "execute green task from test-driven-development")`, context: rewrite the Step 4 completeness gate to enumerate the actual schema file set (`issue.yaml`, `comments.yaml`, `links.yaml` [+ `spec.md`]) as the recognized-complete file set and recognize already-migrated directories per R-3; ensure frontmatter examples remain parser-valid per R-6. What must be true: positive grep at the gate-anchored block returns matches. Minimum change only — no Step 7 counter rewrite here (Phase 3). Pre-clean `pipeline-green-*`.
  - SC reference: SC-2
- [ ] 14. (**task-card**) Post-regression — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: run regression test patterns after GREEN; pre-clean `pipeline-post-regression-*`.
  - SC reference: SC-2
- [ ] 15. (**task-card**) Verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: verify SC-2 — positive grep for `issue.yaml`, `comments.yaml`, `links.yaml` anchored at the Step 4 completeness gate block returns matches; read-back confirms the comment-import instruction into `comments.yaml` list format (R-2 positive verification) and the YAML frontmatter example preserved against the parser's tolerated key set (R-6 positive verification). Pre-clean `pipeline-verify-*`.
  - SC reference: SC-2
- [ ] 16. (**direct**) Commit-inline — orchestrator runs `git add .opencode/skills/issue-operations-sync/tasks/import-remote.md && git commit -m "fix(sync): enumerate actual schema in import-remote completeness gate (SC-2)"` — no sub-agent dispatch.
  - SC reference: SC-2

**SC-2 triplet containment:** RED (step 12), GREEN (step 13), COMMIT (step 16) — all within Phase 2; no cross-phase split.

## Phase 3: counter-validation-item-3 + post-implementation (Steps 17-31)

**Concern:** counter-write-validation — Step 7 presents the single named counter-write validation procedure. **SCs:** SC-3. **Depends on:** Phase 2 (item 2 commit is precondition for item 3's RED). **Full phase file:** `plan-03-counter-validation-item-3.md`.

- [ ] 17. (**task-card**) Pre-regression — dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`, context: run regression test patterns before RED phase; pre-clean `tmp/2477/artifacts/pipeline-pre-regression-*`.
  - SC reference: SC-3
- [ ] 18. (**task-card**) Pre-regression verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")` against pre-regression results; pre-clean `pipeline-pre-regression-verify-*`.
  - SC reference: SC-3
- [ ] 19. (**task-card**) RED — dispatch `task(..., prompt: "execute red task from test-driven-development")`, context: read Step 7 of the card; the test FAILS because a bare `echo $((N+1)) > .counter`-style unvalidated write instruction is present. Pre-clean `pipeline-red-*`.
  - SC reference: SC-3
- [ ] 20. (**task-card**) GREEN — dispatch `task(..., prompt: "execute green task from test-driven-development")`, context: rewrite Step 7 (and referencing edge-case/verification rows) to present the single named counter-write validation procedure from R-4 — read the current `.counter`, verify digit-parse, write the successor value satisfying the monotonic invariant (counter after write >= remote_number + 1), citing `_next_number` semantics — as the SOLE documented mechanism; no alternative mechanism offered. What must be true: read shows the named procedure present; no bare unvalidated echo-style write remains. Minimum change only. Pre-clean `pipeline-green-*`.
  - SC reference: SC-3
- [ ] 21. (**task-card**) Post-regression — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: run regression test patterns after GREEN; pre-clean `pipeline-post-regression-*`.
  - SC reference: SC-3
- [ ] 22. (**task-card**) Verify — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: verify SC-3 — read-back of Step 7 (single verification anchor) confirms the named counter-write validation procedure present as the sole documented mechanism citing `_next_number` semantics; grep for a bare unvalidated `echo $((...))` counter write returns no match. Pre-clean `pipeline-verify-*`.
  - SC reference: SC-3
- [ ] 23. (**direct**) Commit-inline — orchestrator runs `git add .opencode/skills/issue-operations-sync/tasks/import-remote.md && git commit -m "fix(sync): specify counter-write validation procedure in import-remote Step 7 (SC-3)"` — no sub-agent dispatch.
  - SC reference: SC-3

**SC-3 triplet containment:** RED (step 19), GREEN (step 20), COMMIT (step 23) — all within Phase 3; no cross-phase split.

**Post-implementation steps (Phase 3 range 24-31):**

- [ ] 24. (**task-card**) Audit — dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence; context: adversarial audit of the rewritten card against SC-1/SC-2/SC-3 and R-1..R-6. Pre-clean `pipeline-audit-*`.
  - SC reference: all
- [ ] 25. (**direct**) Z3 check — orchestrator runs `.opencode/tools/solve check --state-path tmp/2477/artifacts/state.yaml --contract-path tmp/2477/artifacts/dependency-contract.yaml` directly — no sub-agent dispatch; pre-clean `pipeline-z3-check-*`.
  - SC reference: none (gate)
- [ ] 26. (**task-card**) Structural checks — dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`, context: finishing checklist (lint — markdown lint/format checks per Build/Lint/Test Commands; typecheck not applicable to markdown-only change). Pre-clean `pipeline-structural-checks-*`.
  - SC reference: none (gate)
- [ ] 27. (**task-card**) Pre-PR gate — dispatch `task(..., prompt: "execute verify task from verification-before-completion")`, context: read all SC verdicts; BLOCKS if any FAIL — DONE_WITH_CONCERNS coerces to FAIL per implementation-workflow coercion rules. Pre-clean `pipeline-pre-pr-gate-*`.
  - SC reference: SC-1, SC-2, SC-3
- [ ] 28. (**task-card**) Regression check — dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, context: final regression check before PR. Pre-clean `pipeline-regression-check-*`.
  - SC reference: none (gate)
- [ ] 29. (**task-card**) Review-prep — dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`, context: prepare PR review context for the stacked single-branch PR.
  - SC reference: none (gate)
- [ ] 30. (**task-card**) Create PR — dispatch `task(..., prompt: "execute create task from git-workflow-pr")`, context: squash the three implementation commits into one commit per issue at PR creation; PR targets the trunk `.opencode` repo; no merge by agent (human-only merge).
  - SC reference: none (gate)
- [ ] 31. (**task-card**) Exec summary — dispatch `task(..., prompt: "execute completion task from completion-core")`, context: generate completion executive summary; append lifecycle event `plan_created`-chain completion; chat-only report.
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

## lifecycle_events

- timestamp: "2026-09-30T00:21:40Z"
  event: plan_created
  artifact: ".opencode/.issues/2477/plan.md"
  phase_count: 3
  recorded_by: "writing-plans/completion"