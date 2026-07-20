**Full spec and artifacts: [`.opencode/.issues/1558/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1558)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1558/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The writing-plans SKILL.md marks 3 tasks (create, retroactive, completion) as `orchestrator` dispatch and 11 Z3 `solve check` steps as `(**inline**)`. If the Trigger Dispatch Table routes an orchestrator-level task file to a sub-agent, the sub-agent receives a task file with `[inline]` steps it cannot execute (sub-agents cannot use `task()`). The "unless" clause is the escape hatch masking this routing problem. Fix: audit TDT routing, audit per-step markers, fix misrouted tasks, remove "unless" clause.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| TDT routing audit | proposed | — |
| per-step marker audit | proposed | — |
| unless clause removal | proposed | — |

### Key Decisions

- DEC-1: Each step MUST be dispatched via `task()` unless explicitly marked `[inline]` AND routed as `orchestrator`

### Risk Callouts

- RISK-1: Medium — writing-plans is heavily referenced; routing changes affect downstream skills

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)