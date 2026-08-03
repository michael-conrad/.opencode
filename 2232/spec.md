## Intent and Executive Summary

- **Problem Statement:** Two defects in `writing-plans` task cards violate the spec-is-not-tracking-document mandate and create circular dependency deadlocks. (1) `analyze.md` requires an `approved` field in spec YAML frontmatter — specs are NOT tracking documents; approval status belongs in issue labels. (2) `research.md` requires `dependency-contract.yaml` to exist before it runs, but research is the step that should generate it — creating a circular dependency deadlock.

- **Root Cause / Motivation:** The task cards were written with tracking-state embedded in spec documents and with pre-requisite artifacts that the pipeline itself should produce. This causes every plan-creation run to BLOCK on conditions that cannot be satisfied.

- **Approach Chosen:** (1) Replace `approved` frontmatter check in `analyze.md` with a check against `issue.yaml` labels (the local file synced from remote API). (2) Replace `dependency-contract.yaml` BLOCK in `research.md` with generation from `interface-compatibility.yaml` `dependency_contract` section. (3) Add a mandate SC that all spec/plan task cards must be audited for tracking-state-in-spec violations.

- **Key Design Decisions:** (1) `issue.yaml` is the correct local file for approval status — it is synced from remote API labels via `local-issues sync`. (2) `interface-compatibility.yaml` already contains a `dependency_contract` section — research generates `dependency-contract.yaml` from it, then consumes it in Z3 steps. (3) The mandate SC applies to ALL task cards, not just writing-plans — preventing recurrence.

## Not Included

- Changes to `writing-plans/tasks/create.md`, `writing-plans/tasks/backfill.md`
- Changes to `writing-plans/tasks/revise.md`, `validate.md`, `completion.md` (they read `dependency-contract.yaml` which research now generates — no change needed)
- Changes to any skill outside writing-plans
- Behavioral changes to Z3 constraint solving pipeline

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `writing-plans/tasks/analyze.md` checks `issue.yaml` labels for `approved-for-*` instead of spec frontmatter `approved` field | string | grep for `issue.yaml` and `approved-for` in analyze.md; grep for `frontmatter.*approved` returns zero matches |
| SC-2 | `writing-plans/tasks/research.md` generates `dependency-contract.yaml` from `interface-compatibility.yaml` `dependency_contract` section instead of BLOCKing if missing | string + behavioral | grep for `interface-compatibility.yaml` and `dependency_contract` in research.md; `opencode run` with plan-creation prompt verifies no DEPENDENCY_CONTRACT_NOT_FOUND BLOCK |
| SC-3 | All task cards in `.opencode/skills/` are audited for tracking-state-in-spec violations (frontmatter `approved` fields, status markers, completion indicators in spec/plan documents) | string | grep for `approved` in `tasks/analyze.md` across all skills returns zero matches; grep for `status.*completed\|status.*pending\|status.*in_progress` in spec/plan task files returns zero matches |
| SC-4 | `writing-plans/tasks/analyze.md` Entry Criteria and Procedure no longer reference spec frontmatter `approved` field | string | grep for `frontmatter` in analyze.md returns zero matches |

## Requirements

1. `analyze.md` SHALL check `{issues_prefix}/{N}/issue.yaml` labels for `approved-for-*` pattern instead of spec frontmatter `approved` field.
2. `research.md` SHALL generate `dependency-contract.yaml` from `interface-compatibility.yaml` `dependency_contract` section, then consume it in Z3 steps 10-12.
3. ALL task cards across `.opencode/skills/` SHALL be audited for tracking-state-in-spec violations.
4. The mandate "specs and plans are NOT tracking documents" SHALL be enforced at the task card level.

## Affected Files

- **MODIFY:** `.opencode/skills/writing-plans/tasks/analyze.md` — replace frontmatter check with issue.yaml labels check
- **MODIFY:** `.opencode/skills/writing-plans/tasks/research.md` — replace BLOCK-if-missing with generate-from-artifact
- **AUDIT:** All `.opencode/skills/*/tasks/*.md` — check for tracking-state-in-spec violations

## Enforcement Gate

ALL 4 success criteria MUST pass before this spec is considered complete. No partial delivery.
