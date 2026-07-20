**Full spec and artifacts: [`.opencode/.issues/1741/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1741)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1741/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

SC-9 from `.opencode#1421` is FAIL. The behavioral test `gap-fill-cascade-missing-plan.sh` times out at 1200s because it tests the full authorization pipeline end-to-end (load approval-gate, dispatch verify-authorization, which internally dispatches gap-fill-cascade, which checks spec→plan→etc.) before ever reaching the gap-fill-cascade dispatch. The model (deepseek-v4-flash-free) is too slow for this multi-step pipeline. Additionally, there is no pre-PR gate that blocks PR creation when any SC is FAIL. Solution: create a scoped behavioral test + add pre-PR gate in implementation pipeline.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| scoped behavioral test | proposed | — |
| pre-PR gate | proposed | — |

### Key Decisions

- DEC-1: The scoped test uses a direct prompt targeting gap-fill-cascade without full pipeline

### Risk Callouts

- RISK-1: Medium — existing test retained as integration test alongside new scoped test

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)