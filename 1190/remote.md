---
remote_issue: 1190
remote_url: "https://github.com/michael-conrad/.opencode/issues/1190"
last_sync: "2026-06-14T14:41:17Z"
source: github
---

## Summary

The `reconcile_issue_graph` function was moved from the pre-image of `cleanup.md` (commit `2d436309` Phase 5 decomposition) into `cleanup/issue-closure.md` (line 159). Cross-file callers that reference `reconcile-issue-graph` may expect a different return structure than what the function now produces. This spec audits all callers and fixes any signature mismatches.

## Root Cause

Commit `2d436309` decomposed `cleanup.md` (1518 lines) into 16 atomic task files. The `reconcile_issue_graph` function (pre-image lines 476-533) was moved to `cleanup/issue-closure.md` (line 159). The function signature and return structure may have changed during the move, and cross-file callers were not updated.

## Affected Files

| File | Change |
|------|--------|
| `skills/git-workflow/tasks/cleanup/issue-closure.md` | Canonical source — verify function signature |
| `skills/approval-gate/tasks/reconcile-issue-graph.md` | Standalone task — verify caller compatibility |
| `skills/approval-gate/tasks/pre-impl/reconcile-status.md` | References reconcile-issue-graph procedure — verify alignment |
| `skills/approval-gate/tasks/verify-authorization/sub-issue-verification.md` | Dispatches reconcile-issue-graph — verify contract |

## Phase 1: Audit reconcile_issue_graph Signature

Read the canonical function in `cleanup/issue-closure.md` (line 159) and document:

1. **Function signature:** `def reconcile_issue_graph(merged_pr_number, pr_files)` — verify parameters
2. **Return structure:** `{"orphaned": orphaned, "reconciled": reconciled, "visited": visited}` — verify keys and types
3. **Side effects:** Closes sub-issues via `github_issue_write` when deliverables are covered by PR files — document

## Phase 2: Audit Each Caller

### 2a: `tasks/reconcile-issue-graph.md`

This is the standalone reconciliation task. Verify:
- Does it call `reconcile_issue_graph` directly or re-implement the logic?
- If it calls directly: does it pass the correct parameters (`merged_pr_number`, `pr_files`)?
- If it re-implements: does the re-implementation match the canonical signature?

### 2b: `tasks/pre-impl/reconcile-status.md`

This task invokes `reconcile-issue-graph` procedure (line 50-58). Verify:
- Does it pass findings in the expected format?
- Does it expect the return structure to match `{"orphaned", "reconciled", "visited"}`?

### 2c: `tasks/verify-authorization/sub-issue-verification.md`

This task dispatches `reconcile-issue-graph` after graph traversal (line 93). Verify:
- Does it pass the correct context?
- Does it handle the return structure correctly?

## Phase 3: Fix Mismatches

For each caller where the signature or return structure doesn't match:
- Update the caller to match the canonical signature
- If the caller needs different data, add a wrapper or adapter
- Document any intentional deviations

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Canonical `reconcile_issue_graph` signature documented in audit report | `semantic` |
| SC-2 | All 3 callers (`reconcile-issue-graph.md`, `reconcile-status.md`, `sub-issue-verification.md`) verified against canonical signature | `semantic` |
| SC-3 | Any mismatches fixed with updated caller code | `structural` |
| SC-4 | Behavioral test: post-merge cleanup with sub-issues → reconcile_issue_graph correctly closes covered sub-issues and reports orphaned | `behavioral` |

## Non-Goals

- Not modifying the `reconcile_issue_graph` function itself — only callers
- Not changing the reconciliation logic or adding new features
- Not modifying `cleanup/issue-closure.md` beyond verifying the signature

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/reconcile-signature-audit`
