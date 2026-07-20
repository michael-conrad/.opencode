**Full spec and artifacts: [`.opencode/.issues/1062/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1062)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1062/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The current pipeline has no structural integrity verification at three critical handoff boundaries:

1. **Spec → Plan:** The plan author reads the spec and starts writing. There is no verification that the spec's SC table is complete, that `sc-summary.yaml` (if it exists) matches the prose table, that pre-approval gate confirmed SAT, or that solve contracts are valid. A plan written against a structurally defective spec produces downstream SCHEDULING rework at pipeline step 10.

2. **Plan → Pipeline:** The pipeline dispatches to sc-coherence-gate with no verification that the plan has RED checkpoints for every TDD task, that every SC-ID in the plan maps to the spec's SC table, that phase dependency solve contracts return SAT, or that sub-issues exist for multi-phase decompositions.

3. **Implementation → Close-Out:** The pipeline's exec-summary step posts a completion comment without verifying that every SC-ID from the spec's SC table received at least one PASS verdict.

4. **Cross-handoff consistency:** There is no check that the spec-to-plan and plan-to-pipeline handoffs agree on shared variables (SC count, decomposition type, phase count).

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| spec-to-plan handoff verification | proposed | — |
| plan-to-pipeline handoff verification | proposed | — |
| SC close-out verification | proposed | — |

### Key Decisions

- DEC-1: Handoff manifests are ephemeral `./tmp/{issue-N}/artifacts/` — cleaned at PR merge, not permanent

### Risk Callouts

- RISK-1: Medium — new handoff steps add pipeline latency at each stage boundary

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)