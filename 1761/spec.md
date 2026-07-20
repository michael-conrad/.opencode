**Full spec and artifacts: [`.opencode/.issues/1065/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1065)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1065/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

The `local-issues` tool outputs bare issue numbers (`#7 [open] Title`) and only operates within a single repo. AI agents consuming the output must infer which `.issues/` directory the issue belongs to — impossible when multiple repos are active. Mutation commands accept bare numbers with no repo qualification, risking cross-repo modification errors. With multi-repo support added by #1059, the output format and command interface must evolve to support cross-repo disambiguation using qualified `{repo}#{N}` notation for all user-facing output and mutation commands.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| qualified output format | proposed | — |
| cross-repo read operations | proposed | — |
| mutation bare-number rejection | proposed | — |

### Key Decisions

- DEC-1: Mutations require qualified form (never bare numbers). Reads accept both — safe to be lenient. Cross-repo is the only mode.

### Risk Callouts

- RISK-1: Medium — existing scripts using bare numbers will break on qualified-form requirement

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)