**Full spec and artifacts: [`.opencode/.issues/1048/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1048)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1048/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The viewport-editor#46 spec/plan revision cycle revealed systematic gaps in how specs and plans are created, structured, and audited. The `spec-creation`, `writing-plans`, and `adversarial-audit` skills produce artifacts that exhibit:

- Tracking language in forward-looking specs ("implemented", "confirmed", "pending")
- Prescriptive code content in plans (line numbers, exact import strings, assertion code)
- Cross-referenced requirements that agents ignore (pipeline gates stated once, not per-unit)
- Z3 models that don't enforce pipeline completion
- Contract preconditions that block valid state transitions

These patterns produced a multi-hour revision cycle for a single issue. Without systematic correction, every future issue will repeat the same rework.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| spec-creation tracking language elimination | proposed | — |
| writing-plans prescriptive code removal | proposed | — |
| pipeline gate per-unit enforcement | proposed | — |

### Key Decisions

- DEC-1: Specs must use forward-looking "must be true" stance only — no status/tracking language

### Risk Callouts

- RISK-1: High — existing skill files contain embedded tracking language patterns that agents may reproduce

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)