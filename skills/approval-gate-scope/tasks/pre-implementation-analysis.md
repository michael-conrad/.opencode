# Task: pre-implementation-analysis (Routing Document)

## Purpose

Analyze interdependencies and determine execution order for all approved issues — whether one or many — producing a flat item list for the implementation-pipeline. Every approval follows this unified path: sub-issue expansion → flat item list → implementation-pipeline → work branch → pr-creation → one PR.

This task is a **routing document** that delegates to 6 atomic tasks in `pre-impl/`.

## Entry Criteria

- One or more issues approved
- Each issue verified by `verify-authorization`
- User explicitly authorized implementation

## Exit Criteria

- Execution plan presented in chat (informative only)
- Agent proceeds immediately to the implementation-pipeline per the SKILL.md Trigger Dispatch Table

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
| `pre-impl/write-work-state` | Execution strategy, dev base hash, task context, work state file persistence | Steps 5, 7, 8, 9 |
| `pre-impl/yield-to-assemble-work` | Present execution plan, verify no-questions checkpoint, proceed to implementation-pipeline per the SKILL.md Trigger Dispatch Table | Steps 6, 10 |

**Chain-of-responsibility note:** Each atomic task uses the work state file for inter-task I/O. Tasks read inputs from predecessor sections and write results to their own section per `enforcement/work-state-schema.md`.

## Red Flags

- Never skip dependency analysis when multiple issues are approved together
- Never task() parallel subagents for conflict-risk issues without serialization
- Never include meta/non-code, already-implemented, superseded, or moot issues in the implementation plan
- Never present dependency analysis only in agent reasoning (MUST be in chat)
- Never assume all issues are independent without analysis
- Never execute must-precede issues out of order
- Never use `question` tool
- Never HALT between plan presentation and the implementation-pipeline dispatch per the SKILL.md Trigger Dispatch Table
- Never escalate status inconsistencies to the developer (use `reconcile-issue-graph`)

## Cross-References

- Load [Pushing Agent Intelligence Decisions to the User](guidelines/000-critical-rules.md) — structural decisions are agent intelligence concerns
- Load [GO Prohibitions §1](guidelines/020-go-prohibitions.md) — no prompts for authorization; "approved to PR" covers the full pipeline
- Load [screen-issue task](skills/approval-gate-scope/tasks/screen-issue.md) — exhaustive `requires_developer: true` conditions
- Load [Task Order](skills/approval-gate/SKILL.md) — "MUST auto-dispatch" after analysis completes

## Enforcement References

- Evidence format + finding classification: Load [adversarial-verification](enforcement/adversarial-verification.md)
- Scope parsing: Load [scope-parsing](enforcement/scope-parsing.md)
- Auto-dispatch routing: Load [auto-dispatch-table](enforcement/auto-dispatch-table.md)
- Closed-issue verification: Load [closed-issue-verification](enforcement/closed-issue-verification.md)
- Sub-issue graph traversal: Load [sub-issue-graph-traversal](enforcement/sub-issue-graph-traversal.md)