# Task: verify-authorization — Step 5d.3: Verify Closed Issue (Main)

## Purpose

Check the main approved issue for prior closure via merged PR. This is NOT a wrapper — it implements new logic that was never in the pre-image.

## Entry Criteria

- Authorization verified (from Step 1)
- Codebase checked (from Step 5d.1)
- No blockers (from Step 5d.2)

## Exit Criteria

- Main issue closure verified
- `reconcile-issue-graph` dispatched for main issue's cross-reference graph

## Procedure

1. Check if the main issue is already closed via `github_issue_read(method=get)`
2. If closed with `state_reason: "completed"`:
   - Search for merged PR referencing the issue via `github_search_pull_requests`
   - Verify PR merge via `github_pull_request_read(method=get)` confirming `merged == true`
   - If merged PR found → mark as `VERIFIED_CLOSED`
   - If no merged PR found → mark as `VERIFICATION_GAP`
3. If open → check for merged PRs referencing the issue (issue may be open but work already done)
4. After verification, dispatch `reconcile-issue-graph` to act on findings for the main issue's cross-reference graph

## Work State I/O

- **Reads from:** `## verify-blockers`
- **Writes to:** `## verify-closed-issue-main`
