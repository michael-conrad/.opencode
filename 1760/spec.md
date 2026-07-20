**Full spec and artifacts: [`.opencode/.issues/1064/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1064)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1064/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The writing-plans `create/plan-structure` and `create/create-and-validate` tasks read the spec body as prose — they extract objectives, constraints, and success criteria from free-form text. The expanded spec structure (from #1060) adds 8 new SC table columns (Pipeline Step Binding, Phase Binding, Verification Gate, Artifact Path, Requirement Traceability, Integration Mode, Affinity Group, Re-Entry Step), 5 preamble sections (Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family), and 3 mandatory content areas (Explicit Non-Goals, Regression Invariants, Common SC Designation). The plan author has no substeps to consume these structured fields. Currently the plan author reads the SC table and guesses — there is no mandatory substep to map each SC-ID to a phase and TDD task.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| SC table structured consumption | proposed | — |
| cross-reference validation | proposed | — |

### Key Decisions

- DEC-1: The structured consumption substep maps SC-IDs to phases, TDD tasks, and verification gates — it does NOT re-create binding information

### Risk Callouts

- RISK-1: Medium — plan-structure task file grows significantly with new substep

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)