---
number: 2200
title: "[SPEC-FIX] #2176 audit remediation: remove stale sc-count-gate and enforcement gate references"
state: OPEN
labels: [spec-fix]
---

> **Full spec and artifacts: [`.opencode/.issues/2200/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2200)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2200/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Remediate 2 FAIL findings from the #2176 spec audit: remove stale `sc-count-gate` references from the pipeline state machine, and replace stale enforcement gate references in TDD task files.

## Background

The #2176 implementation audit (DiMo chain) found 2 FAILs:

- **SC-1:** `pipeline-state-machine.yaml` still referenced `sc-count-gate` in both domain lists and Z3 preconditions — a step removed in Phase 1 of #2176
- **SC-7:** `test-driven-development/tasks/red.md`, `green.md`, and `operating-protocol.md` referenced removed enforcement gates (`post-red-enforcement`, `post-green-enforcement`, `pre-red-baseline`)

These were missed during the #2176 implementation because the Phase 1 PR only updated the TDT and state machine transitions but left the state machine domain lists and precondition constraints untouched. The TDD task files were not in the Phase 5 affected-files list.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `pipeline-state-machine.yaml` has no `sc-count-gate` in any domain list or precondition | string | grep — expect 0 matches |
| SC-2 | `test-driven-development/tasks/red.md` has no `post-red-enforcement` reference | string | grep — expect 0 matches |
| SC-3 | `test-driven-development/tasks/green.md` has no `post-green-enforcement` reference | string | grep — expect 0 matches |
| SC-4 | `test-driven-development/tasks/operating-protocol.md` has no `pre-red-baseline` or `post-red-enforcement` references | string | grep — expect 0 matches |

## Affected Files

- `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`
- `.opencode/skills/test-driven-development/tasks/red.md`
- `.opencode/skills/test-driven-development/tasks/green.md`
- `.opencode/skills/test-driven-development/tasks/operating-protocol.md`

## Implementation

All 4 files have already been modified and verified by the re-audit (8/8 PASS). This PR commits those changes.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
