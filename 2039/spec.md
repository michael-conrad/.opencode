> **Full spec and artifacts: [`.issues/2039/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2039/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2039/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

28 task cards are referenced in SKILL.md Trigger Dispatch Tables but do not exist as `.md` files in the corresponding `tasks/` directories. When the orchestrator dispatches these tasks via `task()`, the sub-agent has no task file to execute.

## Affected Skills

| Skill | Missing Task Cards |
|-------|-------------------|
| `approval-gate-scope` | `spec-to-plan-cascade`, `approval-cascade`, `check-halt-boundary`, `apply-label`, `revision-revocation`, `bug-discovery-protocol` |
| `brainstorming` | `top-down-analysis`, `cross-scope` |
| `executing-plans` | `execute`, `tdd-cycle-enforcement` |
| `playwright-cli` | `browse`, `test` |
| `programming-principles` | `principles`, `check-limits`, `decompose` |
| `skill-creator` | `init`, `package`, `fragment-management` |
| `multimodal-dispatch` | `route` |
| `using-git-worktrees` | `verify-worktree` |
| `plan-creation-pipeline` | `plan-creation`, `completion` |
| `issue-operations-core` | `push-artifacts` |
| `writing-plans` | `create`, `update`, `retroactive`, `holistic-self-check` |

## Root Cause

Trigger Dispatch Tables were written with task references before the corresponding task card files were created.

## Fix

For each missing task card, create a `.md` file in the skill's `tasks/` directory with entry criteria, inline-only steps, and exit criteria.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 28 missing task cards exist as `.md` files | `string` | Verify each file exists |
| SC-2 | Each new task card has entry criteria, inline steps, exit criteria | `string` | Sample audit of 5 new task cards |
| SC-3 | No TDT references a non-existent task card | `string` | Cross-reference all TDTs against filesystem |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

After this spec is approved, invoke `writing-plans` to create `.issues/2039/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
