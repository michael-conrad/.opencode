---
number: 1209
title: "[SPEC] Workstream A — YAML frontmatter cleanup (all SKILL.md files)"
status: open
labels: [spec]
created: 2026-06-14T20:48:45Z

---
remote_issue: 1209
remote_url: "https://github.com/michael-conrad/.opencode/issues/1209"
last_sync: 2026-06-14T20:48:45Z
source: github.com
---

## Workstream A — YAML Frontmatter Cleanup

**Parent:** #1208

### Scope
All 39 SKILL.md files across the skill deck.

### Changes

1. **Remove `Triggers on:` keyword lists** from YAML frontmatter `description:` fields. The pre-response gate matches on NLU semantic intent, not keywords. Keyword lists create maintenance burden and add no routing value.

2. **Remove `provenance: "🤖 Co-authored with AI: ..."`** from YAML frontmatter. Provenance is decorative, not functional.

3. **Remove AI byline signoff lines** from SKILL.md bodies (lines containing `Co-authored with AI:`). These are posted-content attribution patterns that do not belong in instruction cards.

4. **Remove word counts, line counts, or any statistics** from card bodies (e.g., "≈750 words" columns in task tables).

5. **Rewrite descriptions** to clean "Use when..." NLU prose — semantic, not taxonomic. Examples:
   - Before: `"Use when creating a branch, committing, pushing, or creating a PR. Also for... Triggers on: branch, commit, push, PR, pull request..."`
   - After: `"Use when performing git operations: creating branches, committing changes, pushing work, managing pull requests, or cleaning up after merges."`

### Files
- `.opencode/skills/*/SKILL.md` — all 39 files

### SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-A1 | No `Triggers on:` keyword lists remain in any YAML frontmatter | string |
| SC-A2 | No `provenance: "🤖 Co-authored with AI:"` lines remain | string |
| SC-A3 | No `Co-authored with AI:` byline lines remain in any SKILL.md body | string |
| SC-A4 | No word count / line count statistics remain in any SKILL.md body | string |
| SC-A5 | All 39 YAML description fields use clean "Use when..." NLU prose | string |
