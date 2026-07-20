**Full spec and artifacts: [`.opencode/.issues/1559/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1559)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1559/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The implementation-pipeline SKILL.md marks 2 tasks (assemble-work, pipeline-executor) as `orchestrator` dispatch, 5 Z3 `solve check` steps as `inline`, and 3 adversarial-audit remediation steps as `inline`. If the Trigger Dispatch Table routes an orchestrator-level task file to a sub-agent, the sub-agent receives a task file with `[inline]` steps it cannot execute. The "unless" clause is the escape hatch masking this routing problem.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| TDT routing audit | proposed | — |
| per-step marker audit | proposed | — |
| unless clause removal | proposed | — |

### Key Decisions

- DEC-1: Same discipline as #1558 — `[inline]` steps only in orchestrator-routed tasks

### Risk Callouts

- RISK-1: Medium — implementation-pipeline is the core pipeline dispatcher

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)