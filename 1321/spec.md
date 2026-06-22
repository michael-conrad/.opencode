# [SPEC-FIX] Fix issues-data URL construction and plan-file repo routing — systemic 404 defect

## Problem Statement

The issues-data URL construction in `spec-creation/tasks/write.md` Step 7r produces 404 URLs, and the plan-file routing logic consistently pushes to the wrong repo.

### Root Cause 1: Conflicting URL Patterns + Hardcoded Platform Assumptions

Two different URL patterns exist in `spec-creation/tasks/write.md`, both with platform-specific hardcoding.

### Root Cause 2: Two Conflicting `.issues/AGENTS.md` Files

Two `.issues/AGENTS.md` files exist with different directory layouts.

### Root Cause 3: Repo Routing Confusion

When a spec is in the `.opencode` submodule repo, the agent must push plan files to the `.opencode` repo's `issues-data` branch.

### Root Cause 4: Manual File Placement Bypasses `local-issues sync`

Plan files created manually are not auto-committed.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Gate | Verification Method |
|----|-----------|---------------|------------------|---------------------|
| SC-1 | Step 7r URL pattern uses `{html_url}/{owner}/{repo}/tree/issues-data/{N}` (no `.issues/` prefix, no hardcoded `github.html_url`) | `string` | CI | `grep` for `tree/issues-data/.issues/` absent from `write.md`; `grep` for `{html_url}` present in Step 7r URL construction; `grep` for `github.html_url` absent from URL construction lines |
| SC-2 | Step 6.8 URL pattern matches Step 7r (both use `{html_url}/{owner}/{repo}/tree/issues-data/{N}`) | `string` | CI | `grep` for `{html_url}` in both Step 6.8 and Step 7r; verify no `.issues/` prefix in either |
| SC-3 | URL construction includes per-repo resolution: `html_url`, `owner`, `repo` come from session-init repo entry matching the issue's repo | `string` | CI | `grep` for `session-init` or `Repo Information` in URL construction instructions; `grep` for per-repo resolution rule |
| SC-4 | Only one `.issues/AGENTS.md` defines the canonical directory layout; the other references it | `string` | CI | `grep` for `canonical` or `see` cross-reference in the non-canonical AGENTS.md |
| SC-5 | `local-issues sync-file` exists and handles commit+push in the correct worktree | `behavioral` | pre-commit | `opencode-cli run` → agent creates plan file → stderr shows `local-issues sync-file` call → file appears on correct repo's issues-data branch |
| SC-6 | Plan-creation workflow includes repo-routing step: determine which repo owns the spec via session-init, place plan in that repo's `.issues/` worktree | `string` | CI | `grep` for repo-routing rule in `writing-plans/tasks/write.md`; `grep` for session-init repo resolution |
| SC-7 | Constructed URL resolves to a valid page (not 404) when tested against a real issue on any platform | `behavioral` | pre-commit | `webfetch` on constructed URL returns 200, not 404; test with both GitHub and GitBucket URL patterns |
