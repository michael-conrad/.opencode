**Parent Plan:** #1881

# Phase 2 — Split issue-operations

**Concern:** issue-operations → 4 sub-skills (issue-operations-core, issue-operations-comments, issue-operations-sub-issues, issue-operations-sync)

**Dependencies:** Phase 1 (dispatcher template exists)

**Summary:** Convert issue-operations/SKILL.md to dispatcher with Trigger Dispatch Table. Create 4 sub-skills: core (14 task files), comments (1 task file), sub-issues (2 task files), sync (3 task files). Preserve platform sub-skills (github-mcp, gitbucket-api, local) unchanged. Update behavioral tests.

Key files:
- `.opencode/skills/issue-operations/SKILL.md` — Converted to dispatcher
- `.opencode/skills/issue-operations-core/SKILL.md` — New
- `.opencode/skills/issue-operations-comments/SKILL.md` — New
- `.opencode/skills/issue-operations-sub-issues/SKILL.md` — New
- `.opencode/skills/issue-operations-sync/SKILL.md` — New
- `.opencode/skills/issue-operations/platforms/` — Preserved (unchanged)