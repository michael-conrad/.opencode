# Task: verify-authorization — Step 6: Scope-Aware Auto-Route

## Purpose

After all verification gates (Steps 1-5) pass, determine the approval context and auto-route to the next skill in the chain. This step runs ONLY when ALL prior verification gates pass. If ANY gate fails, HALT — do NOT route.

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`
- The `pipeline_phase` field is NEW — it tracks which phase of a multi-phase plan is currently executing

## 6.1 Pre-Implementation Branch Setup (MANDATORY)

**Before any sub-agent task() or file modification, the agent MUST task `git-workflow --task pre-work` to:**

1. Create the feature branch (direct-branch or worktree depending on `WORKTREE_REQUIRED`)
2. If `WORKTREE_REQUIRED` is set: set the `worktree.path` environment variable
3. Verify branch state and working tree cleanliness

**This step is MANDATORY and CANNOT be skipped.** Pre-work.md handles the worktree vs direct-branch decision — the agent does NOT decide worktree mode here. If pre-work fails, HALT — do not proceed without a valid branch.

**Evidence requirement:** `git branch --show-current` must show the feature branch. If `WORKTREE_REQUIRED` is set, `git worktree list` must also show the feature branch worktree and `worktree.path` must be set before any `divide-and-conquer` task().

## Auto-Dispatch Situation Differentiation

| Approval Context | How to Detect | Auto-Dispatch Target |
| -- | -- | -- |
| **Spec approval** | Issue title contains `[SPEC` or has `spec` label | `writing-plans --task create` (or `brainstorming --task explore` if gap-fill) |
| **Plan approval** | Issue has `plan` label or `[PLAN]` prefix in title | `executing-plans --task start` |
| **Already implemented** | `verify-already-implemented` returns positive (after closed-issue verification in Step 5.4 confirms legitimate closure) | No dispatch — auto-close instead |
| **Reconciled during verification** | reconcile-issue-graph returned auto-closed or reopened tickets | Include reconciled tickets in chat output; proceed with dispatch |
| **Closed but NOT verified** | Step 5.4 closed-issue verification finds closure without merged PR evidence | flag-for-review — do NOT autoclose |

## Scope-Aware Route Targets

The routing target is modified by `authorization_scope` from Step 2.0. See `enforcement/auto-dispatch-table.md` for the complete scope-dependent routing.

**🚫 HARD HALT AT SCOPE BOUNDARY:** The agent MUST NOT proceed past the pipeline stage specified by `halt_at`. If the pipeline chain reaches the `halt_at` stage, the agent reports completion and STOPS. Proceeding past `halt_at` without re-authorization is a CRITICAL GUIDELINE VIOLATION.

### `for_analysis` Route Behavior

When `authorization_scope == "for_analysis"`:

- Dispatch is read-only investigation
- No `writing-plans` or `executing-plans` routing — only `issue-operations` for issue creation/comments
- No `divide-and-conquer` routing — only `pre-analysis` if needed for context understanding
- No feature branch creation; `investigate/<topic>` scratch branches permitted
- Gap-fill cascade is skipped entirely (gap_fill = none)
- Pre-implementation setup is skipped entirely
- HALT after `analysis_complete`

## Auto-Route Procedure

1. Determine approval context (spec vs plan) by checking:
   - Issue title format: `[SPEC` prefix = spec approval
   - Issue title format: `[PLAN]` prefix = plan approval
   - Labels: presence of `spec` or `plan` labels
   - Plan detection is via `plan` label or `[PLAN]` prefix in title (NOT via sub-issue relationship to spec)
2. Determine scope from Step 2.0 result (`authorization_scope`, `halt_at`, `pr_strategy`)
3. Execute gap-fill from Step 5c if scope >= `for_plan`
5. **If spec approval:** Invoke `writing-plans --task create` with context:
   - `spec_issue=#N` (the approved spec issue number)
   - `authorization_scope=<scope>`, `halt_at=<stage>`, `pr_strategy=<strategy>`, `pipeline_phase=<phase>`
   - `<github.owner>`, `<github.repo>`, `<worktree.path>` from session
5. **If plan approval:** Invoke `executing-plans --task start` with context:
   - `plan_issue=#N` (the approved plan issue number)
   - `spec_issue=#M` (extracted from plan body — the spec reference)
   - `authorization_scope=<scope>`, `halt_at=<stage>`, `pr_strategy=<strategy>`, `pipeline_phase=<phase>`
   - `<github.owner>`, `<github.repo>`, `<worktree.path>` from session
6. **Chat output:** Clearly indicate the transition and scope:
   - Spec approval: "Verification passed → Creating implementation plan (scope: <scope>)"
   - Plan approval: "Verification passed → Starting implementation (scope: <scope>, halt_at: <stage>)"

## Spec Revision Revocation Detection

If a spec is revised (status contains `REVISED - NEEDS APPROVAL` — in either prose or numeric format):

Prose format: `STATUS: in progress — {concern} (REVISED - NEEDS APPROVAL)`
Numeric format: `STATUS: 1.1 (REVISED - NEEDS APPROVAL)`

1. Search for `[PLAN]` issues that reference the spec number in their body
2. Mark found plans for audit (their authorization is revoked by the spec revision)
3. Report affected plans in chat output

## Auto-Route Edge Cases

- **Spec already has a plan:** `writing-plans --task create` handles this (skips or updates per its existing logic)
- **Multi-task plan with missing sub-issues:** Step 5 sub-issue verification gate fails → HALT, no dispatch
- **Authorization set dispatch:** Each plan in the work set gets its own dispatch cycle after work state is established
- **Scope requires gap-fill but artifact exists:** Skip gap-fill for that artifact (check before creating)
- **`for_pr_only` or `for_review_only` scope with no existing branch/PR:** HALT and report — these scopes assume existing work

## Authorization Cascade by Output Lineage (Step 2.1)

When user approves issue #P, and #P's body or comments explicitly state that it created issue #C (e.g., "Spec created: #966"), authorization cascades from #P to #C if ALL conditions are met:

1. #P is a meta/investigation/review issue (no implementation criteria of its own)
2. #P's sole or primary deliverable is the creation of #C
3. #C is a spec or plan with implementation criteria
4. No contradictory evidence (e.g., #P's body says "spec rejected, try again")

When cascade applies:

- #C is treated as if the user said "Approved: #C"
- Add comment to #C: "Authorization cascaded from #P (approvable output of approved issue)"
- Remove `needs-approval` label from #C

When cascade does NOT apply (conditions not met):

- HALT and inform user: "#P was approved but it is an investigation issue — its spec #C was not named. Please confirm: approve #C?"
- This is a genuine authorization gap where the developer's intent is ambiguous

**Evidence artifact:** `issue-operations -> read-comments (github_issue_read(method=get_comments)` showing lineage evidence in #P, and `github_issue_write` / `github_add_issue_comment` responses confirming cascade actions on #C. <!-- Routes through issue-operations per SPEC #683 -->

## Orchestrator Context Discipline Check Before task() (MANDATORY for implementation scopes)

**When `authorization_scope` is `for_implementation` or `for_pr`:**

Before routing to `divide-and-conquer --task assemble-work`, verify that the orchestrator context is not bloated with non-routing data:

1. **Verify routing-only dispatch:** Confirm the orchestrator holds only routing metadata (worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase, pipeline_history). Any cached analysis artifacts, task file contents, or prior sub-agent reasoning traces indicate context bloat.
2. **If context bloat detected:** Do NOT proceed to dispatch. The orchestrator must task a clean sub-agent from the current pipeline phase — do NOT attempt recovery via state cleanup.
3. **Evidence artifact:** Before dispatch, the halt message must include: "Orchestrator context discipline verified: routing-only data held, no task file content cached, no prior sub-agent reasoning retained."

## Work State I/O

- **Reads from:** `## gap-fill-cascade`, `## scope-auto-resolve`
- **Writes to:** `## auto-dispatch`

After completing this task, write results to the work state file under section `## auto-dispatch` using the YAML format defined in `enforcement/work-state-schema.md`.