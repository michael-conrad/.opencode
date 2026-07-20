> **Full spec and artifacts: [`.opencode/.issues/1418/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1418)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1418/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Executive Summary

Replace the gap-fill cascade with a state-verification checklist model. The cascade becomes a routing-only dispatcher that loads per-scope checklist files. Each checklist item verifies a state and, if missing, returns a `BLOCKED` result with a `next_action` routing to the appropriate skill. The orchestrator loops: dispatch cascade → if BLOCKED, dispatch `next_action` → re-dispatch cascade → repeat until DONE.

### Key Changes

- **New**: `gap-fill-cascade/for-pr.md`, `for-implementation.md`, `for-plan.md` — per-scope state-verification checklists
- **Rewrite**: `gap-fill-cascade.md` as routing dispatcher (reads scope, loads checklist, returns result)
- **Simplify**: `010-approval-gate.md` — remove gap-fill column from scope table
- **Remove**: `for_pr_only` and `for_review_only` scopes (silent-failure traps)
- **Remove**: `pr_strategy` from all `authorization_scope` template blocks

### Behavioral Enforcement

- Agent with `for_pr` scope and existing spec+plan must dispatch `gap-fill-cascade` and route through `implementation-pipeline` — not skip to PR creation
- Agent with `for_pr` scope and missing plan must dispatch `writing-plans` via `next_action` routing

### Dependencies

- Supersedes gap-fill concerns in `.opencode#1007`
- `.opencode#1007` should be revised to depend on this spec

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)