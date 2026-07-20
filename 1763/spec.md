**Full spec and artifacts: [`.opencode/.issues/1234/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1234)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1234/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

Enforce that the orchestrator uses the canonical dispatch string verbatim after loading a skill's dispatch table, rather than writing custom prompts with preloaded context. Add a critical rule, update all SKILL.md DISPATCH_GATE sections with Orchestrator Entry Criteria, and add a behavioral enforcement test. Three parallel changes: (1) critical rule in `000-critical-rules.md`, (2) Orchestrator Entry Criteria block in every SKILL.md's DISPATCH_GATE section, (3) behavioral enforcement test.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| critical rule addition | proposed | — |
| Orchestrator Entry Criteria | proposed | — |
| behavioral enforcement test | proposed | — |

### Key Decisions

- DEC-1: Custom prompt with preloaded context after reading canonical string is classified as a DISPATCH_GATE violation

### Risk Callouts

- RISK-1: Medium — affects all SKILL.md files with DISPATCH_GATE sections (30+ files)

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)