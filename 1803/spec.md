## Phase 4 — Migrate procedure content to tasks/*.md

**Parent:** #1784

For each SKILL.md with procedure content identified in Phase 3:
1. Create or update the corresponding `tasks/*.md` file with the procedure content
2. Remove the procedure content from SKILL.md
3. Ensure the task file has proper entry/exit criteria, step definitions, and code snippets
4. Ensure the task file has a discovery directive reference in the SKILL.md dispatch table

**Success Criteria:**
- SC-ROUTING-4: All 39 SKILL.md files pass routing-only audit (no procedure text in body)
- SC-ROUTING-7: All task files that received migrated content have proper entry/exit criteria and step definitions

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)