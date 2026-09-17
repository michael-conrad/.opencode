---
plan_schema_version: 1
issue: 2446
title: "local-issues --labels: comma-separated parsing, malformed rejection, help text"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
dispatch:
  - "phase-1: test-driven-development (red, green, post-regression), verification-before-completion (verify), orchestrator (commit-inline)"
---

# Implementation Plan — .opencode#2446: local-issues --labels normalization, rejection, help text

**Issue:** .opencode/.issues/2446/spec.md
**Repo:** michael-conrad/.opencode (path: `.opencode`)
**Affected file:** `.opencode/tools/local-issues` + its unit test file under `.opencode/tests/`

## Goal

Fix `local-issues update/create --labels` so comma-separated input is normalized (split on commas, strip whitespace, drop empties), malformed remainder is rejected fail-fast before any write or auto-commit, and help text documents accepted formats on both subparsers.

## Blast Radius

- Single file modified: `.opencode/tools/local-issues` (argparse `--labels` definitions on `update`/`create` subparsers; `cmd_update`; `cmd_create`; new `_normalize_labels` helper).
- New/updated unit tests under `.opencode/tests/` (test files for local-issues).
- No schema change; labels remain a YAML list of strings. No callers outside the tool.

## Admonishments

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Label normalization helper + fail-fast rejection + help text | `--labels` input handling in `.opencode/tools/local-issues` | SC-1, SC-2a, SC-2b, SC-3a, SC-3b | none | 1-33 | direct (1-3, 8, 12, 16, 20, 24, 25, 27) + task-card (4-7, 9-11, 13-15, 17-19, 21-23, 26, 28-33) |

## Pre-Implementation Steps

- [ ] 1. (**direct**) Coherence gate — re-read the spec at `.opencode/.issues/2446/spec.md` and this plan; confirm SC list, evidence types, and phase mapping match the structure artifact; halt on any mismatch.
  - SCs: all (coverage check)
- [ ] 2. (**direct**) Baseline check — run existing local-issues unit tests (`uv run pytest .opencode/tests/`) to record a green baseline before any change.
  - SCs: all (baseline)
- [ ] 3. (**direct**) Pre-regression cleanup — `rm -f ./tmp/2446/artifacts/pipeline-pre-regression-*`, then dispatch pre-regression.
  - SCs: all (gate)
- [ ] 4. (**task-card**) Pre-regression — `task(..., prompt: "execute phase-0 task from test-driven-development")` — run regression test patterns before RED phase; then `task(..., prompt: "execute verify task from verification-before-completion")` (pre-regression-verify; pre-clean `pipeline-pre-regression-verify-*` first).
  - SCs: all (gate)

# Phase 1 — Label normalization helper + fail-fast rejection + help text

## Phase Metadata

- **Concern:** `--labels` input handling — normalization, fail-fast rejection, help text — in `.opencode/tools/local-issues`.
- **Files:** `.opencode/tools/local-issues`; unit tests under `.opencode/tests/`.
- **SCs:** SC-1, SC-2a, SC-2b, SC-3a, SC-3b.
- **Dependencies:** none (single-phase DAG).
- **Entry condition:** baseline green, pre-regression verified.
- **Exit condition:** all five SCs verified and committed, daisy-chained in SC order.

## Code Path Coverage

- `cmd_update` (argparse `--labels` definition + label handling) — SC-1, SC-2a, SC-3a.
- `cmd_create` (argparse `--labels` definition + label handling) — SC-1, SC-2b, SC-3b.
- New `_normalize_labels` pure helper (no I/O) — SC-1.
- `_ensure_needs_approval` ordering preserved after normalization (R-5) — SC-1 verify.

## Cross-Cutting SCs

- None — each SC maps to exactly one code target; no SC spans multiple phases (single phase).

## Interface Boundaries

- CLI boundary: `--labels` accepts comma-separated and space-separated tokens; malformed remainder → CLI error exit, no write, no auto-commit.
- YAML boundary: `issue.yaml` labels remain a list of clean strings; value cleanliness changes, schema does not.

## State Transitions

- Malformed remainder → CLI error before `issue.yaml` write and before `_auto_commit`; no partial state.
- Well-formed input → normalization → `_ensure_needs_approval` (first-label ordering preserved) → write → auto-commit as today.

## Step-by-Step

### Item 1 (SC-1): Label normalization helper applied to both entry points

