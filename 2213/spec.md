---
approved: true
---

## Intent and Executive Summary

- **Problem Statement:** `plan-creation-pipeline` is a separate skill that does nothing but dispatch to other skills. Its `plan-create` step is a literal passthrough to `writing-plans --task create`. Its 3 extra steps (`solve-model`, `solve-check`, `plan-plan`) already exist inside `writing-plans/tasks/research.md` as steps 10-12. The pipeline adds routing overhead, maintenance burden, and routing ambiguity (agents must choose between two skills) with zero functional benefit.
- **Root Cause / Motivation:** The skill was created as a separate orchestrator layer before the current flat-architecture pattern was established. It has never had unique functionality — every step duplicates or passthroughs to another skill. Keeping it creates ongoing maintenance burden and routing confusion.
- **Approach Chosen:** Delete the skill directory outright and consolidate its functionality into `writing-plans` via a new `handoff` task and enhanced `completion` task. No deprecation period — the skill has zero unique functionality to migrate.
- **Alternatives Considered & Why Discarded:** Deprecation (adds dead code with no migration benefit), keeping as-is (perpetuates routing ambiguity), merging into a new combined skill (unnecessary — writing-plans already has the right structure).
- **Key Design Decisions:** (1) Delete, don't deprecate — no unique functionality to preserve. (2) Handoff as a new task file in writing-plans, not a separate skill. (3) Z3/planning steps stay in research.md — no behavioral change to constraint solving. (4) Cross-reference audit required before implementation.
- **User Intent / Original Prompt:** Consolidate plan-creation-pipeline into writing-plans to eliminate routing ambiguity and reduce maintenance burden.

## Not Included

- Changes to the Z3 constraint solving pipeline (solve-model, solve-check, plan-plan) — these remain in research.md as steps 10-12 with no behavioral change
- Changes to `writing-plans/tasks/research.md` structure beyond the workflow order update
- Changes to `writing-plans/tasks/create.md`, `writing-plans/tasks/validate.md`, or `writing-plans/tasks/revise.md`
- Deprecation warnings or migration shims for plan-creation-pipeline
- Changes to any skill outside the affected files list
- Behavioral changes to the plan creation output format or content

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `plan-creation-pipeline` skill directory is deleted (SKILL.md + tasks/authorization-context.md) | structural | `ls .opencode/skills/plan-creation-pipeline/` returns "No such file or directory" |
| SC-2 | `writing-plans` workflow gains a `handoff` step before `analyze` that verifies authorization via `approval-gate --task verify-authorization` | string + behavioral | grep for `handoff` in writing-plans/SKILL.md Workflows section; `opencode run` with plan-creation prompt verifies handoff dispatch in stderr |
| SC-3 | `writing-plans` workflow order is: handoff -> analyze -> research -> create -> validate -> (revise loop) -> completion | string | grep for sequential step order in writing-plans/SKILL.md Workflows section |
| SC-4 | `writing-plans/tasks/completion.md` gains worktree sync (`local-issues sync`) and chat output with exec summary + URL + AI byline | string + behavioral | grep for `local-issues sync` and byline pattern in completion.md; `opencode run` verifies completion output includes exec summary + URL + byline |
| SC-5 | All cross-references to `plan-creation-pipeline` in other skills/guidelines are updated to reference `writing-plans` instead | string | grep for `plan-creation-pipeline` across `.opencode/` returns zero matches |
| SC-6 | `writing-plans/SKILL.md` Trigger Dispatch Table and Workflows section updated to reflect the new workflow order | string | grep for `handoff` in writing-plans/SKILL.md Trigger Dispatch Table and Workflows section |
| SC-7 | No behavioral change to the 3 Z3/planning steps (solve-model, solve-check, plan-plan) — they remain in research.md as steps 10-12 | string | Pre-change baseline captured by running `opencode run "create plan for #2213"` and recording stderr Z3 dispatch patterns (solve-model, solve-check, plan-plan). Post-change: same prompt, same model, same test home. PASS if all 3 Z3 dispatch strings appear in stderr in the same order. FAIL if any Z3 dispatch is missing, reordered, or new Z3-related dispatch appears. |

## Requirements

