> **Full spec and artifacts: [`.opencode/.issues/2159/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2159)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2159/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC-FIX: verify-authorization should update issue body Status field (#2156)

## Objective

Authorize the fix for `verify-authorization` not updating the issue body's `### Status` field when authorization scope is `for_spec` or higher.

## Background

Bug #2156: When `verify-authorization` is called with scope `for_pr`, it applies the `approved-for-pr` label but does NOT update the issue body's `### Status` field from "Draft" to "Approved". The gap-fill cascade checks the Status field (not labels) to determine if a spec is approved, so the cascade never triggers.

Root cause: verify-authorization's 5-step workflow (Resolve scope → Record authorization → Verify recording → Apply label → Auto-dispatch) does not update the Status field in any step.

Proposed fix: Add a sub-step to Step 2 (Record authorization) that updates `### Status` to "Approved" when scope is `for_spec` or higher.

## Not Included

- Changes to gap-fill cascade logic (only fixes the Status field update)
- Changes to label application behavior
- Changes to `for_analysis` scope handling

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A sub-step is added to Step 2 (Record authorization) in verify-authorization workflow that updates `### Status` to "Approved" | `string` | grep the task file for `### Status` and `Approved` in the Step 2 section |
| SC-2 | The Status field update only occurs when `authorization_scope` is `for_spec` or higher (not for `for_analysis`) | `semantic` | Sub-agent reads the task file and judges whether the scope guard is correct |
| SC-3 | The field update uses `github_issue_write` to edit the issue body | `string` | grep the task file for `github_issue_write` call in Step 2 |

## Requirements

1. The verify-authorization workflow SHALL update the issue body's `### Status` field to "Approved" when recording authorization for scope `for_spec` or higher.
2. The Status field update SHALL NOT occur for `for_analysis` scope.
3. The Status field update SHALL use `github_issue_write` to edit the issue body.

## Items

| Item | SCs | Description |
|------|-----|-------------|
| 1 | SC-1, SC-2, SC-3 | Add sub-step to Step 2 of verify-authorization that updates `### Status` to "Approved" with scope guard (`for_spec` or higher) using `github_issue_write` |

## Dependencies

- Bug #2156 (parent bug report)
- `approval-gate-scope/SKILL.md` — the verify-authorization workflow to be modified

## Traceability

| Requirement | SC(s) | Item |
|-------------|-------|------|
| REQ-1 | SC-1, SC-2 | 1 |
| REQ-2 | SC-2 | 1 |
| REQ-3 | SC-3 | 1 |