- [ ] 5. (**task-card**) RED — `rm -f ./tmp/2446/artifacts/pipeline-red-*`, then `task(..., prompt: "execute red task from test-driven-development")` — write failing unit test asserting `_normalize_labels(['a, b']) == ['a', 'b']` and `_normalize_labels(['needs-approval']) == ['needs-approval']`; test fails because the helper does not exist.
  - SC: SC-1
- [ ] 6. (**task-card**) GREEN — `rm -f ./tmp/2446/artifacts/pipeline-green-*`, then `task(..., prompt: "execute green task from test-driven-development")` — implement pure `_normalize_labels` (split on commas, strip whitespace, drop empties, no I/O) and wire it into `cmd_update` and `cmd_create` before `_ensure_needs_approval`; RED test passes.
  - SC: SC-1
- [ ] 7. (**task-card**) Post-regression + verify — `rm -f ./tmp/2446/artifacts/pipeline-post-regression-*` and `pipeline-verify-*`, then `task(..., prompt: "execute phase-4 task from test-driven-development")` followed by `task(..., prompt: "execute verify task from verification-before-completion")` — confirm `_ensure_needs_approval` still inserts `needs-approval` first post-normalization; verify SC-1 verdict.
  - SC: SC-1
- [ ] 8. (**direct**) COMMIT — orchestrator runs `git add .opencode/tools/local-issues <test file> && git commit` — test + change as one atomic slice.
  - SC: SC-1

### Item 2a (SC-2a): Fail-fast rejection in `cmd_update`

- [ ] 9. (**task-card**) RED — pre-clean `pipeline-red-*`, then `task(..., prompt: "execute red task from test-driven-development")` — write failing unit test invoking `update` with an unresolvable malformed label token against a temp issues worktree, asserting error exit and byte-identical `issue.yaml`; fails because rejection does not exist.
  - SC: SC-2a
- [ ] 10. (**task-card**) GREEN — pre-clean `pipeline-green-*`, then `task(..., prompt: "execute green task from test-driven-development")` — add pre-write validation in `cmd_update` raising a CLI error before any mutation or `_auto_commit`; RED test passes.
  - SC: SC-2a
- [ ] 11. (**task-card**) Post-regression + verify — pre-clean `pipeline-post-regression-*` and `pipeline-verify-*`, then `task(..., prompt: "execute phase-4 task from test-driven-development")` followed by `task(..., prompt: "execute verify task from verification-before-completion")` — assert `issue.yaml` byte-identical, no commit created, no partial state.
  - SC: SC-2a
- [ ] 12. (**direct**) COMMIT — orchestrator runs `git add .opencode/tools/local-issues <test file> && git commit`.
  - SC: SC-2a

### Item 2b (SC-2b): Fail-fast rejection in `cmd_create`

- [ ] 13. (**task-card**) RED — pre-clean `pipeline-red-*`, then `task(..., prompt: "execute red task from test-driven-development")` — write failing unit test invoking `create` with an unresolvable malformed label token against a temp issues worktree, asserting error exit and no `issue.yaml` created; fails because rejection does not exist.
  - SC: SC-2b
- [ ] 14. (**task-card**) GREEN — pre-clean `pipeline-green-*`, then `task(..., prompt: "execute green task from test-driven-development")` — add pre-write validation in `cmd_create` raising a CLI error before any mutation or `_auto_commit`; RED test passes.
  - SC: SC-2b
- [ ] 15. (**task-card**) Post-regression + verify — pre-clean `pipeline-post-regression-*` and `pipeline-verify-*`, then `task(..., prompt: "execute phase-4 task from test-driven-development")` followed by `task(..., prompt: "execute verify task from verification-before-completion")` — assert no `issue.yaml` created and no commit created.
  - SC: SC-2b
- [ ] 16. (**direct**) COMMIT — orchestrator runs `git add .opencode/tools/local-issues <test file> && git commit`.
  - SC: SC-2b

### Item 3a (SC-3a): Help text on `update` subparser

- [ ] 17. (**task-card**) RED — pre-clean `pipeline-red-*`, then `task(..., prompt: "execute red task from test-driven-development")` — write failing test parsing `update --help` output asserting a `--labels` help string documents comma-separated and space-separated input plus rejection; fails (no per-argument help).
  - SC: SC-3a
- [ ] 18. (**task-card**) GREEN — pre-clean `pipeline-green-*`, then `task(..., prompt: "execute green task from test-driven-development")` — add the help string to `--labels` on the `update` subparser; RED test passes.
  - SC: SC-3a
