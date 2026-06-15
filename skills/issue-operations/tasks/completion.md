# Task: completion

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

Idempotent completion subtask for issue-operations. Ensures mandatory steps run regardless of where the workflow halted.

## State Check Phase

- [ ] 1. **Issue created:** Check if the issue already exists
   - Search by title or check recent issue list (via platform sub-skill)
- [ ] 2. **Labels applied:** Check if `needs-approval` label is present (via `issue-operations → read-labels`)
- [ ] 3. **Sub-issues created:** Check if multi-task spec has sub-issues (via `issue-operations → read-sub-issues` or comment-based tracking)
- [ ] 4. **Auditor invoked:** Check if spec-auditor has been run on the issue (via session records or `./tmp/` files)

## Skill-Specific Completion

- [ ] 1. **Apply `needs-approval` label** (if not already present, routed via `issue-operations → read-labels`):
    - If label not present, add it via `issue-operations → update-issue`
- [ ] 2. **Invoke spec-auditor** (if not already run):
    - Check session records or `./tmp/` files for auditor results
    - If missing: invoke spec-auditor
- [ ] 3. **Create sub-issues** (if multi-task and not already created):
    - Check `get_sub_issues` result
    - If empty and spec is multi-task: invoke `issue-operations --task link-sub-issue`

## Shared Completion Delegation

Reference `.opencode/skills/completion-core/completion-core.md` for reporting:

- [ ] 1. Report executive summary in chat (always runs)
- [ ] 2. Issue URL as the action URL (ALWAYS last)

## Label State Machine

Before adding or removing labels in completion, consult `141-planning-status-tracking.md §10` for the complete label transition matrix and the GitHub `labels` parameter warning (replaces all labels, not additive).

## Report Phase

### Step N: EXTRACT URL FROM API RESPONSE

- [ ] 1. The Issue URL MUST be copied verbatim from the `github_issue_write` API response's `html_url` field.
- [ ] 2. Do NOT retype, reconstruct, or assemble the URL from known values (org, repo, number).
- [ ] 3. Paste the URL exactly as returned. If the API response is `{ "html_url": "https://github.com/Org/Repo/issues/42" }`, the output URL is `https://github.com/Org/Repo/issues/42` — character for character.
- [ ] 4. Verification checkpoint: Compare the pasted URL character-by-character against the `html_url` field in the API response before sending.

Generate executive summary in chat:

```
**Summary:**

<What issue was created and its purpose>

**Outcome:** <What stakeholders get from the new issue>

Issue URL: <html_url from github_issue_write API response — NEVER construct from template>
```

URL is ALWAYS last per `000-critical-rules.md`.

## Live Verification: Completion Evidence (MANDATORY)

**Each completion state check MUST be verified via tool call, not just asserted. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call (routed) | Problem Class |
|-------|-------------------|-----------|---------------|
| "Issue was created" | Verify issue exists | `issue-operations → read-issue` → verify | MISSING-ELEMENT |
| "`needs-approval` label applied" | Verify label present | `issue-operations → read-labels` → verify | MISSING-ELEMENT |
| "Sub-issues created" | Verify sub-issues exist | `issue-operations → read-sub-issues` → verify | MISSING-ELEMENT |
| "Auditor was invoked" | Check for auditor results | Session records or `./tmp/` files | VERIFICATION-GAP |

**Evidence artifact:** Tool call results for each completion state check.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Issue not found | MISSING-ELEMENT | flag-for-review | HALT — creation may have failed |
| Label missing | MISSING-ELEMENT | auto-fix | Add label immediately |
| Sub-issues missing (multi-task) | MISSING-ELEMENT | conditional | Create sub-issues if multi-task spec |
| Auditor not invoked | VERIFICATION-GAP | conditional | Invoke spec-auditor |

## Context Required

- Session values: github.owner, github.repo, github.platform
- Related tasks: `creation` (runs first), `post-creation` (runs after), `single-task-check` (uses determination)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`

## Pipeline Signal

```
HALT
```