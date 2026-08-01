## Problem

`plan-creation-pipeline` is a separate skill that does nothing but dispatch to other skills. Its `plan-create` step is a literal passthrough to `writing-plans --task create`. Its 3 extra steps (`solve-model`, `solve-check`, `plan-plan`) already exist inside `writing-plans/tasks/research.md` as steps 10-12. The pipeline adds routing overhead, maintenance burden, and routing ambiguity (agents must choose between two skills) with zero functional benefit.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `plan-creation-pipeline` skill directory is deleted (SKILL.md + tasks/authorization-context.md) | structural |
| SC-2 | `writing-plans` workflow gains a `handoff` step before `analyze` that verifies authorization via `approval-gate --task verify-authorization` | string + behavioral |
| SC-3 | `writing-plans` workflow order is: handoff -> analyze -> research -> create -> validate -> (revise loop) -> completion | string |
| SC-4 | `writing-plans/tasks/completion.md` gains worktree sync (`local-issues sync`) and chat output with exec summary + URL + AI byline | string + behavioral |
| SC-5 | All cross-references to `plan-creation-pipeline` in other skills/guidelines are updated to reference `writing-plans` instead | string |
| SC-6 | `writing-plans/SKILL.md` Trigger Dispatch Table and Workflows section updated to reflect the new workflow order | string |
| SC-7 | No behavioral change to the 3 Z3/planning steps (solve-model, solve-check, plan-plan) — they remain in research.md as steps 10-12 | behavioral |

## Approach / Design Decisions

1. **Delete, don't deprecate.** The skill has no unique functionality — every step is a passthrough or a duplicate. Deprecation adds dead code with no migration benefit.

2. **Handoff as a new task file.** `writing-plans/tasks/handoff.md` is a lightweight task that calls `approval-gate --task verify-authorization` and returns DONE or BLOCKED. This replaces the `spec-to-plan-handoff` step from `plan-creation-pipeline`.

3. **Completion enhancement.** `writing-plans/tasks/completion.md` gains the `local-issues sync` call and chat output (exec summary + URL + AI byline) that were previously in `plan-creation-pipeline`'s `plan-completion` step.

4. **Z3/planning steps stay in research.md.** Steps 10-12 of `writing-plans/tasks/research.md` (solve-model, solve-check, plan-plan) are unchanged. No behavioral change to the constraint solving pipeline.

5. **Cross-reference audit.** All files referencing `plan-creation-pipeline` must be updated to reference `writing-plans` instead. The known reference is `plan/SKILL.md` description field.

## Affected Files

- **DELETE:** `.opencode/skills/plan-creation-pipeline/SKILL.md`
- **DELETE:** `.opencode/skills/plan-creation-pipeline/tasks/authorization-context.md`
- **CREATE:** `.opencode/skills/writing-plans/tasks/handoff.md`
- **MODIFY:** `.opencode/skills/writing-plans/SKILL.md` — Trigger Dispatch Table, Workflows section, file structure
- **MODIFY:** `.opencode/skills/writing-plans/tasks/completion.md` — add worktree sync + chat output
- **MODIFY:** `.opencode/skills/plan/SKILL.md` — update description to remove `plan-creation-pipeline` reference

## Cross-Reference Audit Requirement

Before implementation, a full grep for `plan-creation-pipeline` across the entire `.opencode/` directory must be performed. All matches must be updated to reference `writing-plans` instead. Known matches:

- `plan/SKILL.md` description field (distinct from note)

Any additional matches discovered during audit must also be updated per SC-5.

