## Problem

Two structural defects in the sub-agent dispatch architecture cause task files to instruct behavior that is structurally impossible, producing defective work.

### Defect 1: Sub-Agent Dispatching Sub-Agents

Sub-agents do **not** have the `task()` tool. When a task file instructs a sub-agent to "dispatch a sub-agent for X", the sub-agent cannot comply. It has three options, all defective:

| Option | Result |
|--------|--------|
| Skip the step | Silent omission — deliverable is incomplete |
| Do the work inline | Bypasses clean-room isolation — defeats the purpose of sub-agent decomposition |
| Return error | Only works if the task file has error-handling for this case (most don't) |

**Affected task files:**

| File | Instruction | Sub-agents to dispatch |
|------|------------|----------------------|
| `skills/writing-plans/tasks/create.md` | "dispatching sub-agents for sub-task steps" | 10+ (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion) |
| `skills/spec-creation/tasks/analytical-artifacts.md` | "dispatching a clean-room sub-agent" for each artifact | 7 (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) |
| `skills/spec-creation/tasks/create.md` | "task()s section-based sub-agents" | Verification sub-agents |
| `skills/verification-before-completion/tasks/behavioral-test-evaluation.md` | "dispatch a clean-room sub-agent" per SC | Per-SC sub-agents |

### Defect 2: DiMo Chain Bypass — Monolithic Task Files

The audit skill's DiMo chain requires **4 sequential clean-room sub-agents** (generator → knowledge-supporter → evaluator → path-provider). Three task files are declared as DiMo chain tasks but are actually monolithic — a single sub-agent does all 4 roles inline:

| Task File | Declared As | Actually Does | Severity |
|-----------|-------------|---------------|----------|
| `skills/audit/tasks/closure-verification.md` | DiMo chain (4 roles) | All 4 roles inline | HIGH |
| `skills/audit/tasks/spec-summary.md` | DiMo chain (4 roles) | All 4 roles inline | HIGH |
| `skills/audit/tasks/coherence-extraction.md` | DiMo chain (4 roles) | Generator only, but monolithic | MEDIUM |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No task file in `skills/` contains instructions for a sub-agent to dispatch another sub-agent via `task()` | `string` | `grep` for "dispatch.*sub-agent" or "task()" in task files that are themselves dispatched as sub-agents |
| SC-2 | `skills/writing-plans/tasks/create.md` is restructured so the orchestrator dispatches all sub-steps directly (flat dispatch chain) | `string` | File read confirms no sub-agent dispatch instructions remain |
| SC-3 | `skills/spec-creation/tasks/analytical-artifacts.md` is restructured so the orchestrator dispatches all 7 artifact sub-agents directly | `string` | File read confirms no sub-agent dispatch instructions remain |
| SC-4 | `skills/spec-creation/tasks/create.md` is restructured so the orchestrator dispatches verification sub-agents directly | `string` | File read confirms no sub-agent dispatch instructions remain |
| SC-5 | `skills/verification-before-completion/tasks/behavioral-test-evaluation.md` is restructured so the orchestrator dispatches per-SC sub-agents directly | `string` | File read confirms no sub-agent dispatch instructions remain |
| SC-6 | `skills/audit/tasks/closure-verification.md` is restructured to implement the DiMo chain as 4 separate role files (generator, knowledge-supporter, evaluator, path-provider) | `string` | File read confirms 4 role files exist and the monolithic task is removed or restructured |
| SC-7 | `skills/audit/tasks/spec-summary.md` is restructured to implement the DiMo chain as 4 separate role files | `string` | File read confirms 4 role files exist and the monolithic task is removed or restructured |
| SC-8 | `skills/audit/tasks/coherence-extraction.md` is restructured to implement the DiMo chain as 4 separate role files | `string` | File read confirms 4 role files exist and the monolithic task is removed or restructured |
| SC-9 | The `skills/skill-creator/reference/skill-card-spec.md` prohibition ("Do not dispatch sub-agents from within this task") is enforced across all task files | `behavioral` | Behavioral test: dispatch a sub-agent that reads a task file with sub-agent dispatch instructions; verify the sub-agent returns BLOCKED or skips the impossible instruction |
| SC-10 | All existing DiMo chain task files that are correctly implemented (verification-audit, spec-audit, plan-fidelity, concern-separation, drift-detection, guideline-audit, content-audit, test-quality-audit, coherence-maintenance) remain unchanged | `structural` | `ls` confirms 4 role files per audit type still exist |

## Affected Files

```
skills/writing-plans/tasks/create.md
skills/spec-creation/tasks/analytical-artifacts.md
skills/spec-creation/tasks/create.md
skills/verification-before-completion/tasks/behavioral-test-evaluation.md
skills/audit/tasks/closure-verification.md
skills/audit/tasks/spec-summary.md
skills/audit/tasks/coherence-extraction.md
```

## Non-Goals

- The DiMo chain protocol itself is not being redesigned — only the monolithic task files that bypass it are being fixed.
- The `implementation-pipeline/SKILL.md` step-level dispatch pattern (orchestrator dispatches directly) is the correct pattern and is not being changed.
- The `audit/SKILL.md` DiMo chain protocol (orchestrator dispatches 4 roles sequentially) is the correct pattern and is not being changed.
- The `writing-plans/tasks/solve.md` leaf-node declaration is the correct pattern and is not being changed.

## Root Cause

The root cause is that task files were written with the assumption that sub-agents have the `task()` tool, which they do not. The fix is to restructure these task files so the orchestrator handles all dispatch directly, and task files only contain instructions for work the sub-agent can actually perform with the tools it has.

## Implementation Approach

For each affected task file, the fix follows the same pattern:

1. **Identify** all instructions in the task file that tell the sub-agent to dispatch another sub-agent
2. **Move** those dispatch instructions to the orchestrator-level dispatch table (SKILL.md Trigger Dispatch Table)
3. **Replace** the dispatch instruction in the task file with a reference to the artifact or result the sub-agent should expect to receive (from the orchestrator)
4. **Update** the SKILL.md Trigger Dispatch Table to include the new dispatch entries

For monolithic DiMo chain task files:
1. **Split** the monolithic task into 4 separate role files (generator, knowledge-supporter, evaluator, path-provider)
2. **Update** the SKILL.md Trigger Dispatch Table to dispatch the 4 roles sequentially
3. **Remove** the monolithic task file or convert it to a reference document

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*