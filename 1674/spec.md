> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/1674/

## Exec Summary

The implementation pipeline has a defective workflow model. Two task files (`assemble-work.md`, `pipeline-executor.md`) are written as if the reader can dispatch sub-agents via `task()`. Sub-agents cannot call `task()` — this is a platform constraint, not a rule. The current design has the orchestrator reading these `.md` files and executing steps inline, which violates clean-room dispatch principles, contains dead code, and creates ambiguity about who executes what.

Additionally, generated plans have a systemic defect: they omit mandatory implementation workflow steps or reference them with incorrect skill/task names. All steps in the implementation workflow are mandatory with no exceptions for any reason. Not including all mandatory steps in plans with the correct skill/task callouts is defective plan generation — plans must call the correct workflow skill task for each step.

### Cards (dependency order)
1. **Behavioral test creation** — Write behavioral enforcement test verifying orchestrator dispatches from SKILL.md dispatch table
2. **Update implementation-pipeline/SKILL.md** — Make Trigger Dispatch Table the single source of truth; preserve coercion rule, checkpoint/rollback, pre-flight handoff
3. **Remove "Sub-agents must not dispatch sub-agents" rule** — From 41 SKILL.md files + 3 reference files (init_skill.py, routing-only-template.md, skill-card-spec.md)
4. **Update cross-references** — In skills (~23 files), tests (5 files), and guidelines (3 files)
5. **Delete assemble-work.md and pipeline-executor.md** — After all cross-references are updated
6. **Enforce mandatory step completeness in plan generation** — Update writing-plans skill to require all implementation pipeline steps be included in generated plans with correct skill/task references. Plans missing mandatory steps or using incorrect skill/task names are defective and must be rejected.

### Key Decisions
- **Delete, don't rewrite**: The two task files contain orchestrator-inline work instructions and dead code (sub-agent dispatch steps that cannot execute). Deleting them and consolidating routing in the SKILL.md dispatch table is cleaner than rewriting.
- **Preserve critical logic**: Coercion rule (DONE_WITH_CONCERNS → FAIL), checkpoint/rollback, pre-flight handoff, and remediation routing are moved to SKILL.md before deletion.
- **Mandatory steps are non-waivable**: All implementation pipeline steps are mandatory. No exception for any reason — not scope, not authorization, not "continue" directives. Plans that omit steps or use incorrect skill/task names are defective and must be rejected at the plan validation gate.

### Risk Callouts
- **R2 — Coercion rule lost**: If DONE_WITH_CONCERNS → FAIL rule is not preserved, caveats ship as completion. Mitigated by SC-12.
- **R5 — Pre-flight handoff broken**: approval-gate and executing-plans both dispatch assemble-work. After deletion, these dispatches fail silently. Mitigated by Phase 3 dependency ordering (update dispatch targets before Phase 8 deletion).
- **R6 — Plan defects from missing steps**: Plans generated without all mandatory pipeline steps produce incomplete implementations. Mitigated by Card 6 enforcement in writing-plans.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.issues/1674/`.
After creation, `local-issues sync 1674` MUST be run and the result committed to create the local `.issues/1674/` entry.
The implementation plan will be created in `.issues/1674/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 OpenCode (deepseek-v4-flash)