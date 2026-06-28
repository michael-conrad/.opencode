# Spec: Platform Sub-Skill Description Compliance Fixes (Issue #1472)

## Scope

Fix 3 platform sub-skills identified in audit #1384 D4/D5/NO_TDT failures: `gitbucket-api`, `github-mcp`, `local`.

## Created Issues

| Issue | Skill | Defects |
|-------|-------|---------|
| [#1472](https://github.com/michael-conrad/.opencode/issues/1472) | gitbucket-api | NO_TDT, D4 FAIL, D5 FAIL (1 narrative sentence) |
| [#1473](https://github.com/michael-conrad/.opencode/issues/1473) | github-mcp | NO_TDT, D4 FAIL, D5 FAIL (1 narrative sentence) |
| [#1474](https://github.com/michael-conrad/.opencode/issues/1474) | local | NO_TDT, D4 FAIL, D5 FAIL (2 narrative sentences) |

All linked as sub-issues under #1384.

## Verification Performed

1. Read all comments on audit #1384 — 2 comments confirming defects
2. Verified all 3 SKILL.md files exist via GitHub API:
   - `gitbucket-api`: SHA 823503af (description = 297 chars)
   - `github-mcp`: SHA 6ac4baa2 (description = 277 chars)
   - `local`: SHA 21e73b44 (description = 270 chars)

## Status: DONE

🤖 Co-authored with AI: <AgentName> (<ModelId>)
