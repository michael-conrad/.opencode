# Task: verify-sub-issues

> **Note:** Sub-issue verification is consolidated into `verify-authorization` Step 5 as the single authoritative readiness check. This task remains available for standalone invocation when detailed sub-issue inspection is needed, but the pre-implementation gate is `verify-authorization` Step 5.

## Purpose

Verify sub-issue structure and phase tracking gate for multi-task plans before implementation. Sub-issues are verified under the plan issue, not the spec issue.

## Entry Criteria

- Plan exists as local file at `.issues/{N}/plan.md` or `{project_root}/{path}/.issues/{N}/plan.md`
- Authorization received for specific subtask (e.g., "approved: 1.2")
- Subtask number provided or extracted from authorization
- Authorization received for plan (covers sub-issue creation)

## Exit Criteria

- Sub-issues verified present under plan
- Phase tracking state in `{project_root}/tmp/{N}/work.md` matches requested subtask
- Auto-create performed if needed

## Procedure

### Step 1: Check for Sub-issues

```python
sub_issues = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=plan_issue) <!-- Routes through issue-operations per SPEC #683 -->
```

### Step 2: Determine Plan Type

**Single-phase plan (EXEMPT from sub-issues):**
- Exactly ONE implementation phase
- No decomposition into phases needed
- Can be implemented as atomic unit

**Multi-task plan (REQUIRES sub-issues):**
- Multiple phases (Phase 1, Phase 2, ...)
- Multiple implementation tasks
- Requires sequential work streams

### Step 3: Verify Phase Tracking Gate

**For multi-task plans with sub-issues:**

Phase tracking state is read from `{project_root}/tmp/{N}/work.md`. The work state file is populated during pre-work and updated by each pipeline step.

- [ ] 1. Extract subtask from authorization:
    - "approved: 1.2" → subtask 1.2 (numeric format)
    - "approved: X.Y" → subtask X.Y (numeric format)
    - "approved: {concern}" → find phase matching concern name (prose format)
    - "approved" (no number) → read `{project_root}/tmp/{N}/work.md` for current phase

- [ ] 2. Read phase tracking state:
    ```bash
    # Read current phase from work state file
    cat "{project_root}/tmp/{plan_issue}/work.md"
    # Expected format:
    # current_phase: <phase_number>
    # current_concern: <concern_name>
    # current_step: <step_label>
    # If file missing → default to first concern, first step
    ```

- [ ] 3. Determine which subtask to implement:
    - If authorized for concern name or X.Y → use that subtask (explicit override)
    - If "approved" (no number) AND work.md has current phase → use that value
    - If "approved" (no number) AND work.md missing → use first concern, first step
    - POST COMMENT explaining which subtask is being implemented

- [ ] 4. Verify subtask exists:
   - If subtask X.Y or concern name exists in sub-issues → PROCEED
   - If subtask X.Y or concern name NOT in sub-issues → HALT and report: "Subtask not found. Available subtasks: [list]"

- [ ] 5. Report to user (MANDATORY - no silent halts):
```markdown
Proceeding to implement subtask for {concern} (or X.Y).

Authorization: "approved" (no phase specified)
Phase tracking: {concern}, Step {N} (or "work.md not found, defaulting to first concern")
Sub-issue: #NNN

Starting implementation now.
```

- [ ] 6. **Why Phase Tracking Gate Matters:**
   - Prevents parallel execution of subtasks
   - Ensures sequential workflow
   - Avoids git branch conflicts
   - Prevents file edit races

### Step 4: Auto-Create Sub-issues if Needed

If empty AND multi-task:

**No separate authorization required.** Plan approval covers sub-issue creation as a setup step.

```python
# For each PHASE in plan:
issue = issue-operations -> creation/update (github_issue_write( <!-- Routes through issue-operations per SPEC #683 -->
    method="create",
    title=f"[Task: #{plan_issue}] {phase_description}",
    body=f"Plan: #{plan_issue}\nSubtask: {phase_number}\n\n## Purpose\n\n{phase_objective}\n\n## Procedure\n\n{phase_steps}",
    labels=["enhancement", "architecture"]
)
issue-operations -> link-sub-issue (github_sub_issue_write( <!-- Routes through issue-operations per SPEC #683 -->
    method="add",
    issue_number=plan_issue,
    sub_issue_id=issue["id"]
)
```

Auto-creating sub-issues for an approved multi-task plan does NOT require separate authorization. The plan's authorization covers this setup step.

**⚠️ Body-Preservation Safeguard:** This task only creates new issues (`method="create"`) and does not modify existing issue bodies. If any task in this skill were to use `issue-operations -> update-issue (github_issue_write(method=update, body=...)`, it MUST verify that the new body preserves all original content (len(new_body) >= 0.8 * len(original_body)). See `000-critical-rules.md` → "Critical Violation: Issue Body Erasure" for the project-wide rule. <!-- Routes through issue-operations per SPEC #683 -->

### Step 5: Post Comment

"Created N sub-issues for phase tracking."

## Auto-Create Authorization

**Auto-creating sub-issues for an approved multi-task plan does NOT require separate authorization.** The plan's authorization covers this setup step.

| Action | Requires Separate Auth? | Why |
|--------|------------------------|-----|
| Auto-creating sub-issues | ❌ NO | Tracking/setup action, covered by plan authorization |
| Linking sub-issues to plan | ❌ NO | Part of sub-issue creation workflow |
| Proceeding to implementation after auto-creation | ❌ NO | Plan authorization continues to implementation |

## Phase Tracking Gate Rules

