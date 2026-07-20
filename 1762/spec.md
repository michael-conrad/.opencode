**Full spec and artifacts: [`.opencode/.issues/1227/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1227)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1227/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

Update the DISPATCH_GATE protocol block in all eligible skill SKILL.md files to include a "Sub-agent Task File Discovery Directive" rule, ensuring dispatched sub-agents know where to find the task file defining their requirements. This is a content-verification fix to DISPATCH_GATE protocol tables — adding a new required pattern row ("Sub-agent Task File Discovery Directive") and a new forbidden pattern entry to each affected SKILL.md. No behavioral logic, no runtime changes.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| DISPATCH_GATE protocol update | proposed | — |
| 7 SKILL.md files modified | proposed | — |

### Key Decisions

- DEC-1: Same structural change applied identically to each SKILL.md file

### Risk Callouts

- RISK-1: Low — content-verification only, no behavioral logic changes

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)