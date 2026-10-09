---
remote_issue: 1195
remote_url: "https://github.com/michael-conrad/.opencode/issues/1195"
last_sync: "2026-10-09T15:25:00Z"
source: github
---

> **Full spec and artifacts: [`.opencode/.issues/1195/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/1195/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1195/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

**2026-10-09 revision — scope narrowed after deck-rewrite review.** The original spec (2026-06-14) asked for a four-mandate Communication Discipline section in `.opencode/AGENTS.md`. A review against the rewritten deck (floor.md + routing.md + skills/) found mandates 1–3 absorbed or superseded; the spec now covers the single surviving gap.

Disposition of the original mandates:

- **Mandate 1 (no question tool):** superseded by the floor's later ruling — the `question` tool is the canonical constrained-choice surface, prohibited for unsolicited decisions, unsure-halts, and `discuss` mode; picklists only on explicit developer request, presented in prose.
- **Mandate 2 (open-ended, research-informed discussion):** absorbed into the `discuss` vocabulary entry and the `explore`/`research` cards.
- **Mandate 3 (single-point back-and-forth):** absorbed, scoped to discussion modes (`discuss`: one topic at a time; `explore`: one question per message).
- **Mandate 4 (no solicitation):** the surviving gap — no deck content states the rule; the deck is otherwise compliant by absence (zero solicitation patterns found in any card).

**Final what:** add an explicit no-solicitation rule to floor.md, adjacent to the standing formula — after authorized work completes, the agent reports and waits; it never solicits work, phases, steps, or assignments. The rule is intent-decidable (scripts forbidden); the deck edit routes through the `skill-creator` admission gate (trace included in the spec). A judgment-reviewed behavioral-evidence follow-up is deferred unless requested.

Full criteria, the re-evaluation record, and the admission-gate trace live in the spec folder above.


🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)