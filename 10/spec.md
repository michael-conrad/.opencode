## Objective

Add explicit negative constraint to `AGENTS.md` Submodule Discipline section stating that submodule pointer bumps are never a separate PR.

## Problem

`AGENTS.md` Submodule Discipline currently describes tagging and release behavior but never explicitly states that pointer bumps must not become separate PRs. The agent reads this section during pre-work and cleanup, and without the explicit prohibition, infers action from "dirty" `.opencode` status.

## Fix Approach

Add to the Submodule Discipline section (after the tag layers table):

> **Submodule pointer bumps are never a separate PR.** The parent repo's `.opencode` pointer advances as a side effect of the next feature branch that touches `.opencode/` content — it is staged and committed as part of that feature's pre-work, never as a standalone "chore: update submodule pointer" commit or PR.

## Success Criteria

| ID | Criterion |
|----|-----------|
| SC-1 | `AGENTS.md` Submodule Discipline section contains explicit statement that submodule pointer bumps are never a separate PR |

## Affected Files

| File | Change Type |
|------|-------------|
| `AGENTS.md` | **UPDATE** — Add no-pointer-bump-PR statement to Submodule Discipline |

STATUS: 1.0 (DRAFT - NEEDS APPROVAL)

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
