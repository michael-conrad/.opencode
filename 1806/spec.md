## Phase 8 — Pre-commit structural gate

**Parent:** #1784

Add a pre-commit hook check that scans SKILL.md files for prohibited procedure content patterns:
- Numbered step lists (`- [ ] N.` or `N. **Step**`)
- "Entry Criteria:" / "Exit Criteria:" sections
- "Procedure:" sections
- "Operating Protocol:" sections
- Code blocks with bash/python/YAML

This is a structural gate, not a behavioral one — it catches violations at commit time.

**Success Criteria:**
- SC-ROUTING-5: Pre-commit hook detects prohibited procedure patterns in SKILL.md files
- SC-ROUTING-6: Pre-commit hook does NOT block commits that only modify tasks/*.md files

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)