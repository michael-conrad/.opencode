# Task: context-passing

Migrated from `implementation-workflow` task context-passing.

## Purpose

Reference document for yield-back context patterns between subtasks in the implementation-pipeline orchestration chain, including phase progress information that must travel across phase boundaries.

## Entry Criteria

- Orchestration is in progress
- A subtask is about to be invoked and needs context

## Exit Criteria

- Correct context shape is passed to the next subtask

## Procedure

### What Pre-Work Needs FROM Authorization

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
issue_number: int
```

**`must_receive` validation:** The task context `must_receive` array MUST include `authorization_scope`. If missing, HALT and report a context-contamination violation.

### What Implementation Needs FROM Pre-Work

```yaml
branch: string
working_tree_clean: bool
```

### What Review-Prep Needs FROM Implementation

```yaml
files_changed: list
commit_summary: string
implementation_status: success | failure
```

### What Verification Gate Needs FROM Implementation

```yaml
issue_number: int
phase: string
success_criteria: list
files_changed: list
```

### What Finishing Checklist Needs FROM Verification

```yaml
branch: string
verification_passed: true
```

### What Chat Needs FROM Review-Prep

```yaml
compare_url: string (actionable link)
exec_summary: string (markdown, human-readable)
```

### Phase Progress — What Travels at Phase Boundaries

When the orchestrator task()s a sub-agent for a phase that follows a prior phase, the task context MUST carry phase progress information composed from prior sub-agent results and the work state file at `{project_root}/tmp/{N}/work.md`. This information ensures each phase knows what has already been accomplished and can act accordingly.

The orchestrator builds phase_progress incrementally. Before each sub-agent task():
- [ ] 1. Read the work state file (`{project_root}/tmp/{N}/work.md`) to identify which phases are already complete
- [ ] 2. Accumulate `completed_phases`, `concern_boundaries_crossed`, and `verification_evidence` from each prior sub-agent's result
- [ ] 3. If this sub-agent's work crosses a concern boundary, note the transition in `concern_boundaries_crossed`

**How it is NOT composed:**

There is no fixed template, no rigid YAML schema, no mandatory section headers. The orchestrator describes progress in natural prose that communicates what the next sub-agent needs to know. The information requirement is the rule; the encoding is up to the agent.

### Decision Log for Full Context History

`prior_context` in the task context carries the most recent intent summary — it is designed for immediate consumption by the next sub-agent. For the full history of design decisions across ALL phases, the orchestrator and sub-agents should reference the **Decision Log** persisted on the Plan issue.

The Decision Log is an append-only sequence stored in `.issues/` local storage. Each entry captures one sub-agent's `decision_log_entry` — the design decisions made during that phase. It survives session restarts because it lives in the `.issues/` directory, not in transient agent context. <!-- Decision log routes to .issues/ per SPEC #683 Phase 4 -->

When `prior_context` references a decision that may need fuller explanation, the orchestrator should note "see Decision Log in `.issues/N/comments.md`" so the sub-agent can retrieve the full context history if needed.

To append a decision log entry:

```bash
./.opencode/tools/local-issues comment N --body "decision_log_entry: <content>"
```

Decision log entries are classified as `internal` content per the content classification gate (Step 1.5 in `comment.md`). They are written to `.issues/N/comments.md` only — they are NOT posted to GitHub Issue comments. <!-- Decision log routes to .issues/ per SPEC #683 Phase 4 -->

## Edge Cases

### Context Lost Between Steps

If a yield-back produces empty or missing fields:

- [ ] 1. HALT orchestration
- [ ] 2. Report which context field is missing
- [ ] 3. Wait for manual intervention

### Phase Progress with No Prior Phases

For the first sub-agent task()ed (no prior phases completed), `phase_progress` should still be present but note that no prior phases exist. For example: "No phases completed yet. This is the first phase." This ensures the field is never absent — it is either populated with prior progress or explicitly states that no progress has been made.

### Pre-Work Asks for Auth Again

Pre-work receives context from orchestrator — no re-authorization check needed. If pre-work prompts for auth, it received stale context. Re-invoke with fresh context from approval-gate.

Co-authored with AI: <AgentName> (<ModelId>)
## Live Verification: Context Accuracy (MANDATORY)

**Verify task context accuracy before sending to sub-agents.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "worktree.path correct" | Verify path exists | `ls -d <path>` | STRUCTURE-VIOLATION |
| "Session vars current" | Verify vars match session init | Check against session values | VERIFICATION-GAP |
| "Prior results accurate" | Verify result contracts from prior sub-agents | Read work state file | VERIFICATION-GAP |

**Evidence artifacts:** See enforcement/work-state-verification.md §Evidence Artifacts

## Enforcement References
- Completion checkpoint protocol: see `enforcement/completion-checkpoint.md`
- Result validation and finding classification: see `enforcement/result-validation.md`
- Work state verification: see `enforcement/work-state-verification.md`
