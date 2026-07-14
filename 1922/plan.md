# Plan: Remove outdated GitBucket API deficiency documentation

## Goal

Remove all obsolete files documenting deficiencies of the deprecated raw-API approach, remove all `GB_*` environment variable references (`GB_TOKEN`, `GB_HOST`, `GB_USER`, `GB_PASSWORD`, `GB_REPO`) from `.opencode/`, and update the SKILL.md cross-reference table.

## Architecture

Single-phase cleanup: delete 4 files + empty `tests/` directory, remove all `GB_*` references from 7 files, update SKILL.md cross-reference table.

## Affected Files

### Delete
- `.opencode/skills/issue-operations/platforms/gitbucket-api/API-DEFICIENCIES.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/test_api_deficiencies.py`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/verify_api.py`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/test_pr_idempotency.py`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/` (remove if empty)

### Modify — Remove all `GB_*` environment variable references
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
- `.opencode/AGENTS.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/repository-operations.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/error-recovery.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/session-integration.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md`

## Phase Table

| Phase | Description | Files | SCs |
|-------|-------------|-------|-----|
| 1 | Delete obsolete files and remove all `GB_*` references | All affected files | SC-1 through SC-8 |

## Exit Criteria

All 8 success criteria verified PASS.

## Implementation Steps

### Phase 1: Cleanup

1. **Delete obsolete files** — remove the 4 files and empty `tests/` directory
2. **Remove `API-DEFICIENCIES.md` row from SKILL.md** — edit the Cross-References table
3. **Remove all `GB_*` rows from AGENTS.md** — edit the Environment Variables table
4. **Remove all `GB_*` references from 6 task files** — edit each file individually
5. **Verify** — confirm all SCs pass

## Self-Review

- [ ] All deletions are within the gitbucket-api skill directory
- [ ] No external references to deleted files exist
- [ ] Table formatting preserved after edits
- [ ] All `GB_*` references removed from all 7 files
