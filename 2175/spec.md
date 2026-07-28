> **Full spec and artifacts: [`.opencode#2175/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2175)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2175/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The agent's reasoning blocks contain deliberation patterns triggered by aggregate metadata in plan files. When the plan summary states "134 steps total across 4 phases," the agent perceives a volume signal and rationalizes procedural shortcuts: batching multiple pipeline steps into a single sub-agent dispatch, skipping intermediate gates, and overriding the step-level dispatch mandate.

The deliberation sequence is:
1. Perception: "134 steps" → volume signal
2. Evaluation: "that's a lot of roundtrips" → cost signal
3. Rationalization: "let me be efficient and batch" → override justification
4. Action: dispatch multiple steps to one sub-agent → violation

The root cause is that plan files contain aggregate metadata (total step counts) that the orchestrator reads but has no routing use for. The orchestrator dispatches steps one-at-a-time via step-level dispatch — it never needs to know the total count. The total count is consumed, uselessly, and causes harm.

## Scope

Audit and remediate all plan artifacts in `.opencode/skills/writing-plans/` that produce or reference aggregate step counts, total phase sizes, or any volume metadata that the orchestrator reads but has no routing use for.

**In scope:**
- Plan summary lines with total step counts (e.g., "134 steps total across 4 phases")
- Plan phase headers with per-phase step counts
- Any aggregate count in plan files that the orchestrator reads
- The `writing-plans/tasks/create.md` task file that produces these summaries
- The `writing-plans/tasks/self-review.md` task file that validates plan structure
- The `writing-plans/tasks/validate.md` task file that validates plan structure
- The `writing-plans/reference/plan-artifact-format.md` reference document

**Out of scope:**
- Internal pipeline bookkeeping (assemble-work.md total_steps field — consumed by the pipeline, not the orchestrator)
- Spec SC tables with line counts (covered by #2138)
- Agent output pattern detection (covered by #2089)
- Pseudo-machine-parseable formatting (covered by #2137)
- The `lessons-learned/` directory

## Relationship to Existing Issues

| Issue | Title | Relationship |
|-------|-------|-------------|
| #2138 | Audit line-count/word-count metrics as proxy for correctness | **Related but distinct** — #2138 targets spec SC tables using `wc -l` as verification. This spec targets plan metadata that triggers deliberation. No overlap. |
| #2089 | Agent cost-blindness enforcement — watchdog detection and hard halt | **Complementary** — #2089 catches cost-rationalization in agent output. This spec removes the trigger from plan files so the deliberation never starts. Both needed. |
| #2137 | Audit pseudo-machine-parseable formatting with no consumer | **Partial overlap** — #2137 targets formatting with no consumer. This spec targets metadata that has a consumer (the orchestrator) but the consumption is harmful. The remediation may overlap (removing summary lines from plan files). |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `writing-plans/tasks/create.md` no longer produces plan summary lines with aggregate step counts (e.g., "134 steps total across 4 phases") | string | grep create.md for absence of step-count summary patterns |
| SC-2 | `writing-plans/tasks/self-review.md` no longer validates or references aggregate step counts in plan structure | string | grep self-review.md for absence of step-count validation patterns |
| SC-3 | `writing-plans/tasks/validate.md` no longer validates or references aggregate step counts in plan structure | string | grep validate.md for absence of step-count validation patterns |
| SC-4 | `writing-plans/reference/plan-artifact-format.md` no longer documents aggregate step counts as part of plan format | string | grep plan-artifact-format.md for absence of step-count format documentation |
| SC-5 | Internal pipeline bookkeeping (assemble-work.md total_steps field) is NOT modified — pipeline state tracking is legitimate | string | grep assemble-work.md for presence of total_steps field (unchanged) |
| SC-6 | Behavioral enforcement test verifies agent does NOT deliberate about step volume when executing a plan | behavioral | opencode run with plan execution prompt → assert_semantic for clean-room evaluation of reasoning blocks |
| SC-7 | Spec defines the defective pattern (aggregate metadata with no routing use that triggers deliberation) with IS/IS NOT examples | string | grep spec for pattern definition |
| SC-8 | Spec scopes the audit with explicit in-scope and out-of-scope categories | string | grep spec for scope section |
| SC-9 | Spec documents relationship to existing issues #2138, #2089, #2137 | string | grep spec for cross-references to those issues |
| SC-10 | Spec does NOT contain any aggregate step count or volume metadata in its own body | string | grep spec for absence of step-count patterns |

## Phases

### Phase 1: Spec creation and validation
Create this spec, validate it, and file as a GitHub Issue.

### Phase 2: Remediation — remove aggregate step counts from plan artifacts
Update the 4 affected files (create.md, self-review.md, validate.md, plan-artifact-format.md) to remove aggregate step count summaries. Each file change is a separate item with its own RED/GREEN cycle.

### Phase 3: Verification — pipeline bookkeeping unchanged + behavioral test
Verify that internal pipeline bookkeeping (assemble-work.md total_steps) is NOT modified. Create a behavioral enforcement test that verifies the agent does not deliberate about step volume when executing a plan.

## Files Affected

- `.opencode/skills/writing-plans/tasks/create.md` — remove step-count summary from plan output
- `.opencode/skills/writing-plans/tasks/self-review.md` — remove step-count validation
- `.opencode/skills/writing-plans/tasks/validate.md` — remove step-count validation
- `.opencode/skills/writing-plans/reference/plan-artifact-format.md` — remove step-count format documentation
- `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` — verify NOT modified (pipeline bookkeeping is legitimate)
- `.opencode/tests-v2/behaviors/` — new behavioral enforcement test

## Dependencies

- None. Standalone spec.
