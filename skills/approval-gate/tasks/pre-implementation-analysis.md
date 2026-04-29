# Task: pre-implementation-analysis (Routing Document)

## Purpose

Analyze interdependencies and determine execution order for all approved issues — whether one or many — producing a flat item list for `assemble-work` dispatch. Every approval follows this unified path: sub-issue expansion → flat item list → assemble-work → work branch → pr-creation → one PR.

This task is a **routing document** that delegates to 6 atomic tasks in `pre-impl/`. The routing document itself stays compact; sub-agents perform the heavy analysis.

## Entry Criteria

- One or more issues approved
- Each issue verified by `verify-authorization`
- User explicitly authorized implementation

## Exit Criteria

- Execution plan presented in chat (informative only — not a gate)
- Agent proceeds immediately to `assemble-work` (no HALT between analysis and dispatch)

## Atomic Task Chain

```
collect-screening-results → reconcile-status → build-dependency-graph
→ check-cross-spec-overlap → write-work-state → yield-to-assemble-work
```

| Atomic Task | Concern | Original Steps |
|------------|---------|----------------|
| `pre-impl/collect-screening-results` | Mandatory sub-agent dispatch, screening collection, no-questions rule, autonomous classification resolution, gate evidence audit table | Steps -1, 0, 0.1, 0.15, 0.5 |
| `pre-impl/reconcile-status` | Issue status inconsistency reconciliation via `reconcile-issue-graph` | Step 0.7 |
| `pre-impl/build-dependency-graph` | Flat item list, cross-issue analysis, issue classification, dependency graph construction | Steps 1, 2, 3, 4 |
| `pre-impl/check-cross-spec-overlap` | Overlap check against open specs/plans outside the batch (four-tier classification) | Step 2 (Cross-Spec Overlap subsection) |
| `pre-impl/write-work-state` | Execution strategy, dev base hash, dispatch context, work state file persistence | Steps 5, 7, 8, 9 |
| `pre-impl/yield-to-assemble-work` | Present execution plan, verify no-questions checkpoint, dispatch to assemble-work | Steps 6, 10 |

**Chain-of-responsibility note:** Each atomic task uses the work state file for inter-task I/O. Tasks read inputs from predecessor sections and write results to their own section per `enforcement/work-state-schema.md`.

## Execution Order Determination

The analysis produces an execution order based on:

1. **Must-precede dependencies:** Issue A must complete before Issue B starts
2. **Should-precede dependencies:** Issue A should complete before Issue B for efficiency
3. **Independent issues:** Issues can be executed in any order or in parallel (opportunistic)

**Stacking is prerequisite, parallel is opportunistic.** The default execution model is sequential branch stacking. Parallel execution requires explicit justification documented in the work state.

## Branch Stacking Model

For multi-issue authorization sets, branches are stacked:

```
dev → feature/A (implement issue A)
       ↓ merge feature/A into feature/B
       feature/B (implement issue B, includes A's changes)
```

This ensures each branch builds on the prior branch's changes, avoiding merge conflicts between the branches.

## Red Flags — CRITICAL

These patterns indicate a violation or impending violation:

- **Never skip dependency analysis** when multiple issues are approved together
- **Never dispatch parallel subagents** for conflict-risk issues without serialization
- **Never include meta/non-code, already-implemented, superseded, or moot issues** in the implementation plan
- **Never present dependency analysis only in agent reasoning** — MUST be in chat
- **Never assume all issues are independent** without analysis
- **Never execute must-precede issues out of order**
- **Never use `question` tool** after presenting the execution plan
- **Never HALT between plan presentation and `assemble-work`** — proceed immediately
- **Never escalate status inconsistencies** to the developer (use `reconcile-issue-graph`)

## Cross-References

- `000-critical-rules.md` §"Pushing Agent Intelligence Decisions to the User" — structural decisions are agent intelligence concerns
- `020-go-prohibitions.md` §1 — no prompts for authorization; "approved to PR" covers the full pipeline
- `screen-issue.md` — exhaustive `requires_developer: true` conditions
- `approval-gate/SKILL.md` §"Dispatch Order" — "MUST auto-dispatch" after analysis completes

## Enforcement References

- Evidence format + finding classification: see `enforcement/adversarial-verification.md`
- Scope parsing: see `enforcement/scope-parsing.md`
- Auto-dispatch routing: see `enforcement/auto-dispatch-table.md`
- Closed-issue verification: see `enforcement/closed-issue-verification.md`
- Sub-issue graph traversal: see `enforcement/sub-issue-graph-traversal.md`

## for_pr Scope Continuation Gate (MANDATORY)

**⚠️ CRITICAL: When `authorization_scope` is `for_pr`, `pr_only`, `for_implementation`, or `for_code_review`, the agent MUST NOT produce a halting summary with "Next steps" or similar forward-looking text.**

The `pre-implementation-analysis` task is a pipeline stage, NOT a terminal deliverable. When the authorization scope requires the pipeline to continue, the task MUST set `continue_pipeline=true` and proceed immediately to the next dispatch chain step.

### Scope-Based Continuation Rules

| `authorization_scope` | Action After Analysis | Halting Output? |
|-----------------------|----------------------|-----------------|
| `for_pr` | Proceed directly to gap-fill → `pre-work` → `assemble-work` | **NO** — continue pipeline |
| `pr_only` | Proceed directly to `pre-work` → `assemble-work` → PR creation | **NO** — continue pipeline |
| `for_implementation` | Proceed directly to `pre-work` → `assemble-work` | **NO** — continue pipeline |
| `for_code_review` | Proceed directly to `pre-work` → `assemble-work` | **NO** — continue pipeline |
| `for_plan` | HALT after plan creation | Yes — `halt_at == plan_created` |
| `for_spec` | HALT after spec creation | Yes — `halt_at == spec_created` |
| `standard` | HALT after analysis (review-prep) | Yes — `halt_at == review_prep` |

### Mandatory Behavior When `continue_pipeline=true`

1. **DO NOT** include "Next steps", "Recommended actions", or similar forward-looking text in chat output
2. **DO NOT** produce a summary that reads as a terminal deliverable
3. **DO NOT** use the `question` tool for structural decisions (execution order, grouping, plan creation)
4. **DO** set `continue_pipeline=true` in result contract
5. **DO** proceed immediately to gap-fill cascade (auto-create plans for issues missing them)
6. **DO** proceed to `git-workflow --task pre-work` after gap-fill
7. **DO** proceed through the full dispatch chain to `halt_at` without stopping

### Enforcement

Violating this gate is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §pre-implementation-analysis Halts Under for_pr Scope. The agent MUST check `authorization_scope` before producing output and MUST NOT halt when the scope requires pipeline continuation.

## Result Contract

```yaml
status: DONE | BLOCKED
task: pre-implementation-analysis
issues_analyzed: <count>
execution_order: [<issue_numbers>]
dependency_graph: <text>
branch_strategy: <stacked | parallel>
blocking_reason: <reason|null>
continue_pipeline: <bool>
authorization_scope: <standard|for_spec|for_plan|for_implementation|for_code_review|for_pr|pr_only>
halt_at: <pipeline_stage>
```
