# Plan Input Verification Ledger — .opencode#2440

Written once; all downstream plan steps read THIS ledger, not the sources.

## Issue state + labels
- Issue: .opencode#2440 — `[BUG] trunk-tip-verification gate unsatisfiable after legitimate trunk-tip pull — submodule pointer staleness treated as FAIL`
- Status: open
- Local labels (canonical, from `issue.yaml`): `approved-for-for_pr`
- authorization_scope: `for_pr` — pr_strategy: `stacked`
- issues_prefix: `.opencode/.issues` — project_root: `/home/muksihs/git/opencode-config`

## SC list (from spec.md, verified)
| SC | Criterion (summary) | Evidence Type |
|----|---------------------|---------------|
| SC-1 | Pointer-only ` M <submodule>` in safe state → `parent_clean` WARN, gate DONE | behavioral |
| SC-2 | `+` prefix in safe state → `submodule_pointer_match` WARN, gate DONE | behavioral |
| SC-3 | Step 8 fail-open branch uses if/else, no `continue` in foreach body | structural |
| SC-4 | Exit Criteria + Result Contract document PASS \| WARN \| FAIL; SUBMODULE_UNMERGED_COMMIT sole BLOCKED trigger | structural |
| SC-5 | Regression: local-only pointer commit still BLOCKs (SUBMODULE_UNMERGED_COMMIT); safe-state scenario DONE with WARNs | behavioral |

## Structure artifact mappings (verified)
- Phase 1 — task-card safe-state semantics: SC-1..SC-4; target `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md`; items 1–4 map 1:1 to SC-1..SC-4 (co-located RED/GREEN/verify/commit)
- Phase 2 — behavioral regression verification: SC-5; target `.opencode/tests-v2/behaviors/` (regression scenario)
- DAG edges: phase-1 (SC-1, SC-2, SC-4) → phase-2 (SC-5); no cycles; no forward dependencies
- Triplet co-location verified — no split triplets

## CLI surface needed
- Local label write: `./.opencode/tools/local-issues update .opencode#2440 --labels spec-cleared approved-for-for_pr` (update REPLACES entire labels array — must carry existing labels)
- Remote label write: best-effort GitHub API on michael-conrad/.opencode — never blocking

## Reference-card steps verified (implementation-workflow.md)
- Pre-implementation: `pre-regression` (tdd phase-0), `pre-regression-verify` (vbc verify)
- Daisy chain per task: `red`, `green`, `post-regression` (tdd phase-4), `verify` (vbc), `commit-inline` (orchestrator, direct)
- Post-implementation: `audit`, `z3-check` (direct), `structural-checks` (finishing-a-development-branch checklist), `pre-pr-gate` (vbc), `regression-check` (tdd phase-4), `review-prep` + `create-pr` (git-workflow-pr), `exec-summary` (completion-core)

## Format standards pinned (plan-structure-standards.md §Composition Conventions)
- Frontmatter order: plan_schema_version, issue, title, authorization_scope, pr_strategy, phase_count, dispatch
- Phase-table columns: Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch
- Continuous step numbering 1..N; dispatch cell summary form; no fenced code blocks in body; exit criteria C1..Cn; Pre-Flight Guard block verbatim (reason code ORCHESTRATOR_ONLY_PLAN); multi-phase → split files
