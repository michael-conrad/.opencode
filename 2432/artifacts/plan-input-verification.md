# Plan Input Verification Ledger — .opencode#2432

Verified once at plan creation; re-read THIS ledger, not the sources, for subsequent steps.

## Issue state + labels (from `issue.yaml`, read 2026-09-15)

- Issue: `.opencode#2432`, status `open`
- Labels (current, canonical local): `approved-for-pr`
- Authorization scope: `for_pr` (from `approved-for-pr`); PR strategy: `stacked`
- Target path for label write: `.opencode/.issues/2432/issue.yaml` via `./.opencode/tools/local-issues update .opencode#2432 --labels approved-for-pr,spec-cleared`
  (CLI `update` REPLACES the entire labels array — must include `approved-for-pr` + `spec-cleared`)

## SC list with evidence types (from `spec.md`)

| SC | Title | Evidence type |
|----|-------|---------------|
| SC-01 | Qualifier enforcement on all commands | behavioral |
| SC-02 | PROJECT_DIR anchoring of identity + discovery | behavioral |
| SC-03 | Worktree bootstrap remote-tracking remediation | behavioral |
| SC-04 | Counter hygiene — resolved-repo counter targeting | behavioral |
| SC-05 | YAML parse hardening (warn-and-skip) | behavioral |
| SC-06 | validate-yaml subcommand | behavioral |
| SC-07 | Malformed tracking file repair | behavioral |
| SC-08 | doctor subcommand | behavioral |
| SC-09 | Pipeline validate-yaml gate insertion | behavioral |

All 9 SCs: behavioral evidence type.

## Structure artifact phase/SC mappings (from `structure.yaml`, acyclic: true, triplet co-location verified)

| Phase | Name | Items (SCs) | Depends on |
|-------|------|-------------|-----------|
| phase-1-tool-core-identity | Qualifier enforcement + PROJECT_DIR anchoring | 1 (SC-01), 2 (SC-02) | — |
| phase-2-tool-core-infra | Bootstrap remediation + counter hygiene + doctor | 3 (SC-03), 4 (SC-04), 8 (SC-08) | phase-1 |
| phase-3-parse-gate | YAML warn-and-skip hardening + validate-yaml | 5 (SC-05), 6 (SC-06) | — |
| phase-4-repair | Malformed tracking file repair | 7 (SC-07) | phase-3 |
| phase-5-integration | Pipeline validate-yaml gate insertion | 9 (SC-09) | phase-3 |

DAG: phase-1 → phase-2; phase-3 → phase-4; phase-3 → phase-5. No circular dependencies.

## Per-task cycle steps (from implementation-workflow reference card)

Per-item: RED → GREEN → post-regression → verify → commit-inline.
Pre-implementation (once per plan): pre-regression, pre-regression-verify.
Post-implementation (once per plan, last phase): audit → z3-check → structural-checks → pre-pr-gate → regression-check → review-prep → create-pr → exec-summary.

## CLI surface flags needed

- `./.opencode/tools/local-issues update .opencode#2432 --labels <csv>` (labels write, auto-commit+push)
- Phase-4 repair commits: tool auto-commit on issues-data worktree branches (R-10) — orchestrator does not run parent-repo git for repair.

## Coherence Gate — 2026-09-15 (executing-plans pre-implementation step 1)

- Outcome: PASS
- SC mapping: SC-01..SC-09 each map to exactly one item in exactly one phase (structure.yaml verified)
- Phase DAG: acyclic — phase-1 → phase-2; phase-3 → phase-4; phase-3 → phase-5
- Plan file: .opencode/.issues/2432/plan.md (5 phases, 59 numbered steps)
