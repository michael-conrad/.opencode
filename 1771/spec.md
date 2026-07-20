**Full spec and artifacts: [`.opencode/.issues/1560/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1560)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1560/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The spec-creation SKILL.md marks 4 steps as `[inline]` (pre-spec inspection, solve model, solve check, plan plan). If the Trigger Dispatch Table routes an orchestrator-level task file to a sub-agent, the sub-agent receives a task file with `[inline]` steps it cannot execute. The "unless" clause is the escape hatch masking this routing problem. Audit required to confirm whether `create` task is already written correctly for sub-agent execution.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| TDT routing audit | proposed | — |
| per-step marker audit | proposed | — |
| unless clause removal | proposed | — |

### Key Decisions

- DEC-1: Same discipline as #1558 and #1559

### Risk Callouts

- RISK-1: Medium — spec-creation is a heavily-used skill

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)