> **Full spec and artifacts: [`.issues/2040/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2040/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2040/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

42 task card files exist in `tasks/` directories but are not referenced by any SKILL.md Trigger Dispatch Table or Invocation section. These orphaned files are dead code — the orchestrator never dispatches them.

## Affected Skills

| Skill | Orphaned Files |
|-------|---------------|
| `implementation-pipeline` | `pipeline-executor.md`, `pre-flight-handoff.md`, `sc-closeout.md` |
| `executing-plans` | `progress.md`, `start.md`, `step.md`, `verify.md`, `operating-protocol.md` |
| `spec-creation-validation` | `create-remote-stub.md`, `holistic-self-check.md`, `pipeline-readiness-gate.md`, `pre-spec-inspection.md`, `revise-remote-body.md`, `risk.md`, `traceability.md` |
| `spec-creation-decomposition` | `analytical-artifacts.md`, `blast-radius.md`, `code-path-analysis.md`, `concern-analysis.md`, `cross-cutting.md`, `decompose.md`, `interface-compatibility.md`, `state-analysis.md`, `testability-assessment.md` |
| `spec-creation-requirements` | `requirements.md` |
| `spec-creation-change-control` | `change-control.md` |
| `writing-plans-creation` | All 16 task files |
| `writing-plans-holistic` | `holistic-self-check.md` |

## Root Cause

Task cards were created as part of skill decomposition but the SKILL.md Trigger Dispatch Table was never updated to reference them.

## Fix

For each orphaned task card, either add a TDT entry in the parent SKILL.md or delete the orphaned file.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 42 orphaned task cards are either TDT-referenced or deleted | `string` | Cross-reference all task files against all TDTs |
| SC-2 | No unreferenced task card files remain in any `tasks/` directory | `string` | grep for all task files not in any TDT |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

After this spec is approved, invoke `writing-plans` to create `.issues/2040/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
