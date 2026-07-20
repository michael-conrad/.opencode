## Defects

| Defect | Details |
|--------|---------|
| NO_TDT | No Trigger Dispatch Table in frontmatter |
| D4 FAIL | Missing mandatory language (MUST/REQUIRED) |
| D5 FAIL | 2 narrative sentences: "Untracked work is work that can be lost." + "Even local issues deserve structured tracking." — value judgments, zero dispatch info |

## Current Description

```
Use when local .issues/ directory tracking is needed. Local .issues/ directory platform for issue tracking. Used when github.platform is local or unset. Routes all issue operations to .issues/ directory with YAML frontmatter and markdown files. Untracked work is work that can be lost. Even local issues deserve structured tracking.
```

## Proposed Description

```
Use when local .issues/ directory tracking is needed for GitHub Issues on platforms without remote access. Routes all issue operations to YAML frontmatter and markdown files. REQUIRED before any local issue operation — always use the platform-aware routing.
```

## Required Action

1. Update `description` field in SKILL.md frontmatter (replace 2 narrative-only sentences with routing language + mandatory keyword)
2. Add Trigger Dispatch Table to task routing section

🤖 Co-authored with AI: <AgentName> (<ModelId>)