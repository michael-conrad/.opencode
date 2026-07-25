---
remote_issue: 2133
remote_url: https://github.com/michael-conrad/.opencode/issues/2133
---

> **Full spec and artifacts: [`.opencode/.issues/2133/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2133/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2133/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`091-incremental-build.md` has a duplicate cross-ref, a paragraph duplicated in 020, and a dead reference to already-removed content.

## Scope

Deduplicate line 9 cross-ref. Remove line 47 paragraph (duplicated in 020). Remove line 49 dead reference.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Only one cross-ref to 000-critical-rules.md on line 9 | string |
| SC-2 | Remove "Implementation work is measured" paragraph | string |
| SC-3 | Remove "Symbolic rules below" line | string |

## Files Affected

- `.opencode/guidelines/091-incremental-build.md`

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
