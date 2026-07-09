## Goal

Standardize PR body VbC results into a 4-column table format (ID, Criterion, Test, Result) with auto-detected test-type annotations, populated from VbC output.

## Architecture

The VbC table flows through three pipeline stages:
1. **VbC output** (`verification-before-completion`) produces structured per-SC evidence with test-type annotations
2. **PR body generation** (`git-workflow/pr-creation`) reads VbC artifacts and renders the 4-column table
3. **Finishing checklist** (`finishing-a-development-branch/checklist`) verifies the table exists in the PR body

Test-type annotations are auto-detected by inspecting test infrastructure usage (fixtures, mocks, testcontainers).

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/verification-before-completion/tasks/verify.md` | Add structured VbC table output format with test-type annotations |
| `.opencode/skills/verification-before-completion/tasks/collect.md` | Add test-type detection step during evidence collection |
| `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` | Update PR body template to include VbC 4-column table |
| `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` | Add checklist item verifying VbC table presence in PR body |
| `.opencode/skills/verification-before-completion/tasks/behavioral-test-evaluation.md` | Add test-type annotation output to evaluation results |

## Phase Table

| Phase | Description | Files Modified | Chain Dependency |
|-------|-------------|----------------|------------------|
| 1 | Update VbC output to produce structured 4-column table data with test-type annotations | `verify.md`, `collect.md`, `behavioral-test-evaluation.md` | None (foundation) |
| 2 | Update PR body generation to include the VbC table | `create-pr.md` | Phase 1 |
| 3 | Update finishing checklist to verify table presence | `checklist.md` | Phase 2 |
| 4 | Auto-detect test-type annotations from infrastructure usage | `collect.md`, `behavioral-test-evaluation.md` | Phase 1 |

## Exit Criteria

- VbC verification output includes a structured 4-column table (ID, Criterion, Test, Result) with test-type annotations
- PR body template renders the VbC table from VbC artifacts
- Finishing checklist verifies VbC table presence in PR body
- Test-type annotations are auto-detected from test infrastructure usage patterns
- All implementation-pipeline gates enumerated in phase structure

## Implementation Pipeline Gates (Mandatory per Phase)

Each phase MUST pass through these gates in order:
1. `sc-coherence-gate` — verify spec coherence
2. `pre-red-baseline` — establish baseline
3. `red-phase` — write failing test
4. `z3-check-red` — verify RED
5. `red-doublecheck` — verify RED evidence
6. `post-red-enforcement` — RED gate
7. `green-phase` — implement
8. `z3-check-green` — verify GREEN
9. `post-green-enforcement` — GREEN gate
10. `checkpoint-tag-create` — save checkpoint
11. `checkpoint-commit` — commit checkpoint
12. `structural-checks` — lint/typecheck
13. `green-doublecheck` — verify GREEN evidence
14. `green-vbc` — verification before completion
15. `pre-pr-gate` — pre-PR gate
16. `audit` — audit step
17. `cross-validate` — consensus check
18. `regression-check` — regression tests
19. `review-prep` — prepare review
20. `exec-summary` — completion

## Self-Review Evidence

- Spec #1802 approved with `approved-for-pr` label
- Spec-to-plan cascade applies (auto-approved for `for_pr` scope)
- Single-issue spec, no sub-issues needed
- All 4 requirements mapped to phases
- Implementation-pipeline gates enumerated
