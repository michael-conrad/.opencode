**Full spec and artifacts: [`.opencode/.issues/1709/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1709)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1709/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

Fix the agent's release PR workflow bypass by adding trigger phrases, wiring the Pre-Response Gate into task files, closing the escape hatch, creating version-manager and release-promoter skills, adding release branch naming, post-merge release detection, pre-release validation, and behavioral enforcement tests. 10-phase plan modifying existing skill/guideline files and creating new skill files. Each phase is a self-contained set of file modifications that can be verified independently.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| trigger phrase additions | proposed | — |
| Pre-Response Gate wiring | proposed | — |
| version-manager skill | proposed | — |
| release-promoter skill | proposed | — |
| behavioral enforcement tests | proposed | — |

### Key Decisions

- DEC-1: All changes within the `.opencode` submodule

### Risk Callouts

- RISK-1: High — 10-phase plan with 24 files modified/created

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)