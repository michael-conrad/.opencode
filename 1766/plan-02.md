# Phase 2: github-mcp Description Compliance Fix

**File:** `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md`

## Changes

1. **Description field** — Replace current description with proposed description from #1473:
   - Remove D5 narrative sentence: "Every misrouted call is wasted effort."
   - Add REQUIRED mandatory dispatch language
   - Proposed: `"Use when GitHub MCP platform operations are needed for GitHub Issue tracking. Thin wrappers around github_* MCP tools with owner/repo verification. REQUIRED before any GitHub API call — always verify routing."`

2. **Trigger Dispatch Table** — Add TDT to task routing section per audit #1384 requirements.

## Verification

- [ ] Description contains no D5 narrative-only sentences
- [ ] Description contains REQUIRED or MUST mandatory language
- [ ] TDT present in frontmatter or routing section
