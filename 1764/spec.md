**Full spec and artifacts: [`.opencode/.issues/1302/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1302)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1302/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The plan-structure.md task currently uses a flat step list. The spec requires replacing this with a three-part phase structure: Pre-RED Common, Per-Item RED+green Chains, Post-RED/green. Each phase has validation rules. The flat step list doesn't enforce this structure, leading to plans that mix concerns across the three-part boundary.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| plan-structure.md Step 4 three-part template | proposed | — |
| validation rules | proposed | — |
| behavioral test | proposed | — |

### Key Decisions

- DEC-1: Replace flat step list with Pre-RED Common, Per-Item RED+green Chains, Post-RED/green sections

### Risk Callouts

- RISK-1: Medium — existing plan-structure.md template is heavily referenced across skills

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)