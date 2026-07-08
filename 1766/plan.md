# Plan: Platform Sub-Skill Description Compliance Fixes

**Issue:** #1766
**Authorization Scope:** `for_pr`
**Halt At:** `pr_created`
**Pipeline Phase:** `planning`

## Phase Table

| Phase | File | Sub-Skill | Description Fix | TDT Addition |
|-------|------|-----------|-----------------|--------------|
| 1 | `plan-01.md` | gitbucket-api | Replace D5 narrative sentence with routing language + REQUIRED keyword | Add Trigger Dispatch Table |
| 2 | `plan-02.md` | github-mcp | Replace D5 narrative sentence with routing language + REQUIRED keyword | Add Trigger Dispatch Table |
| 3 | `plan-03.md` | local | Replace 2 D5 narrative sentences with routing language + REQUIRED keyword | Add Trigger Dispatch Table |

## Dependency DAG

```
Phase 1 (gitbucket-api) ──→ Phase 2 (github-mcp) ──→ Phase 3 (local)
```

All phases are sequential — each is an independent SKILL.md edit, but they share the same feature branch and PR.

## Implementation Pipeline Gates

| Gate | Skill/Task | Phase |
|------|-----------|-------|
| Pre-work | `git-workflow --task pre-work` | Before Phase 1 |
| Implementation | `implementation-pipeline` | Per phase |
| Verification | `verification-before-completion` | Per phase |
| Finishing checklist | `finishing-a-development-branch` | After Phase 3 |
| Review prep | `git-workflow --task review-prep` | After finishing |
| PR creation | `git-workflow --task pr-creation` | After review prep |
| Cleanup | `git-workflow --task cleanup` | After PR merge |

## Proposed Descriptions (from #1472, #1473, #1474)

### gitbucket-api (Phase 1)
```
Use when GitBucket platform operations are needed for GitHub Issue tracking. Routes to gb CLI command reference for all GitBucket API calls. REQUIRED before any GitBucket operation — always use the platform-aware routing.
```

### github-mcp (Phase 2)
```
Use when GitHub MCP platform operations are needed for GitHub Issue tracking. Thin wrappers around github_* MCP tools with owner/repo verification. REQUIRED before any GitHub API call — always verify routing.
```

### local (Phase 3)
```
Use when local .issues/ directory tracking is needed for GitHub Issues on platforms without remote access. Routes all issue operations to YAML frontmatter and markdown files. REQUIRED before any local issue operation — always use the platform-aware routing.
```
