# Plan Input Verification Ledger — issue #2477

Written once (create.md step 3a). Subsequent steps re-read THIS file, not sources.

## Issue state + labels (from issue.yaml)

- issue.yaml present; status: open
- labels: [approved-for-for_pr] (canonical local record)
- authorization_scope: for_pr; pr_strategy: stacked
- Title: [ENHANCEMENT] issue-operations-sync import-remote task card references legacy mirror filenames comments.md/state.md not used by local-issues schema

## SC list with evidence types (from spec §3 / sc-summary.yaml)

- SC-1 (string): import-remote.md contains zero references to legacy mirror filenames (comments.md, remote.md, state.md) — verification: `grep -c 'comments\.md\|remote\.md\|state\.md' .opencode/skills/issue-operations-sync/tasks/import-remote.md` returns 0
- SC-2 (string): Step 4 completeness gate enumerates actual schema files (issue.yaml, comments.yaml, links.yaml [+ spec.md]) — verification: positive grep for those filenames anchored at the Step 4 completeness gate block returns matches
- SC-3 (string): Step 7 specifies the named counter-write validation procedure (read .counter, digit-parse check, successor write satisfying monotonic invariant counter after write >= remote_number + 1) as the sole documented mechanism, citing _next_number semantics — verification: read of revised Step 7

## Structure artifact mappings

- Phase 1 (schema-accuracy-item-1): SC-1; dependency edges: none
- Phase 2 (completeness-gate-item-2): SC-2; depends on phase 1 (same-file sequential TDD)
- Phase 3 (counter-validation-item-3): SC-3; depends on phase 2 (same-file sequential TDD)
- DAG acyclic: true; triplet colocation PASS for SC-1/SC-2/SC-3
- Per-phase skill_task_selection: pre-regression (tdd), pre-regression-verify (vbc), red (tdd), green (tdd), post-regression (tdd), verify (vbc), commit-inline (orchestrator direct)

## Target file + ground truth

- Target file: .opencode/skills/issue-operations-sync/tasks/import-remote.md (single file, documentation-only rewrite)
- Ground truth (read-only): .opencode/tools/local-issues — YAML_FILES = (issue.yaml, comments.yaml, links.yaml), MARKDOWN_FILES = (spec.md), _next_number fail-fast digit-parse

## CLI surface flags needed

- `./.opencode/tools/local-issues update .opencode#2477 --labels approved-for-for_pr,spec-cleared` (labels array REPLACES entire array — include all existing labels plus new)

## Plan composition formats (from standards read once)

- Frontmatter order: plan_schema_version, issue, title, authorization_scope, pr_strategy, phase_count, dispatch
- Phase-table columns: Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch
- Dispatch indicators: (**direct**) / (**task-card**) only
- Pre-Flight Guard block copied VERBATIM from 023-pre-flight-guard.md with reason ORCHESTRATOR_ONLY_PLAN
- Continuous step numbering 1..N; no fenced code blocks in body; no TBD; exit criteria C1..Cn
- Cost frames: dark-prose-007 pattern (action cost / skipping cost, one per phase)
- Implementation workflow per-task cycle: pre-regression, pre-regression-verify, red, green, post-regression, verify, commit-inline; post-implementation: audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary