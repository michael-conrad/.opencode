---
remote_issue: 2138
remote_url: https://github.com/michael-conrad/.opencode/issues/2138
---

> **Full spec and artifacts: [`.opencode/.issues/2138/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2138/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2138/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

Agents repeatedly use line counts, word counts, or file size as a measurement of success in specs. These are size metrics — they measure how much text exists, not whether the content is correct, focused, or semantically complete.

The defective pattern: `| SC-N | Final file size < N lines | structural | wc -l |`

A 199-line file that lost critical rules is worse than a 250-line file with all rules intact. Compaction success should be measured by content correctness and structural integrity — not by byte count.

## Scope

Audit `.opencode/` for:
1. Success criteria tables with line-count/word-count targets
2. Verification methods using `wc -l` or equivalent
3. `structural` evidence type misused with `wc -l` for behavioral claims
4. Spec bodies using line count as a proxy for correctness

**Out of scope:** Factual descriptions, user-mandated targets, informational counts, `lessons-learned/`.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Spec defines defective pattern with IS/IS NOT legitimate examples | string |
| SC-2 | Spec scopes audit with explicit out-of-scope categories | string |
| SC-3 | Spec defines DEFECT vs LEGITIMATE classification | string |
| SC-4 | Spec requires per-finding reporting (file, line, text, classification) | string |
| SC-5 | Spec distinguishes open vs closed issues in findings | string |
| SC-6 | Spec itself contains no line-count or word-count SC | string |

## Files Affected

- `.opencode/.issues/2138/spec.md`
- `.opencode/.issues/2138/research/`
- `.opencode/.issues/2138/audit/`

## Dependencies

None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
