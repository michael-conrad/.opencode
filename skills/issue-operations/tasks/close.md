# Task: close

## Purpose

Close an issue after verifying PR merge. Handles parent/child verification and platform-specific closure.

## Entry Criteria

- PR has been merged (verified via platform API)
- Issue number identified
- Merge SHA available for verification

## Exit Criteria

- Issue closed via platform API (where supported) or closure comment posted (GitBucket PATCH fallback)
- Parent/child relationships verified before closure
- Closure comment posted if substantive

## Procedure

### Step 1: Verify PR Merge

Invoke `verify-merge` task to confirm PR is actually merged before closing any issue.

### Step 2: Verify Parent/Child Relationships

**CRITICAL: Only close the child corresponding to the merged PR. Parent stays open until ALL children are closed.**

- [ ] 1. If issue has sub-issues: check all sub-issues are closed before closing parent
- [ ] 2. If issue is a sub-issue: verify parent has no other open sub-issues before closing parent
- [ ] 3. Plan-bridge hierarchy: close sub-issues under the plan first, then the plan, then the spec

### Step 3: Close Issue (Platform Routing)

Route based on `github.platform`:

| `github.platform` | Route to |
|---|---|
| `github` | `platforms/github-mcp/` sub-skill |
| `gitbucket` | `platforms/gitbucket-api/` sub-skill |
| `local` | `platforms/local/` sub-skill |

**⚠️ Body-Preservation Safeguard (CRITICAL):** If `github_issue_write(method=update, body=...)` is used to close an issue, the body parameter MUST preserve all original content. NEVER replace an issue body with a shortened status summary or closing comment. The 80% length threshold applies: if `len(new_body) < 0.8 * len(original_body)`, HALT — this indicates content erasure. Status updates and closing comments MUST be added as separate comments, not written into the body.

**GitHub platform (sub-skill implementation):**
```python
github_issue_write(
    method="update",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N,
    state="closed",
    state_reason="completed"
)
```

**GitBucket platform (sub-skill implementation — PATCH fallback):**
```bash
# PATCH /issues/:number returns 404 on GitBucket
# Post closure comment instead
gb issue close <issue-number> -R <github.owner>/<github.repo>
gb issue comment <issue-number> -b "Closing: PR merged and implementation verified." -R <github.owner>/<github.repo>
```

**Local platform (sub-skill implementation):**
Route to `platforms/local/tasks/close.md` via task(). Pass: `{issue_number: N, reason: "completed"}`.

### Step 4: Post Closure Comment (if substantive)

Only if the closure provides information stakeholders need:

```markdown
**Summary:**

<What was implemented and merged>

**Outcome:** <What changed for stakeholders>

All tasks complete from this specification.

---
🤖 <AgentName> (<ModelId>) ✅ completed
```

## Common Issues

| Issue | Resolution |
|-------|------------|
| PR not actually merged | HALT — do not close issue |
| Parent has open children | Do not close parent yet |
| GitBucket PATCH broken | Use closure comment fallback |
| Non-substantive closure | Skip comment, just close |

## Context Required

- Session values: github.owner, github.repo, github.platform
- Related tasks: `verify-merge` (runs first), `comment` (format for closure comment)
- Parent/child closure order per `010-approval-gate.md`
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`

## Live Verification: Closure Evidence (MANDATORY)

**Each closure precondition MUST be verified via tool call before closing. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call (routed) | Problem Class |
|-------|-------------------|-----------|---------------|
| "PR #N is merged" | Verify merge status via platform API | `github_pull_request_read(method="get", pullNumber=N)` → `merged` field *(PR ops — not routed through issue-operations)* | VERIFICATION-GAP |
| "All sub-issues are closed" | Verify each sub-issue state | `issue-operations → read-sub-issues` → check each closed | VERIFICATION-GAP |
| "Issue #N has a merged PR" | Search for PR referencing issue | `github_search_pull_requests(query="fixes #N")` | MISSING-ELEMENT |
| "Platform supports PATCH close" | Probe platform capabilities | `issue-operations → capabilities` | CONFLICTING |

**Evidence artifact:** Merge verification result, sub-issue state check results.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| PR not merged | VERIFICATION-GAP | FAIL | HALT — do not close issue |
| Sub-issues still open | VERIFICATION-GAP | FAIL | Do not close parent |
| No PR references issue | MISSING-ELEMENT | FAIL | HALT — cannot verify implementation |
| Platform lacks PATCH | CONFLICTING | auto-fix | Use closure comment fallback |