- [ ] 19. (**task-card**) Post-regression + verify — pre-clean `pipeline-post-regression-*` and `pipeline-verify-*`, then `task(..., prompt: "execute phase-4 task from test-driven-development")` followed by `task(..., prompt: "execute verify task from verification-before-completion")` — assert content present on the `update` subparser; verify SC-3a verdict.
  - SC: SC-3a
- [ ] 20. (**direct**) COMMIT — orchestrator runs `git add .opencode/tools/local-issues <test file> && git commit`.
  - SC: SC-3a

### Item 3b (SC-3b): Help text on `create` subparser

- [ ] 21. (**task-card**) RED — pre-clean `pipeline-red-*`, then `task(..., prompt: "execute red task from test-driven-development")` — write failing test parsing `create --help` output asserting a `--labels` help string documents accepted formats plus rejection; fails (no per-argument help).
  - SC: SC-3b
- [ ] 22. (**task-card**) GREEN — pre-clean `pipeline-green-*`, then `task(..., prompt: "execute green task from test-driven-development")` — add the help string to `--labels` on the `create` subparser; RED test passes.
  - SC: SC-3b
- [ ] 23. (**task-card**) Post-regression + verify — pre-clean `pipeline-post-regression-*` and `pipeline-verify-*`, then `task(..., prompt: "execute phase-4 task from test-driven-development")` followed by `task(..., prompt: "execute verify task from verification-before-completion")` — assert content present on the `create` subparser; verify SC-3b verdict.
  - SC: SC-3b
- [ ] 24. (**direct**) COMMIT — orchestrator runs `git add .opencode/tools/local-issues <test file> && git commit`.
  - SC: SC-3b

## Phase Completion Block

- [ ] 25. (**direct**) Verify all five SC verdicts (SC-1, SC-2a, SC-2b, SC-3a, SC-3b) are PASS with evidence artifacts under `./tmp/2446/artifacts/`; any FAIL blocks phase exit.

**Cost frame:** Running the five SC verification suites costs minutes of execution time. Skipping means malformed labels keep crossing the CLI→issue.yaml boundary, corrupting the canonical `approved-for-*` authorization record — discovered days-to-weeks later in approval-gate checks at 100× fix cost.

## Concern Transition

Phase 1 is the only phase — proceed to post-implementation steps.

# Post-Implementation Steps

- [ ] 26. (**task-card**) Audit — `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence (pre-clean `pipeline-audit-*` first).
- [ ] 27. (**direct**) Z3 check — pre-clean `pipeline-z3-check-*`, then orchestrator runs `.opencode/tools/solve check --state-path ./tmp/2446/state.yaml --contract-path ./tmp/2446/contract.yaml` if a contract exists for this issue; otherwise record not-applicable with reason.
- [ ] 28. (**task-card**) Structural checks — pre-clean `pipeline-structural-checks-*`, then `task(..., prompt: "execute checklist task from finishing-a-development-branch")` — lint, typecheck, finishing checklist.
- [ ] 29. (**task-card**) Pre-PR gate — pre-clean `pipeline-pre-pr-gate-*`, then `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL.
- [ ] 30. (**task-card**) Regression check — pre-clean `pipeline-regression-check-*`, then `task(..., prompt: "execute phase-4 task from test-driven-development")` — final regression run before PR.
- [ ] 31. (**task-card**) Review prep — `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.
- [ ] 32. (**task-card**) Create PR — `task(..., prompt: "execute create task from git-workflow-pr")` — squash to one commit for the issue; stacked PR targeting the trunk. Do not merge (human-only).
- [ ] 33. (**task-card**) Executive summary — `task(..., prompt: "execute completion task from completion-core")` — emit `plan_created` lifecycle event already recorded at plan creation; emit completion summary with `plan_file` and `phase_count: 1`.

## Exit Criteria

- [ ] C1. All five SCs verified PASS with evidence artifacts; no FAIL or INCONCLUSIVE remains.
- [ ] C2. Each SC committed in its own atomic RED/GREEN commit (test + change together).
- [ ] C3. No malformed label can reach `issue.yaml` via `update` or `create` (SC-2a, SC-2b enforced).
- [ ] C4. Help text present on both subparsers (SC-3a, SC-3b).
- [ ] C5. Audit, structural checks, pre-PR gate, and final regression check all passed.
- [ ] C6. PR created (human-only merge); no merge performed by the agent.

## Lifecycle Events

- event: plan_created
  timestamp: 2026-09-17T19:45:00-04:00
  plan_file: .opencode/.issues/2446/plan.md
  phase_count: 1
