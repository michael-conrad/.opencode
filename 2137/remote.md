---
remote_issue: 2137
remote_url: https://github.com/michael-conrad/.opencode/issues/2137
---

> **Full spec and artifacts: [`.opencode/.issues/2137/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2137/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2137/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The entire `.opencode/` infrastructure is formatted as if going through a mechanical parser. The only consumer is an LLM reading natural language prose.

## Scope

Audit 5 pattern categories across `.opencode/` for pseudo-machine-parseable formatting with no consumer.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Machine-parseable ID prefixes counted and consumer-verified | string |
| SC-2 | Enforcement label prefixes counted and consumer-verified | string |
| SC-3 | Fixed-width structured sections counted and consumer-verified | string |
| SC-4 | Evidence type declarations counted and consumer-verified | string |
| SC-5 | Frontmatter fields with no consumer counted and consumer-verified | string |

## Files Affected

Entire `.opencode/` directory.

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