1. The `plan-creation-pipeline` skill directory SHALL be deleted in its entirety.
2. A `handoff` task SHALL be created at `writing-plans/tasks/handoff.md` that calls `approval-gate --task verify-authorization`.
3. The `writing-plans` workflow SHALL include `handoff` as the first step before `analyze`.
4. The `writing-plans/tasks/completion.md` SHALL include `local-issues sync` and chat output with exec summary, URL, and AI byline.
5. All cross-references to `plan-creation-pipeline` SHALL be updated to `writing-plans`.
6. The `writing-plans/SKILL.md` Trigger Dispatch Table and Workflows section SHALL reflect the new workflow order.
7. The Z3/planning steps (solve-model, solve-check, plan-plan) SHALL remain unchanged in `writing-plans/tasks/research.md`.

## Items

1. SC-1: Delete plan-creation-pipeline skill directory
2. SC-2: Create handoff task in writing-plans
3. SC-3: Update writing-plans workflow order
4. SC-4: Enhance completion.md with sync + chat output
5. SC-5: Update all cross-references
6. SC-6: Update writing-plans/SKILL.md routing metadata
7. SC-7: Verify no behavioral change to Z3 steps

## Dependencies

- None — this spec is self-contained. No prerequisite specs, skills, or guidelines are required.

## Traceability

| Requirement | SC | Phase |
|-------------|----|-------|
| R1 | SC-1 | Phase 1 |
| R2 | SC-2 | Phase 2 |
| R3 | SC-3, SC-6 | Phase 3 |
| R4 | SC-4 | Phase 4 |
| R5 | SC-5 | Phase 5 |
| R6 | SC-6 | Phase 3 |
| R7 | SC-7 | Phase 6 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| writing-plans/SKILL.md | Skill card | `.opencode/skills/writing-plans/SKILL.md` | Read file |
| writing-plans/tasks/completion.md | Task card | `.opencode/skills/writing-plans/tasks/completion.md` | Read file |
| writing-plans/tasks/research.md | Task card | `.opencode/skills/writing-plans/tasks/research.md` | Read file |
| plan-creation-pipeline/SKILL.md | Skill card | `.opencode/skills/plan-creation-pipeline/SKILL.md` | Read file (pre-deletion) |
| plan/SKILL.md | Skill card | `.opencode/skills/plan/SKILL.md` | Read file |
| approval-gate skill | Skill card | `.opencode/skills/approval-gate/SKILL.md` | Read file |

## Enforcement Gate

ALL 7 success criteria MUST pass before this spec is considered complete. No partial delivery is permitted.

## Cost Frame

| SC | Cost Frame |
|----|-----------|
| SC-1 | Structural — file deletion. Low cost, single `rm -rf` operation. |
| SC-2 | String + behavioral — new task file creation plus behavioral test. Medium cost. |
| SC-3 | String — workflow order update in SKILL.md. Low cost. |
| SC-4 | String + behavioral — modify completion.md plus behavioral test. Medium cost. |
| SC-5 | String — grep-and-replace across `.opencode/`. Low cost. |
| SC-6 | String — SKILL.md routing metadata update. Low cost. |
| SC-7 | String — pre/post stderr dispatch pattern comparison. Low cost. |

## Edge Cases

- **SC-1 rollback:** If deletion causes unexpected issues, `git checkout .opencode/skills/plan-creation-pipeline/` restores the directory from git history. The deletion is a standard `git rm -r` operation — fully recoverable via git.
- **SC-5 cross-reference miss:** If a cross-reference is discovered post-implementation, it must be fixed in a follow-up. The pre-implementation grep audit minimizes this risk.
- **SC-7 regression:** If the Z3 steps produce different stderr dispatch patterns after the workflow reorder, the change must be reverted and the root cause investigated. The pre-change stderr baseline captures pre-change behavior.
- **SC-2 authorization failure:** If `approval-gate --task verify-authorization` blocks the handoff, the plan creation workflow halts with a clear BLOCKED message — no silent failure.
- **Concurrent spec conflicts:** If another spec modifies writing-plans/SKILL.md concurrently, merge conflicts must be resolved manually. The affected files are limited to writing-plans and plan-creation-pipeline.

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

## Rollback / Recovery

SC-1 involves deleting a skill directory. While git provides full recovery via `git checkout`, the following procedure documents the recovery path:

1. **Pre-deletion checkpoint:** Before deletion, verify the directory exists and note its contents.
2. **Deletion:** `git rm -r .opencode/skills/plan-creation-pipeline/`
3. **Recovery (if needed):** `git checkout HEAD~1 -- .opencode/skills/plan-creation-pipeline/` restores the directory.
4. **Post-deletion verification:** Confirm `ls .opencode/skills/plan-creation-pipeline/` returns "No such file or directory".
5. **Commit includes deletion only alongside other changes** — never a standalone deletion commit.
