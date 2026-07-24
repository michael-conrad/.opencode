---
remote_issue: 1203
remote_url: "https://github.com/michael-conrad/.opencode/issues/1203"
last_sync: "2026-06-14T17:08:08Z"
source: github
---

## Summary

The pre-push hook blocks direct pushes to `main`/`master`/`dev` — but the error message prints `SKIP_BRANCH_PROTECTION=1` as the workaround. The pre-commit hook blocks submodule-only commits — but checks `SKIP_SUBMODULE_GATE` as a bypass. A gate with a documented override is not enforcement. Remove the env var bypasses. Replace the error messages with a clear remediation path: refer to the correct git-workflow task or to the implementation workflow.

## Root Cause

The bypass env vars were added for legitimate edge cases (tag pushes, rollback merges). But documenting them in the error message itself makes every enforcement event a suggestion. GitHub branch protection provides real enforcement at the repo level. The hooks should guide the agent toward the correct workflow.

## Affected Files

| File | Change |
|------|--------|
| `.git/modules/.opencode/hooks/pre-push` | Remove `SKIP_BRANCH_PROTECTION` env var; update gate error message to refer to git-workflow pre-work task and implementation pipeline; keep branch protection gate |
| `.git/modules/.opencode/hooks/pre-commit` | Remove `SKIP_SUBMODULE_GATE` env var; keep Gate 3 (submodule bump prevention) with updated error message |
| `.opencode/AGENTS.md` | Remove any documentation referencing these bypass env vars |

## Spec

### Phase 1: Clean up pre-push hook

1. Remove the `SKIP_BRANCH_PROTECTION` environment variable check from the branch protection gate
2. Replace the error message with:
   ```
   ERROR: Direct pushes to 'main', 'master', and 'dev' are blocked.
   A feature branch + pull request is mandatory.
   Run the pre-work task from git-workflow to create a feature branch.
   ```
   For pushes that are part of an approved implementation, the full implementation workflow (implementation-pipeline) handles branch creation, commits, and PR creation through its standard gate sequence. Direct pushes to protected branches bypass all pipeline gates.
3. No mention of any env var bypass or override

### Phase 2: Clean up pre-commit hook

1. Remove the `SKIP_SUBMODULE_GATE` environment variable check from the submodule bump gate (Gate 3)
2. Ensure the gate error message instructs the correct remediation path without mentioning any env var override
3. No mention of any bypass or override in error output

### Phase 3: Remove env var documentation from AGENTS.md

Search for `SKIP_BRANCH_PROTECTION` and `SKIP_SUBMODULE_GATE` references in `.opencode/AGENTS.md` and any other agent-facing files. Remove any documentation that describes these as valid operation mechanisms.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | pre-push hook blocks direct push to main/master/dev without env var override | `behavioral` |
| SC-2 | Error message for blocked push references git-workflow pre-work task — no bypass instructions | `string` |
| SC-3 | pre-commit hook blocks submodule-only commits without env var override | `behavioral` |
| SC-4 | Error message for submodule bump shows correct remediation path — no bypass instructions | `string` |
| SC-5 | No `SKIP_BRANCH_PROTECTION` or `SKIP_SUBMODULE_GATE` references remain in agent-facing files | `string` |

## Non-Goals

- Not removing the branch protection or submodule bump gates themselves — only the bypass env vars
- Not changing GitHub branch protection rules (that's repo-level, not hook-level)
- Not modifying the parent repo's hooks (they don't have these bypass vars)

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/remove-hook-bypass-envvars`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)