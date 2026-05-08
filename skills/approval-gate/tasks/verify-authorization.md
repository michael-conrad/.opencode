# Task: verify-authorization

## Purpose

Check for explicit authorization and apply the correct `approved-for-*` label before implementation. This task orchestrates the atomized sub-tasks in `verify-authorization/` for fine-grained, low-context verification.

## Entry Criteria

- User says "approved", "go", or similar authorization
- Spec exists as GitHub Issue

## Exit Criteria

- Authorization verified as explicit and for correct issue
- `approved-for-*` label applied per mapping table; deprecated `needs-approval` label removed
- Git state verified (worktree environment ready)
- Authorization recorded for scope tracking

## Sub-Task Dispatch Order

This task delegates to atomic sub-tasks. Each sub-task reads inputs from the work state file and writes results back. Invoke in sequence:

| Step | Sub-Task | Purpose |
|------|----------|---------|
| 0 | Re-dispatch guard | If sub-agent returns empty, re-dispatch with original scoped context (max 2 retries); on exhaustion, fall through to double-failure protocol |
| 0.2 | Model resolution (inline) | Resolve local + cloud models via `ollama-model-resolve --target enforcement`; record model pair for dispatch context |
| 0.5 | `verify-authorization/scope-auto-resolve` | Parse authorization text, resolve scope/halt_at/pr_strategy/gap_fill |
| 1 | `verify-authorization/verify-explicit-authorization` | Check for "approved"/"go" + author identity + currency |
| 2 | Label application (inline) | Apply `approved-for-*` label per mapping table; remove prior `approved-for-*` and `needs-approval` labels |
| 3 | Authorization decision (inline) | Route based on authorization result |
| 4.5 | `verify-authorization/item-decomposition-check` | Verify item enumeration, dependency ordering, TDD steps |
| 4.6 | `verify-authorization/sc-traceability-check` | Verify SC-to-test traceability, RED-phase ordering |
| 5 | `verify-authorization/sub-issue-verification` | Sub-issue phase count, adversarial verification, closed-issue check |
| 5b | `verify-authorization/spec-to-plan-cascade` | Spec-to-plan approval cascade |
| 5b.5+5c | `verify-authorization/gap-fill-cascade` | Gap-fill precedence and cascade execution |
| 6 | `verify-authorization/auto-dispatch` | Scope-aware auto-dispatch + output lineage |

### Step 0.2: Model Selection Gate (MANDATORY)

Before dispatching behavioral test sub-agents (Phase 4 of any plan), resolve the local and cloud model pair:

1. Run `.opencode/tools/ollama-model-resolve --target enforcement` to select the smallest local model
2. Extract `selected` (local model) and `fallback` (cloud model) from the JSON output
3. Record the model pair in the authorization context: `test_models: {local: "<model_name>", cloud: "<model_name>"}`
4. This model pair is embedded in all downstream dispatch contexts

**Model resolution evidence:** Tool-call artifact from `ollama-model-resolve` must be present in the session log before behavioral test dispatch proceeds.

**Chain-of-responsibility:** Sub-tasks use work state file for I/O per `enforcement/work-state-schema.md`. Path selection per SKILL.md §Chain-of-Responsibility Paths:

| Condition | Path |
|-----------|------|
| 1 issue + `standard` scope + 0 sub-issues + explicit auth | fast-path (skip 2, 4.5, 4.6, 5, 5b, 5b.5+5c) |
| 1 issue + scope ∈ {for_pr, for_implementation, for_plan, for_code_review} + 0 sub-issues | gap-fill-path (0.5, 1, 5b.5+5c, then 6) |
| 1 issue + sub-issues OR plan with phases | medium-path (0.5, 1, 4.5, 4.6, 5, then 6) |
| Multi-issue authorization set | full-path (all steps) |

## Sub-Agent Result Guard

When `verify-authorization` is dispatched as a sub-agent and returns empty or whitespace-only:

1. Report: `"Sub-agent for verify-authorization returned empty result, re-dispatching (retry {N}/2)"`
2. Re-dispatch with original scoped context only (no expanded context, no orchestrator reasoning)
3. If re-dispatch returns empty and retry count < 2, go to step 1 (increment retry counter)
4. If re-dispatch returns empty after 2 retries, fall through to double-failure protocol

**Double-failure protocol (exhaustion handler):** After 2 failed re-dispatch attempts:
1. Report: `"verify-authorization sub-agent failed after 2 re-dispatch attempts"`
2. Invoke `--task completion` on the `approval-gate` skill
3. HALT with status message + byline

## Enforcement References

- Evidence format + finding classification: see `enforcement/adversarial-verification.md`
- Scope parsing: see `enforcement/scope-parsing.md`
- Dispatch routing: see `enforcement/auto-dispatch-table.md`
- Closed-issue verification: see `enforcement/closed-issue-verification.md`
- Sub-issue graph traversal: see `enforcement/sub-issue-graph-traversal.md`

## Result Contract

```yaml
status: DONE | BLOCKED
task: verify-authorization
issue_number: <N>
authorization_result: authorized | unauthorized | needs_approval
cascade_applied: bool
sub_issues_verified: bool
gates_passed: [gate_name]
blocking_reason: <reason|null>
cascade_type: plan_cascade | output_lineage_cascade | none
cascade_parent: <issue_number | null>
authorization_scope: standard | for_spec | for_plan | for_implementation | for_code_review | for_pr | pr_only | review_only
scope_source: parsed | default
halt_at: <pipeline_stage>
pr_strategy: stacked | individual | none
gap_fill_actions: [<action_list>]
```