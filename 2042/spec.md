> **Full spec and artifacts: [`.issues/2042/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2042/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2042/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

6 skills have `tasks/` directories with task card files but their SKILL.md files lack a Trigger Dispatch Table section. Without a TDT, the orchestrator has no routing information for these tasks.

## Affected Skills

| Skill | Task Count | Notes |
|-------|-----------|-------|
| `spec-creation-change-control` | 1 | `change-control.md` |
| `spec-creation-decomposition` | 9 | Analytical artifact task cards |
| `spec-creation-requirements` | 1 | `requirements.md` |
| `spec-creation-validation` | 8 | Create, holistic check, risk, etc. |
| `writing-plans-creation` | 16 | Full plan creation pipeline |
| `writing-plans-holistic` | 1 | `holistic-self-check.md` |

## Root Cause

These skills were created as sub-skills (task containers) without their own TDT. The parent skills reference them via Invocation sections, but the sub-skills themselves have no TDT.

## Fix

For each skill, add a Trigger Dispatch Table to the SKILL.md that references all task card files in its `tasks/` directory.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 6 skills have a TDT in their SKILL.md | `string` | Verify each SKILL.md has a `## Trigger Dispatch Table` section |
| SC-2 | Each TDT references all task card files in the skill's `tasks/` directory | `string` | Cross-reference TDT entries against filesystem |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

After this spec is approved, invoke `writing-plans` to create `.issues/2042/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
