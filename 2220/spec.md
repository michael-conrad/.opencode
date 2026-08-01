> **Full spec and artifacts: [`.opencode/.issues/2220/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2220)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2220/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC-FIX] Reduce approval-gate ceremony: 53 files → ~6 files

## Intent and Executive Summary

**Problem Statement:** The approval-gate skill hierarchy has grown to 53 files across 4 directory levels (dispatcher → sub-skill → task → sub-task). The core function — parse authorization scope, apply label, route — requires only 3 operations, but the ceremony around it (write-then-read-back recording, 14-step verify-authorization full path, 6 pre-implementation sub-tasks, 2 screen-issue sub-gates) inflates the surface area by ~8×. This ceremony creates maintenance burden, slows orchestrator dispatch, and duplicates concerns that belong to other skills (verify-codebase → pre-analysis, verify-blockers → pre-analysis, verify-closed-issue → verification, gap-fill-cascade → writing-plans).

**Root Cause / Motivation:** The approval-gate-scope sub-skill was created as a "scope verification" layer that accreted tasks over time. Each new task was added to the sub-skill because it was "related to authorization" rather than because it belonged to the authorization gatekeeping concern. The result is a skill that does too much: it verifies codebase state, checks for blockers, reconciles issue graphs, cascades spec-to-plan, screens issues through dual gates, and runs pre-implementation analysis — none of which are authorization gatekeeping.

**Approach Chosen:** Consolidate the 2 SKILL.md files into 1, delete all 47 task/enforcement files that belong to other concerns, keep only the core 3-step path (resolve scope → apply label → route), and update all cross-references. The merged SKILL.md retains the authorization scope model, bug discovery protocol, and DISPATCH_GATE protocol as inline sections — not as task dispatches.

**Alternatives Considered & Why Discarded:**
- *Keep everything, add documentation* — Does not solve the ceremony problem; 53 files remain.
- *Refactor into 3 separate skills* — Over-engineering; the core function is 3 operations.
- *Keep sub-skill but reduce tasks* — The sub-skill itself is the problem; the indirection layer adds no value.

**Key Design Decisions:**
- The merged SKILL.md is the single entry point. No sub-skill.
- The 3 retained tasks live in a flat `tasks/` directory under `approval-gate/`.
- Deleted tasks' concerns are absorbed by their owning skills (pre-analysis, verification, writing-plans, issue-operations).
- Behavioral enforcement tests that dispatched to deleted tasks are updated to dispatch to the merged skill.

**User Intent / Original Prompt:** Reduce the approval-gate skill hierarchy from 53 files across 4 levels to ~6 files in 1 flat directory, eliminating ceremony and redundant concern boundaries.

## Not Included

- Changes to the authorization scope model (for_analysis, for_spec, for_plan, for_implementation, for_pr) — preserved as-is.
- Changes to the `approved-for-*` label convention — preserved as-is.
- Changes to the bug discovery protocol — preserved as an inline section in the merged SKILL.md.
- Changes to other skills' concern boundaries — only cross-references are updated; no skill absorbs new tasks from approval-gate.
- New behavioral enforcement tests — existing tests are updated; no new test scenarios are added.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `approval-gate-scope/SKILL.md` content is merged into `approval-gate/SKILL.md` with all routing metadata, scope model, bug discovery protocol, and DISPATCH_GATE protocol preserved | `semantic` | Clean-room sub-agent reads merged SKILL.md and verifies all sections are present |
| SC-2 | `approval-gate-scope/SKILL.md` file is deleted | `structural` | `ls .opencode/skills/approval-gate-scope/SKILL.md` returns error |
| SC-3 | All `skill({name: 'approval-gate-scope'})` calls across the codebase are updated to `skill({name: 'approval-gate'})` | `string` | `grep -r 'approval-gate-scope' .opencode/` returns zero matches |
| SC-4 | All 22 task files under `approval-gate-scope/tasks/` are deleted | `structural` | `ls .opencode/skills/approval-gate-scope/tasks/` returns error or empty |
| SC-5 | All 5 enforcement files under `approval-gate-scope/enforcement/` are deleted | `structural` | `ls .opencode/skills/approval-gate-scope/enforcement/` returns error or empty |
| SC-6 | All 13 verify-authorization sub-task files are deleted | `structural` | `ls .opencode/skills/approval-gate-scope/tasks/verify-authorization/` returns error or empty |
| SC-7 | All 2 screen sub-task files are deleted | `structural` | `ls .opencode/skills/approval-gate-scope/tasks/screen/` returns error or empty |
| SC-8 | All 3 gap-fill-cascade sub-task files are deleted | `structural` | `ls .opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/` returns error or empty |
| SC-9 | All 6 pre-impl sub-task files are deleted | `structural` | `ls .opencode/skills/approval-gate-scope/tasks/pre-impl/` returns error or empty |
| SC-10 | All cross-references in other skills/guidelines that dispatch to deleted task files are updated or removed | `string` | `grep -r 'approval-gate-scope/tasks/' .opencode/` returns zero matches |
| SC-11 | Behavioral enforcement tests that dispatched to deleted tasks are updated to use the new dispatch interface | `behavioral` | `opencode run` with skill dispatch assertion verifies `approval-gate` loads correctly |
| SC-12 | No remaining references to `approval-gate-scope` exist in any `.opencode/` file | `string` | `grep -r 'approval-gate-scope' .opencode/` returns zero matches across all file types |

## Requirements

1. The merged `approval-gate/SKILL.md` SHALL contain all routing metadata, scope model, bug discovery protocol, and DISPATCH_GATE protocol from the deleted `approval-gate-scope/SKILL.md`.
2. The `approval-gate-scope/` directory SHALL be completely removed from the repository.
3. All `skill()` dispatch calls SHALL use `name: 'approval-gate'` — no callers SHALL reference `approval-gate-scope`.
4. All cross-references to deleted task files SHALL be updated or removed.
5. Behavioral enforcement tests SHALL verify the merged skill dispatches correctly.
6. The 3 retained tasks (resolve-scope, apply-label, route) SHALL live in a flat `tasks/` directory under `approval-gate/`.

## Items

1. **SC-1:** Merge approval-gate-scope/SKILL.md content into approval-gate/SKILL.md
2. **SC-2:** Delete approval-gate-scope/SKILL.md
3. **SC-3:** Update all skill() dispatch calls from 'approval-gate-scope' to 'approval-gate'
4. **SC-4:** Delete 22 task files in approval-gate-scope/tasks/
5. **SC-5:** Delete 5 enforcement files in approval-gate-scope/enforcement/
6. **SC-6:** Delete 13 verify-authorization sub-task files
7. **SC-7:** Delete 2 screen sub-task files
8. **SC-8:** Delete 3 gap-fill-cascade sub-task files
9. **SC-9:** Delete 6 pre-impl sub-task files
10. **SC-10:** Update cross-references in other skills/guidelines
11. **SC-11:** Update behavioral enforcement tests
12. **SC-12:** Verify no remaining references to deleted files

## Dependencies

- **Prerequisite:** None — this is a self-contained structural refactor of the approval-gate skill hierarchy.
- **Downstream:** All skills that dispatch to `approval-gate-scope` must be updated (SC-3, SC-10). Behavioral enforcement tests must be updated (SC-11).

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1 (merged SKILL.md) | SC-1 | Phase 1 |
| R2 (remove directory) | SC-2, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 | Phase 2 |
| R3 (dispatch calls) | SC-3 | Phase 1 |
| R4 (cross-references) | SC-10, SC-12 | Phase 3 |
| R5 (behavioral tests) | SC-11 | Phase 3 |
| R6 (flat tasks/) | SC-1 (implied by merge) | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Pre-spec inspection | Analysis artifact | `tmp/approval-gate-fix/artifacts/pre-spec-inspection.yaml` | Read |
| Blast radius | Analysis artifact | `tmp/approval-gate-fix/artifacts/blast-radius.yaml` | Read |
| Concern map | Analysis artifact | `tmp/approval-gate-fix/artifacts/concern-map.yaml` | Read |
| Code path inventory | Analysis artifact | `tmp/approval-gate-fix/artifacts/code-path-inventory.yaml` | Read |
| Cross-cutting matrix | Analysis artifact | `tmp/approval-gate-fix/artifacts/cross-cutting-matrix.yaml` | Read |
| Interface compatibility | Analysis artifact | `tmp/approval-gate-fix/artifacts/interface-compatibility.yaml` | Read |
| State analysis | Analysis artifact | `tmp/approval-gate-fix/artifacts/state-analysis.yaml` | Read |
| Testability assessment | Analysis artifact | `tmp/approval-gate-fix/artifacts/testability-assessment.yaml` | Read |
| Pipeline readiness | Analysis artifact | `tmp/approval-gate-fix/artifacts/pipeline-readiness.yaml` | Read |

## Enforcement Gate

ALL 12 success criteria MUST pass before this fix is complete. There is no partial delivery — the approval-gate skill is either consolidated or it is not. A single remaining reference to `approval-gate-scope` or a single undeleted task file constitutes a FAIL.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the merged SKILL.md preserves all sections costs one clean-room sub-agent read. Skipping means the merged skill loses routing metadata and orchestrators cannot dispatch approval-gate correctly.
- SC-2: Verifying the deleted file is gone costs one `ls` call. Skipping means the old SKILL.md remains and orchestrators may load the wrong file.
- SC-3: Grepping for stale dispatch calls costs seconds. Skipping means orchestrators silently fail when dispatching to the deleted skill name.
- SC-4/5/6/7/8/9: Verifying deleted task directories are gone costs one `ls` per directory. Skipping means orphaned files accumulate and confuse future maintainers.
- SC-10: Grepping for stale cross-references costs seconds. Skipping means broken `Read [Text](path)` references in other skills.
- SC-11: Running the behavioral test costs minutes of execution time. Skipping means the behavioral defect ships and costs 1000× more to fix.
- SC-12: Final grep sweep costs seconds. Skipping means a stale reference survives and breaks the next orchestrator dispatch.

## Edge Cases

- **Orchestrator in-flight:** If an orchestrator has already loaded `approval-gate-scope` in its current session, the old skill card remains cached. The fix only affects new sessions. This is acceptable — orchestrator context is per-session disposable.
- **Submodule pointer:** The `.opencode` submodule pointer in the parent repo must be updated after this fix is merged. This is handled by the normal submodule pointer update workflow.
- **Behavioral test flakiness:** If the behavioral test (SC-11) flakes due to model timeout, increase `BEHAVIOR_TIMEOUT` per the test integrity mandate — do not remove or weaken the assertion.
- **Cross-repo references:** If any parent-repo files reference `approval-gate-scope`, those must be updated in the parent repo separately. This spec covers only the `.opencode` submodule.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
