---
remote_issue: 2128
remote_url: https://github.com/michael-conrad/.opencode/issues/2128
---

> **Full spec and artifacts: [`.opencode/.issues/2128/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2128/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2128/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`060-tool-usage.md` contains Junie-specific rules (Path Rules, Guidelines Lookup), sections duplicated in 000, and tool-specific patterns that belong in skill cards.

## Scope

Remove 6 sections (Junie-specific, duplicated, or covered elsewhere). Move 2 sections to skill cards. Keep 5 universal sections.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Remove §0 Progressive Disclosure | string |
| SC-2 | Remove §1 Guidelines Lookup | string |
| SC-3 | Remove §2 Path Rules | string |
| SC-4 | Remove pre-submit root cleanliness check | string |
| SC-5 | Remove §5 Verification & Audit | string |
| SC-6 | Remove §8 Skill Call Principle | string |
| SC-7 | Behavioral evidence exemption → verification-before-completion | string |
| SC-8 | Todowrite Lifecycle → mcp-tool-usage | string |
| SC-9 | All keep sections remain | string |
| SC-10 | Remove `./.opencode/tools/guidelines` tool | structural |

## Files Affected

- `.opencode/guidelines/060-tool-usage.md`
- `.opencode/skills/verification-before-completion/SKILL.md`
- `.opencode/skills/mcp-tool-usage/SKILL.md`
- `.opencode/tools/guidelines` (remove)

## Dependencies

- Depends on 000-critical-rules.md compaction (#2121).

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
