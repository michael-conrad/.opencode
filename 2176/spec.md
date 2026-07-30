> **Full spec and artifacts: [`.opencode/.issues/2176/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2176)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2176/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Reduce pipeline ceremony overhead and remove legacy audit system references from the opencode agent pipeline.

## Background

SQLite analysis of 17,187 sessions in the production database shows 8,488 sessions (49.4%) are ceremony-related, consuming 7.22B input tokens (31.9% of all tokens). The per-item cycle has 15+ sub-agent dispatches per SC. The writing-plans pipeline has 8+ steps. Checkpoint tag creation dispatches a full sub-agent session for a single git tag command (98 sessions, 78M tokens). 13 stale `git-workflow/tasks/` path references point to a non-existent directory (verified: 5 in skills, 2 in guidelines, 6 in .guidelines/). 14 SKILL.md files reference the old resolve-models auditor routing pattern (verified: `grep -rnl 'resolve-models' .opencode/skills/*/SKILL.md`). Multiple task files contain skill() + task() instructions that sub-agents cannot execute. The cross-validate step in the implementation-pipeline TDT is from the old audit system. Legacy task files remain in skill directories after being removed from TDTs.

> **Provenance note:** The SQLite session analysis numbers (17,187 sessions, 8,488 ceremony, 7.22B tokens) are from a production database analysis conducted prior to this spec. The analysis artifact is at `.opencode/.issues/2176/artifacts/session-analysis.md` (generated during spec creation). The grep-based counts (13 stale paths, 14 SKILL.md files) were verified live during this spec audit via `grep -rn 'git-workflow/tasks/' .opencode/` and `grep -rnl 'resolve-models' .opencode/skills/*/SKILL.md`.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| SQLite session analysis | Production DB analysis | `.opencode/.issues/2176/artifacts/session-analysis.md` | Pre-spec analysis, methodology documented in artifact |
| Stale git-workflow/tasks/ references | Live grep | `.opencode/` | `grep -rn 'git-workflow/tasks/' .opencode/` — 13 matches in active files |
| resolve-models in SKILL.md | Live grep | `.opencode/skills/*/SKILL.md` | `grep -rnl 'resolve-models' .opencode/skills/*/SKILL.md` — 14 files |
| Legacy task files | File listing | `.opencode/skills/implementation-pipeline/tasks/` + `.opencode/skills/audit/tasks/` | `ls` — 12 files in impl-pipeline, 2 in audit |
| skill()/task() in task files | Live grep | `.opencode/skills/*/tasks/` | `grep -rn 'skill({name:\|task(' .opencode/skills/*/tasks/` — 100+ matches |

## Intent and Executive Summary

- **Problem Statement:** Pipeline ceremony overhead consumes 49.4% of agent sessions and 31.9% of input tokens. Legacy audit system references, stale path references, and over-engineered pipeline steps add unnecessary sub-agent dispatches and token consumption.
- **Root Cause / Motivation:** The implementation-pipeline and writing-plans pipelines accumulated legacy patterns (resolve-models auditor routing, cross-validate steps, checkpoint-commit sub-agent dispatches, stale git-workflow/tasks/ paths) that are no longer needed after the audit DiMo chain migration. Per-item cycles grew to 15+ dispatches per SC without any single change being responsible.
- **Approach Chosen:** Five-phase incremental restructuring: (1) TDT and state machine updates, (2) path reference fixes, (3) sub-agent dispatch prohibition cleanup, (4) pipeline restructuring, (5) file cleanup. Each phase is independently verifiable and gated by the prior phase.
- **Alternatives Considered & Why Discarded:**
  - *Wholesale rewrite of implementation-pipeline SKILL.md* — Discarded because it would break all in-flight work and require re-approval of the entire pipeline. Incremental phases allow each change to be verified independently.
  - *Single monolithic PR* — Discarded because 27+ affected files across 5 concern areas would produce an unreviewable PR. Phase decomposition enables per-phase review and checkpoint rollback.
  - *Defer cleanup to a follow-up spec* — Discarded because stale references and legacy files accumulate technical debt that compounds with each new skill addition. Cleaning up alongside the restructuring is cheaper than a separate cleanup pass.
- **Key Design Decisions:**
  - Checkpoint tag creation is inline (orchestrator runs git commands directly) — eliminates 98 sub-agent sessions for a single git tag command
  - Per-item cycle collapsed to uniform 6 steps + inline commit + DiMo audit — eliminates 9+ dispatches per SC
  - Writing-plans pipeline collapsed to 4 steps — eliminates 4+ dispatches per plan
  - Single inline Z3 check per phase after AUDIT — eliminates bifurcated Z3 routing
  - Phase 3 skips files in the Phase 5 removal list — avoids wasted work on files slated for deletion

## Not Included

- Behavioral enforcement test creation (handled by implementation plan)
- Changes to the audit DiMo chain itself (investigator → validator → evaluator → arbiter)
- Changes to the solve skill or Z3 constraint solver
- Changes to the spec-creation pipeline
- Changes to the approval-gate pipeline

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | implementation-pipeline TDT has no cross-validate, checkpoint-commit, or old per-item cycle steps. New steps (pre-regression, pre-regression-verify, red, green, post-regression, verify, commit inline, audit DiMo) are present. Pipeline state machine updated. Single inline Z3 check per phase after AUDIT. | string (DDL: seconds) | grep for removed step names in TDT; grep for new step names |
| SC-2 | All git-workflow/tasks/ references updated to correct sub-skill paths. No file in .opencode/ contains "git-workflow/tasks/" as a task file path. | string (DDL: seconds) | grep 'git-workflow/tasks/' across .opencode/ — expect 0 matches |
| SC-3 | No task file in .opencode/skills/*/tasks/ contains skill({name: ...}) or task(...) as an imperative instruction to the sub-agent. An "imperative instruction" is a step or directive telling the sub-agent to call skill() or task() (e.g., "Run `skill({name: 'audit'})` then `task(...)`"). Documentation references (e.g., "Invoked by: `skill({name: 'foo'})` → `task()`" in a task file header) are permitted — they describe how the orchestrator invokes the task, not what the sub-agent must do. | string (DDL: seconds) | grep for skill({name: pattern in tasks/ directories; manual review of each match to classify as imperative vs documentation |
| SC-4 | No SKILL.md file in .opencode/skills/ contains "resolve-models" or "auditor_1" or "auditor_2" in Sub-Agent Routing sections. | string (DDL: seconds) | grep for resolve-models/auditor_1/auditor_2 in SKILL.md files |
| SC-5 | Per-item cycle dispatches 6 steps (pre-regression, pre-regression-verify, red, green, post-regression, verify) plus inline commit. Writing-plans pipeline dispatches 4 steps (analyze, research, create, validate). | behavioral (DDL: minutes) | opencode run with full pipeline scenario, assert_semantic for step sequence |
| SC-6 | Checkpoint tag creation is inline (orchestrator runs git commands directly, no sub-agent dispatch). checkpoint-commit step removed from TDT. | behavioral (DDL: minutes) | opencode run with checkpoint scenario, assert_stderr_pattern for inline git tag |
| SC-7 | Legacy task files (cross-validate.md, resolve-models.md, checkpoint-tag-create.md, sc-count-gate.md, pre-red-baseline.md, post-red-enforcement.md, post-green-enforcement.md, tdd-chaining-gate.md, pre-flight.md) are removed or archived. No remaining reference to any removed file path exists in .opencode/. | string (DDL: seconds) | ls for each removed file + grep for each path |
| SC-8 | Orchestrator runs Z3 check inline at phase boundary after AUDIT, every phase, no skip condition. | behavioral (DDL: minutes) | opencode run with multi-phase scenario, assert_semantic for Z3 check after each AUDIT |

> **Enforcement gate:** All success criteria (SC-1 through SC-8) must pass verification before this spec is considered complete. Partial implementation is not permitted. Each phase gates on the prior phase's SCs passing.
>
> **Cost frame:** Verification cost is measured in defect-discovery-latency (DDL), not model roundtrips or execution time. A behavioral test that costs minutes to run but catches a defect at gate 1 is cheaper than a structural check that costs seconds but lets the defect ship to production. Every SC below uses the minimum sufficient evidence type — string SCs use grep (seconds), behavioral SCs use `opencode run` (minutes). Neither is "expensive" compared to the downstream rework cost of an undiscovered defect.

## Requirements

- REQ-1: Legacy audit system references removed from implementation-pipeline TDT and task files
- REQ-2: Checkpoint tag creation is inline (not sub-agent dispatch), checkpoint-commit step removed
- REQ-3: All git-workflow/tasks/ path references updated to correct sub-skill paths
- REQ-4: No task file contains skill() or task() instructions that sub-agents cannot execute
- REQ-5: Per-item cycle collapsed from 15+ steps to uniform 6-step cycle (pre-regression → pre-regression-verify → RED → GREEN → post-regression → VERIFY) + inline COMMIT + DiMo AUDIT
- REQ-6: Writing-plans pipeline collapsed from 8+ steps to 4-step pipeline (ANALYZE → RESEARCH → CREATE → VALIDATE)
- REQ-7: Implementation-pipeline TDT and state machine updated to reflect new cycle
- REQ-8: Single inline Z3 check per phase after AUDIT, no bifurcation
- REQ-9: Legacy task files removed and all cross-references audited
- REQ-10: Stale resolve-models references removed from all SKILL.md files

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Update implementation-pipeline TDT, state machine, and Z3 integration |
| 2 | SC-2 | Fix git-workflow/tasks/ path references across all affected files |
| 3 | SC-3 | Audit task files for skill()+task() instructions, replace with result contract instructions |
| 4 | SC-4 | Remove stale resolve-models references from all SKILL.md files |
| 5 | SC-5 | Collapse per-item cycle and writing-plans pipeline |
| 6 | SC-6 | Make checkpoint tags inline, remove checkpoint-commit step |
| 7 | SC-7 | Remove legacy task files, audit cross-references |
| 8 | SC-8 | Single inline Z3 check per phase after AUDIT |

## Dependencies

- None — this spec is self-contained within the .opencode submodule

## Traceability

| Requirement | SC | Phase |
|-------------|----|-------|
| REQ-1 | SC-1 | Phase 1 |
| REQ-7 | SC-1 | Phase 1 |
| REQ-8 | SC-8 | Phase 1 |
| REQ-3 | SC-2 | Phase 2 |
| REQ-4 | SC-3 | Phase 3 |
| REQ-10 | SC-4 | Phase 3 |
| REQ-5 | SC-5 | Phase 4 |
| REQ-6 | SC-5 | Phase 4 |
| REQ-2 | SC-6 | Phase 5 |
| REQ-9 | SC-7 | Phase 5 |

## Phases

### Phase 1 (REQ-1, REQ-7, REQ-8): TDT and state machine updates

Update implementation-pipeline TDT, state machine, and Z3 integration. Remove cross-validate, checkpoint-commit, and all old per-item cycle steps. Add new steps. This must precede Phase 4 (same TDT file).

**Affected files:** .opencode/skills/implementation-pipeline/SKILL.md, .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml

### Phase 2 (REQ-3): Fix path references

Fix git-workflow/tasks/ path references across all affected files.

**Affected files:** .opencode/skills/implementation-pipeline/SKILL.md, .opencode/skills/completion-core/SKILL.md, .opencode/skills/approval-gate-scope/tasks/verify-closed-issue.md, .opencode/skills/pr-creation-workflow/tasks/create.md, .opencode/guidelines/065-verification-honesty.md, .opencode/CHANGELOG.md, .opencode/.guidelines/registry.yaml

### Phase 3 (REQ-4, REQ-10): Sub-agent dispatch prohibition

Audit task files for skill()+task() instructions and resolve-models references. Replace with result contract instructions.

**Affected files:** All task files matching `grep -rn 'skill({name:\|task(' .opencode/skills/*/tasks/` (these contain imperative skill()/task() instructions that must be replaced with result contract instructions). All SKILL.md files matching `grep -rnl 'resolve-models' .opencode/skills/*/SKILL.md` (these contain stale resolve-models references that must be removed).

> **Cross-cutting note:** Phase 3 modifies task files containing skill()/task() instructions. Phase 5 removes legacy task files. If a file is both modified in Phase 3 and removed in Phase 5, the Phase 3 work is wasted. To avoid this, Phase 3 MUST skip any file that is in the Phase 5 removal list (`.opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md`, `.opencode/skills/audit/tasks/cross-validate.md`, `.opencode/skills/audit/tasks/resolve-models.md`, and all other files listed in Phase 5). Only modify files that will survive Phase 5 removal.

### Phase 4 (REQ-5, REQ-6): Pipeline restructuring

Collapse per-item cycle and writing-plans pipeline. Depends on Phase 1 (TDT must be updated first).

**Affected files:** .opencode/skills/implementation-pipeline/SKILL.md, .opencode/skills/writing-plans/SKILL.md, .opencode/skills/writing-plans/tasks/ (explore, structure, solve, self-review)

### Phase 5 (REQ-2, REQ-9): File cleanup

Make checkpoint tags inline, remove legacy task files, audit cross-references. Depends on all prior phases.

**Affected files:** Legacy task files to remove:
- `.opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md`
- `.opencode/skills/implementation-pipeline/tasks/sc-count-gate.md`
- `.opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md`
- `.opencode/skills/implementation-pipeline/tasks/post-red-enforcement.md`
- `.opencode/skills/implementation-pipeline/tasks/post-green-enforcement.md`
- `.opencode/skills/implementation-pipeline/tasks/tdd-chaining-gate.md`
- `.opencode/skills/implementation-pipeline/tasks/pre-flight.md`
- `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md`
- `.opencode/skills/implementation-pipeline/tasks/sc-closeout.md`
- `.opencode/skills/implementation-pipeline/tasks/assemble-work.md`
- `.opencode/skills/implementation-pipeline/tasks/behavioral-test-remediation.md`
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`
- `.opencode/skills/audit/tasks/cross-validate.md`
- `.opencode/skills/audit/tasks/resolve-models.md`
Verify no stale cross-references to any removed file path remain across `.opencode/` — expect 0 matches.
