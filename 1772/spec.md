**Full spec and artifacts: [`.opencode/.issues/1672/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1672)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

> **Local artifacts:** `.opencode/.issues/1672/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The current adversarial-audit system has grown into a high-maintenance, cloud-dependent architecture with a brittle failure mode. When only one model family is available locally (e.g., only `deepseek` variants installed), `resolve-models` cannot select 2 auditors from different families and returns `INSUFFICIENT_FAMILIES`. This blocks ALL adversarial audits — the entire pipeline halts because the dispatch precondition cannot be met. Replace with DiMo-aligned architecture: same-model, role-differentiated agent chaining with Generator, Evaluator, Knowledge Supporter, and Path Provider roles.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| DiMo role architecture | proposed | — |
| resolve-models elimination | proposed | — |
| artifact flow redesign | proposed | — |

### Key Decisions

- DEC-1: Same-model, role-differentiated chaining eliminates cross-model family dependency

### Risk Callouts

- RISK-1: High — eliminates ~1,900 lines and restructures the entire audit dispatch system

---

**Closed as already-implemented.** The DiMo role chain (Generator → Knowledge Supporter → Evaluator → Path Provider) is live in `audit/SKILL.md` and all audit task files. `resolve-models` has been converted to a Path Provider reference doc. Verified by code inspection on 2026-07-07.

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)