# Plan Input Verification Ledger — Issue 2450

Written once 2026-09-17. Subsequent plan-construction steps read THIS file, not the sources.

## Issue state

- Local issue `.opencode#2450`, status `open`, labels `["approved-for-pr"]`, `remote_issue: 2450`.
- Remote: https://github.com/michael-conrad/.opencode/issues/2450 (platform github.com).
- Issues prefix: `.opencode/.issues`.

## SC list (from spec.md §3, verified 2026-09-17)

| SC | Criterion (short) | Evidence Type |
|----|-------------------|---------------|
| SC-1 | scoped `validate-yaml --number <repo>#N`: target-only validation + scoped exit codes (0 clean target amid violating neighbors; 1 only on target findings) | behavioral (pytest) |
| SC-2 | report format parity: `<path>: <error-class>` lines, same error classes, scoped output = workspace output filtered to target paths | behavioral (pytest) |
| SC-3 | analyze.md Step 5.3 gate invokes scoped `--number` form as the progress-gating check | behavioral (with-test-home) |
| SC-4 | analyze.md gate contract scoped-primary/workspace-secondary, MUST-NOT-gate-on-unrelated clause (Step 5.3 body, exit criteria, result contract) | behavioral (with-test-home) |
| SC-5 | create.md Step 6.1 gate site: scoped invocation + scoped-primary/workspace-secondary contract | behavioral (with-test-home) |
| SC-6 | `.opencode/.issues/AGENTS.md` hygiene mandate (agent repairs ALL issues-data files, authorization-free, no spec) | behavioral (with-test-home) |
| SC-7 | `.opencode/AGENTS.md` worktree section states same hygiene mandate verbatim in semantics | behavioral (with-test-home) |
| SC-8 | `.opencode/.issues/AGENTS.md` Workflow section remote-first reservation mandate (remote filed FIRST, clean-room-restartable context, BEFORE local setup; local-first = violation) | behavioral (with-test-home, remote env) |
| SC-9 | spec-creation create.md Step 3 same reservation mandate verbatim in semantics | behavioral (with-test-home, remote env) |
| SC-10 | issue-operations-core creation.md Step 2.1 same reservation mandate verbatim in semantics | behavioral (with-test-home, remote env) |

## Structure artifact mappings (structure.yaml, verified 2026-09-17)

- Phase 1 "tool — scoped validation mode in local-issues": SC-1, SC-2 (Items 1-2); files: `.opencode/tools/local-issues`, `.opencode/tests/test_local_issues/`.
- Phase 2 "gate text — analyze.md and create.md R-13 gate scoping": SC-3, SC-4, SC-5 (Items 3-5); files: `.opencode/skills/spec-creation/tasks/analyze.md`, `create.md`. Depends on Phase 1 (Items 3, 5 depend on Item 1; Item 5 depends on Item 4).
- Phase 3 "governance docs — hygiene and reservation mandates": SC-6..SC-10 (Items 6-10); files: `.opencode/.issues/AGENTS.md`, `.opencode/AGENTS.md`, `create.md`, `creation.md`. Independent — may run in parallel with Phases 1-2.
- Item deps: item-2←item-1; item-3←item-1; item-4←item-3; item-5←item-1,item-4; items 6-10 no deps.
- Triplet co-location PASS; cross-phase dependency PASS (forward-only).

## Per-task cycle steps (implementation-workflow.md, verified 2026-09-17)

Pre-implementation: `pre-regression` (tdd), `pre-regression-verify` (vbc).
Per item: `red` (tdd) → `green` (tdd) → `post-regression` (tdd) → `verify` (vbc) → `commit-inline` (orchestrator direct). Behavioral items add `PUSH` after COMMIT, before the behavioral verify run.
Post-implementation: `audit`, `z3-check` (orchestrator direct), `structural-checks` (finishing-a-development-branch), `pre-pr-gate` (vbc), `regression-check` (tdd), `review-prep` (git-workflow-pr), `create-pr` (git-workflow-pr), `exec-summary` (completion-core).
Coercions: DONE_WITH_CONCERNS→FAIL; EVIDENCE_TYPE_MISMATCH→FAIL.
Step pre-cleanup table: rm `tmp/2450/artifacts/pipeline-<step>-*` at each step start.

## CLI surface flags needed

- Label write (canonical local): `./.opencode/tools/local-issues update .opencode#2450 --labels spec-cleared --labels approved-for-pr` (update replaces the ENTIRE labels array — existing `approved-for-pr` must be included).
- Remote label write: best-effort via gh; failure never blocks.

## Key doc anchors (stable anchors, not line numbers)

- analyze.md Step 5.3 (R-13 gate), exit criteria, result contract `gate_evidence`/`blocker_reason`.
- create.md Step 6.1 (R-13 gate), Step 3 (remote-number-first), exit criteria, result contract.
- creation.md Step 2.1 (Remote-First Flow); Step 2.2 local-only counter path untouched.
- `.opencode/.issues/AGENTS.md` Authorization section (hygiene host) and Workflow section (reservation host).
- `.opencode/AGENTS.md` `### .issues/ Is a Worktree — NOT a Regular Directory` section.

## Requirements coverage (traceability, verified)

SC-1←R-1,R-3,R-5,R-9,R-10,R-11; SC-2←R-2,R-4,R-9; SC-3←R-6; SC-4←R-7; SC-5←R-8; SC-6←R-12; SC-7←R-14; SC-8←R-15; SC-9←R-16; SC-10←R-17. R-13 intentionally skipped (identifier collision).
