# Plan Input Verification Ledger — issue 2437

Written once (2026-09-20). All subsequent plan-composition steps re-read THIS ledger, not the sources.

## Issue state + labels (from issue.yaml, read 2026-09-20)

- Issue: .opencode#2437, status open
- Labels: `approved-for-pr` (single label; all future label writes must include it)
- github_url: https://github.com/michael-conrad/.opencode/issues/2437

## SC list with evidence types (from spec.md)

| SC | Evidence Type | Verification Method | Item | File(s) |
|----|---------------|---------------------|------|---------|
| SC-1 | behavioral | tests-v2 enforcement scenario via with-test-home opencode run; stderr agent-action assertions | 1 | .opencode/skills/git-workflow-pr/SKILL.md |
| SC-2 | string | grep: `task-card` + dispatch-vocabulary-table citation present; no contradictory marker | 2 | .opencode/skills/git-workflow-pr/SKILL.md |
| SC-3 | semantic | clean-room sub-agent read confirms exactly one classification per step group (Steps 0-1, 2-4, 5-7: orchestrator-direct) | 3 | .opencode/skills/git-workflow-pr/tasks/pr-creation.md |
| SC-4 | semantic | clean-room sub-agent read confirms enforcement-gate.md, squash-push.md, create-pr.md listed as task-card dispatch points | 4 | .opencode/skills/git-workflow-pr/tasks/pr-creation.md |
| SC-5 | string | grep: git-workflow/SKILL.md "Create a PR" entry contains `task-card`; old sub-agent-dispatch prompt absent | 5 | .opencode/skills/git-workflow/SKILL.md |

## Structure artifact mappings

- Single phase: Phase 1 "pr-creation routing-metadata reclassification", SCs 1-5, no DAG edges
- Intra-phase item order 1→2→3→4→5 (daisy-chained)
- Triplet colocation verified; no cross-phase dependencies

## Per-task cycle steps (from implementation-workflow reference card)

Per-item: red → green → post-regression → verify → commit-inline (orchestrator-direct git add+commit).
Pre-implementation: pre-regression, pre-regression-verify.
Post-implementation: audit → z3-check → structural-checks → pre-pr-gate → regression-check → review-prep → create-pr → exec-summary.

## CLI surface flags needed

- `.opencode/tools/local-issues update .opencode#2437 --labels approved-for-pr,spec-cleared` (labels array is REPLACED — must include existing `approved-for-pr`)
- Behavioral scenario: `bash .opencode/tests-v2/with-test-home opencode run '<message>'`

## Key requirements constraints

- R-6: fix resolves contradiction by removing/rewriting markers directly — no overriding clauses
- R-7: preserve + append existing bylines
- SC-1 evidence: behavioral only — structural substitute is EVIDENCE_TYPE_MISMATCH → FAIL
- Plan format: single-phase → plan.md sole file; dispatch indicators `(**direct**)`/`(**task-card**)`; continuous step numbering 1..N; no fenced code blocks in body; no line numbers; frontmatter per pinned convention (plan_schema_version, issue, title, authorization_scope, pr_strategy, phase_count, dispatch)
