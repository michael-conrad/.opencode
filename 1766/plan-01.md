# Phase 1: gitbucket-api Description Compliance Fix

**File:** `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`

## Changes

1. **Description field** — Replace current description with proposed description from #1472:
   - Remove D5 narrative sentence: "Platform-aware routing is what makes multi-platform workflows reliable."
   - Add REQUIRED mandatory dispatch language
   - Proposed: `"Use when GitBucket platform operations are needed for GitHub Issue tracking. Routes to gb CLI command reference for all GitBucket API calls. REQUIRED before any GitBucket operation — always use the platform-aware routing."`

2. **Trigger Dispatch Table** — Add TDT to task routing section per audit #1384 requirements.

## Verification

- [ ] Description contains no D5 narrative-only sentences
- [ ] Description contains REQUIRED or MUST mandatory language
- [ ] TDT present in frontmatter or routing section