| Scenario | Action |
|----------|--------|
| work.md phase matches authorized subtask (prose or numeric) | ✅ PROCEED - report which subtask and concern |
| Phase mismatch | ⛔ HALT - report mismatch clearly |
| work.md says "completed" | ⛔ HALT - all phases complete |
| work.md not found + "approved" | ✅ PROCEED - default to first concern's first step, report decision |
| work.md not found + "approved: X.Y" | ✅ PROCEED - use specified X.Y, report decision |
| work.md not found + "approved: {concern}" | ✅ PROCEED - find phase matching concern name, report decision |
| Single-phase plan (no tracking needed) | ✅ PROCEED - no gate needed |
| Subtask not in sub-issues list | ⛔ HALT - report available subtasks |

## Mandatory Reporting (No Silent Halts)

**Every phase tracking gate check MUST report status to user:**

- [ ] 1. Which subtask is being implemented
- [ ] 2. Why that subtask was selected (work.md value or default)
- [ ] 3. Link to the sub-issue

**Example report:**
```markdown
**Phase Tracking Gate Verification:**
- Authorization: "approved" (no phase specified)
- work.md: Not found → Defaulting to first concern's first step
- Sub-issue: #473
- Proceeding with implementation
```

**Never HALT silently.** Always explain what was checked and what the outcome is.

## Forbidden Actions

- Implementing phase without verified sub-issue structure
- Proceeding **to implementation** when `get_sub_issues` returns empty for multi-task specs **without creating sub-issues first**
- Creating step-level sub-issues (use PHASE level)
- Assuming markdown checkboxes = task tracking
- Implementing when phase tracking doesn't match authorized subtask
- Parallel execution of subtasks (enforce single-subtask flow)

## Common Issues

| Issue | Resolution |
|-------|------------|
| Phase mismatch | POST report: "Phase mismatch: authorized for {concern}/{X.Y} but work.md shows {actual}. Please update tracking state or authorize correct subtask." |
| work.md not found | Default to first concern's first step, POST report: "work.md not found. Defaulting to first concern. Add tracking state to work.md for phase tracking." |
| Sub-issue not linked | Auto-create and link, POST report: "Created N sub-issues for phase tracking." |
| Single-phase plan with tracking state | Ignore tracking, proceed, POST report: "Single-phase plan, ignoring phase tracking." |
| Subtask not in list | HALT, POST report: "Subtask {X.Y}/{concern} not found. Available subtasks: [list]. Please authorize a valid subtask." |
| Plan issue missing work.md | Default to first concern's first step, proceed, report to chat |

## Adversarial Verification: Sub-Issue State

Adversarial verification model (evidence format, classification tiers, tier actions): see `enforcement/adversarial-verification.md`

### Verify Sub-Issue Existence and State

```
sub_issues = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=plan_issue) <!-- Routes through issue-operations per SPEC #683 -->

For each sub-issue returned:
  child = issue-operations -> read-issue (github_issue_read(method="get", issue_number=sub_issue_number) <!-- Routes through issue-operations per SPEC #683 -->
  
  - Verify child exists (404 = deleted sub-issue → MISSING-TRACEABILITY)
  - Verify child.state matches claimed state (do NOT trust cache)
  - If child.state == "closed" → verify merged PR exists before treating as complete
    - Search for PRs referencing the sub-issue
    - If closed but no merged PR → VERIFICATION-GAP (premature closure)
  - Verify child.title matches the phase description (not reassigned to different work)
```

**Evidence artifact:** `issue-operations -> read-issue (github_issue_read(method=get)` for each sub-issue showing actual state, title, and labels. <!-- Routes through issue-operations per SPEC #683 -->

### Verify Sub-Issue Labels and Phase State

```
For each sub-issue:
  labels = issue-operations -> read-labels (github_issue_read(method=get_labels, issue_number=sub_issue_number) <!-- Routes through issue-operations per SPEC #683 -->
  work_state = $(cat {project_root}/tmp/{plan_issue}/work.md 2>/dev/null || echo "not found")

  - If has "needs-approval" label but parent plan has explicit authorization → STRUCTURE-VIOLATION
    (auto-fix: authorization cascades from plan, label should be removed)
  - If work.md phase tracking is mismatched to actual sub-issue progress → STRUCTURE-VIOLATION
    (auto-fix: update work.md per ground-truth progress)
  - If work.md says completed but sub-issue is open → CONFLICTING
    (FAIL: may indicate tracking mismatch)
```

**Evidence artifact:** Label list and work.md state for each sub-issue.

### Verify Sub-Issue Link Integrity

```
sub_issues = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=plan_issue) <!-- Routes through issue-operations per SPEC #683 -->
parent_check = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=sub_issue_number) <!-- Routes through issue-operations per SPEC #683 -->

- Verify sub-issues are linked under the correct parent (plan, not spec)
- If sub-issue is linked under spec instead of plan → STRUCTURE-VIOLATION
  (auto-fix: re-link under plan, remove from spec)
```

**Evidence artifact:** Sub-issue list from plan showing correct parent-child relationships.

### Task-Specific Findings

Read [the binary PASS/FAIL classification model](enforcement/adversarial-verification.md) (auto-fix as remediation action only) and evidence artifact format.

## Context Required

- Related tasks: `verify-authorization`, `verify-codebase`
- Label state machine: Read [planning-status-tracking §10](guidelines/141-planning-status-tracking.md) (label transitions when creating sub-issues under plan)

## Enforcement References

- Evidence format + finding classification: Read [adversarial-verification](enforcement/adversarial-verification.md)
- Scope parsing: Read [scope-parsing](enforcement/scope-parsing.md)
- Sub-issue graph traversal: Read [sub-issue-graph-traversal](enforcement/sub-issue-graph-traversal.md)
