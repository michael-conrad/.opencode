## Defects

| Defect | Details |
|--------|---------|
| NO_TDT | No Trigger Dispatch Table in frontmatter |
| D4 FAIL | Missing mandatory language (MUST/REQUIRED) |
| D5 FAIL | 1 narrative sentence: "Every misrouted call is wasted effort." — value judgment, zero dispatch info |

## Current Description

```
Use when GitHub MCP platform operations are needed. GitHub MCP platform sub-skill for issue-operations. Provides capability manifest and thin wrappers around github_* MCP tools. API calls without owner/repo verification target the wrong repository. Every misrouted call is wasted effort.
```

## Proposed Description

```
Use when GitHub MCP platform operations are needed for GitHub Issue tracking. Thin wrappers around github_* MCP tools with owner/repo verification. REQUIRED before any GitHub API call — always verify routing.
```

## Required Action

1. Update `description` field in SKILL.md frontmatter (replace narrative-only sentence with routing language + mandatory keyword)
2. Add Trigger Dispatch Table to task routing section

🤖 Co-authored with AI: <AgentName> (<ModelId>)