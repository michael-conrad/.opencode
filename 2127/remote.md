---
remote_issue: 2127
remote_url: https://github.com/michael-conrad/.opencode/issues/2127
---

> **Full spec and artifacts: [`.opencode/.issues/2127/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2127/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2127/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`020-go-prohibitions.md` has significant duplication with 000 and 065, an obsolete sub-issue model, and a Node.js-specific prohibition that should be a general `.tools/` rule.

## Scope

Remove 7 duplicated sections, collapse 2 sections, replace Node.js rule with general `.tools/` rule. Keep 6 universal sections.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Remove §1.1 Orchestrator Context Discipline | string |
| SC-2 | Remove §5 Multi-task Plan Without Sub-issues | string |
| SC-3 | Remove §6 Progressive Iterative Implementation | string |
| SC-4 | Remove "stop" command section | string |
| SC-5 | Remove 5 duplicated lines in §1 | string |
| SC-6 | Remove 3 duplicated lines in §1.6 | string |
| SC-7 | Remove 3 restated ALWAYS DO lines | string |
| SC-8 | Remove 10 duplicated ALWAYS DO items | string |
| SC-9 | §1.2 merged into §1 as bullet | string |
| SC-10 | §1.5 collapsed into §1 | string |
| SC-11 | §4 replaced with general `.tools/` rule | string |
| SC-12 | All keep sections remain | string |
| SC-13 | No content loss — removed sections verified as duplicated in 000/065 | behavioral |
| SC-14 | No orphaned cross-references to removed section names | string |
| SC-15 | No line-count or word-count metrics used as success measurement | string |

## Files Affected

- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/guidelines/070-environment.md`

## Dependencies

- Depends on 000-critical-rules.md compaction (#2121).

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
