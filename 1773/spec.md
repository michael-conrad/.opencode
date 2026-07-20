**Full spec and artifacts: [`.opencode/.issues/1677/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1677)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1677/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

## Problem

When the agent's CWD is inside a git submodule (e.g., `.opencode/`, `vendor/`, `lib/`), every relative path resolves against the submodule root, not the project root. This breaks `./tmp/` → resolves to `.opencode/tmp/`, `./.issues/` → resolves to `.opencode/.issues/`, and any `mkdir -p ./tmp/` creates the wrong directory. No canonical "project root" anchor exists; session-init emits repo info but not the absolute top-level git root. Solution: emit `project_root` from session-init as `git rev-parse --show-toplevel`; update all task files to use `{project_root}` prefix.

---

### Cards

| Card | Status | Decision Log |
|------|--------|--------------|
| project_root emission | proposed | — |
| task file path updates | proposed | — |
| wildcard hack elimination | proposed | — |

### Key Decisions

- DEC-1: `project_root` from `git rev-parse --show-toplevel` — single source of truth

### Risk Callouts

- RISK-1: High — 42+ task files use `*/.issues/` wildcard hack that must be replaced

---

🤖 Co-authored with AI: OpenCode (opencode/mimo-v2-pro-free)