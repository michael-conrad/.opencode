**Full spec and artifacts: [`.opencode/.issues/1476/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1476)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1476/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

Audit #1384 identified 3 platform sub-skills with NO_TDT, D4 FAIL (no mandatory language), and D5 FAIL (narrative content). One fix issue per skill created: `gitbucket-api`, `github-mcp`, `local`. All linked as sub-issues under #1384.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| gitbucket-api fix spec | proposed | — |
| github-mcp fix spec | proposed | — |
| local fix spec | proposed | — |

### Key Decisions

- DEC-1: Fix specs are narrowly scoped to description and TDT compliance only

### Risk Callouts

- RISK-1: Low — sub-skill fixes don't affect core pipeline

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)