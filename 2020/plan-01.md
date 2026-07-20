---
title: "Phase 1: Audit and classify all SKILL.md Invocation sections"
phase: 1
issue: 2020
status: draft
risk: low
Dispatch: sub-agent
---

## Entry Criteria

- [ ] Spec approved (authorization_scope: for_pr)
- [ ] Feature branch exists: `feature/2020-dispatch-boundary-fix`

## Steps

- [ ] 1. Read all SKILL.md Invocation sections (**sub-agent**)

    For each SKILL.md in `.opencode/skills/*/SKILL.md`:
    1. Read the Invocation section
    2. Classify each entry: does it dispatch a pipeline (multiple `[sub-task]` steps) or a single task card?
    3. If pipeline with `[sub-task]` steps: mark for fix (orchestrator executes pipeline)
    4. If single task card: no change needed
    5. If missing orchestrator entry point: mark for addition

- [ ] 2. Blast radius analysis — srclight_get_dependents on affected files (**sub-agent**)

    For each affected file identified in the spec's In-scope table, run `srclight_get_dependents` to collect blast radius evidence. Write results to `.opencode/.issues/2020/artifacts/blast-radius.yaml`.

- [ ] 3. Document classification results (**inline**)

    Write classification results to `.opencode/.issues/2020/artifacts/audit-classification.yaml`.

- [ ] 4. Z3 check — solve check verify audit output (**sub-agent**)

    Run `.opencode/tools/solve check` with the audit classification contract.

## Exit Criteria

- [ ] All SKILL.md Invocation sections read and classified — verify: `ls .opencode/skills/*/SKILL.md | wc -l` matches classified count in artifact
- [ ] Blast radius evidence collected for all affected files — verify: `test -f .opencode/.issues/2020/artifacts/blast-radius.yaml`
- [ ] Classification results documented in artifact — verify: `test -f .opencode/.issues/2020/artifacts/audit-classification.yaml`
- [ ] Z3 check passes — verify: `.opencode/tools/solve check` exits 0

### Evidence Type Annotations

| SC | Evidence Type | Verification Method |
|----|---------------|---------------------|
| SC-1 | string | `ls` + `test -f` + `.opencode/tools/solve check` exit code |

## SC Coverage

- SC-1 (audit scope determines fix scope)

## Concern Transition

Phase 1 is read-only — no files modified. Output feeds Phase 2 fix scope.
