# Phase 3: local Description Compliance Fix

**File:** `.opencode/skills/issue-operations/platforms/local/SKILL.md`

## Changes

1. **Description field** — Replace current description with proposed description from #1474:
   - Remove 2 D5 narrative sentences: "Untracked work is work that can be lost." + "Even local issues deserve structured tracking."
   - Add REQUIRED mandatory dispatch language
   - Proposed: `"Use when local .issues/ directory tracking is needed for GitHub Issues on platforms without remote access. Routes all issue operations to YAML frontmatter and markdown files. REQUIRED before any local issue operation — always use the platform-aware routing."`

2. **Trigger Dispatch Table** — Add TDT to task routing section per audit #1384 requirements.

## Verification

- [ ] Description contains no D5 narrative-only sentences
- [ ] Description contains REQUIRED or MUST mandatory language
- [ ] TDT present in frontmatter or routing section
