---
remote_issue: 2128
remote_url: https://github.com/michael-conrad/.opencode/issues/2128
---

> **Full spec and artifacts: [`.opencode/.issues/2128/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2128/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2128/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`060-tool-usage.md` contains Junie-specific rules (Path Rules, Guidelines Lookup, most of §4 Command Restrictions), sections overlapping with 000, project-specific rules (`uv run python`), and tool-specific patterns (Todowrite Lifecycle, File Renaming). These are Junie-specific remediations that accumulated over time.

## Scope

Remove 12 Junie-specific items, 2 overlapping sections, 1 covered section, 2 purged tool-specific sections, 1 project-specific rule. Keep 6 universal sections. Update cross-references in 7 files.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Remove §0 Progressive Disclosure | string |
| SC-2 | Remove §1 Guidelines Lookup | string |
| SC-3 | Remove §2 Path Rules | string |
| SC-4 | Remove pre-submit root cleanliness check | string |
| SC-5 | Remove §5 Verification & Audit | string |
| SC-6 | Remove §8 Skill Call Principle | string |
| SC-7 | Remove fixed sleep value `15` from §4 | string |
| SC-8 | Remove "one clear command per invocation" from §4 | string |
| SC-9 | Remove "use built-in Edit/Write tools" from §4 | string |
| SC-10 | Remove no `stty` from §4 | string |
| SC-11 | Remove no heredocs from §4 | string |
| SC-12 | Remove no repeated grep/egrep/sed from §4 | string |
| SC-13 | Remove `sed -i`, `printf`, `echo` redirection from §4 | string |
| SC-14 | Remove no multi-line shell loops from §4 | string |
| SC-15 | Remove no `sed` for file edits from §4 | string |
| SC-16 | Remove §6 File Renaming | string |
| SC-17 | Remove §7 Todowrite Lifecycle | string |
| SC-18 | Remove `uv run python` from §4 + update 070 cross-ref | string |
| SC-19 | All 6 keep sections remain (enumerated) | string |
| SC-20 | Remove `./.opencode/tools/guidelines` tool | structural |
| SC-21 | Update `tools/guidelines` refs in 5 pre-existing files | string |

## Files Affected

- `.opencode/guidelines/060-tool-usage.md`
- `.opencode/tools/guidelines` (remove)
- `.opencode/tools/impl/guidelines-*` (remove)
- 5 files with `tools/guidelines` references (update)

## Dependencies

- Depends on 000-critical-rules.md compaction (#2121).

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
