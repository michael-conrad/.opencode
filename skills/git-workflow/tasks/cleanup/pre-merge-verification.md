# Task: Pre-Merge Verification

## Purpose

Verify PR is merged before cleanup begins. This is a Tier 1 gate — cleanup must never proceed without confirmed merge evidence. Premature cleanup (branch deletion, issue closure) on an unmerged PR destroys recoverable work and violates the closure-before-merge prohibition in `000-critical-rules.md`.

## Entry Criteria

- PR number identified for cleanup
- Agent is in cleanup path (post-review or check-pr triggered)

## Exit Criteria

- PR merge verified via GitHub API with `merged_at` timestamp
- Ready for branch deletion and issue closure
- If not merged: HALT with clear blocker message

## Procedure

### Step 1: Fetch PR State via GitHub MCP

```python
pr = github_pull_request_read(
    method="get",
    owner=<github.owner>,
    repo=<github.repo>,
    pullNumber=<N>
)
```

Extract the following fields:
- `state` — open, closed
- `merged_at` — timestamp if merged, null if not
- `merged` — boolean (derived: `merged_at is not None`)
- `closed_at` — timestamp when PR was closed

### Step 2: Classify PR State

| State | Merged | Action |
|-------|--------|--------|
| `closed` + `merged_at` not null | ✅ Merged | Proceed to cleanup |
| `closed` + `merged_at` null | ❌ Closed without merge | HALT — PR was rejected |
| `open` | ❌ Not merged | HALT — PR still open |
| `open` + draft | ❌ Not merged | HALT — PR is draft |

### Step 3: HALT if Not Merged

If PR is not merged, HALT and produce blocker message:

```
**Blockers:** PR #N is not merged (state: <state>). Cleanup requires confirmed merge.

🤖 <AgentName> (<ModelId>) ⛔ blocked
```

Do NOT proceed with branch deletion or issue closure.

### Step 4: Verify Merge Target

Confirm the PR merged into the expected base branch (typically `dev`):

```python
base_branch = pr["base"]["ref"]
if base_branch != "dev":
    WARN: "PR merged into '{base_branch}', expected 'dev'"
```

If PR merged into `main` directly (release hotfix), note this for provenance tracking but still proceed.

### Step 5: Record Merge Evidence

Store merge verification for downstream cleanup tasks:

```yaml
pr_merge_verified: true
pr_number: N
merged_at: <timestamp>
base_branch: <branch>
merge_commit_sha: <sha>
```

This evidence is used by `branch-cleanup`, `issue-closure`, and `pair-cleanup` to confirm their operations are safe.

## Verification Commands

```bash
# Verify PR merge state from CLI (supplementary check)
git log --oneline origin/dev | grep "Merge pull request #N"
```

## Edge Cases

### PR State Inconsistency

If GitHub API returns `merged: true` but `merged_at` is null, treat as verification failure. Re-fetch with `github_pull_request_read(method=get)` and retry once. If still inconsistent, HALT and report.

### Network Failure During Verification

If GitHub API call fails, do NOT assume merge status. HALT and report the API failure. Retry once after 5 seconds. If second attempt fails, report:

```
**Blockers:** GitHub API unavailable — cannot verify PR #N merge status.

🤖 <AgentName> (<ModelId>) ⛔ blocked
```

## Verification Principles

### API Response Is the Single Source of Truth

PR merge verification must use the GitHub API response, not local git state. Local branches may have the merge commit but the API is authoritative for whether GitHub processed the merge correctly. The `merged_at` field is the definitive evidence of merge completion.

### No Assumption Without Evidence

If the API call fails or returns ambiguous data, assume the PR is NOT merged. Proceeding with cleanup on an unmerged PR destroys recoverable work and violates the closure-before-merge prohibition. This is a Tier 1 mandate — it never yields to developer convenience.

### Re-Verification Within Session

Once PR merge is verified in the current session, the verification is trusted per `000-critical-rules.md` §Session-Verified State Trust. However, if more than 5 minutes have passed with other agents potentially active, consider re-verifying before proceeding with cleanup.

## Sub-Agent Integration

When `pre-merge-verification` is dispatched as a sub-agent from the cleanup workflow:

- Receive: `pr_number`, `github.owner`, `github.repo`
- Return: `status`, `pr_merge_verified`, `merged_at`, `base_branch`
- Must NOT: Proceed with branch deletion, issue closure, or any cleanup action
- Must NOT: Assume merge status without a tool-call artifact proving API response was checked

## References

- See `cleanup.md` for full workflow
- `000-critical-rules.md` §Closing Issues Before PR Merge
- `000-critical-rules.md` §Content Verification Before Branch Deletion
- `000-critical-rules.md` §Assuming Closed Issues Are Verified