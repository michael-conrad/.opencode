> **Full spec and artifacts: [`.opencode/.issues/2176/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2176)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2176/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Reduce pipeline ceremony overhead and remove legacy audit system references from the opencode agent pipeline.

## Background

SQLite analysis of 17,187 sessions in the production database shows 8,488 sessions (49.4%) are ceremony-related, consuming 7.22B input tokens (31.9% of all tokens). The per-item cycle has 15+ sub-agent dispatches per SC. The writing-plans pipeline has 8+ steps. Checkpoint tag creation dispatches a full sub-agent session for a single git tag command (98 sessions, 78M tokens). 12+ stale git-workflow/tasks/ path references point to a non-existent directory. 18+ SKILL.md files reference the old resolve-models auditor routing pattern. Multiple task files contain skill() + task() instructions that sub-agents cannot execute. The cross-validate step in the implementation-pipeline TDT is from the old audit system. Legacy task files remain in skill directories after being removed from TDTs.

## Not Included

- Behavioral enforcement test creation (handled by implementation plan)
- Changes to the audit DiMo chain itself (investigator → validator → evaluator → arbiter)
- Changes to the solve skill or Z3 constraint solver
- Changes to the spec-creation pipeline
- Changes to the approval-gate pipeline

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | implementation-pipeline TDT has no cross-validate, checkpoint-commit, or old per-item cycle steps. New steps (pre-regression, pre-regression-verify, red, green, post-regression, verify, commit inline, audit DiMo) are present. Pipeline state machine updated. Single inline Z3 check per phase after AUDIT. | string | grep for removed step names in TDT; grep for new step names |
| SC-2 | All git-workflow/tasks/ references updated to correct sub-skill paths. No file in .opencode/ contains "git-workflow/tasks/" as a task file path. | string | grep 'git-workflow/tasks/' across .opencode/ — expect 0 matches |
| SC-3 | No task file in .opencode/skills/*/tasks/ contains skill({name: ...}) or task(...) as an imperative instruction to the sub-agent. | string | grep for skill({name: pattern in tasks/ directories |
| SC-4 | No SKILL.md file in .opencode/skills/ contains "resolve-models" or "auditor_1" or "auditor_2" in Sub-Agent Routing sections. | string | grep for resolve-models/auditor_1/auditor_2 in SKILL.md files |
| SC-5 | Per-item cycle dispatches 6 steps (pre-regression, pre-regression-verify, red, green, post-regression, verify) plus inline commit. Writing-plans pipeline dispatches 4 steps (analyze, research, create, validate). | behavioral | opencode run with full pipeline scenario, assert_semantic for step sequence |
| SC-6 | Checkpoint tag creation is inline (orchestrator runs git commands directly, no sub-agent dispatch). checkpoint-commit step removed from TDT. | behavioral | opencode run with checkpoint scenario, assert_stderr_pattern for inline git tag |
| SC-7 | Legacy task files (cross-validate.md, resolve-models.md, checkpoint-tag-create.md, sc-count-gate.md, pre-red-baseline.md, post-red-enforcement.md, post-green-enforcement.md, tdd-chaining-gate.md, pre-flight.md) are removed or archived. No remaining reference to any removed file path exists in .opencode/. | string | ls for each removed file + grep for each path |
| SC-8 | Orchestrator runs Z3 check inline at phase boundary after AUDIT, every phase, no skip condition. | behavioral | opencode run with multi-phase scenario, assert_semantic for Z3 check after each AUDIT |

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

**Affected files:** 30+ task files across skills, 14 SKILL.md files with resolve-models references

### Phase 4 (REQ-5, REQ-6): Pipeline restructuring

Collapse per-item cycle and writing-plans pipeline. Depends on Phase 1 (TDT must be updated first).

**Affected files:** .opencode/skills/implementation-pipeline/SKILL.md, .opencode/skills/writing-plans/SKILL.md, .opencode/skills/writing-plans/tasks/ (explore, structure, solve, self-review)

### Phase 5 (REQ-2, REQ-9): File cleanup

Make checkpoint tags inline, remove legacy task files, audit cross-references. Depends on all prior phases.

**Affected files:** 12 legacy task files to remove, grep-audit across entire .opencode/ tree
